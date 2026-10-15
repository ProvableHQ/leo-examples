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
//   storage balance: u64;            — singleton (one value on-chain)
//   storage config: FeeConfig;       — struct in storage
//   storage deposit_log: [u64];      — vector (dynamically-sized on-chain list)
//   balance.unwrap_or(0u64)          — read with fallback for uninitialized slots
//   balance = none;                  — clear a storage slot
//   deposit_log.push(amount);        — append to a vector
//   deposit_log.pop();               — remove and return the last element
//   deposit_log.get(0u32)            — read a vector element (returns optional)
//   deposit_log.set(0u32, 100u64);   — overwrite an existing element
//   deposit_log.swap_remove(0u32);   — drop element by swapping with the tail
//   deposit_log.len();               — current vector length
//   deposit_log.clear();             — reset the vector to empty

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

    // Reverses the most recent deposit: pops the log, refunds the balance,
    // and decrements the deposit count.  Demonstrates `pop`, which both
    // shrinks the vector and returns the removed element.
    fn undo_last_deposit() -> Final {
        return final {
            // pop() returns the last element as an optional, or none if empty.
            let removed: u64? = deposit_log.pop();
            assert(removed != none);

            // Mirror the pop in the running balance and counter so that
            // treasury state stays consistent with the deposit log.
            balance = balance.unwrap_or(0u64) - removed.unwrap();
            deposit_count = deposit_count.unwrap_or(0u32) - 1u32;
        };
    }

    // Overwrites a logged deposit at a specific index.  Demonstrates `set`,
    // which replaces an existing element (asserts the index is in range).
    // Useful, e.g., when correcting a bookkeeping mistake without reshaping
    // the log.
    fn correct_deposit(index: u32, amount: u64) -> Final {
        return final {
            // get() returns the previous value as an optional so we can
            // adjust the running balance by the delta.
            let previous: u64 = deposit_log.get(index).unwrap();
            deposit_log.set(index, amount);

            let current: u64 = balance.unwrap_or(0u64);
            balance = current + amount - previous;
        };
    }

    // Drops a logged deposit out of order by swapping with the tail.
    // Demonstrates `swap_remove`, which is O(1) but does not preserve order.
    fn drop_deposit(index: u32) -> Final {
        return final {
            // swap_remove() returns the removed element directly (no option),
            // and asserts that the index is in range.
            let removed: u64 = deposit_log.swap_remove(index);

            balance = balance.unwrap_or(0u64) - removed;
            deposit_count = deposit_count.unwrap_or(0u32) - 1u32;
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
