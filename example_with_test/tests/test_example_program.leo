import example_program.aleo;

program test_example_program.aleo {
    mapping random_values: field => field;

    @test
    @should_fail
    fn test_simple_addition_fail() {
        let result: u32 = example_program.aleo::simple_addition(2u32, 3u32);
        assert_eq(result, 3u32);
    }

    @test
    fn test_simple_addition() {
        let result: u32 = example_program.aleo::simple_addition(2u32, 3u32);
        assert_eq(result, 5u32);
    }

    @test
    fn test_record_maker() {
        let r: example_program.aleo::Example = example_program.aleo::mint_record(0field);
        assert_eq(r.x, 0field);
    }

    @test
    fn test_async() -> Final {
        const VAL: field = 12field;
        let fin: Final = example_program.aleo::set_mapping(VAL);
        return final {
            fin.run();
            assert_eq(Mapping::get(example_program.aleo::map, 0field), VAL);

            let rand_val: field = ChaCha::rand_field();
            Mapping::set(random_values, VAL, rand_val);
            let value: field = Mapping::get(random_values, VAL);
            assert_eq(value, rand_val);
        };
    }

    @noupgrade
    constructor() {}
}
