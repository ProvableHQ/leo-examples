# Quadratic Vote

## Summary

`quadratic_vote` is a governance example that demonstrates Leo **library packages**.

Two reusable libraries handle all the math:

| Package | Kind | What it provides |
|---------|------|-----------------|
| `sqrt_math` | library | `isqrt` — integer square root via Newton's method |
| `vote_math` | library | QV weights, credit costs, voter profiles (depends on `sqrt_math`) |
| `governance.aleo` | program | Private vote records, proposal outcome checks |

Under **Quadratic Voting (QV)**, a participant's vote weight equals ⌊√(token\_balance)⌋ and
casting *k* votes costs *k²* credits.  This makes influence grow with the square root of
wealth rather than linearly — fairer to smaller holders.

| Token balance | Vote weight |
|---------------|-------------|
| 1             | 1           |
| 100           | 10          |
| 225           | 15          |
| 1 000         | 31          |
| 10 000        | 100 (cap)   |

This example is inspired by the [Quadratic Voting](https://en.wikipedia.org/wiki/Quadratic_voting)
mechanism used in decentralised governance systems such as Gitcoin Grants.

## Noteworthy Features

**Library packages** — `sqrt_math` and `vote_math` are pure libraries: they have no
`.aleo` program name, are never deployed on their own, and only take effect when included
by a program package.

**Library submodules** — each extra `.leo` file under `src/` becomes a named module.  No
declaration is needed; the filename is the module name.  Items are accessed as
`lib_name::module_name::item`.

**Cross-submodule calls within a library** — `vote_math::cost::build_profile` calls
`vote_math::weight::compute` internally; `sqrt_math::checks::is_perfect_square` calls
`sqrt_math::newton::isqrt`.

**Cross-library submodule calls** — `vote_math::weight::compute` reaches directly into
`sqrt_math::newton::isqrt`, demonstrating the full dependency chain
(`governance → vote_math::cost → vote_math::weight → sqrt_math::newton`).

**Top-level library constants** — `vote_math::MAX_WEIGHT`, `vote_math::MIN_BALANCE`, and
`sqrt_math::ISQRT_MAX` are defined in each library's `lib.leo` and referenced by name from
within submodules.

**Library struct export** — `vote_math::cost::VoterProfile` is defined in a submodule (field:
`weight: u32`) and used directly as a variable type inside `governance.aleo`.

**Private vote receipt** — the `Vote` record is private; the token balance that drove the
weight computation is never revealed on-chain.

## How to Build

### Option A — clone this repo and build in place

```bash
cd quadratic_vote

cd sqrt_math  && leo build && cd ..
cd vote_math  && leo build && cd ..
cd governance && leo build && cd ..
```

### Option B — create from scratch with the Leo CLI

```bash
# Create the two libraries and the program.
leo new --library sqrt_math
leo new --library vote_math
leo new governance

# Wire up dependencies.
cd vote_math  && leo add sqrt_math --local ../sqrt_math && cd ..
cd governance && leo add sqrt_math --local ../sqrt_math && cd ..
cd governance && leo add vote_math  --local ../vote_math  && cd ..

# Copy source files, then build.
cd sqrt_math  && leo build && cd ..
cd vote_math  && leo build && cd ..
cd governance && leo build && cd ..
```

`leo new --library` creates a library package — `program.json` has no `.aleo` suffix and the
source lives in `src/lib.leo` instead of `src/main.leo`.  `leo add --local` records the
dependency in `program.json` and lets the compiler resolve cross-package symbols.

## How to Run

All `leo run` commands are issued from inside the `governance/` directory.

### Cast a vote

A participant's token balance is kept private.  The program derives their QV weight and
returns a private `Vote` receipt.

```
leo run cast_vote <proposal_id: field> <token_balance: u32> <approve: bool>
```

**Alice (1 000 tokens, approval):**
```bash
leo run cast_vote 1field 1000u32 true
```

Output:
```
{
  owner: aleo1...private,
  proposal_id: 1field.private,
  weight: 31u32.private,
  approve: true.private,
  _nonce: ...group.public,
  _version: 1u8.public
}
```

**Bob (225 tokens, rejection):**
```bash
leo run cast_vote 1field 225u32 false
```

**Carol (10 000 tokens — hits the `MAX_WEIGHT` cap of 100):**
```bash
leo run cast_vote 1field 10000u32 true
```

### Query the credit cost of casting votes

```
leo run qv_cost <votes: u32>
```

How much does it cost to cast 5 votes?

```bash
leo run qv_cost 5u32
# Output: 25u32  (= 5²)
```

### Check whether a number is a perfect square

```
leo run has_perfect_sqrt <token_balance: u32>
```

This function bypasses `vote_math` entirely and calls `sqrt_math::checks::is_perfect_square`
directly, illustrating that a program can reach any library submodule independently.

```bash
leo run has_perfect_sqrt 1024u32   # 1024 = 32²  → true
leo run has_perfect_sqrt 1000u32   # 31² = 961, 32² = 1024  → false
```

### Check whether a proposal is passing

```
leo run is_passing <approvals: u32> <rejections: u32>
```

After tallying Alice (31) + Carol (100) = 131 approvals vs Bob's 15 rejections:

```bash
leo run is_passing 131u32 15u32
# Output: true
```

## Run the unit tests

From inside `governance/`:

```bash
leo test
```

18 tests covering `cast_vote`, `qv_cost`, `has_perfect_sqrt`, and `is_passing`.

## Run the full demo

```bash
bash run.sh
```

## Project structure

Each library is split into **submodules** — separate `.leo` files under `src/` that are
automatically discovered by the compiler.  No explicit `module` keyword is needed; the
filename becomes the module name.

```
quadratic_vote/
├── sqrt_math/                   # Library: integer square root
│   ├── program.json             #   "program": "sqrt_math"  (no .aleo suffix)
│   └── src/
│       ├── lib.leo              #   const ISQRT_MAX
│       ├── newton.leo           #   fn isqrt(n) — Newton's method              [module: newton]
│       └── checks.leo          #   fn is_perfect_square(n)                    [module: checks]
│
├── vote_math/                   # Library: QV weight & cost formulas
│   ├── program.json             #   depends on sqrt_math
│   └── src/
│       ├── lib.leo              #   const MAX_WEIGHT, MIN_BALANCE
│       ├── weight.leo           #   fn compute(balance), fn is_eligible(balance) [module: weight]
│       └── cost.leo             #   struct VoterProfile { weight },            [module: cost]
│                                #   fn credits_for_votes, fn build_profile(balance)
│
├── governance/                  # Program: private vote receipts
│   ├── program.json             #   depends on sqrt_math + vote_math
│   ├── inputs/governance.in
│   ├── src/main.leo             #   record Vote
│   │                            #   fn cast_vote       — uses vote_math::weight + vote_math::cost
│   │                            #   fn qv_cost         — uses vote_math::cost
│   │                            #   fn has_perfect_sqrt — uses sqrt_math::checks directly
│   │                            #   fn is_passing
│   └── tests/
│       └── test_governance.leo  #   @test fns covering cast_vote, qv_cost, has_perfect_sqrt,
│                                #   is_passing (18 test cases)
│
├── run.sh
└── README.md
```

### Call graph

```
governance.aleo
├── vote_math::weight::is_eligible(token_balance)
│     └── vote_math::MIN_BALANCE                  (top-level lib constant)
├── vote_math::cost::build_profile(token_balance)
│     └── vote_math::weight::compute(balance)     (cross-submodule call within vote_math)
│           ├── sqrt_math::newton::isqrt(n)       (cross-library submodule call)
│           │     └── sqrt_math::ISQRT_MAX         (top-level lib constant, safety assert)
│           └── vote_math::MAX_WEIGHT              (top-level lib constant)
├── vote_math::cost::credits_for_votes(votes)
└── sqrt_math::checks::is_perfect_square(n)       (direct cross-library submodule call)
      └── sqrt_math::newton::isqrt(n)              (cross-submodule call within sqrt_math)
            └── sqrt_math::ISQRT_MAX               (top-level lib constant, safety assert)
```
