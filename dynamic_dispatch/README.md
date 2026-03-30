# Dynamic Dispatch in Leo

This example demonstrates two related Leo 4.0 features: **interfaces** and **dynamic dispatch**.

## The Scenario

Different governance systems call for different voting-power formulas.  A _linear_ strategy grants one vote per token (simple majority), while a _quadratic_ strategy grants floor(√tokens) votes (reducing whale influence).  We want a single governance contract that can apply **either** formula — or any future formula — without being redeployed.

Dynamic dispatch makes this possible: the caller names the target strategy at runtime using the `identifier` type, and the AVM routes the call to whichever deployed program is named.

## Program Architecture

```
voting_power.aleo          quadratic_power.aleo
  │  declares VotingStrategy   │  implements VotingStrategy
  │  implements (linear)       │  (floor √balance votes)
  └──────────┬─────────────────┘
             │  governance.aleo resolves the VotingStrategy interface
             ▼  and dispatches to either program at runtime
        governance.aleo
          get_voting_power(strategy, balance)
          proposal_passes(strategy, for_bal, against_bal)
          compare_strategies(balance)
```

## Features Showcased

### Interfaces

An `interface` specifies the functions a program must expose.  It is a _compile-time_ concept: Leo verifies the implementing program satisfies the contract; no interface bytecode appears on-chain.

```leo
// In voting_power.aleo
interface VotingStrategy {
    fn compute_power(balance: u64) -> u64;
}

program voting_power.aleo : VotingStrategy {
    fn compute_power(balance: u64) -> u64 { return balance; }
    ...
}

// In quadratic_power.aleo — same interface, different implementation
program quadratic_power.aleo : VotingStrategy {
    fn compute_power(balance: u64) -> u64 { /* floor(√balance) */ ... }
    ...
}
```

**Note on interface scoping:** The `VotingStrategy` interface is declared at the top level of each program's `.leo` file (outside the `program {}` block).  An interface defined in one program is not automatically exported to programs that depend on it via `program.json`; each program re-declares the interface with the matching signature, and Leo's type checker verifies the contract at compile time.

### Dynamic Dispatch

The `identifier` type holds a program name resolved at runtime.  The call syntax is:

```
Interface@(target)::function(args)
├─ Interface  → interface declared in the same file
├─ @(target)  → `identifier` value resolved at runtime (the program to call)
└─ ::function → function to invoke on that target
```

`governance.aleo` re-declares `VotingStrategy` locally and accepts `strategy: identifier` as a parameter, routing to whichever program the caller names:

```leo
fn get_voting_power(strategy: identifier, balance: u64) -> u64 {
    return VotingStrategy@(strategy)::compute_power(balance);
}
```

Identifier literals use single quotes and can appear inline when the target is known at compile time:

```leo
fn compare_strategies(balance: u64) -> (u64, u64) {
    let linear_power:    u64 = VotingStrategy@('voting_power')::compute_power(balance);
    let quadratic_power: u64 = VotingStrategy@('quadratic_power')::compute_power(balance);
    return (linear_power, quadratic_power);
}
```

## Project Structure

```
dynamic_dispatch/
├── run.sh
├── voting_power/          # VotingStrategy interface + linear implementation
│   ├── program.json
│   └── src/
│       └── main.leo
├── quadratic_power/       # Quadratic implementation of VotingStrategy
│   ├── program.json
│   └── src/
│       └── main.leo
└── governance/            # Dynamic dispatch hub
    ├── program.json       # lists voting_power.aleo + quadratic_power.aleo as network deps
    └── src/
        └── main.leo
```

**Note on network dependencies:** `governance/program.json` lists `voting_power.aleo` and `quadratic_power.aleo` with `"location": "network"`.  When you run `leo build` (or any command that triggers a build), Leo fetches the deployed bytecode from the devnode endpoint into `build/imports/`, making it available to the local VM for proof generation.

## Running the Example

### Part 1 — Local execution (no devnode)

Individual programs can be tested locally with `leo run`:

```bash
cd voting_power
leo run compute_power 10000u64    # → 10000  (linear: 1:1)
leo run compute_power 100u64      # → 100

cd ../quadratic_power
leo run compute_power 10000u64    # → 100  (quadratic: √10000)
leo run compute_power 100u64      # → 10   (quadratic: √100)
```

### Part 2 — Dynamic dispatch (requires `leo devnode`)

Dynamic calls require all three programs to be deployed.  Start a local devnode in a **separate terminal** first:

```bash
leo devnode start --private-key APrivateKey1zkp8CZNn3yeCseEtxuVPbDCwSyhGW6yZKUYKfgXmcpoGPWH
```

Then run the full demo from the `dynamic_dispatch/` directory:

```bash
./run.sh
```

The script:
1. Deploys `voting_power.aleo` — establishes the interface on-chain
2. Deploys `quadratic_power.aleo` — registers a second implementation
3. Deploys `governance.aleo` — the dispatch hub (holds no logic itself)
4. Calls `get_voting_power` with `'voting_power'` → routes to linear
5. Calls `get_voting_power` with `'quadratic_power'` → routes to quadratic
6. Calls `proposal_passes` to show diverging outcomes under each strategy
7. Calls `compare_strategies` to see both results side-by-side

### Expected outputs

| Function | Strategy | Balance | Result |
|---|---|---|---|
| `compute_power` | linear | 10 000 | 10 000 |
| `compute_power` | quadratic | 10 000 | 100 |
| `proposal_passes` | linear | 1 000 000 vs 10 000 | true (10 000× margin) |
| `proposal_passes` | quadratic | 1 000 000 vs 10 000 | true (10× margin) |
| `compare_strategies` | both | 10 000 | (10 000, 100) |

## Key Takeaways

- **Interfaces** are compile-time contracts — they enforce structure without on-chain overhead.
- **Dynamic dispatch** lets a single contract target any compliant program at runtime; adding a new strategy requires only a new deployment, not a governance upgrade.
- **`identifier` literals** (`'program_name'`) give you dynamic dispatch with a compile-time-known target when you want both flexibility and readability.
