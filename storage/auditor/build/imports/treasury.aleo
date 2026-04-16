program treasury.aleo;

struct FeeConfig:
    rate as u64;
    minimum as u64;

struct Optional__DbbQYuLaHdi:
    is_some as boolean;
    val as boolean;

struct Optional__DOnC9eGtnsJ:
    is_some as boolean;
    val as u64;

struct Optional__EsDmm5O6sv6:
    is_some as boolean;
    val as u32;

mapping balance__:
    key as boolean.public;
    value as u64.public;

mapping is_frozen__:
    key as boolean.public;
    value as boolean.public;

mapping deposit_count__:
    key as boolean.public;
    value as u32.public;

mapping config__:
    key as boolean.public;
    value as FeeConfig.public;

mapping deposit_log__:
    key as u32.public;
    value as u64.public;

mapping deposit_log__len__:
    key as boolean.public;
    value as u32.public;

function initialize:
    async initialize into r0;
    output r0 as treasury.aleo/initialize.future;

finalize initialize:
    set 0u64 into balance__[false];
    set false into is_frozen__[false];
    set 0u32 into deposit_count__[false];
    cast 250u64 10u64 into r0 as FeeConfig;
    set r0 into config__[false];

function deposit:
    input r0 as u64.private;
    async deposit r0 into r1;
    output r1 as treasury.aleo/deposit.future;

finalize deposit:
    input r0 as u64.public;
    contains is_frozen__[false] into r1;
    get.or_use is_frozen__[false] false into r2;
    cast true r2 into r3 as Optional__DbbQYuLaHdi;
    cast false false into r4 as Optional__DbbQYuLaHdi;
    ternary r1 r3.is_some r4.is_some into r5;
    ternary r1 r3.val r4.val into r6;
    cast r5 r6 into r7 as Optional__DbbQYuLaHdi;
    contains is_frozen__[false] into r8;
    get.or_use is_frozen__[false] false into r9;
    cast true r9 into r10 as Optional__DbbQYuLaHdi;
    cast false false into r11 as Optional__DbbQYuLaHdi;
    ternary r8 r10.is_some r11.is_some into r12;
    ternary r8 r10.val r11.val into r13;
    cast r12 r13 into r14 as Optional__DbbQYuLaHdi;
    ternary r7.is_some r14.val false into r15;
    is.eq r15 false into r16;
    assert.eq r16 true;
    contains balance__[false] into r17;
    get.or_use balance__[false] 0u64 into r18;
    cast true r18 into r19 as Optional__DOnC9eGtnsJ;
    cast false 0u64 into r20 as Optional__DOnC9eGtnsJ;
    ternary r17 r19.is_some r20.is_some into r21;
    ternary r17 r19.val r20.val into r22;
    cast r21 r22 into r23 as Optional__DOnC9eGtnsJ;
    contains balance__[false] into r24;
    get.or_use balance__[false] 0u64 into r25;
    cast true r25 into r26 as Optional__DOnC9eGtnsJ;
    cast false 0u64 into r27 as Optional__DOnC9eGtnsJ;
    ternary r24 r26.is_some r27.is_some into r28;
    ternary r24 r26.val r27.val into r29;
    cast r28 r29 into r30 as Optional__DOnC9eGtnsJ;
    ternary r23.is_some r30.val 0u64 into r31;
    add r31 r0 into r32;
    set r32 into balance__[false];
    contains deposit_count__[false] into r33;
    get.or_use deposit_count__[false] 0u32 into r34;
    cast true r34 into r35 as Optional__EsDmm5O6sv6;
    cast false 0u32 into r36 as Optional__EsDmm5O6sv6;
    ternary r33 r35.is_some r36.is_some into r37;
    ternary r33 r35.val r36.val into r38;
    cast r37 r38 into r39 as Optional__EsDmm5O6sv6;
    contains deposit_count__[false] into r40;
    get.or_use deposit_count__[false] 0u32 into r41;
    cast true r41 into r42 as Optional__EsDmm5O6sv6;
    cast false 0u32 into r43 as Optional__EsDmm5O6sv6;
    ternary r40 r42.is_some r43.is_some into r44;
    ternary r40 r42.val r43.val into r45;
    cast r44 r45 into r46 as Optional__EsDmm5O6sv6;
    ternary r39.is_some r46.val 0u32 into r47;
    add r47 1u32 into r48;
    set r48 into deposit_count__[false];
    get.or_use deposit_log__len__[false] 0u32 into r49;
    add r49 1u32 into r50;
    set r50 into deposit_log__len__[false];
    set r0 into deposit_log__[r49];

