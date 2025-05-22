import example_program.aleo;

program test_example_program.aleo {
    @test
    @should_fail
    transition do_nothing() {
        let result: u32 = example_program.aleo/simple_addition(2u32, 3u32);
        assert_eq(result, 3u32);
    }

    @test
    transition test_simple_addition() {
        let result: u32 = example_program.aleo/simple_addition(2u32, 3u32);
        assert_eq(result, 5u32);
    }

    // We can await futures, set mapping values, and access mapping values using 
    // `script` testing mode.
    @test
    script test_async() {
    const VAL: field = 12field;
    let fut: Future = example_program.aleo/set_mapping(VAL);
    // We must await this future for the async code to run.
    fut.await();
    assert_eq(Mapping::get(example_program.aleo/map, 0field), VAL);

    // scripts can also do other things normally only async code can do:
    let rand_val: field = ChaCha::rand_field();
    Mapping::set(example_program.aleo/map, VAL, rand_val);
    let value: field = Mapping::get(example_program.aleo/map, VAL);
    assert_eq(value, rand_val);
}

    @test
    transition test_record_maker() {
        let r: example_program.aleo/Example = example_program.aleo/mint_record(0field);
        assert_eq(r.x, 0field);
    }
}
