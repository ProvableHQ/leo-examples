import treasury.aleo;
program auditor.aleo;

struct Snapshot:
    balance as u64;
    deposit_count as u32;
    is_frozen as boolean;

struct Optional__DmN5CQ9hzeK:
    is_some as boolean;
    val as u64;

struct Optional__JzunLORyB8U:
    is_some as boolean;
    val as u32;

struct Optional__ATAkdHctJwx:
    is_some as boolean;
    val as boolean;

struct Optional__HgFNdm7FG0G:
    is_some as boolean;
    val as treasury.aleo/FeeConfig;

mapping last_snapshot__:
    key as boolean.public;
    value as Snapshot.public;

mapping is_alert__:
    key as boolean.public;
    value as boolean.public;

function take_snapshot:
    async take_snapshot into r0;
    output r0 as auditor.aleo/take_snapshot.future;

finalize take_snapshot:
    contains treasury.aleo/balance__[false] into r0;
    get.or_use treasury.aleo/balance__[false] 0u64 into r1;
    ternary r0 r1 0u64 into r2;
    cast r0 r2 into r3 as Optional__DmN5CQ9hzeK;
    ternary r3.is_some r3.val 0u64 into r4;
    contains treasury.aleo/deposit_count__[false] into r5;
    get.or_use treasury.aleo/deposit_count__[false] 0u32 into r6;
    ternary r5 r6 0u32 into r7;
    cast r5 r7 into r8 as Optional__JzunLORyB8U;
    ternary r8.is_some r8.val 0u32 into r9;
    contains treasury.aleo/is_frozen__[false] into r10;
    get.or_use treasury.aleo/is_frozen__[false] false into r11;
    ternary r10 r11 false into r12;
    cast r10 r12 into r13 as Optional__ATAkdHctJwx;
    ternary r13.is_some r13.val false into r14;
    cast r4 r9 r14 into r15 as Snapshot;
    set r15 into last_snapshot__[false];
    set r14 into is_alert__[false];

function check_fee_config:
    async check_fee_config into r0;
    output r0 as auditor.aleo/check_fee_config.future;

finalize check_fee_config:
    contains treasury.aleo/config__[false] into r0;
    cast 0u64 0u64 into r1 as treasury.aleo/FeeConfig;
    get.or_use treasury.aleo/config__[false] r1 into r2;
    cast 0u64 0u64 into r3 as treasury.aleo/FeeConfig;
    ternary r0 r2.rate r3.rate into r4;
    ternary r0 r2.minimum r3.minimum into r5;
    cast r4 r5 into r6 as treasury.aleo/FeeConfig;
    cast r0 r6 into r7 as Optional__HgFNdm7FG0G;
    ternary r7.is_some r7.val.rate 0u64 into r8;
    ternary r7.is_some r7.val.minimum 0u64 into r9;
    cast r8 r9 into r10 as treasury.aleo/FeeConfig;
    lte r10.rate 1000u64 into r11;
    assert.eq r11 true;

function check_deposits:
    async check_deposits into r0;
    output r0 as auditor.aleo/check_deposits.future;

finalize check_deposits:
    get.or_use treasury.aleo/deposit_log__len__[false] 0u32 into r0;
    gt r0 0u32 into r1;
    assert.eq r1 true;
    get.or_use treasury.aleo/deposit_log__len__[false] 0u32 into r2;
    lt 0u32 r2 into r3;
    get.or_use treasury.aleo/deposit_log__[0u32] 0u64 into r4;
    ternary r3 r4 0u64 into r5;
    cast r3 r5 into r6 as Optional__DmN5CQ9hzeK;
    cast false 0u64 into r7 as Optional__DmN5CQ9hzeK;
    is.neq r6 r7 into r8;
    assert.eq r8 true;

constructor:
    assert.eq edition 0u16;
