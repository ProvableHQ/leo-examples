# Virtual Wallet

## Summary

The `virtual_wallet` example ships **two sibling Leo programs** that
implement the same single-custodian smart-contract wallet on top of
**Ethereum-only primitives** — an ECDSA keypair, a nonce, and a block
height — without integrating Aleo's native Schnorr / curve tooling.  The
two programs differ only in how the on-chain verifier identifies the
custodian's secp256k1 keypair:

| Program                       | On-chain identity                                           | Verifier                       |
| ----------------------------- | ----------------------------------------------------------- | ------------------------------ |
| `virtual_wallet_eth.aleo`     | 20-byte Ethereum address (`keccak256(pubkey)[12:]`)         | `ECDSA::verify_keccak256_eth`     |
| `virtual_wallet_pubkey.aleo`  | 33-byte SEC1 compressed public key (`0x02\|0x03 ‖ x_coord`) | `ECDSA::verify_keccak256_raw`     |

Pick whichever variant matches the custodian's existing tooling:

- **`eth`** for custodians whose identity is already an Ethereum address
  (MetaMask, an EOA on an L2, ledgers configured for ETH).
- **`pubkey`** for custodians whose identity is a raw secp256k1 public
  key (Bitcoin, Cosmos secp256k1 chains, ICP, etc.).

Each program exposes exactly two transitions:

| Transition                      | Wraps                                       |
| ------------------------------- | ------------------------------------------- |
| `transfer_public`               | `credits.aleo::transfer_public`              |
| `transfer_public_to_private`    | `credits.aleo::transfer_public_to_private`   |

Each transition requires an off-chain ECDSA signature over a canonical
authorization payload.  The custodian's identity is **hardcoded in the
program** as `OWNER_ETH_ADDR` (eth variant) or `OWNER_PUBKEY` (pubkey
variant), so only that one secp256k1 keypair can authorize transfers — an
attacker cannot submit a signature from a different keypair.  Any relayer
may submit the signed payload; the contract debits its own public balance.

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
                               │  virtual_wallet_{eth|pubkey}.aleo    │
                               │  ─ verify ECDSA signature against    │
                               │    hardcoded OWNER_*                 │
                               │  ─ check block.height < expiry       │
                               │  ─ check & consume nonce             │
                               │  ─ call credits.aleo::transfer_*     │
                               └──────────────────┬───────────────────┘
                                                  │ 3. credits debited from
                                                  │    the program's own
                                                  ▼    public balance
                                           recipient
