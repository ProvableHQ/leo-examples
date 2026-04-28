// virtual_wallet_pubkey.aleo — raw-secp256k1-pubkey-flavored variant.
//
// Authorizes transfers via an ECDSA signature checked against a 33-byte
// SEC1-compressed secp256k1 public key (`0x02|0x03 || x_coord`).  Use this
// variant when the custodian's identity is the public key itself rather
// than an Ethereum-style address hash — common in Bitcoin, Cosmos
// secp256k1 chains, ICP, and any ecosystem that doesn't apply the
// keccak-truncate derivation Ethereum uses.
//
// We use `ECDSA::verify_keccak256_raw` (not the bare `verify_keccak256`)
// so that the on-chain message digest is computed over the raw byte
// concatenation of the `TransferAuth` fields — matching what the
// off-chain signer produces.  The bare `verify_keccak256` would hash
// `to_bits_le()`, which prepends type metadata for non-trivial types and
// would not match a plain Keccak256(msg_bytes) computed off-chain.
//
// See `virtual_wallet/eth/src/main.leo` for the sibling variant that
// verifies against a 20-byte Ethereum address.
//
// See `virtual_wallet/README.md` for the overall design (single-custodian,
// pre-funded program-address pool, replay/expiry/cross-call protections).

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

    struct TransferAuth {
        selector: u8,         //   1 byte
        to_bytes: [u8; 32],   //  32 bytes
        amount: u64,          //   8 bytes (little-endian)
        nonce: u64,           //   8 bytes (little-endian)
        expiry: u32,          //   4 bytes (little-endian)
    }                         //  53 bytes = 424 bits

    mapping used_nonces: u64 => bool;

    @noupgrade
    constructor() {}

    fn transfer_public(
        public sig: [u8; 65],
        public to: address,
        public amount: u64,
        public nonce: u64,
        public expiry: u32,
    ) -> Final {
        let f: Final = credits.aleo::transfer_public(to, amount);
        return final {
            let auth: TransferAuth = TransferAuth {
                selector: SELECTOR_PUBLIC,
                to_bytes: address_to_bytes(to),
                amount: amount,
                nonce: nonce,
                expiry: expiry,
            };
            assert(ECDSA::verify_keccak256_raw(sig, OWNER_PUBKEY, auth));
            assert(block.height < expiry);
            assert(!used_nonces.contains(nonce));
            used_nonces.set(nonce, true);
            f.run();
        };
    }

    fn transfer_public_to_private(
        public sig: [u8; 65],
        public to: address,
        public amount: u64,
        public nonce: u64,
        public expiry: u32,
    ) -> (credits.aleo::credits, Final) {
        let (cred, f): (credits.aleo::credits, Final) =
            credits.aleo::transfer_public_to_private(to, amount);
        return (cred, final {
            let auth: TransferAuth = TransferAuth {
                selector: SELECTOR_PUBLIC_TO_PRIVATE,
                to_bytes: address_to_bytes(to),
                amount: amount,
                nonce: nonce,
                expiry: expiry,
            };
            assert(ECDSA::verify_keccak256_raw(sig, OWNER_PUBKEY, auth));
            assert(block.height < expiry);
            assert(!used_nonces.contains(nonce));
            used_nonces.set(nonce, true);
            f.run();
        });
    }
}

// Encode an Aleo address as its 32-byte x-coordinate representation.
// Called from the `final` blocks above; the off-chain signer re-implements
// this byte layout (see `virtual_wallet/signer/sign.js`).
fn address_to_bytes(addr: address) -> [u8; 32] {
    let x: field = addr as field;
    let bits: [bool; 253] = Serialize::to_bits_raw(x);
    let padded: [bool; 256] = [false; 256];
    for i: u16 in 0u16..253u16 {
        padded[i] = bits[i];
    }
    return Deserialize::from_bits_raw::[[u8; 32]](padded);
}
