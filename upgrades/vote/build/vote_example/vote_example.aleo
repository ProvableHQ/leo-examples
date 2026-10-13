import basic_voting.aleo;
program vote_example.aleo;

function main:
    input r0 as u32.public;
    input r1 as u32.private;
    add r0 r1 into r2;
    output r2 as u32.private;

constructor:
    branch.eq edition 0u16 to end;
    get basic_voting.aleo/approved_checksum[true] into r0;
    assert.eq checksum r0;
    position end;
