# Storage in Leo

This example demonstrates **storage variables** in Leo 4 — on-chain state that replaces single-entry mappings with a simpler, typed API.

## The Scenario

A treasury program tracks its balance, configuration, and deposit history using on-chain storage.  A separate auditor program reads the treasury's storage externally to monitor its state — without the treasury needing to expose any getter functions.

## Program Architecture

```
treasury.aleo                     auditor.aleo
  │  storage balance: u64            │  reads treasury.aleo::balance
  │  storage config: FeeConfig       │  reads treasury.aleo::config
  │  storage deposit_log: [u64]      │  reads treasury.aleo::deposit_log
  │  storage is_frozen: bool         │  reads treasury.aleo::is_frozen
  │  (owns and writes all state)     │  (read-only external access)
  └──────────────────────────────────┘
```

## Features Showcased

### Storage Singletons

A `storage` declaration creates a single named on-chain slot.  Values are optional — `none` until set, clearable back to `none`.

```leo
program treasury.aleo {
    storage balance: u64;
    storage is_frozen: bool;
    storage deposit_count: u32;

    fn initialize() -> Final {
        return final {
            balance = 0u64;
            is_frozen = false;
        };
    }
}
```

All storage operations happen inside a `return final { ... };` block.  The `Final` return type tells the AVM that the function modifies on-chain state.

### Reading Storage

Storage slots are optional.  Use `unwrap()` when the value must exist, or `unwrap_or()` to provide a fallback:

```leo
fn deposit(amount: u64) -> Final {
    return final {
        let current: u64 = balance.unwrap_or(0u64);  // fallback if uninitialized
        balance = current + amount;
    };
}
```

### Struct Storage

Structs are stored and read as a single unit:

```leo
struct FeeConfig {
    rate: u64,
    minimum: u64,
}

program treasury.aleo {
    storage config: FeeConfig;

    fn update_config(rate: u64, minimum: u64) -> Final {
        return final {
            config = FeeConfig { rate: rate, minimum: minimum };
        };
    }
}
```

### Vector Storage

Vectors are dynamically-sized on-chain lists with `push`, `pop`, `get`, `set`, `clear`, `swap_remove`, and `len`:

```leo
program treasury.aleo {
    storage deposit_log: [u64];

    fn deposit(amount: u64) -> Final {
        return final {
            deposit_log.push(amount);       // append
        };
    }

    fn pop_last_deposit() -> Final {
        return final {
            let removed = deposit_log.pop();  // remove last
            assert(removed != none);
        };
    }

    fn reset() -> Final {
        return final {
            deposit_log.clear();            // empty the list
        };
    }
}
```

### Clearing Storage

Assign `none` to clear a singleton, or call `.clear()` on a vector:

```leo
fn reset() -> Final {
    return final {
        balance = none;         // slot reverts to uninitialized
        config = none;          // struct slot cleared
        deposit_log.clear();    // vector emptied
    };
}
```

### External Storage Access

Any program can **read** another deployed program's storage using `program.aleo::variable` syntax.  Writes are restricted to the owning program.

```leo
import treasury.aleo;

program auditor.aleo {
    fn take_snapshot() -> Final {
        return final {
            // Read external singletons
            let bal: u64 = treasury.aleo::balance.unwrap_or(0u64);
            let frozen: bool = treasury.aleo::is_frozen.unwrap_or(false);

            // Read external struct
            let cfg = treasury.aleo::config.unwrap_or(
                treasury.aleo::FeeConfig { rate: 0u64, minimum: 0u64 }
            );

            // Read external vector
            let count: u32 = treasury.aleo::deposit_log.len();
            let first = treasury.aleo::deposit_log.get(0u32);
        };
    }
}
```

## Project Structure

```
storage/
├── run.sh
├── treasury/              # Owns and writes all storage
│   ├── program.json
│   └── src/
│       └── main.leo
└── auditor/               # Reads treasury storage externally
    ├── program.json       # lists treasury.aleo as a local dependency
    └── src/
        └── main.leo
```

## Running the Example

### Part 1 — Local execution (no devnode)

Individual treasury operations can be tested locally with `leo run`:

```bash
cd treasury
leo run initialize
leo run deposit 5000u64
leo run withdraw 1000u64
leo run update_config 500u64 25u64
```

Note: each `leo run` starts with fresh state, so operations don't accumulate across calls.

### Part 2 — External storage access (requires `leo devnode`)

Cross-program storage reads require both programs to be deployed.  Start a local devnode in a **separate terminal** first:

```bash
leo devnode start --private-key APrivateKey1zkp8CZNn3yeCseEtxuVPbDCwSyhGW6yZKUYKfgXmcpoGPWH
```

Then run the full demo from the `storage/` directory:

```bash
./run.sh
```

The script:
1. Runs local demos of treasury operations
2. Deploys `treasury.aleo` and initializes it with deposits
3. Deploys `auditor.aleo` (local dependency on treasury — Leo deploys both in order)
4. Calls `take_snapshot` — reads treasury balance, count, and frozen state
5. Calls `check_fee_config` — reads the treasury's `FeeConfig` struct
6. Calls `check_deposits` — reads the treasury's deposit log vector
7. Freezes the treasury, then snapshots again to show the alert triggers
8. Resets all treasury storage to `none`

## Key Takeaways

- **Storage singletons** replace single-entry mappings with a cleaner, typed API.
- **Struct storage** lets you group related fields into a single on-chain slot.
- **Vector storage** gives you a dynamically-sized on-chain list with push/pop/get/set/clear.
- **External reads** let any program inspect another's storage — no getter functions needed.
- **`none`** semantics: all storage starts as `none`; use `unwrap_or()` for safe fallbacks.
