import treasury.aleo;
program auditor.aleo;

struct Snapshot:
    balance as u64;
    deposit_count as u32;
    is_frozen as boolean;

struct Optional__DOnC9eGtnsJ:
    is_some as boolean;
    val as u64;

struct Optional__EsDmm5O6sv6:
    is_some as boolean;
    val as u32;

struct Optional__DbbQYuLaHdi:
    is_some as boolean;
    val as boolean;

struct Optional__BTjRu7uI1vR:
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
    cast true r1 into r2 as Optional__DOnC9eGtnsJ;
    cast false 0u64 into r3 as Optional__DOnC9eGtnsJ;
    ternary r0 r2.is_some r3.is_some into r4;
    ternary r0 r2.val r3.val into r5;
    cast r4 r5 into r6 as Optional__DOnC9eGtnsJ;
    contains treasury.aleo/balance__[false] into r7;
    get.or_use treasury.aleo/balance__[false] 0u64 into r8;
    cast true r8 into r9 as Optional__DOnC9eGtnsJ;
    cast false 0u64 into r10 as Optional__DOnC9eGtnsJ;
    ternary r7 r9.is_some r10.is_some into r11;
    ternary r7 r9.val r10.val into r12;
    cast r11 r12 into r13 as Optional__DOnC9eGtnsJ;
    ternary r6.is_some r13.val 0u64 into r14;
    contains treasury.aleo/deposit_count__[false] into r15;
    get.or_use treasury.aleo/deposit_count__[false] 0u32 into r16;
    cast true r16 into r17 as Optional__EsDmm5O6sv6;
    cast false 0u32 into r18 as Optional__EsDmm5O6sv6;
    ternary r15 r17.is_some r18.is_some into r19;
    ternary r15 r17.val r18.val into r20;
    cast r19 r20 into r21 as Optional__EsDmm5O6sv6;
    contains treasury.aleo/deposit_count__[false] into r22;
    get.or_use treasury.aleo/deposit_count__[false] 0u32 into r23;
    cast true r23 into r24 as Optional__EsDmm5O6sv6;
    cast false 0u32 into r25 as Optional__EsDmm5O6sv6;
    ternary r22 r24.is_some r25.is_some into r26;
    ternary r22 r24.val r25.val into r27;
    cast r26 r27 into r28 as Optional__EsDmm5O6sv6;
    ternary r21.is_some r28.val 0u32 into r29;
    contains treasury.aleo/is_frozen__[false] into r30;
    get.or_use treasury.aleo/is_frozen__[false] false into r31;
    cast true r31 into r32 as Optional__DbbQYuLaHdi;
    cast false false into r33 as Optional__DbbQYuLaHdi;
    ternary r30 r32.is_some r33.is_some into r34;
    ternary r30 r32.val r33.val into r35;
    cast r34 r35 into r36 as Optional__DbbQYuLaHdi;
    contains treasury.aleo/is_frozen__[false] into r37;
    get.or_use treasury.aleo/is_frozen__[false] false into r38;
    cast true r38 into r39 as Optional__DbbQYuLaHdi;
    cast false false into r40 as Optional__DbbQYuLaHdi;
    ternary r37 r39.is_some r40.is_some into r41;
    ternary r37 r39.val r40.val into r42;
    cast r41 r42 into r43 as Optional__DbbQYuLaHdi;
    ternary r36.is_some r43.val false into r44;
    cast r14 r29 r44 into r45 as Snapshot;
    set r45 into last_snapshot__[false];
    set r44 into is_alert__[false];

function check_fee_config:
    async check_fee_config into r0;
    output r0 as auditor.aleo/check_fee_config.future;

finalize check_fee_config:
    contains treasury.aleo/config__[false] into r0;
    cast 0u64 0u64 into r1 as treasury.aleo/FeeConfig;
    get.or_use treasury.aleo/config__[false] r1 into r2;
    cast true r2 into r3 as Optional__BTjRu7uI1vR;
    cast 0u64 0u64 into r4 as treasury.aleo/FeeConfig;
    cast false r4 into r5 as Optional__BTjRu7uI1vR;
    ternary r0 r3.val.rate r5.val.rate into r6;
    ternary r0 r3.val.minimum r5.val.minimum into r7;
    cast r6 r7 into r8 as treasury.aleo/FeeConfig;
    ternary r0 r3.is_some r5.is_some into r9;
    cast r9 r8 into r10 as Optional__BTjRu7uI1vR;
    contains treasury.aleo/config__[false] into r11;
    cast 0u64 0u64 into r12 as treasury.aleo/FeeConfig;
    get.or_use treasury.aleo/config__[false] r12 into r13;
    cast true r13 into r14 as Optional__BTjRu7uI1vR;
    cast 0u64 0u64 into r15 as treasury.aleo/FeeConfig;
    cast false r15 into r16 as Optional__BTjRu7uI1vR;
    ternary r11 r14.val.rate r16.val.rate into r17;
    ternary r11 r14.val.minimum r16.val.minimum into r18;
    cast r17 r18 into r19 as treasury.aleo/FeeConfig;
    ternary r11 r14.is_some r16.is_some into r20;
    cast r20 r19 into r21 as Optional__BTjRu7uI1vR;
    cast 0u64 0u64 into r22 as treasury.aleo/FeeConfig;
    ternary r10.is_some r21.val.rate r22.rate into r23;
    ternary r10.is_some r21.val.minimum r22.minimum into r24;
    cast r23 r24 into r25 as treasury.aleo/FeeConfig;
    lte r25.rate 1000u64 into r26;
    assert.eq r26 true;

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
    cast true r4 into r5 as Optional__DOnC9eGtnsJ;
    cast false 0u64 into r6 as Optional__DOnC9eGtnsJ;
    ternary r3 r5.is_some r6.is_some into r7;
    ternary r3 r5.val r6.val into r8;
    cast r7 r8 into r9 as Optional__DOnC9eGtnsJ;
    cast false 0u64 into r10 as Optional__DOnC9eGtnsJ;
    is.neq r9 r10 into r11;
    assert.eq r11 true;

constructor:
    assert.eq edition 0u16;
