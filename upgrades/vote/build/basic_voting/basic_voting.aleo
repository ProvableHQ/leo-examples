program basic_voting.aleo;

mapping proposed_checksum:
    key as boolean.public;
    value as [u8; 32u32].public;

mapping approved_checksum:
    key as boolean.public;
    value as [u8; 32u32].public;

mapping accepting_votes:
    key as boolean.public;
    value as u32.public;

mapping voters:
    key as address.public;
    value as boolean.public;

function propose:
    input r0 as [u8; 32u32].private;
    async propose into r1;
    output r1 as basic_voting.aleo/propose.future;

finalize propose:
    contains proposed_checksum[true] into r0;
    not r0 into r1;
    assert.eq r1 true;
    contains approved_checksum[true] into r2;
    not r2 into r3;
    assert.eq r3 true;

function vote:
    input r0 as [u8; 32u32].private;
    input r1 as boolean.private;
    async vote self.caller r1 r0 into r2;
    output r2 as basic_voting.aleo/vote.future;

finalize vote:
    input r0 as address.public;
    input r1 as boolean.public;
    input r2 as [u8; 32u32].public;
    contains proposed_checksum[true] into r3;
    assert.eq r3 true;
    contains approved_checksum[true] into r4;
    not r4 into r5;
    assert.eq r5 true;
    contains voters[r0] into r6;
    not r6 into r7;
    assert.eq r7 true;
    set true into voters[r0];
    branch.eq r1 false to end_then_0_0;
    get accepting_votes[true] into r8;
    add r8 1u32 into r9;
    set r9 into accepting_votes[true];
    gte r9 2u32 into r10;
    branch.eq r10 false to end_then_1_2;
    set r2 into approved_checksum[true];
    branch.eq true true to end_otherwise_1_3;
    position end_then_1_2;
    position end_otherwise_1_3;
    branch.eq true true to end_otherwise_0_1;
    position end_then_0_0;
    position end_otherwise_0_1;

constructor:
    assert.eq edition 0u16;
