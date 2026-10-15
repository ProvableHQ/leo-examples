import treasury.aleo;
program test_treasury.aleo;

struct Optional__DmN5CQ9hzeK:
    is_some as boolean;
    val as u64;

struct Optional__ATAkdHctJwx:
    is_some as boolean;
    val as boolean;

struct Optional__JzunLORyB8U:
    is_some as boolean;
    val as u32;

struct Optional__HgFNdm7FG0G:
    is_some as boolean;
    val as treasury.aleo/FeeConfig;

function unset_storage_reads_as_none:
    async unset_storage_reads_as_none into r0;
    output r0 as test_treasury.aleo/unset_storage_reads_as_none.future;

finalize unset_storage_reads_as_none:
    contains treasury.aleo/balance__[false] into r0;
    get.or_use treasury.aleo/balance__[false] 0u64 into r1;
    ternary r0 r1 0u64 into r2;
    cast r0 r2 into r3 as Optional__DmN5CQ9hzeK;
    ternary r3.is_some r3.val 0u64 into r4;
    is.eq r4 0u64 into r5;
    assert.eq r5 true;
    contains treasury.aleo/is_frozen__[false] into r6;
    get.or_use treasury.aleo/is_frozen__[false] false into r7;
    ternary r6 r7 false into r8;
    cast r6 r8 into r9 as Optional__ATAkdHctJwx;
    ternary r9.is_some r9.val false into r10;
    is.eq r10 false into r11;
    assert.eq r11 true;
    contains treasury.aleo/deposit_count__[false] into r12;
    get.or_use treasury.aleo/deposit_count__[false] 0u32 into r13;
    ternary r12 r13 0u32 into r14;
    cast r12 r14 into r15 as Optional__JzunLORyB8U;
    ternary r15.is_some r15.val 0u32 into r16;
    is.eq r16 0u32 into r17;
    assert.eq r17 true;
    get.or_use treasury.aleo/deposit_log__len__[false] 0u32 into r18;
    is.eq r18 0u32 into r19;
    assert.eq r19 true;

function initialize_sets_state:
    call treasury.aleo/initialize into r0;
    async initialize_sets_state r0 into r1;
    output r1 as test_treasury.aleo/initialize_sets_state.future;

finalize initialize_sets_state:
    input r0 as treasury.aleo/initialize.future;
    await r0;
    contains treasury.aleo/balance__[false] into r1;
    get.or_use treasury.aleo/balance__[false] 0u64 into r2;
    ternary r1 r2 0u64 into r3;
    cast r1 r3 into r4 as Optional__DmN5CQ9hzeK;
    assert.eq r4.is_some true;
    is.eq r4.val 0u64 into r5;
    assert.eq r5 true;
    contains treasury.aleo/is_frozen__[false] into r6;
    get.or_use treasury.aleo/is_frozen__[false] false into r7;
    ternary r6 r7 false into r8;
    cast r6 r8 into r9 as Optional__ATAkdHctJwx;
    assert.eq r9.is_some true;
    is.eq r9.val false into r10;
    assert.eq r10 true;
    contains treasury.aleo/deposit_count__[false] into r11;
    get.or_use treasury.aleo/deposit_count__[false] 0u32 into r12;
    ternary r11 r12 0u32 into r13;
    cast r11 r13 into r14 as Optional__JzunLORyB8U;
    assert.eq r14.is_some true;
    is.eq r14.val 0u32 into r15;
    assert.eq r15 true;
    contains treasury.aleo/config__[false] into r16;
    cast 0u64 0u64 into r17 as treasury.aleo/FeeConfig;
    get.or_use treasury.aleo/config__[false] r17 into r18;
    cast 0u64 0u64 into r19 as treasury.aleo/FeeConfig;
    ternary r16 r18.rate r19.rate into r20;
    ternary r16 r18.minimum r19.minimum into r21;
    cast r20 r21 into r22 as treasury.aleo/FeeConfig;
    cast r16 r22 into r23 as Optional__HgFNdm7FG0G;
    assert.eq r23.is_some true;
    is.eq r23.val.rate 250u64 into r24;
    assert.eq r24 true;
    is.eq r23.val.minimum 10u64 into r25;
    assert.eq r25 true;

function deposit_accumulates_state:
    call treasury.aleo/initialize into r0;
    call treasury.aleo/deposit 5000u64 into r1;
    call treasury.aleo/deposit 3000u64 into r2;
    async deposit_accumulates_state r0 r1 r2 into r3;
    output r3 as test_treasury.aleo/deposit_accumulates_state.future;

