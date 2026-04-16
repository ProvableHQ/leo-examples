// treasury.aleo demonstrates storage singletons, structs, and vectors.
//
// Storage replaces mappings for single-valued on-chain state.  Each `storage`
// declaration creates a named slot that holds an optional value — initially
// `none`, settable to a typed value, and clearable back to `none`.
//
// All storage reads and writes happen inside a `return final { ... };` block.
// The `Final` return type tells the AVM these operations touch on-chain state.
//
// Key concepts:
//   storage balance: u64;           — singleton (one value on-chain)
//   storage config: FeeConfig;      — struct in storage
//   storage deposit_log: [u64];     — vector (dynamically-sized on-chain list)
//   balance.unwrap_or(0u64)         — read with fallback for uninitialized slots
//   balance = none;                 — clear a storage slot
//   deposit_log.push(amount);       — append to a vector
//   deposit_log.get(0u32)           — read a vector element (returns optional)

// Structs used in storage are declared at file scope (outside the program block).
struct FeeConfig {
    rate: u64,      // fee rate in basis points (e.g., 250 = 2.5%)
    minimum: u64,   // minimum fee amount
}

program treasury.aleo {
    // ── Singleton storage ───────────────────────────────────────────
    // Each declaration creates a single on-chain slot.
    // All slots start as `none` and become `Some(value)` once set.
    storage balance: u64;
    storage is_frozen: bool;
    storage deposit_count: u32;

    // ── Struct storage ──────────────────────────────────────────────
    // Structs are stored as a single unit, set and read atomically.
    storage config: FeeConfig;

    // ── Vector storage ──────────────────────────────────────────────
    // Vectors are dynamically-sized on-chain lists.
    // Operations: push, pop, get, set, clear, swap_remove, len.
    storage deposit_log: [u64];

    // Sets up the treasury with default configuration.
    fn initialize() -> Final {
        return final {
            balance = 0u64;
            is_frozen = false;
            deposit_count = 0u32;
            config = FeeConfig { rate: 250u64, minimum: 10u64 };
        };
    }

    // Adds `amount` to the treasury balance and logs it in the vector.
    fn deposit(amount: u64) -> Final {
        return final {
            // unwrap_or gracefully handles uninitialized storage.
            assert(is_frozen.unwrap_or(false) == false);

            let current: u64 = balance.unwrap_or(0u64);
            balance = current + amount;

            deposit_count = deposit_count.unwrap_or(0u32) + 1u32;

            // Vector push — appends to the on-chain list.
            deposit_log.push(amount);
        };
    }

    // Subtracts `amount` from the treasury balance.
    fn withdraw(amount: u64) -> Final {
        return final {
            assert(is_frozen.unwrap_or(false) == false);

            // unwrap() fails if the slot is none (no balance set yet).
            let current: u64 = balance.unwrap();
            assert(current >= amount);
            balance = current - amount;
        };
    }

    // Freezes the treasury, blocking deposits and withdrawals.
    fn freeze() -> Final {
        return final {
            is_frozen = true;
        };
    }

    // Unfreezes the treasury.
    fn unfreeze() -> Final {
        return final {
            is_frozen = false;
        };
    }

    // Updates the fee configuration struct.
    fn update_config(rate: u64, minimum: u64) -> Final {
        return final {
            config = FeeConfig { rate: rate, minimum: minimum };
        };
    }

    // Removes the most recent deposit from the log.
    // Demonstrates vector pop (returns the removed element).
    fn pop_last_deposit() -> Final {
        return final {
            let removed = deposit_log.pop();
            assert(removed != none);
        };
    }

    // Resets all storage to `none`, demonstrating storage clearing.
    fn reset() -> Final {
        return final {
            balance = none;
            is_frozen = none;
            deposit_count = none;
            config = none;

            // clear() empties the entire vector.
            deposit_log.clear();
        };
    }

    @noupgrade
    constructor() {}
}
