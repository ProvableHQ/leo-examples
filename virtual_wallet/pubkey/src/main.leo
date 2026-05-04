// virtual_wallet_pubkey.aleo — raw-secp256k1-pubkey-flavored variant.
//
// Authorizes transfers via an ECDSA signature checked against a 33-byte
// SEC1-compressed secp256k1 public key (`0x02|0x03 || x_coord`).  Use this
// variant when the custodian's identity is the public key itself rather
// than an Ethereum-style address hash — common in Bitcoin, Cosmos
// secp256k1 chains, ICP, and any ecosystem that doesn't apply the
// keccak-truncate derivation Ethereum uses.
//
// Hashing is done in-circuit with `Keccak256::hash_to_bits_raw` (raw byte
// concatenation, no struct type-tag metadata), and `ECDSA::verify_digest`
// is used in `final` against the precomputed digest.  This keeps the
// witness-only fields (`salt`, plus — for `transfer_public_to_private` —
// the recipient address) out of the on-chain finalize input.
//
// See `virtual_wallet/eth/src/main.leo` for the sibling variant that
// verifies against a 20-byte Ethereum address, and
// `virtual_wallet/README.md` for the overall design.

import credits.aleo;

program virtual_wallet_pubkey.aleo {
    // The 33-byte compressed secp256k1 public key of the sole custodian.
    // Derived from the secp256k1 private key 0x4646…4646 (a well-known
    // test key; see run.sh).  For a real deployment, replace with the
    // production pubkey and redeploy.
    const OWNER_PUBKEY: [u8; 33] = [
        2u8, 75u8, 194u8, 163u8, 18u8, 101u8, 21u8, 63u8, 7u8, 231u8, 14u8,
        11u8, 171u8, 8u8, 114u8, 78u8, 107u8, 133u8, 226u8, 23u8, 248u8,
        205u8, 98u8, 140u8, 235u8, 98u8, 151u8, 66u8, 71u8, 187u8, 73u8,
        51u8, 130u8,
    ];

    // Selector values for this program occupy the range 3..=4.  The sister
    // `virtual_wallet_eth.aleo` uses 1..=2, so a signature produced for one
    // program cannot be replayed against the other even if the same
    // secp256k1 key signs for both.
    const SELECTOR_PUBLIC: u8 = 3u8;
    const SELECTOR_PUBLIC_TO_PRIVATE: u8 = 4u8;

    // Singleton-mapping key for `next_nonce`.
    const NONCE_KEY: u8 = 0u8;

    // Canonical authorization payload signed by the custodian.  Hashed
    // *in-circuit* (via `Keccak256::hash_to_bits_raw`) so that only the
    // resulting 32-byte digest crosses into the on-chain `final` scope —
    // the salt (and, for `transfer_public_to_private`, the recipient) stay
    // in witness data.
    struct TransferAuth {
        selector: u8,         //   1 byte
        to_bytes: [u8; 32],   //  32 bytes
        amount: u64,          //   8 bytes (little-endian)
        nonce: u64,           //   8 bytes (little-endian)
        expiry: u32,          //   4 bytes (little-endian)
        salt: [u8; 32],       //  32 bytes
    }                         //  85 bytes total

    // Auto-incrementing nonce counter.  A single u64 keyed by `NONCE_KEY`,
    // starting at 0u64.  Each accepted transition advances it by exactly 1,
    // so the signed `nonce` field doubles as a sequence number — replay
    // protection is implicit (a replayed payload's nonce no longer matches
    // the on-chain counter) and the wallet's storage footprint is O(1)
    // rather than O(transactions).
    mapping next_nonce: u8 => u64;

    @noupgrade
    constructor() {}

    fn transfer_public(
        public sig: [u8; 65],
        public to: address,
        public amount: u64,
        public nonce: u64,
        public expiry: u32,
        private salt: [u8; 32],
    ) -> Final {
        let digest: [u8; 32] = auth_digest(
            SELECTOR_PUBLIC, to, amount, nonce, expiry, salt,
        );
        let f: Final = credits.aleo::transfer_public(to, amount);
        return final {
            // Cheap checks first so a rejected nonce/expiry doesn't pay
            // for the secp256k1 verify on the failure path.
            assert(block.height < expiry);
            let cur: u64 = next_nonce.get_or_use(NONCE_KEY, 0u64);
            assert_eq(nonce, cur);
            assert(ECDSA::verify_digest(sig, OWNER_PUBKEY, digest));
            next_nonce.set(NONCE_KEY, cur + 1u64);
            f.run();
        };
    }

    fn transfer_public_to_private(
        public sig: [u8; 65],
        // `to` and `amount` are *private* here — they're the values we
        // most want to keep out of this wallet's public transition input.
        // `credits.aleo::transfer_public_to_private` itself takes
        // `address.private, u64.public`, so the recipient flows straight
        // through into the encrypted output record while the amount is
        // (necessarily) republished by credits.aleo's own finalize.
        private to: address,
        private amount: u64,
        public nonce: u64,
        public expiry: u32,
        private salt: [u8; 32],
    ) -> (credits.aleo::credits, Final) {
        let digest: [u8; 32] = auth_digest(
            SELECTOR_PUBLIC_TO_PRIVATE, to, amount, nonce, expiry, salt,
        );
        let (cred, f): (credits.aleo::credits, Final) =
            credits.aleo::transfer_public_to_private(to, amount);
        return (cred, final {
            assert(block.height < expiry);
            let cur: u64 = next_nonce.get_or_use(NONCE_KEY, 0u64);
            assert_eq(nonce, cur);
            assert(ECDSA::verify_digest(sig, OWNER_PUBKEY, digest));
            next_nonce.set(NONCE_KEY, cur + 1u64);
            f.run();
        });
    }
}

// Build the canonical TransferAuth payload and hash it with Keccak256
// using `*_raw` so the digest is over the plain 85-byte concatenation —
// matching what the off-chain signer hashes (see `signer/sign.js`).
fn auth_digest(
    selector: u8,
    to: address,
    amount: u64,
    nonce: u64,
    expiry: u32,
    salt: [u8; 32],
) -> [u8; 32] {
    let auth: TransferAuth = TransferAuth {
        selector: selector,
        to_bytes: address_to_bytes(to),
        amount: amount,
        nonce: nonce,
        expiry: expiry,
        salt: salt,
    };
    let digest_bits: [bool; 256] = Keccak256::hash_to_bits_raw(auth);
    return Deserialize::from_bits_raw::[[u8; 32]](digest_bits);
}

// Encode an Aleo address as its 32-byte x-coordinate representation.
// Used inside `auth_digest`; the off-chain signer reproduces this byte
// layout via the Aleo SDK's `Address.toBytesLe()`.
fn address_to_bytes(addr: address) -> [u8; 32] {
    let x: field = addr as field;
    let bits: [bool; 253] = Serialize::to_bits_raw(x);
    let padded: [bool; 256] = [false; 256];
    for i: u16 in 0u16..253u16 {
        padded[i] = bits[i];
    }
    return Deserialize::from_bits_raw::[[u8; 32]](padded);
}
