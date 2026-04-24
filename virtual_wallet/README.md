# Virtual Wallet

## Summary

`virtual_wallet.aleo` is a smart-contract wallet that custodians can drive
with **Ethereum-only primitives** — an ECDSA keypair, a nonce, and a block
height — without integrating Aleo's native Schnorr / curve tooling.

The program exposes exactly two transitions:

| Transition                      | Wraps                                       |
| ------------------------------- | ------------------------------------------- |
| `transfer_public`               | `credits.aleo::transfer_public`              |
| `transfer_public_to_private`    | `credits.aleo::transfer_public_to_private`   |

Each transition requires an off-chain ECDSA signature over a canonical
authorization payload.  Any relayer may submit the signed payload; the
contract debits its own public balance.

## How it works

```
┌─────────────┐   1. sign(TransferAuth)    ┌──────────────┐
│  Custodian  │ ─────────────────────────▶ │   Relayer    │
│  (eth key)  │                            │  (any aleo   │
└─────────────┘                            │   account)   │
                                            └──────┬───────┘
                                                   │ 2. execute
                                                   ▼
                               ┌──────────────────────────────────────┐
                               │    virtual_wallet.aleo               │
                               │  ─ verify ECDSA signature            │
                               │  ─ check block.height < expiry       │
                               │  ─ check & consume nonce             │
                               │  ─ call credits.aleo::transfer_*     │
                               └──────────────────┬───────────────────┘
                                                  │ 3. credits debited from
                                                  │    virtual_wallet.aleo's
                                                  ▼    own public balance
                                           recipient
```

### Security properties

| Property         | Mechanism                                                             |
| ---------------- | --------------------------------------------------------------------- |
| Authorization    | ECDSA (Keccak256) signature by custodian's Ethereum private key        |
| Replay protection | `(owner_eth, nonce)` tracked in `used_nonces` mapping                 |
| Expiry           | Signed payload carries a block-height deadline                         |
| Cross-call replay | `selector` field in the signed payload differs per transition          |
| Upgradability    | `@noupgrade` — the contract cannot be replaced after deployment        |

### Funding model

The wallet's credits live at `virtual_wallet.aleo`'s own program address.
Custodians (or their operator) pre-fund the contract by sending public
credits to that address with a direct `credits.aleo/transfer_public` from
any Aleo account.  There is no per-custodian sub-accounting on-chain; if
multiple custodians share one deployment, account segregation is an
off-chain concern.

## The authorization payload

The custodian signs Keccak256 of the serialized `TransferAuth` struct:

```
struct TransferAuth {
    selector: u8,         //   1 byte     1 = transfer_public
                          //              2 = transfer_public_to_private
    owner_eth: [u8; 20],  //  20 bytes    the custodian's 20-byte eth address
    to_bytes: [u8; 32],   //  32 bytes    the recipient (see below)
    amount: u64,          //   8 bytes    little-endian
    nonce: u64,           //   8 bytes    little-endian
    expiry: u32,          //   4 bytes    little-endian
}                         //  73 bytes total
```

Byte ordering is little-endian for all multi-byte integers.  Fields are
concatenated in declaration order with no padding.  The verifier is
`ECDSA::verify_keccak256_eth`, which applies no Ethereum-signed-message
prefix — the signer must hash the raw 73 bytes directly.

### `to_bytes` encoding

`to_bytes` is the **32-byte little-endian encoding of the recipient Aleo
address's x-coordinate field element**.  On-chain, `virtual_wallet.aleo`
computes it as:

```leo
let x: field = to as field;                        // x-coord of the group
let bits: [bool; 253] = Serialize::to_bits_raw(x); // LE, bit 0 = LSB
let padded: [bool; 256] = [false; 256];
for i in 0u16..253u16 { padded[i] = bits[i]; }     // top 3 bits zero-pad
let to_bytes: [u8; 32] = Deserialize::from_bits_raw::[[u8; 32]](padded);
```

Off-chain, the same bytes are produced by: parsing the Aleo address,
extracting the x-coordinate field value as a 253-bit integer, and
encoding it as 32 little-endian bytes.  `signer/sign.js` does this using
the Aleo SDK.

## How to build

```bash
cd virtual_wallet
leo build
```

The build emits `build/main.aleo` with two finalize blocks that invoke
`credits.aleo/transfer_public` and `credits.aleo/transfer_public_to_private`
respectively.

## How to run the demo

`run.sh` deploys the wallet, pre-funds it, signs a transfer off-chain, and
has a relayer submit it on-chain.

Prerequisites:

- `leo devnode` running in another terminal:
  `leo devnode start --private-key APrivateKey1zkp8CZNn3yeCseEtxuVPbDCwSyhGW6yZKUYKfgXmcpoGPWH`
- Node.js 20+ and `npm install` run inside `signer/`.

```bash
bash run.sh
```

The script walks through: deploy → pre-fund → off-chain sign → relay
`transfer_public` → re-submit same payload and observe the nonce replay
failure.

## Project structure

```
virtual_wallet/
├── program.json           # depends on credits.aleo (network)
├── src/main.leo           # virtual_wallet.aleo
├── signer/
│   ├── sign.js            # off-chain ECDSA signer (ethers + @provablehq/sdk)
│   └── package.json
├── run.sh
└── README.md
```

## Limitations & follow-ups

- **Shared-pool funds.**  All custodians share the wallet's balance.  A
  future iteration can add a `deposit` entry point and a `balances:
  [u8;20] => u64` mapping so each custodian has its own sub-balance.
- **No private-input custody.**  Only public credits can be spent; a
  production custodian would also want ECDSA-gated withdrawals from
  private records.
- **Selector scheme is minimal.**  Two selectors (1, 2).  Extending the
  contract with a third transition requires bumping the selector set and
  documenting the mapping.
