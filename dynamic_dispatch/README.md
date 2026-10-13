# Dynamic dispatch with an exported Leo interface

Call different programs through one exported interface, with the target selected by an `identifier` value at runtime.

## Build and run locally

Use Leo 4.4.5 and Bash. Check the compiler with `leo --version`. You do not need a node or funded account for the local demo.

From the repository root, run:

```bash
bash dynamic_dispatch/run.sh
```

The script builds and tests all three programs. It then runs calls with variable targets and identifier literals. You can run the script from any directory. To select another compiler, set `LEO` to its executable path. Both absolute and relative paths are supported.

| Local call | Result |
| --- | --- |
| Linear power for `10000u64` | `10000u64` |
| Square-root power for `10000u64` | `100u64` |
| Linear comparison of `101u64` and `100u64` | `true` |
| Square-root comparison of `101u64` and `100u64` | `false` |
| Both strategies for `10000u64` | `10000u64`, `100u64` |

`leo run` evaluates the calls in a local VM. It does not generate an execution proof or broadcast a transaction. The local dependencies make both target programs available to that VM, so dynamic calls work without deployment.

## Programs and dependencies

| Program | Purpose |
| --- | --- |
| `voting_power.aleo` | Exports `VotingStrategy` and returns the supplied balance unchanged |
| `quadratic_power.aleo` | Implements the same interface and returns `floor(sqrt(balance))` |
| `governance.aleo` | Calls a strategy selected at runtime, compares two supplied balances, or calls both fixed targets |

`quadratic_power` has a local dependency on `voting_power`. `governance` has local dependencies on both strategies. The dependency names and paths are in each `program.json` file.

```text
governance.aleo
├── voting_power.aleo::VotingStrategy
├── target 'voting_power' -> compute_power(balance) -> balance
└── target 'quadratic_power' -> compute_power(balance) -> floor(sqrt(balance))
```

### Export one shared interface

The interface is declared once in `voting_power/src/main.leo`:

```leo
export interface VotingStrategy {
    fn compute_power(balance: u64) -> u64;
}
```

The linear program implements `VotingStrategy`. The square-root program imports `voting_power.aleo` and implements `voting_power.aleo::VotingStrategy`. Leo checks each implementation against the shared declaration at compile time. You do not need to copy the interface into each source file.

The interface specifies types and visibility modes. It does not specify the formula or authorize a target. Interfaces are compiler constructs; the deployed programs contain the executable functions.

### Select a target at runtime

`get_voting_power` uses a qualified interface name and a variable target:

```leo
fn get_voting_power(strategy: identifier, balance: u64) -> u64 {
    return voting_power.aleo::VotingStrategy@(strategy)::compute_power(balance);
}
```

`VotingStrategy` gives the compiler the call signature. `strategy` supplies the target program name. `compute_power` names the function on that target. The target must be available to the VM and expose the required function with matching inputs and outputs. A missing program or function causes the call to fail.

Identifier literals use single quotes around the program name without `.aleo`. Quote the complete literal in the shell so that Leo receives those single quotes:

```bash
leo run get_voting_power "'voting_power'" 10000u64 --path dynamic_dispatch/governance --network testnet
leo run get_voting_power "'quadratic_power'" 10000u64 --path dynamic_dispatch/governance --network testnet
```

The results are `10000u64` and `100u64`.

### Load another target without changing governance

Build another strategy program with the required `compute_power` signature. Use `--with` to load its compiled `.aleo` file into the local VM. You do not need to add this target to the governance manifest or change the governance source.

Replace `EXTRA_PROGRAM_NAME` with the target program name without `.aleo`. Replace `EXTRA_PROGRAM_ALEO` with the path to its compiled `.aleo` file.

```bash
leo run get_voting_power "'EXTRA_PROGRAM_NAME'" 10000u64 --with EXTRA_PROGRAM_ALEO --path dynamic_dispatch/governance --network testnet
```

