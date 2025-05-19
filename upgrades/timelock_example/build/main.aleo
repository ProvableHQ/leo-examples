program timelock_example.aleo;

function main:
    input r0 as u32.public;
    input r1 as u32.private;
    add r0 r1 into r2;
    output r2 as u32.private;

constructor:
    gt timelock_example.aleo/edition 0u16 into r0;
    branch.eq r0 false to end_then_0_0;
    gte block.height 1000u32 into r1;
    assert.eq r1 true;
    branch.eq true true to end_otherwise_0_1;
    position end_then_0_0;
    position end_otherwise_0_1;

