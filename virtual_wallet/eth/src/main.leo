// virtual_wallet_eth.aleo — Ethereum-address-flavored variant.
//
// Authorizes transfers via an ECDSA signature checked against a 20-byte
// Ethereum address (`keccak256(uncompressed_pubkey[1:])[12:]`).  Use this
// variant when the custodian's identity is already an Ethereum address
// (MetaMask, ledgers configured for ETH, an EOA on an L2, etc.).
//
// See `virtual_wallet/pubkey/src/main.leo` for the sibling variant that
// verifies against a raw 33-byte compressed secp256k1 public key.
//
// See `virtual_wallet/README.md` for the overall design (single-custodian,
// pre-funded program-address pool, replay/expiry/cross-call protections).

import credits.aleo;

program virtual_wallet_eth.aleo {
    // The 20-byte Ethereum address of the sole custodian.  Derived from the
    // secp256k1 private key 0x4646…4646 (a well-known test key; see
    // run.sh).  For a real deployment, replace with the production eth
    // address and redeploy.
    const OWNER_ETH_ADDR: [u8; 20] = [
        157u8, 138u8, 98u8, 246u8, 86u8, 168u8, 209u8, 97u8, 92u8, 18u8,
        148u8, 253u8, 113u8, 233u8, 207u8, 179u8, 228u8, 133u8, 90u8, 79u8,
    ];

    // Selector values for this program occupy the range 1..=2.  The sister
    // `virtual_wallet_pubkey.aleo` uses 3..=4, so a signature produced for
    // one program cannot be replayed against the other even if the same
    // secp256k1 key signs for both.
    const SELECTOR_PUBLIC: u8 = 1u8;
    const SELECTOR_PUBLIC_TO_PRIVATE: u8 = 2u8;

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
            assert(ECDSA::verify_keccak256_eth(sig, OWNER_ETH_ADDR, auth));
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
            assert(ECDSA::verify_keccak256_eth(sig, OWNER_ETH_ADDR, auth));
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