finalize deposit_accumulates_state:
    input r0 as treasury.aleo/initialize.future;
    input r1 as treasury.aleo/deposit.future;
    input r2 as treasury.aleo/deposit.future;
    await r0;
    await r1;
    await r2;
    contains treasury.aleo/balance__[false] into r3;
    get.or_use treasury.aleo/balance__[false] 0u64 into r4;
    ternary r3 r4 0u64 into r5;
    cast r3 r5 into r6 as Optional__DmN5CQ9hzeK;
    assert.eq r6.is_some true;
    is.eq r6.val 8000u64 into r7;
    assert.eq r7 true;
    contains treasury.aleo/deposit_count__[false] into r8;
    get.or_use treasury.aleo/deposit_count__[false] 0u32 into r9;
    ternary r8 r9 0u32 into r10;
    cast r8 r10 into r11 as Optional__JzunLORyB8U;
    assert.eq r11.is_some true;
    is.eq r11.val 2u32 into r12;
    assert.eq r12 true;
    get.or_use treasury.aleo/deposit_log__len__[false] 0u32 into r13;
    is.eq r13 2u32 into r14;
    assert.eq r14 true;
    get.or_use treasury.aleo/deposit_log__len__[false] 0u32 into r15;
    lt 0u32 r15 into r16;
    get.or_use treasury.aleo/deposit_log__[0u32] 0u64 into r17;
    ternary r16 r17 0u64 into r18;
    cast r16 r18 into r19 as Optional__DmN5CQ9hzeK;
    assert.eq r19.is_some true;
    is.eq r19.val 5000u64 into r20;
    assert.eq r20 true;
    get.or_use treasury.aleo/deposit_log__len__[false] 0u32 into r21;
    lt 1u32 r21 into r22;
    get.or_use treasury.aleo/deposit_log__[1u32] 0u64 into r23;
    ternary r22 r23 0u64 into r24;
    cast r22 r24 into r25 as Optional__DmN5CQ9hzeK;
    assert.eq r25.is_some true;
    is.eq r25.val 3000u64 into r26;
    assert.eq r26 true;

function deposit_without_initialize:
    call treasury.aleo/deposit 100u64 into r0;
    async deposit_without_initialize r0 into r1;
    output r1 as test_treasury.aleo/deposit_without_initialize.future;

finalize deposit_without_initialize:
    input r0 as treasury.aleo/deposit.future;
    await r0;
    contains treasury.aleo/balance__[false] into r1;
    get.or_use treasury.aleo/balance__[false] 0u64 into r2;
    ternary r1 r2 0u64 into r3;
    cast r1 r3 into r4 as Optional__DmN5CQ9hzeK;
    assert.eq r4.is_some true;
    is.eq r4.val 100u64 into r5;
    assert.eq r5 true;
    contains treasury.aleo/deposit_count__[false] into r6;
    get.or_use treasury.aleo/deposit_count__[false] 0u32 into r7;
    ternary r6 r7 0u32 into r8;
    cast r6 r8 into r9 as Optional__JzunLORyB8U;
    assert.eq r9.is_some true;
    is.eq r9.val 1u32 into r10;
    assert.eq r10 true;
    get.or_use treasury.aleo/deposit_log__len__[false] 0u32 into r11;
    is.eq r11 1u32 into r12;
    assert.eq r12 true;

function withdraw_reduces_balance:
    call treasury.aleo/initialize into r0;
    call treasury.aleo/deposit 5000u64 into r1;
    call treasury.aleo/withdraw 1500u64 into r2;
    async withdraw_reduces_balance r0 r1 r2 into r3;
    output r3 as test_treasury.aleo/withdraw_reduces_balance.future;

finalize withdraw_reduces_balance:
    input r0 as treasury.aleo/initialize.future;
    input r1 as treasury.aleo/deposit.future;
    input r2 as treasury.aleo/withdraw.future;
    await r0;
    await r1;
    await r2;
    contains treasury.aleo/balance__[false] into r3;
    get.or_use treasury.aleo/balance__[false] 0u64 into r4;
    ternary r3 r4 0u64 into r5;
    cast r3 r5 into r6 as Optional__DmN5CQ9hzeK;
    assert.eq r6.is_some true;
    is.eq r6.val 3500u64 into r7;
    assert.eq r7 true;
    get.or_use treasury.aleo/deposit_log__len__[false] 0u32 into r8;
    is.eq r8 1u32 into r9;
    assert.eq r9 true;

function overdraw_fails:
    call treasury.aleo/initialize into r0;
    call treasury.aleo/deposit 100u64 into r1;
    call treasury.aleo/withdraw 101u64 into r2;
    async overdraw_fails r0 r1 r2 into r3;
    output r3 as test_treasury.aleo/overdraw_fails.future;

