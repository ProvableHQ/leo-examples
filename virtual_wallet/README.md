# Virtual Wallet

## Summary

The `virtual_wallet` example ships **two sibling Leo programs** that
implement the same single-custodian smart-contract wallet on top of
**Ethereum-only primitives** — an ECDSA keypair, an auto-incrementing
nonce, and a block height — without integrating Aleo's native Schnorr /
curve tooling.  The two programs differ only in how the on-chain
verifier identifies the custodian's secp256k1 keypair:

| Program                       | On-chain identity                                           | Verifier                       |
| ----------------------------- | ----------------------------------------------------------- | ------------------------------ |
| `virtual_wallet_eth.aleo`     | 20-byte Ethereum address (`keccak256(pubkey)[12:]`)         | `ECDSA::verify_digest_eth`     |
| `virtual_wallet_pubkey.aleo`  | 33-byte SEC1 compressed public key (`0x02\|0x03 ‖ x_coord`) | `ECDSA::verify_digest`         |

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

The authorization payload is hashed **in-circuit** with Keccak256, and
only the resulting 32-byte digest crosses into the on-chain `final`
scope.  Combined with `transfer_public_to_private`'s recipient and a
per-tx random `salt` being declared as **private** transition inputs,
this keeps both fields out of the public on-chain transaction data.

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
                               │  ─ build TransferAuth + Keccak256    │
                               │    digest entirely in-circuit        │
                               │  ─ verify ECDSA against the digest,  │
                               │    using hardcoded OWNER_*           │
                               │  ─ check block.height < expiry       │
                               │  ─ check & advance next_nonce        │
                               │  ─ call credits.aleo::transfer_*     │
                               └──────────────────┬───────────────────┘
                                                  │ 3. credits debited from
                                                  │    the program's own
                                                  ▼    public balance
                                           recipient
```

### Security properties

| Property             | Mechanism                                                                                                  |
| -------------------- | ---------------------------------------------------------------------------------------------------------- |
| Authorization        | ECDSA (Keccak256) signature, verified against the hardcoded `OWNER_*` constant in each program             |
| Replay protection    | auto-incrementing `next_nonce: u8 => u64` counter — signed `nonce` must equal the current counter value    |
| Expiry               | Signed payload carries a block-height deadline                                                             |
| Cross-call replay    | `selector` byte in the signed payload differs per transition                                                |
| Cross-program replay | selector ranges are disjoint: eth uses 1..=2, pubkey uses 3..=4, so a sig for one program can't be replayed against the other |
| Upgradability        | `@noupgrade` — neither contract can be replaced after deployment                                            |

### Privacy properties

- **`transfer_public`**: all auth fields are inherently public (the
  underlying `credits.aleo::transfer_public` exposes recipient and amount
  on-chain).  The `salt` is still a private input, so an observer cannot
  reproduce the signed digest without it.
- **`transfer_public_to_private`**: `to`, `amount`, and `salt` are all
  **private** transition inputs to this wallet — none of them appears in
  the wallet's own public transition data.  `to` flows straight into
  `credits.aleo::transfer_public_to_private`'s `address.private`
  parameter (so it ends up only in the encrypted output record).
  `amount` is republished by credits.aleo's own finalize (its signature
  is `u64.public`, which is unavoidable for the public-balance debit),
  but it stays out of *this* program's transition input view.  `nonce`
  and `expiry` remain public because the on-chain finalize checks need
  them.
- The `final` scope only ever receives the **digest**, never the
  individual `TransferAuth` fields.  Hashing happens in-circuit.

### Funding model

Each program holds its own pool at its program address.  The custodian
(or their operator) pre-funds whichever program they intend to use by
sending public credits to that address with a direct
`credits.aleo/transfer_public` from any Aleo account.  The deployment
binds the wallet to exactly one secp256k1 keypair via the `OWNER_*`
constant; rotating that key requires a fresh deployment, since the
custodian intentionally does not hold Aleo keys and so cannot run an
admin transition to update an on-chain whitelist.

### Nonce strategy: auto-increment vs. random

The wallet uses a **single auto-incrementing counter** rather than the
"random nonce + `mapping used_nonces: u64 => bool`" pattern.  Each
accepted transition advances `next_nonce[0u8]` by exactly 1, and the
signed `nonce` field must equal the counter's current value at
submission time.

Pros of the auto-increment design:
- **O(1) state** — one mapping entry instead of one per transaction.
- **Safe by default** — the client doesn't need a CSPRNG; just read the
  current counter.
- **No front-running between the custodian's own concurrent txs** — if
  two txs are signed for the same nonce, only one wins; the other is
  rejected on-chain.

Cost: parallel transaction generation is harder.  A custodian that
needs to fan out many concurrent transfers can either serialize their
signing or extend this design with a sub-nonce range; that's left as a
follow-up.

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
    nonce: u64,           //   8 bytes    little-endian — must equal next_nonce[0u8]
    expiry: u32,          //   4 bytes    little-endian
    salt: [u8; 32],       //  32 bytes    private witness — fresh-random per tx
}                         //  85 bytes total
```

The custodian's identity is deliberately **not** part of the signed
payload — each program's verifier checks the signature against its own
hardcoded `OWNER_*` constant, so an attacker cannot supply a signature
from a different keypair.

Byte ordering is little-endian for all multi-byte integers.  Fields are
concatenated in declaration order with no padding.  Hashing happens
**in-circuit** using `Keccak256::hash_to_bits_raw` (raw byte
concatenation, no struct type-tag metadata) and the resulting digest is
verified in `final` with `ECDSA::verify_digest{,_eth}`.

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
→ off-chain sign → relay `transfer_public` (nonce=0, counter advances to
1) → re-submit the same payload and observe the rejection (counter has
moved past nonce=0) → relay `transfer_public_to_private` with nonce=1.

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
- **Sequential signing.**  The auto-incrementing nonce means concurrent
  transfers must be serialized at the signer; parallel fan-out would need
  a sub-nonce range or a different replay scheme.
- **Selector scheme is minimal.**  Four selectors total (1..=4).
  Extending either program with a third transition requires bumping the
  per-program range and documenting the mapping.
