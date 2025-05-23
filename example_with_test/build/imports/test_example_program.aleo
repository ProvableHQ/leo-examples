import example_program.aleo;
program test_example_program.aleo;

function test_simple_addition_fail:
    call example_program.aleo/simple_addition 2u32 3u32 into r0;
    assert.eq r0 3u32;

function test_simple_addition:
    call example_program.aleo/simple_addition 2u32 3u32 into r0;
    assert.eq r0 5u32;

function test_record_maker:
    call example_program.aleo/mint_record 0field into r0;
    assert.eq r0.x 0field;