```

### Security properties

| Property          | Mechanism                                                                                       |
| ----------------- | ----------------------------------------------------------------------------------------------- |
| Authorization     | ECDSA (Keccak256) signature, verified against the hardcoded `OWNER_*` constant in each program  |
| Replay protection | each `nonce` tracked in `used_nonces: u64 => bool`                                              |
| Expiry            | Signed payload carries a block-height deadline                                                  |
| Cross-call replay | `selector` field in the signed payload differs per transition                                   |
| Cross-program replay | selector ranges are disjoint: eth uses 1..=2, pubkey uses 3..=4, so a sig for one program can't be replayed against the other |
| Upgradability     | `@noupgrade` — neither contract can be replaced after deployment                                |

### Funding model

Each program holds its own pool at its program address.  The custodian
(or their operator) pre-funds whichever program they intend to use by
sending public credits to that address with a direct
`credits.aleo/transfer_public` from any Aleo account.  The deployment
binds the wallet to exactly one secp256k1 keypair via the `OWNER_*`
constant; rotating that key requires a fresh deployment, since the
custodian intentionally does not hold Aleo keys and so cannot run an
admin transition to update an on-chain whitelist.

## The authorization payload

The custodian signs Keccak256 of the serialized `TransferAuth` struct
(layout is identical between the two programs):

```
struct TransferAuth {
    selector: u8,         //   1 byte     1 = eth/transfer_public
                          //              2 = eth/transfer_public_to_private
                          //              3 = pubkey/transfer_public
                          //              4 = pubkey/transfer_public_to_private
    to_bytes: [u8; 32],   //  32 bytes    the recipient (see below)
    amount: u64,          //   8 bytes    little-endian
    nonce: u64,           //   8 bytes    little-endian
    expiry: u32,          //   4 bytes    little-endian
}                         //  53 bytes total
```

The custodian's identity is deliberately **not** part of the signed
payload — each program's verifier checks the signature against its own
hardcoded `OWNER_*` constant, so an attacker cannot supply a signature
from a different keypair.

Byte ordering is little-endian for all multi-byte integers.  Fields are
concatenated in declaration order with no padding.  Both programs use
`*_eth` / `*_raw` ECDSA variants so the on-chain verifier hashes the raw
byte concatenation of the struct fields (no type-tag metadata, no
Ethereum-signed-message prefix); the off-chain signer must hash the raw
53 bytes directly.

### `to_bytes` encoding

`to_bytes` is the **32-byte little-endian encoding of the recipient Aleo
address's x-coordinate field element**.  Both programs compute it
identically:

```leo
let x: field = to as field;                        // x-coord of the group
let bits: [bool; 253] = Serialize::to_bits_raw(x); // LE, bit 0 = LSB
let padded: [bool; 256] = [false; 256];
for i in 0u16..253u16 { padded[i] = bits[i]; }     // top 3 bits zero-pad
let to_bytes: [u8; 32] = Deserialize::from_bits_raw::[[u8; 32]](padded);
```

Off-chain, `signer/sign.js` produces the same bytes via the Aleo SDK's
`Address.toBytesLe()`.

## How to build

```bash
cd virtual_wallet/eth     && leo build
cd virtual_wallet/pubkey  && leo build
```

Each build emits its own `build/main.aleo` with two finalize blocks that
invoke `credits.aleo/transfer_public` and
`credits.aleo/transfer_public_to_private` respectively.

## How to run the demo

`run.sh` deploys both programs, pre-funds them, signs transfers off-chain
in each variant, and has a relayer submit them on-chain.

Prerequisites:

- `leo devnode` running in another terminal:
  `leo devnode start --private-key APrivateKey1zkp8CZNn3yeCseEtxuVPbDCwSyhGW6yZKUYKfgXmcpoGPWH`
- Node.js 20+ and `npm install` run inside `signer/`.

```bash
bash run.sh
```

The script walks through both variants, in each case: deploy → pre-fund
→ off-chain sign → relay `transfer_public` → re-submit same payload and
observe the nonce replay failure → relay `transfer_public_to_private`
with a fresh nonce.

## Project structure

```
virtual_wallet/
├── README.md
├── run.sh                       # demos both variants end-to-end
├── signer/
│   ├── sign.js                  # off-chain ECDSA signer (mode: eth|pubkey)
│   └── package.json
├── eth/
│   ├── program.json             # virtual_wallet_eth.aleo
│   ├── src/main.leo
│   └── build/
└── pubkey/
    ├── program.json             # virtual_wallet_pubkey.aleo
    ├── src/main.leo
    └── build/
```

## Limitations & follow-ups

- **Single custodian, no rotation.**  `OWNER_ETH_ADDR` / `OWNER_PUBKEY` is
  hardcoded, so rotating the custodian's secp256k1 key requires a fresh
  deployment.  This is a deliberate trade-off for the "no Aleo keys"
  constraint; a multi-custodian or rotatable design would need an admin
  transition (and therefore an Aleo-keyed admin role).
- **No private-input custody.**  Only public credits can be spent; a
  production custodian would also want ECDSA-gated withdrawals from
  private records.
- **Selector scheme is minimal.**  Four selectors total (1..=4).
  Extending either program with a third transition requires bumping the
  per-program range and documenting the mapping.
