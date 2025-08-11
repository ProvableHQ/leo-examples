program admin_example.aleo;

function main:
    input r0 as u32.public;
    input r1 as u32.private;
    add r0 r1 into r2;
    output r2 as u32.private;

constructor:
    assert.eq program_owner aleo1tm8mt8r96fnya58zz2ws43ud7e4q2guktfujj8ye6zzfrstjpyysakpmdu;