finalize overdraw_fails:
    input r0 as treasury.aleo/initialize.future;
    input r1 as treasury.aleo/deposit.future;
    input r2 as treasury.aleo/withdraw.future;
    await r0;
    await r1;
    await r2;

function withdraw_without_balance_fails:
    call treasury.aleo/withdraw 1u64 into r0;
    async withdraw_without_balance_fails r0 into r1;
    output r1 as test_treasury.aleo/withdraw_without_balance_fails.future;

finalize withdraw_without_balance_fails:
    input r0 as treasury.aleo/withdraw.future;
    await r0;

function freeze_blocks_deposit:
    call treasury.aleo/initialize into r0;
    call treasury.aleo/freeze into r1;
    call treasury.aleo/deposit 100u64 into r2;
    async freeze_blocks_deposit r0 r1 r2 into r3;
    output r3 as test_treasury.aleo/freeze_blocks_deposit.future;

finalize freeze_blocks_deposit:
    input r0 as treasury.aleo/initialize.future;
    input r1 as treasury.aleo/freeze.future;
    input r2 as treasury.aleo/deposit.future;
    await r0;
    await r1;
    await r2;

function freeze_blocks_withdraw:
    call treasury.aleo/initialize into r0;
    call treasury.aleo/deposit 500u64 into r1;
    call treasury.aleo/freeze into r2;
    call treasury.aleo/withdraw 100u64 into r3;
    async freeze_blocks_withdraw r0 r1 r2 r3 into r4;
    output r4 as test_treasury.aleo/freeze_blocks_withdraw.future;

finalize freeze_blocks_withdraw:
    input r0 as treasury.aleo/initialize.future;
    input r1 as treasury.aleo/deposit.future;
    input r2 as treasury.aleo/freeze.future;
    input r3 as treasury.aleo/withdraw.future;
    await r0;
    await r1;
    await r2;
    await r3;

function unfreeze_restores_deposits:
    call treasury.aleo/initialize into r0;
    call treasury.aleo/freeze into r1;
    call treasury.aleo/unfreeze into r2;
    call treasury.aleo/deposit 42u64 into r3;
    async unfreeze_restores_deposits r0 r1 r2 r3 into r4;
    output r4 as test_treasury.aleo/unfreeze_restores_deposits.future;

finalize unfreeze_restores_deposits:
    input r0 as treasury.aleo/initialize.future;
    input r1 as treasury.aleo/freeze.future;
    input r2 as treasury.aleo/unfreeze.future;
    input r3 as treasury.aleo/deposit.future;
    await r0;
    await r1;
    await r2;
    await r3;
    contains treasury.aleo/is_frozen__[false] into r4;
    get.or_use treasury.aleo/is_frozen__[false] false into r5;
    ternary r4 r5 false into r6;
    cast r4 r6 into r7 as Optional__ATAkdHctJwx;
    assert.eq r7.is_some true;
    is.eq r7.val false into r8;
    assert.eq r8 true;
    contains treasury.aleo/balance__[false] into r9;
    get.or_use treasury.aleo/balance__[false] 0u64 into r10;
    ternary r9 r10 0u64 into r11;
    cast r9 r11 into r12 as Optional__DmN5CQ9hzeK;
    assert.eq r12.is_some true;
    is.eq r12.val 42u64 into r13;
    assert.eq r13 true;

function update_config_replaces_struct:
    call treasury.aleo/initialize into r0;
    call treasury.aleo/update_config 500u64 25u64 into r1;
    async update_config_replaces_struct r0 r1 into r2;
    output r2 as test_treasury.aleo/update_config_replaces_struct.future;

finalize update_config_replaces_struct:
    input r0 as treasury.aleo/initialize.future;
    input r1 as treasury.aleo/update_config.future;
    await r0;
    await r1;
    contains treasury.aleo/config__[false] into r2;
    cast 0u64 0u64 into r3 as treasury.aleo/FeeConfig;
    get.or_use treasury.aleo/config__[false] r3 into r4;
    cast 0u64 0u64 into r5 as treasury.aleo/FeeConfig;
    ternary r2 r4.rate r5.rate into r6;
    ternary r2 r4.minimum r5.minimum into r7;
    cast r6 r7 into r8 as treasury.aleo/FeeConfig;
    cast r2 r8 into r9 as Optional__HgFNdm7FG0G;
    assert.eq r9.is_some true;
    is.eq r9.val.rate 500u64 into r10;
    assert.eq r10 true;
    is.eq r9.val.minimum 25u64 into r11;
    assert.eq r11 true;

