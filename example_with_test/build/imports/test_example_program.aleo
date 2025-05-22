import example_program.aleo;
program test_example_program.aleo;

function do_nothing:
    call example_program.aleo/simple_addition 2u32 3u32 into r0;
    assert.eq r0 3u32;

function test_simple_addition:
    call example_program.aleo/simple_addition 2u32 3u32 into r0;
    assert.eq r0 5u32;
