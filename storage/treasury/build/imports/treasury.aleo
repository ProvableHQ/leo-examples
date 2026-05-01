program treasury.aleo;

struct FeeConfig:
    rate as u64;
    minimum as u64;

struct Optional__ATAkdHctJwx:
    is_some as boolean;
    val as boolean;

struct Optional__DmN5CQ9hzeK:
    is_some as boolean;
    val as u64;

struct Optional__JzunLORyB8U:
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
    ternary r1 r2 false into r3;
    cast r1 r3 into r4 as Optional__ATAkdHctJwx;
    ternary r4.is_some r4.val false into r5;
    is.eq r5 false into r6;
    assert.eq r6 true;
    contains balance__[false] into r7;
    get.or_use balance__[false] 0u64 into r8;
    ternary r7 r8 0u64 into r9;
    cast r7 r9 into r10 as Optional__DmN5CQ9hzeK;
    ternary r10.is_some r10.val 0u64 into r11;
    add r11 r0 into r12;
    set r12 into balance__[false];
    contains deposit_count__[false] into r13;
    get.or_use deposit_count__[false] 0u32 into r14;
    ternary r13 r14 0u32 into r15;
    cast r13 r15 into r16 as Optional__JzunLORyB8U;
    ternary r16.is_some r16.val 0u32 into r17;
    add r17 1u32 into r18;
    set r18 into deposit_count__[false];
    get.or_use deposit_log__len__[false] 0u32 into r19;
    add r19 1u32 into r20;
    set r20 into deposit_log__len__[false];
    set r0 into deposit_log__[r19];

function withdraw:
    input r0 as u64.private;
    async withdraw r0 into r1;
    output r1 as treasury.aleo/withdraw.future;

finalize withdraw:
    input r0 as u64.public;
    contains is_frozen__[false] into r1;
    get.or_use is_frozen__[false] false into r2;
    ternary r1 r2 false into r3;
    cast r1 r3 into r4 as Optional__ATAkdHctJwx;
    ternary r4.is_some r4.val false into r5;
    is.eq r5 false into r6;
    assert.eq r6 true;
    contains balance__[false] into r7;
    get.or_use balance__[false] 0u64 into r8;
    ternary r7 r8 0u64 into r9;
    cast r7 r9 into r10 as Optional__DmN5CQ9hzeK;
    assert.eq r10.is_some true;
    gte r10.val r0 into r11;
    assert.eq r11 true;
    sub r10.val r0 into r12;
    set r12 into balance__[false];

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

function undo_last_deposit:
    async undo_last_deposit into r0;
    output r0 as treasury.aleo/undo_last_deposit.future;

finalize undo_last_deposit:
    get.or_use deposit_log__len__[false] 0u32 into r0;
    gt r0 0u32 into r1;
    sub.w r0 1u32 into r2;
    ternary r1 r2 r0 into r3;
    set r3 into deposit_log__len__[false];
    get.or_use deposit_log__[r2] 0u64 into r4;
    ternary r1 r4 0u64 into r5;
    cast r1 r5 into r6 as Optional__DmN5CQ9hzeK;
    cast false 0u64 into r7 as Optional__DmN5CQ9hzeK;
    is.neq r6 r7 into r8;
    assert.eq r8 true;
    contains balance__[false] into r9;
    get.or_use balance__[false] 0u64 into r10;
    ternary r9 r10 0u64 into r11;
    cast r9 r11 into r12 as Optional__DmN5CQ9hzeK;
    assert.eq r6.is_some true;
    ternary r12.is_some r12.val 0u64 into r13;
    sub r13 r6.val into r14;
    set r14 into balance__[false];
    contains deposit_count__[false] into r15;
    get.or_use deposit_count__[false] 0u32 into r16;
    ternary r15 r16 0u32 into r17;
    cast r15 r17 into r18 as Optional__JzunLORyB8U;
    ternary r18.is_some r18.val 0u32 into r19;
    sub r19 1u32 into r20;
    set r20 into deposit_count__[false];

function correct_deposit:
    input r0 as u32.private;
    input r1 as u64.private;
    async correct_deposit r0 r1 into r2;
    output r2 as treasury.aleo/correct_deposit.future;

finalize correct_deposit:
    input r0 as u32.public;
    input r1 as u64.public;
    get.or_use deposit_log__len__[false] 0u32 into r2;
    lt r0 r2 into r3;
    get.or_use deposit_log__[r0] 0u64 into r4;
    ternary r3 r4 0u64 into r5;
    cast r3 r5 into r6 as Optional__DmN5CQ9hzeK;
    assert.eq r6.is_some true;
    get.or_use deposit_log__len__[false] 0u32 into r7;
    lt r0 r7 into r8;
    assert.eq r8 true;
    set r1 into deposit_log__[r0];
    contains balance__[false] into r9;
    get.or_use balance__[false] 0u64 into r10;
    ternary r9 r10 0u64 into r11;
    cast r9 r11 into r12 as Optional__DmN5CQ9hzeK;
    ternary r12.is_some r12.val 0u64 into r13;
    add r13 r1 into r14;
    sub r14 r6.val into r15;
    set r15 into balance__[false];

function drop_deposit:
    input r0 as u32.private;
    async drop_deposit r0 into r1;
    output r1 as treasury.aleo/drop_deposit.future;

finalize drop_deposit:
    input r0 as u32.public;
    get.or_use deposit_log__len__[false] 0u32 into r1;
    lt r0 r1 into r2;
    assert.eq r2 true;
    get deposit_log__[r0] into r3;
    sub r1 1u32 into r4;
    get deposit_log__[r4] into r5;
    set r5 into deposit_log__[r0];
    set r4 into deposit_log__len__[false];
    contains balance__[false] into r6;
    get.or_use balance__[false] 0u64 into r7;
    ternary r6 r7 0u64 into r8;
    cast r6 r8 into r9 as Optional__DmN5CQ9hzeK;
    ternary r9.is_some r9.val 0u64 into r10;
    sub r10 r3 into r11;
    set r11 into balance__[false];
    contains deposit_count__[false] into r12;
    get.or_use deposit_count__[false] 0u32 into r13;
    ternary r12 r13 0u32 into r14;
    cast r12 r14 into r15 as Optional__JzunLORyB8U;
    ternary r15.is_some r15.val 0u32 into r16;
    sub r16 1u32 into r17;
    set r17 into deposit_count__[false];

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
