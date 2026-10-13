# Quadratic voting math with Leo libraries

Build two Leo libraries and use their functions in a program that creates vote records.

## Build and run

Use Leo 4.4.5 and Bash. Check the installed compiler with `leo --version`. The commands below run locally with testnet settings. They need no network node, funded account, or token program.

From the repository root, run:

```bash
leo build --path quadratic_vote/sqrt_math --network testnet
leo build --path quadratic_vote/vote_math --network testnet
leo build --path quadratic_vote/governance --network testnet
bash quadratic_vote/run.sh
```

The demo shows weights of `31`, `15`, and `100`, a cost of `25u32`, a passing result of `true`, and two integer-square checks. It also runs the tests. You can run the script from any directory. To select a compiler outside `PATH`, set `LEO` to its executable path.

`leo run` evaluates the program locally. It does not generate an execution proof or send a transaction to the network. The demo uses the same signer for all three balance scenarios. If you do not configure a private key, Leo uses its built-in test key.

## What the example demonstrates

| Package | Type | Exported items |
| --- | --- | --- |
| `sqrt_math` | Library | Integer square roots and integer-square checks |
| `vote_math` | Library | Capped weights, quadratic costs, and a `VoterProfile` struct |
| `governance.aleo` | Program | Vote records and functions that use the libraries |

A library package has no `.aleo` suffix in its manifest name. Its root source file is `src/lib.leo`. The library code is included in the program at compile time. You do not deploy the libraries as separate programs.

Each additional `.leo` file under `src/` defines a submodule with the same name as the file. For example, `sqrt_math/src/newton.leo` defines the `sqrt_math::newton` module. You do not need a module declaration.

Use `export` on a function, constant, or struct that another module or package needs. For example, `export fn isqrt` makes `sqrt_math::newton::isqrt` available to `vote_math::weight::compute`. The exported `vote_math::cost::VoterProfile` struct is also used as a variable type in `governance.aleo`.

The call sequence is:

```text
governance.aleo::cast_vote
  -> vote_math::cost::build_profile
     -> vote_math::weight::compute
        -> sqrt_math::newton::isqrt
```

`governance.aleo::has_perfect_sqrt` calls `sqrt_math::checks::is_perfect_square` directly. This shows that a program can use both a library and its dependency.

## Math and limits

The calculated weight is `min(floor(sqrt(token_balance)), MAX_WEIGHT)`. The supplied balance must be at least `MIN_BALANCE`, which is `1`. `MAX_WEIGHT` is `100`.

| Supplied balance | Weight |
| --- | --- |
| `1u32` | `1u32` |
| `100u32` | `10u32` |
| `225u32` | `15u32` |
| `1000u32` | `31u32` |
| `9999u32` | `99u32` |
| `10000u32` | `100u32` |
| `4294967295u32` | `100u32` |

The integer square root uses 20 fixed Newton iterations. It returns `floor(sqrt(n))` for a `u32` input, including zero. The largest result is `65535`. The divisor is guarded so that zero input does not cause division by zero. The estimate never increases, which prevents oscillation near the result.

Quadratic voting assigns a cost of `votes * votes`. `qv_cost` calculates this value for inputs from `0u32` to `65535u32`. The maximum cost is `4294836225u32`. Larger inputs are rejected because their square exceeds `u32`. These credits are mathematical units in the example. They are not ALEO, and the program does not spend them.

**This is a library and math example.** The supplied `token_balance` is not checked against a token record or account. The program does not register proposals, prevent repeat votes, enforce a credit budget, or calculate a tally from vote records. `is_passing` compares the two totals that you supply. Do not use these functions as an election system without those controls.

The `token_balance` and `approve` inputs use Leo `private` visibility. `proposal_id` is public. The returned `Vote` record contains the signer, proposal ID, calculated weight, and choice. Local `leo run` output displays the record contents. These visibility settings do not prove token ownership or prevent repeat votes.

## Run individual examples

From the repository root, select the program with `--path quadratic_vote/governance`.

### Create a vote record

```bash
leo run cast_vote 1field 1000u32 true --path quadratic_vote/governance --network testnet
```

The returned `Vote` record has `proposal_id: 1field`, `weight: 31u32`, and `approve: true`. Its owner is the configured signer. The balance is a supplied number, not a verified token holding.

### Calculate the quadratic cost

```bash
leo run qv_cost 5u32 --path quadratic_vote/governance --network testnet
```

The result is `25u32`.

### Check for an integer square

```bash
leo run has_perfect_sqrt 1024u32 --path quadratic_vote/governance --network testnet
leo run has_perfect_sqrt 1000u32 --path quadratic_vote/governance --network testnet
```

The results are `true` and `false`. `1024` is `32 * 32`. The integer square root of `1000` is `31`, and `31 * 31` is `961`.

### Compare supplied totals

```bash
leo run is_passing 131u32 15u32 --path quadratic_vote/governance --network testnet
```

The result is `true`. The sample approval weights are `31 + 100 = 131`, and the rejection weight is `15`. This call does not read or count the records from earlier calls. A tie returns `false`.

## Run the tests

```bash
leo test --path quadratic_vote/governance --network testnet
```

The tests check record ownership and fields, weight eligibility and caps, integer square roots, quadratic-cost overflow, and comparisons of vote totals. They include values near the largest integer square and the maximum `u32` value.

## Create the packages with the CLI

To repeat the package setup in an empty directory, run:

```bash
leo new sqrt_math --library
leo new vote_math --library
leo new governance

(cd vote_math && leo add sqrt_math --local ../sqrt_math)
(cd governance && leo add sqrt_math --local ../sqrt_math)
(cd governance && leo add vote_math --local ../vote_math)
```

Copy the source files from each corresponding package in this example. Use the same Leo version for all three manifests. Then run `leo build --path governance --network testnet`.

## Project files

```text
quadratic_vote/
├── sqrt_math/
│   ├── program.json
│   └── src/
│       ├── lib.leo       # Exported ISQRT_MAX constant
│       ├── newton.leo    # Exported isqrt function
│       └── checks.leo    # Exported is_perfect_square function
├── vote_math/
│   ├── program.json
│   └── src/
│       ├── lib.leo       # Exported MAX_WEIGHT and MIN_BALANCE constants
│       ├── weight.leo    # Exported weight and eligibility functions
│       └── cost.leo      # Exported VoterProfile struct and cost functions
├── governance/
│   ├── program.json
│   ├── src/main.leo
│   └── tests/test_governance.leo
├── run.sh
└── README.md
```

## Extensions for a complete voting system

Use an authenticated token record or account to establish the budget. Add proposal state, a rule for repeat votes, credit consumption, and a tally derived from accepted votes. Define how a vote record is consumed so that it cannot be counted more than once. These changes need a separate design and security review.