function undo_last_deposit_reverses:
    call treasury.aleo/deposit 100u64 into r0;
    call treasury.aleo/deposit 250u64 into r1;
    call treasury.aleo/undo_last_deposit into r2;
    async undo_last_deposit_reverses r0 r1 r2 into r3;
    output r3 as test_treasury.aleo/undo_last_deposit_reverses.future;

finalize undo_last_deposit_reverses:
    input r0 as treasury.aleo/deposit.future;
    input r1 as treasury.aleo/deposit.future;
    input r2 as treasury.aleo/undo_last_deposit.future;
    await r0;
    await r1;
    await r2;
    contains treasury.aleo/balance__[false] into r3;
    get.or_use treasury.aleo/balance__[false] 0u64 into r4;
    ternary r3 r4 0u64 into r5;
    cast r3 r5 into r6 as Optional__DmN5CQ9hzeK;
    assert.eq r6.is_some true;
    is.eq r6.val 100u64 into r7;
    assert.eq r7 true;
    contains treasury.aleo/deposit_count__[false] into r8;
    get.or_use treasury.aleo/deposit_count__[false] 0u32 into r9;
    ternary r8 r9 0u32 into r10;
    cast r8 r10 into r11 as Optional__JzunLORyB8U;
    assert.eq r11.is_some true;
    is.eq r11.val 1u32 into r12;
    assert.eq r12 true;
    get.or_use treasury.aleo/deposit_log__len__[false] 0u32 into r13;
    is.eq r13 1u32 into r14;
    assert.eq r14 true;
    get.or_use treasury.aleo/deposit_log__len__[false] 0u32 into r15;
    lt 0u32 r15 into r16;
    get.or_use treasury.aleo/deposit_log__[0u32] 0u64 into r17;
    ternary r16 r17 0u64 into r18;
    cast r16 r18 into r19 as Optional__DmN5CQ9hzeK;
    assert.eq r19.is_some true;
    is.eq r19.val 100u64 into r20;
    assert.eq r20 true;

function undo_on_empty_log_fails:
    call treasury.aleo/undo_last_deposit into r0;
    async undo_on_empty_log_fails r0 into r1;
    output r1 as test_treasury.aleo/undo_on_empty_log_fails.future;

finalize undo_on_empty_log_fails:
    input r0 as treasury.aleo/undo_last_deposit.future;
    await r0;

function correct_deposit_overwrites:
    call treasury.aleo/deposit 100u64 into r0;
    call treasury.aleo/deposit 200u64 into r1;
    call treasury.aleo/correct_deposit 1u32 250u64 into r2;
    async correct_deposit_overwrites r0 r1 r2 into r3;
    output r3 as test_treasury.aleo/correct_deposit_overwrites.future;

finalize correct_deposit_overwrites:
    input r0 as treasury.aleo/deposit.future;
    input r1 as treasury.aleo/deposit.future;
    input r2 as treasury.aleo/correct_deposit.future;
    await r0;
    await r1;
    await r2;
    contains treasury.aleo/balance__[false] into r3;
    get.or_use treasury.aleo/balance__[false] 0u64 into r4;
    ternary r3 r4 0u64 into r5;
    cast r3 r5 into r6 as Optional__DmN5CQ9hzeK;
    assert.eq r6.is_some true;
    is.eq r6.val 350u64 into r7;
    assert.eq r7 true;
    get.or_use treasury.aleo/deposit_log__len__[false] 0u32 into r8;
    lt 1u32 r8 into r9;
    get.or_use treasury.aleo/deposit_log__[1u32] 0u64 into r10;
    ternary r9 r10 0u64 into r11;
    cast r9 r11 into r12 as Optional__DmN5CQ9hzeK;
    assert.eq r12.is_some true;
    is.eq r12.val 250u64 into r13;
    assert.eq r13 true;
    get.or_use treasury.aleo/deposit_log__len__[false] 0u32 into r14;
    is.eq r14 2u32 into r15;
    assert.eq r15 true;

function drop_deposit_swap_removes:
    call treasury.aleo/deposit 10u64 into r0;
    call treasury.aleo/deposit 20u64 into r1;
    call treasury.aleo/deposit 30u64 into r2;
    call treasury.aleo/drop_deposit 0u32 into r3;
    async drop_deposit_swap_removes r0 r1 r2 r3 into r4;
    output r4 as test_treasury.aleo/drop_deposit_swap_removes.future;