function withdraw:
    input r0 as u64.private;
    async withdraw r0 into r1;
    output r1 as treasury.aleo/withdraw.future;

finalize withdraw:
    input r0 as u64.public;
    contains is_frozen__[false] into r1;
    get.or_use is_frozen__[false] false into r2;
    cast true r2 into r3 as Optional__DbbQYuLaHdi;
    cast false false into r4 as Optional__DbbQYuLaHdi;
    ternary r1 r3.is_some r4.is_some into r5;
    ternary r1 r3.val r4.val into r6;
    cast r5 r6 into r7 as Optional__DbbQYuLaHdi;
    contains is_frozen__[false] into r8;
    get.or_use is_frozen__[false] false into r9;
    cast true r9 into r10 as Optional__DbbQYuLaHdi;
    cast false false into r11 as Optional__DbbQYuLaHdi;
    ternary r8 r10.is_some r11.is_some into r12;
    ternary r8 r10.val r11.val into r13;
    cast r12 r13 into r14 as Optional__DbbQYuLaHdi;
    ternary r7.is_some r14.val false into r15;
    is.eq r15 false into r16;
    assert.eq r16 true;
    contains balance__[false] into r17;
    get.or_use balance__[false] 0u64 into r18;
    cast true r18 into r19 as Optional__DOnC9eGtnsJ;
    cast false 0u64 into r20 as Optional__DOnC9eGtnsJ;
    ternary r17 r19.is_some r20.is_some into r21;
    ternary r17 r19.val r20.val into r22;
    cast r21 r22 into r23 as Optional__DOnC9eGtnsJ;
    assert.eq r23.is_some true;
    contains balance__[false] into r24;
    get.or_use balance__[false] 0u64 into r25;
    cast true r25 into r26 as Optional__DOnC9eGtnsJ;
    cast false 0u64 into r27 as Optional__DOnC9eGtnsJ;
    ternary r24 r26.is_some r27.is_some into r28;
    ternary r24 r26.val r27.val into r29;
    cast r28 r29 into r30 as Optional__DOnC9eGtnsJ;
    gte r30.val r0 into r31;
    assert.eq r31 true;
    sub r30.val r0 into r32;
    set r32 into balance__[false];

function freeze:
    async freeze into r0;
    output r0 as treasury.aleo/freeze.future;

finalize freeze:
    set true into is_frozen__[false];

function unfreeze:
    async unfreeze into r0;
    output r0 as treasury.aleo/unfreeze.future;

finalize unfreeze:
    set false into is_frozen__[false];

function update_config:
    input r0 as u64.private;
    input r1 as u64.private;
    async update_config r0 r1 into r2;
    output r2 as treasury.aleo/update_config.future;

finalize update_config:
    input r0 as u64.public;
    input r1 as u64.public;
    cast r0 r1 into r2 as FeeConfig;
    set r2 into config__[false];

function pop_last_deposit:
    async pop_last_deposit into r0;
    output r0 as treasury.aleo/pop_last_deposit.future;

finalize pop_last_deposit:
    get.or_use deposit_log__len__[false] 0u32 into r0;
    gt r0 0u32 into r1;
    sub.w r0 1u32 into r2;
    ternary r1 r2 r0 into r3;
    set r3 into deposit_log__len__[false];
    get.or_use deposit_log__[r2] 0u64 into r4;
    cast true r4 into r5 as Optional__DOnC9eGtnsJ;
    cast false 0u64 into r6 as Optional__DOnC9eGtnsJ;
    ternary r1 r5.is_some r6.is_some into r7;
    ternary r1 r5.val r6.val into r8;
    cast r7 r8 into r9 as Optional__DOnC9eGtnsJ;
    cast false 0u64 into r10 as Optional__DOnC9eGtnsJ;
    is.neq r9 r10 into r11;
    assert.eq r11 true;

function reset:
    async reset into r0;
    output r0 as treasury.aleo/reset.future;

finalize reset:
    remove balance__[false];
    remove is_frozen__[false];
    remove deposit_count__[false];
    remove config__[false];
    set 0u32 into deposit_log__len__[false];

constructor:
    assert.eq edition 0u16;
