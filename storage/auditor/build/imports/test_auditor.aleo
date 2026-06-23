import treasury.aleo;
import auditor.aleo;
program test_auditor.aleo;

struct Optional__DQLgKQ6OK1W:
    is_some as boolean;
    val as auditor.aleo/Snapshot;

struct Optional__ATAkdHctJwx:
    is_some as boolean;
    val as boolean;

struct Optional__DmN5CQ9hzeK:
    is_some as boolean;
    val as u64;

function snapshot_reads_treasury:
    call treasury.aleo/initialize into r0;
    call treasury.aleo/deposit 5000u64 into r1;
    call treasury.aleo/deposit 3000u64 into r2;
    call auditor.aleo/take_snapshot into r3;
    async snapshot_reads_treasury r0 r1 r2 r3 into r4;
    output r4 as test_auditor.aleo/snapshot_reads_treasury.future;

finalize snapshot_reads_treasury:
    input r0 as treasury.aleo/initialize.future;
    input r1 as treasury.aleo/deposit.future;
    input r2 as treasury.aleo/deposit.future;
    input r3 as auditor.aleo/take_snapshot.future;
    await r0;
    await r1;
    await r2;
    await r3;
    contains auditor.aleo/last_snapshot__[false] into r4;
    cast 0u64 0u32 false into r5 as auditor.aleo/Snapshot;
    get.or_use auditor.aleo/last_snapshot__[false] r5 into r6;
    cast 0u64 0u32 false into r7 as auditor.aleo/Snapshot;
    ternary r4 r6.balance r7.balance into r8;
    ternary r4 r6.deposit_count r7.deposit_count into r9;
    ternary r4 r6.is_frozen r7.is_frozen into r10;
    cast r8 r9 r10 into r11 as auditor.aleo/Snapshot;
    cast r4 r11 into r12 as Optional__DQLgKQ6OK1W;
    assert.eq r12.is_some true;
    is.eq r12.val.balance 8000u64 into r13;
    assert.eq r13 true;
    is.eq r12.val.deposit_count 2u32 into r14;
    assert.eq r14 true;
    is.eq r12.val.is_frozen false into r15;
    assert.eq r15 true;
    contains auditor.aleo/is_alert__[false] into r16;
    get.or_use auditor.aleo/is_alert__[false] false into r17;
    ternary r16 r17 false into r18;
    cast r16 r18 into r19 as Optional__ATAkdHctJwx;
    assert.eq r19.is_some true;
    is.eq r19.val false into r20;
    assert.eq r20 true;

function snapshot_defaults_on_empty:
    call auditor.aleo/take_snapshot into r0;
    async snapshot_defaults_on_empty r0 into r1;
    output r1 as test_auditor.aleo/snapshot_defaults_on_empty.future;

finalize snapshot_defaults_on_empty:
    input r0 as auditor.aleo/take_snapshot.future;
    await r0;
    contains auditor.aleo/last_snapshot__[false] into r1;
    cast 0u64 0u32 false into r2 as auditor.aleo/Snapshot;
    get.or_use auditor.aleo/last_snapshot__[false] r2 into r3;
    cast 0u64 0u32 false into r4 as auditor.aleo/Snapshot;
    ternary r1 r3.balance r4.balance into r5;
    ternary r1 r3.deposit_count r4.deposit_count into r6;
    ternary r1 r3.is_frozen r4.is_frozen into r7;
    cast r5 r6 r7 into r8 as auditor.aleo/Snapshot;
    cast r1 r8 into r9 as Optional__DQLgKQ6OK1W;
    assert.eq r9.is_some true;
    is.eq r9.val.balance 0u64 into r10;
    assert.eq r10 true;
    is.eq r9.val.deposit_count 0u32 into r11;
    assert.eq r11 true;
    is.eq r9.val.is_frozen false into r12;
    assert.eq r12 true;
    contains auditor.aleo/is_alert__[false] into r13;
    get.or_use auditor.aleo/is_alert__[false] false into r14;
    ternary r13 r14 false into r15;
    cast r13 r15 into r16 as Optional__ATAkdHctJwx;
    assert.eq r16.is_some true;
    is.eq r16.val false into r17;
    assert.eq r17 true;

function snapshot_detects_freeze:
    call treasury.aleo/initialize into r0;
    call treasury.aleo/freeze into r1;
    call auditor.aleo/take_snapshot into r2;
    async snapshot_detects_freeze r0 r1 r2 into r3;
    output r3 as test_auditor.aleo/snapshot_detects_freeze.future;

finalize snapshot_detects_freeze:
    input r0 as treasury.aleo/initialize.future;
    input r1 as treasury.aleo/freeze.future;
    input r2 as auditor.aleo/take_snapshot.future;
    await r0;
    await r1;
    await r2;
    contains auditor.aleo/last_snapshot__[false] into r3;
    cast 0u64 0u32 false into r4 as auditor.aleo/Snapshot;
    get.or_use auditor.aleo/last_snapshot__[false] r4 into r5;
    cast 0u64 0u32 false into r6 as auditor.aleo/Snapshot;
    ternary r3 r5.balance r6.balance into r7;
    ternary r3 r5.deposit_count r6.deposit_count into r8;
    ternary r3 r5.is_frozen r6.is_frozen into r9;
    cast r7 r8 r9 into r10 as auditor.aleo/Snapshot;
    cast r3 r10 into r11 as Optional__DQLgKQ6OK1W;
    assert.eq r11.is_some true;
    is.eq r11.val.is_frozen true into r12;
    assert.eq r12 true;
    contains auditor.aleo/is_alert__[false] into r13;
    get.or_use auditor.aleo/is_alert__[false] false into r14;
    ternary r13 r14 false into r15;
    cast r13 r15 into r16 as Optional__ATAkdHctJwx;
    assert.eq r16.is_some true;
    is.eq r16.val true into r17;
    assert.eq r17 true;