finalize drop_deposit_swap_removes:
    input r0 as treasury.aleo/deposit.future;
    input r1 as treasury.aleo/deposit.future;
    input r2 as treasury.aleo/deposit.future;
    input r3 as treasury.aleo/drop_deposit.future;
    await r0;
    await r1;
    await r2;
    await r3;
    contains treasury.aleo/balance__[false] into r4;
    get.or_use treasury.aleo/balance__[false] 0u64 into r5;
    ternary r4 r5 0u64 into r6;
    cast r4 r6 into r7 as Optional__DmN5CQ9hzeK;
    assert.eq r7.is_some true;
    is.eq r7.val 50u64 into r8;
    assert.eq r8 true;
    contains treasury.aleo/deposit_count__[false] into r9;
    get.or_use treasury.aleo/deposit_count__[false] 0u32 into r10;
    ternary r9 r10 0u32 into r11;
    cast r9 r11 into r12 as Optional__JzunLORyB8U;
    assert.eq r12.is_some true;
    is.eq r12.val 2u32 into r13;
    assert.eq r13 true;
    get.or_use treasury.aleo/deposit_log__len__[false] 0u32 into r14;
    is.eq r14 2u32 into r15;
    assert.eq r15 true;
    get.or_use treasury.aleo/deposit_log__len__[false] 0u32 into r16;
    lt 0u32 r16 into r17;
    get.or_use treasury.aleo/deposit_log__[0u32] 0u64 into r18;
    ternary r17 r18 0u64 into r19;
    cast r17 r19 into r20 as Optional__DmN5CQ9hzeK;
    assert.eq r20.is_some true;
    is.eq r20.val 30u64 into r21;
    assert.eq r21 true;
    get.or_use treasury.aleo/deposit_log__len__[false] 0u32 into r22;
    lt 1u32 r22 into r23;
    get.or_use treasury.aleo/deposit_log__[1u32] 0u64 into r24;
    ternary r23 r24 0u64 into r25;
    cast r23 r25 into r26 as Optional__DmN5CQ9hzeK;
    assert.eq r26.is_some true;
    is.eq r26.val 20u64 into r27;
    assert.eq r27 true;

function reset_clears_every_slot:
    call treasury.aleo/initialize into r0;
    call treasury.aleo/deposit 100u64 into r1;
    call treasury.aleo/deposit 200u64 into r2;
    call treasury.aleo/reset into r3;
    async reset_clears_every_slot r0 r1 r2 r3 into r4;
    output r4 as test_treasury.aleo/reset_clears_every_slot.future;

finalize reset_clears_every_slot:
    input r0 as treasury.aleo/initialize.future;
    input r1 as treasury.aleo/deposit.future;
    input r2 as treasury.aleo/deposit.future;
    input r3 as treasury.aleo/reset.future;
    await r0;
    await r1;
    await r2;
    await r3;
    contains treasury.aleo/balance__[false] into r4;
    get.or_use treasury.aleo/balance__[false] 0u64 into r5;
    ternary r4 r5 0u64 into r6;
    cast r4 r6 into r7 as Optional__DmN5CQ9hzeK;
    ternary r7.is_some r7.val 0u64 into r8;
    is.eq r8 0u64 into r9;
    assert.eq r9 true;
    contains treasury.aleo/is_frozen__[false] into r10;
    get.or_use treasury.aleo/is_frozen__[false] false into r11;
    ternary r10 r11 false into r12;
    cast r10 r12 into r13 as Optional__ATAkdHctJwx;
    ternary r13.is_some r13.val false into r14;
    is.eq r14 false into r15;
    assert.eq r15 true;
    contains treasury.aleo/deposit_count__[false] into r16;
    get.or_use treasury.aleo/deposit_count__[false] 0u32 into r17;
    ternary r16 r17 0u32 into r18;
    cast r16 r18 into r19 as Optional__JzunLORyB8U;
    ternary r19.is_some r19.val 0u32 into r20;
    is.eq r20 0u32 into r21;
    assert.eq r21 true;
    get.or_use treasury.aleo/deposit_log__len__[false] 0u32 into r22;
    is.eq r22 0u32 into r23;
    assert.eq r23 true;
    get.or_use treasury.aleo/deposit_log__len__[false] 0u32 into r24;
    lt 0u32 r24 into r25;
    get.or_use treasury.aleo/deposit_log__[0u32] 0u64 into r26;
    ternary r25 r26 0u64 into r27;
    cast r25 r27 into r28 as Optional__DmN5CQ9hzeK;
    ternary r28.is_some r28.val 0u64 into r29;
    is.eq r29 0u64 into r30;
    assert.eq r30 true;

constructor:
    assert.eq edition 0u16;
