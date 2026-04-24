// virtual_wallet.aleo — an Ethereum-style smart-contract wallet on Aleo.
//
// Custodians authorize transfers off-chain with an ECDSA signature over a
// Keccak256 digest (the same primitive an Ethereum-only wallet already has).
// Any relayer can submit the signed payload on-chain: the relayer pays the
// network fee, but the credits being moved are drawn from the wallet
// contract's own public balance.
//
// Pre-funding: the contract's program address is the source of funds.  A
// custodian (or their operator) first sends credits to `virtual_wallet.aleo`
// via `credits.aleo/transfer_public`; those credits sit at the program
// address and can only be spent through the two transitions below.
//
// Replay protection: (owner_eth, nonce) is tracked in `used_nonces`; a nonce
// may only be consumed once per custodian.  The `selector` field in the
// signed payload prevents a signature authorizing `transfer_public` from
// being replayed as `transfer_public_to_private` (or vice versa).
//
// Expiry: the signed payload includes a block height after which the
// authorization is no longer valid.  This bounds how long a leaked payload
// is useful without requiring the custodian to be online to revoke it.

import credits.aleo;

program virtual_wallet.aleo {
    // Selector values distinguish the two transitions in the signed payload
    // so one signature cannot be replayed against the other transition.
    const SELECTOR_PUBLIC: u8 = 1u8;
    const SELECTOR_PUBLIC_TO_PRIVATE: u8 = 2u8;

    // The authorization payload that the custodian signs off-chain.  Its
    // bit layout must total a multiple of 8 bits so the ECDSA verifier
    // accepts it.  All fields are byte-aligned primitive types.
    //
    // The recipient Aleo address is committed as `to_bytes`, the 32-byte
    // encoding of the address's x-coordinate field (little-endian, with
    // the top 3 bits zero-padded so every address fits in 256 bits).
    //
    // See `signer/sign.js` for the exact byte layout the off-chain signer
    // must reproduce.
    struct TransferAuth {
        selector: u8,         //   1 byte
        owner_eth: [u8; 20],  //  20 bytes
        to_bytes: [u8; 32],   //  32 bytes
        amount: u64,          //   8 bytes (little-endian)
        nonce: u64,           //   8 bytes (little-endian)
        expiry: u32,          //   4 bytes (little-endian)
    }                         //  73 bytes = 584 bits

    // Per-custodian nonce key.  Two custodians with different Ethereum
    // addresses can use the same nonce without conflict.
    struct NonceKey {
        owner_eth: [u8; 20],
        nonce: u64,
    }

    mapping used_nonces: NonceKey => bool;

    @noupgrade
    constructor() {}

    // Transfer credits from this program's public balance to `to`, on behalf
    // of the custodian identified by `owner_eth`.
    //
    // Any account may submit this transition; the ECDSA signature is what
    // authorizes the transfer, not `self.caller`.  credits.aleo debits the
    // caller of `transfer_public`, which here is virtual_wallet.aleo itself.
    fn transfer_public(
        public owner_eth: [u8; 20],
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
                owner_eth: owner_eth,
                to_bytes: address_to_bytes(to),
                amount: amount,
                nonce: nonce,
                expiry: expiry,
            };
            assert(ECDSA::verify_keccak256_eth(sig, owner_eth, auth));
            assert(block.height < expiry);
            let key: NonceKey = NonceKey {
                owner_eth: owner_eth,
                nonce: nonce,
            };
            assert(!used_nonces.contains(key));
            used_nonces.set(key, true);
            f.run();
        };
    }

    // Transfer credits from this program's public balance to `to`, emitting
    // a private `credits` record owned by `to`.  Same authorization model as
    // `transfer_public`.
    fn transfer_public_to_private(
        public owner_eth: [u8; 20],
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
                owner_eth: owner_eth,
                to_bytes: address_to_bytes(to),
                amount: amount,
                nonce: nonce,
                expiry: expiry,
            };
            assert(ECDSA::verify_keccak256_eth(sig, owner_eth, auth));
            assert(block.height < expiry);
            let key: NonceKey = NonceKey {
                owner_eth: owner_eth,
                nonce: nonce,
            };
            assert(!used_nonces.contains(key));
            used_nonces.set(key, true);
            f.run();
        });
    }
}

// Encode an Aleo address as its 32-byte x-coordinate representation.
// Called from the `final` blocks of the transitions above; the off-chain
// signer re-implements this byte layout (see `signer/sign.js`).
fn address_to_bytes(addr: address) -> [u8; 32] {
    let x: field = addr as field;
    let bits: [bool; 253] = Serialize::to_bits_raw(x);
    let padded: [bool; 256] = [false; 256];
    for i: u16 in 0u16..253u16 {
        padded[i] = bits[i];
    }
    return Deserialize::from_bits_raw::[[u8; 32]](padded);
}