function alert_clears_after_unfreeze:
    call treasury.aleo/initialize into r0;
    call treasury.aleo/freeze into r1;
    call auditor.aleo/take_snapshot into r2;
    call treasury.aleo/unfreeze into r3;
    call auditor.aleo/take_snapshot into r4;
    async alert_clears_after_unfreeze r0 r1 r2 r3 r4 into r5;
    output r5 as test_auditor.aleo/alert_clears_after_unfreeze.future;

finalize alert_clears_after_unfreeze:
    input r0 as treasury.aleo/initialize.future;
    input r1 as treasury.aleo/freeze.future;
    input r2 as auditor.aleo/take_snapshot.future;
    input r3 as treasury.aleo/unfreeze.future;
    input r4 as auditor.aleo/take_snapshot.future;
    await r0;
    await r1;
    await r2;
    await r3;
    await r4;
    contains auditor.aleo/last_snapshot__[false] into r5;
    cast 0u64 0u32 false into r6 as auditor.aleo/Snapshot;
    get.or_use auditor.aleo/last_snapshot__[false] r6 into r7;
    cast 0u64 0u32 false into r8 as auditor.aleo/Snapshot;
    ternary r5 r7.balance r8.balance into r9;
    ternary r5 r7.deposit_count r8.deposit_count into r10;
    ternary r5 r7.is_frozen r8.is_frozen into r11;
    cast r9 r10 r11 into r12 as auditor.aleo/Snapshot;
    cast r5 r12 into r13 as Optional__DQLgKQ6OK1W;
    assert.eq r13.is_some true;
    is.eq r13.val.is_frozen false into r14;
    assert.eq r14 true;
    contains auditor.aleo/is_alert__[false] into r15;
    get.or_use auditor.aleo/is_alert__[false] false into r16;
    ternary r15 r16 false into r17;
    cast r15 r17 into r18 as Optional__ATAkdHctJwx;
    assert.eq r18.is_some true;
    is.eq r18.val false into r19;
    assert.eq r19 true;

function fee_config_passes_at_default:
    call treasury.aleo/initialize into r0;
    call auditor.aleo/check_fee_config into r1;
    async fee_config_passes_at_default r0 r1 into r2;
    output r2 as test_auditor.aleo/fee_config_passes_at_default.future;

finalize fee_config_passes_at_default:
    input r0 as treasury.aleo/initialize.future;
    input r1 as auditor.aleo/check_fee_config.future;
    await r0;
    await r1;

function fee_config_accepts_low_rate:
    call treasury.aleo/update_config 50u64 1u64 into r0;
    call auditor.aleo/check_fee_config into r1;
    async fee_config_accepts_low_rate r0 r1 into r2;
    output r2 as test_auditor.aleo/fee_config_accepts_low_rate.future;

finalize fee_config_accepts_low_rate:
    input r0 as treasury.aleo/update_config.future;
    input r1 as auditor.aleo/check_fee_config.future;
    await r0;
    await r1;

function fee_config_rejects_high_rate:
    call treasury.aleo/update_config 1500u64 0u64 into r0;
    call auditor.aleo/check_fee_config into r1;
    async fee_config_rejects_high_rate r0 r1 into r2;
    output r2 as test_auditor.aleo/fee_config_rejects_high_rate.future;

finalize fee_config_rejects_high_rate:
    input r0 as treasury.aleo/update_config.future;
    input r1 as auditor.aleo/check_fee_config.future;
    await r0;
    await r1;

function check_fee_config_uses_fallback:
    call auditor.aleo/check_fee_config into r0;
    async check_fee_config_uses_fallback r0 into r1;
    output r1 as test_auditor.aleo/check_fee_config_uses_fallback.future;

finalize check_fee_config_uses_fallback:
    input r0 as auditor.aleo/check_fee_config.future;
    await r0;

function check_deposits_after_deposit:
    call treasury.aleo/deposit 1000u64 into r0;
    call auditor.aleo/check_deposits into r1;
    async check_deposits_after_deposit r0 r1 into r2;
    output r2 as test_auditor.aleo/check_deposits_after_deposit.future;

finalize check_deposits_after_deposit:
    input r0 as treasury.aleo/deposit.future;
    input r1 as auditor.aleo/check_deposits.future;
    await r0;
    await r1;
    get.or_use treasury.aleo/deposit_log__len__[false] 0u32 into r2;
    is.eq r2 1u32 into r3;
    assert.eq r3 true;
    get.or_use treasury.aleo/deposit_log__len__[false] 0u32 into r4;
    lt 0u32 r4 into r5;
    get.or_use treasury.aleo/deposit_log__[0u32] 0u64 into r6;
    ternary r5 r6 0u64 into r7;
    cast r5 r7 into r8 as Optional__DmN5CQ9hzeK;
    assert.eq r8.is_some true;
    is.eq r8.val 1000u64 into r9;
    assert.eq r9 true;

function check_deposits_empty_fails:
    call auditor.aleo/check_deposits into r0;
    async check_deposits_empty_fails r0 into r1;
    output r1 as test_auditor.aleo/check_deposits_empty_fails.future;

finalize check_deposits_empty_fails:
    input r0 as auditor.aleo/check_deposits.future;
    await r0;

constructor:
    assert.eq edition 0u16;
