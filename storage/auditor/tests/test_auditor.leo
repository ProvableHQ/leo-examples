// Unit tests for auditor.aleo.
//
// The auditor reads treasury.aleo's storage cross-program.  Each test sets
// up treasury state by calling treasury transitions, runs the auditor's
// transition under test, and then asserts on both treasury *and* auditor
// storage from inside the test's finalize block.
//
// Run with:  leo test
// (See ../README.md for details.)

import treasury.aleo;
import auditor.aleo;

program test_auditor.aleo {
    // ── Snapshot mirrors treasury state set up by deposit + update_config ──
    @test
    fn snapshot_reads_treasury() -> Final {
        let f0: Final = treasury.aleo::initialize();
        let f1: Final = treasury.aleo::deposit(5000u64);
        let f2: Final = treasury.aleo::deposit(3000u64);
        let f3: Final = auditor.aleo::take_snapshot();
        return final {
            f0.run();
            f1.run();
            f2.run();
            f3.run();

            let snap: auditor.aleo::Snapshot = auditor.aleo::last_snapshot.unwrap();
            assert(snap.balance == 8000u64);
            assert(snap.deposit_count == 2u32);
            assert(snap.is_frozen == false);
            // Treasury isn't frozen, so the auditor's alert flag is clear.
            assert(auditor.aleo::is_alert.unwrap() == false);
        };
    }

    // ── Snapshot of an empty treasury falls back through unwrap_or ─────────
    @test
    fn snapshot_defaults_on_empty() -> Final {
        // No initialize, no deposit — every treasury slot is none.
        let f: Final = auditor.aleo::take_snapshot();
        return final {
            f.run();
            let snap: auditor.aleo::Snapshot = auditor.aleo::last_snapshot.unwrap();
            assert(snap.balance == 0u64);
            assert(snap.deposit_count == 0u32);
            assert(snap.is_frozen == false);
            assert(auditor.aleo::is_alert.unwrap() == false);
        };
    }

    // ── Snapshot detects a freeze and raises the alert flag ─────────────────
    @test
    fn snapshot_detects_freeze() -> Final {
        let f0: Final = treasury.aleo::initialize();
        let f1: Final = treasury.aleo::freeze();
        let f2: Final = auditor.aleo::take_snapshot();
        return final {
            f0.run();
            f1.run();
            f2.run();
            assert(auditor.aleo::last_snapshot.unwrap().is_frozen == true);
            assert(auditor.aleo::is_alert.unwrap() == true);
        };
    }

    // ── A subsequent unfreeze + snapshot clears the alert flag ─────────────
    @test
    fn alert_clears_after_unfreeze() -> Final {
        let f0: Final = treasury.aleo::initialize();
        let f1: Final = treasury.aleo::freeze();
        let f2: Final = auditor.aleo::take_snapshot();
        let f3: Final = treasury.aleo::unfreeze();
        let f4: Final = auditor.aleo::take_snapshot();
        return final {
            f0.run();
            f1.run();
            f2.run();
            f3.run();
            f4.run();
            assert(auditor.aleo::last_snapshot.unwrap().is_frozen == false);
            assert(auditor.aleo::is_alert.unwrap() == false);
        };
    }

    // ── check_fee_config accepts a default-rate config ──────────────────────
    @test
    fn fee_config_passes_at_default() -> Final {
        let f0: Final = treasury.aleo::initialize();
        let f1: Final = auditor.aleo::check_fee_config();
        return final {
            f0.run();
            f1.run();
        };
    }

    // ── check_fee_config also accepts a tightened config ────────────────────
    @test
    fn fee_config_accepts_low_rate() -> Final {
        let f0: Final = treasury.aleo::update_config(50u64, 1u64);
        let f1: Final = auditor.aleo::check_fee_config();
        return final {
            f0.run();
            f1.run();
        };
    }

    // ── check_fee_config rejects a rate above 10% ───────────────────────────
    @test
    @should_fail
    fn fee_config_rejects_high_rate() -> Final {
        // 1500 basis points = 15%, which exceeds the auditor's 10% cap.
        let f0: Final = treasury.aleo::update_config(1500u64, 0u64);
        let f1: Final = auditor.aleo::check_fee_config();
        return final {
            f0.run();
            f1.run();
        };
    }

    // ── check_fee_config falls back when treasury never set a config ────────
    // The default fallback (rate 0, minimum 0) trivially satisfies rate ≤ 10%.
    @test
    fn check_fee_config_uses_fallback() -> Final {
        let f: Final = auditor.aleo::check_fee_config();
        return final {
            f.run();
        };
    }

    // ── check_deposits sees the treasury's logged deposits ─────────────────
    @test
    fn check_deposits_after_deposit() -> Final {
        let f0: Final = treasury.aleo::deposit(1000u64);
        let f1: Final = auditor.aleo::check_deposits();
        return final {
            f0.run();
            f1.run();
            // Cross-check what the auditor read against treasury storage.
            assert(treasury.aleo::deposit_log.len() == 1u32);
            assert(treasury.aleo::deposit_log.get(0u32).unwrap() == 1000u64);
        };
    }

    // ── check_deposits halts if the log is empty (assert count > 0) ─────────
    @test
    @should_fail
    fn check_deposits_empty_fails() -> Final {
        let f: Final = auditor.aleo::check_deposits();
        return final {
            f.run();
        };
    }

    @noupgrade
    constructor() {}
}
