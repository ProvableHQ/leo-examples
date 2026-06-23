// Unit tests for treasury.aleo.
//
// Each `@test` runs against a fresh deployment, so any state observed in a
// test must be produced inside that same test.  Tests drive treasury
// transitions (which mutate storage in their `final` blocks) and then read
// storage back via `treasury.aleo::<var>` access from the test's own
// finalize block.
//
// Run with:  leo test
// (See ../README.md for details.)

import treasury.aleo;

program test_treasury.aleo {
    // ── Defaults: everything reads as `none` before any write ───────────────
    @test
    fn unset_storage_reads_as_none() -> Final {
        return final {
            assert(treasury.aleo::balance.unwrap_or(0u64) == 0u64);
            assert(treasury.aleo::is_frozen.unwrap_or(false) == false);
            assert(treasury.aleo::deposit_count.unwrap_or(0u32) == 0u32);
            assert(treasury.aleo::deposit_log.len() == 0u32);
        };
    }

    // ── initialize sets every singleton ─────────────────────────────────────
    @test
    fn initialize_sets_state() -> Final {
        let f: Final = treasury.aleo::initialize();
        return final {
            f.run();
            assert(treasury.aleo::balance.unwrap() == 0u64);
            assert(treasury.aleo::is_frozen.unwrap() == false);
            assert(treasury.aleo::deposit_count.unwrap() == 0u32);

            let cfg: treasury.aleo::FeeConfig = treasury.aleo::config.unwrap();
            assert(cfg.rate == 250u64);
            assert(cfg.minimum == 10u64);
        };
    }

    // ── deposit accumulates balance, count, and log ─────────────────────────
    @test
    fn deposit_accumulates_state() -> Final {
        let f0: Final = treasury.aleo::initialize();
        let f1: Final = treasury.aleo::deposit(5000u64);
        let f2: Final = treasury.aleo::deposit(3000u64);
        return final {
            f0.run();
            f1.run();
            f2.run();
            assert(treasury.aleo::balance.unwrap() == 8000u64);
            assert(treasury.aleo::deposit_count.unwrap() == 2u32);
            assert(treasury.aleo::deposit_log.len() == 2u32);
            assert(treasury.aleo::deposit_log.get(0u32).unwrap() == 5000u64);
            assert(treasury.aleo::deposit_log.get(1u32).unwrap() == 3000u64);
        };
    }

    // ── deposit works on a brand-new treasury (unwrap_or fallback) ──────────
    @test
    fn deposit_without_initialize() -> Final {
        let f: Final = treasury.aleo::deposit(100u64);
        return final {
            f.run();
            assert(treasury.aleo::balance.unwrap() == 100u64);
            assert(treasury.aleo::deposit_count.unwrap() == 1u32);
            assert(treasury.aleo::deposit_log.len() == 1u32);
        };
    }

    // ── withdraw subtracts from balance ─────────────────────────────────────
    @test
    fn withdraw_reduces_balance() -> Final {
        let f0: Final = treasury.aleo::initialize();
        let f1: Final = treasury.aleo::deposit(5000u64);
        let f2: Final = treasury.aleo::withdraw(1500u64);
        return final {
            f0.run();
            f1.run();
            f2.run();
            assert(treasury.aleo::balance.unwrap() == 3500u64);
            // Withdraw is independent of the deposit log.
            assert(treasury.aleo::deposit_log.len() == 1u32);
        };
    }

    // ── overdraw halts ──────────────────────────────────────────────────────
    @test
    @should_fail
    fn overdraw_fails() -> Final {
        let f0: Final = treasury.aleo::initialize();
        let f1: Final = treasury.aleo::deposit(100u64);
        let f2: Final = treasury.aleo::withdraw(101u64);
        return final {
            f0.run();
            f1.run();
            f2.run();
        };
    }

    // ── withdraw before any deposit hits unwrap() and halts ─────────────────
    @test
    @should_fail
    fn withdraw_without_balance_fails() -> Final {
        // No initialize, no deposit — balance is none, so unwrap() halts.
        let f: Final = treasury.aleo::withdraw(1u64);
        return final {
            f.run();
        };
    }

    // ── freeze blocks deposit ───────────────────────────────────────────────
    @test
    @should_fail
    fn freeze_blocks_deposit() -> Final {
        let f0: Final = treasury.aleo::initialize();
        let f1: Final = treasury.aleo::freeze();
        let f2: Final = treasury.aleo::deposit(100u64);
        return final {
            f0.run();
            f1.run();
            f2.run();
        };
    }

    // ── freeze blocks withdraw ──────────────────────────────────────────────
    @test
    @should_fail
    fn freeze_blocks_withdraw() -> Final {
        let f0: Final = treasury.aleo::initialize();
        let f1: Final = treasury.aleo::deposit(500u64);
        let f2: Final = treasury.aleo::freeze();
        let f3: Final = treasury.aleo::withdraw(100u64);
        return final {
            f0.run();
            f1.run();
            f2.run();
            f3.run();
        };
    }

    // ── unfreeze restores deposits ──────────────────────────────────────────
    @test
    fn unfreeze_restores_deposits() -> Final {
        let f0: Final = treasury.aleo::initialize();
        let f1: Final = treasury.aleo::freeze();
        let f2: Final = treasury.aleo::unfreeze();
        let f3: Final = treasury.aleo::deposit(42u64);
        return final {
            f0.run();
            f1.run();
            f2.run();
            f3.run();
            assert(treasury.aleo::is_frozen.unwrap() == false);
            assert(treasury.aleo::balance.unwrap() == 42u64);
        };
    }

    // ── update_config replaces the struct atomically ────────────────────────
    @test
    fn update_config_replaces_struct() -> Final {
        let f0: Final = treasury.aleo::initialize();
        let f1: Final = treasury.aleo::update_config(500u64, 25u64);
        return final {
            f0.run();
            f1.run();
            let cfg: treasury.aleo::FeeConfig = treasury.aleo::config.unwrap();
            assert(cfg.rate == 500u64);
            assert(cfg.minimum == 25u64);
        };
    }

    // ── undo_last_deposit reverses the most recent deposit ──────────────────
    @test
    fn undo_last_deposit_reverses() -> Final {
        let f0: Final = treasury.aleo::deposit(100u64);
        let f1: Final = treasury.aleo::deposit(250u64);
        let f2: Final = treasury.aleo::undo_last_deposit();
        return final {
            f0.run();
            f1.run();
            f2.run();
            assert(treasury.aleo::balance.unwrap() == 100u64);
            assert(treasury.aleo::deposit_count.unwrap() == 1u32);
            assert(treasury.aleo::deposit_log.len() == 1u32);
            assert(treasury.aleo::deposit_log.get(0u32).unwrap() == 100u64);
        };
    }

    // ── undo_last_deposit on an empty log halts (pop returns none) ──────────
    @test
    @should_fail
    fn undo_on_empty_log_fails() -> Final {
        let f: Final = treasury.aleo::undo_last_deposit();
        return final {
            f.run();
        };
    }

    // ── correct_deposit overwrites a logged amount and rebalances ───────────
    @test
    fn correct_deposit_overwrites() -> Final {
        let f0: Final = treasury.aleo::deposit(100u64);
        let f1: Final = treasury.aleo::deposit(200u64);
        // Originally logged 200 at index 1; correct it to 250.
        let f2: Final = treasury.aleo::correct_deposit(1u32, 250u64);
        return final {
            f0.run();
            f1.run();
            f2.run();
            assert(treasury.aleo::balance.unwrap() == 350u64);
            assert(treasury.aleo::deposit_log.get(1u32).unwrap() == 250u64);
            // Log length is unchanged by `set`.
            assert(treasury.aleo::deposit_log.len() == 2u32);
        };
    }

    // ── drop_deposit removes out of order via swap_remove ───────────────────
    @test
    fn drop_deposit_swap_removes() -> Final {
        let f0: Final = treasury.aleo::deposit(10u64);
        let f1: Final = treasury.aleo::deposit(20u64);
        let f2: Final = treasury.aleo::deposit(30u64);
        // Drop index 0 (value 10).  swap_remove pulls the tail (30) into slot 0.
        let f3: Final = treasury.aleo::drop_deposit(0u32);
        return final {
            f0.run();
            f1.run();
            f2.run();
            f3.run();
            assert(treasury.aleo::balance.unwrap() == 50u64);
            assert(treasury.aleo::deposit_count.unwrap() == 2u32);
            assert(treasury.aleo::deposit_log.len() == 2u32);
            assert(treasury.aleo::deposit_log.get(0u32).unwrap() == 30u64);
            assert(treasury.aleo::deposit_log.get(1u32).unwrap() == 20u64);
        };
    }

    // ── reset clears every storage slot back to none / empty ────────────────
    @test
    fn reset_clears_every_slot() -> Final {
        let f0: Final = treasury.aleo::initialize();
        let f1: Final = treasury.aleo::deposit(100u64);
        let f2: Final = treasury.aleo::deposit(200u64);
        let f3: Final = treasury.aleo::reset();
        return final {
            f0.run();
            f1.run();
            f2.run();
            f3.run();
            assert(treasury.aleo::balance.unwrap_or(0u64) == 0u64);
            assert(treasury.aleo::is_frozen.unwrap_or(false) == false);
            assert(treasury.aleo::deposit_count.unwrap_or(0u32) == 0u32);
            assert(treasury.aleo::deposit_log.len() == 0u32);
            // The first read after reset returns none.
            assert(treasury.aleo::deposit_log.get(0u32).unwrap_or(0u64) == 0u64);
        };
    }

    @noupgrade
    constructor() {}
}
