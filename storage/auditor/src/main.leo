// auditor.aleo demonstrates reading another program's storage externally.
//
// In Leo 4, any program can read another deployed program's storage
// variables using the `program.aleo::variable` syntax.  This is read-only:
// only the owning program can write to its own storage.
//
// Key concepts:
//   treasury.aleo::balance.unwrap()           — read external singleton
//   treasury.aleo::balance.unwrap_or(0u64)    — read with fallback
//   treasury.aleo::config.unwrap()            — read external struct
//   treasury.aleo::FeeConfig { ... }          — reference external struct type
//   treasury.aleo::deposit_log.get(0u32)      — read external vector element
//   treasury.aleo::deposit_log.len()          — read external vector length

import treasury.aleo;

struct Snapshot {
    balance: u64,
    deposit_count: u32,
    is_frozen: bool,
}

program auditor.aleo {
    // The auditor maintains its own storage for snapshots.
    storage last_snapshot: Snapshot;
    storage is_alert: bool;

    // Reads treasury state and stores a local snapshot.
    // Demonstrates external singleton reads with unwrap_or.
    fn take_snapshot() -> Final {
        return final {
            // Read external storage singletons.
            let bal: u64 = treasury.aleo::balance.unwrap_or(0u64);
            let deps: u32 = treasury.aleo::deposit_count.unwrap_or(0u32);
            let frozen: bool = treasury.aleo::is_frozen.unwrap_or(false);

            // Write to local storage.
            last_snapshot = Snapshot {
                balance: bal,
                deposit_count: deps,
                is_frozen: frozen,
            };

            // Raise alert if treasury is frozen.
            is_alert = frozen;
        };
    }

    // Reads the treasury's fee configuration struct externally.
    // Demonstrates cross-program struct access.
    fn check_fee_config() -> Final {
        return final {
            // Read an external struct.  The fallback uses the
            // qualified struct type: treasury.aleo::FeeConfig.
            let cfg = treasury.aleo::config.unwrap_or(
                treasury.aleo::FeeConfig { rate: 0u64, minimum: 0u64 }
            );

            // Verify fee rate is within acceptable bounds (≤ 10%).
            assert(cfg.rate <= 1000u64);
        };
    }

    // Reads the treasury's deposit log vector externally.
    // Demonstrates external vector access.
    fn check_deposits() -> Final {
        return final {
            // Vector length — how many deposits have been logged.
            let count: u32 = treasury.aleo::deposit_log.len();
            assert(count > 0u32);

            // Vector get — read the first deposit (returns optional).
            let first = treasury.aleo::deposit_log.get(0u32);
            assert(first != none);
        };
    }

    @noupgrade
    constructor() {}
}