`leo execute` also accepts `--with`. For network execution, deploy the new target first and load the same bytecode for proof generation.

### Use fixed identifier literals

`compare_strategies` uses these two calls:

```leo
fn compare_strategies(balance: u64) -> (u64, u64) {
    let linear_power: u64 = voting_power.aleo::VotingStrategy@('voting_power')::compute_power(balance);
    let quadratic_power: u64 = voting_power.aleo::VotingStrategy@('quadratic_power')::compute_power(balance);
    return (linear_power, quadratic_power);
}
```

The literal fixes the target name in the source. These are still dynamic calls. You can evaluate both with one command:

```bash
leo run compare_strategies 10000u64 --path dynamic_dispatch/governance --network testnet
```

The results are `10000u64` and `100u64`.

## Arithmetic and example limits

The square-root implementation accepts the full `u64` range. It starts with an estimate of `2^32` and uses 33 fixed Newton iterations. Each step above the integer square root reduces the remaining gap by at least half. The smaller estimate is retained to prevent oscillation. The result for zero is zero, and the result for `18446744073709551615u64` is `4294967295u64`.

`proposal_passes` applies the selected formula to two supplied balances and returns whether the first result is larger. For `101u64` and `100u64`, the linear results are `101` and `100`. The square-root results are both `10`, so the square-root comparison returns `false`.

For `1000000u64` and `10000u64`, both comparisons return `true`. The linear power ratio is `100:1`, and the square-root power ratio is `10:1`. A square root is monotone, so it can turn a narrow win into a tie, but it cannot reverse the order of these two inputs.

**This is a dispatch and arithmetic example.** The programs do not verify token holdings, accept ballots, spend credits, or store a tally. Applying a square root to a total does not calculate the sum of individual vote weights. The caller can name any available target with the required function signature. A complete governance system also needs a rule that authorizes which strategies can be used.

## Run the tests separately

From the repository root, run:

```bash
leo test --path dynamic_dispatch/voting_power --network testnet
leo test --path dynamic_dispatch/quadratic_power --network testnet
leo test --path dynamic_dispatch/governance --network testnet
```

The tests check zero, square boundaries, the maximum `u64` input, variable dispatch targets, identifier literals, comparisons, and failures for missing programs or functions.

## Deploy and execute on a local devnode

Use a fresh devnode for each deployment run. All three programs use `@noupgrade`, so the same program names cannot be deployed again on that ledger. The demo uses the public test key below, which is only for local testing.

1. Start the node in a separate terminal:

```bash
leo devnode start --socket-addr 127.0.0.1:3030 --private-key APrivateKey1zkp8CZNn3yeCseEtxuVPbDCwSyhGW6yZKUYKfgXmcpoGPWH --disable-update-check
```

2. From the repository root, run the network demo:

```bash
bash dynamic_dispatch/run.sh --devnode
```

The script first runs the local demo. It then deploys from the `governance` package, which includes both local strategy dependencies. Finally, it executes and broadcasts the five dispatch calls to the local node. Unlike `leo run`, these calls generate execution proofs and submit transactions.

The script uses `--devnet` to select the devnode consensus schedule. It does not hardcode a list of consensus activation heights. The expected values are the same as in the local demo.

To use another local port, start the node with that port and set `LEO_DEVNODE_PORT` for the script:

```bash
LEO_DEVNODE_PORT=4040 bash dynamic_dispatch/run.sh --devnode
```

The script connects only to `127.0.0.1`. It stops when a command returns a nonzero exit status.

## Project files

```text
dynamic_dispatch/
├── run.sh
├── voting_power/
│   ├── program.json
│   ├── src/main.leo
│   └── tests/test_voting_power.leo
├── quadratic_power/
│   ├── program.json
│   ├── src/main.leo
│   └── tests/test_quadratic_power.leo
└── governance/
    ├── program.json
    ├── src/main.leo
    └── tests/test_governance.leo
```
