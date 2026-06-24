program example_program.aleo {
    fn simple_addition(public a: u32, b: u32) -> u32 {
        let c: u32 = a + b;
        return c;
    }

    mapping map: field => field;

    record Example {
        owner: address,
        x: field,
    }

    fn mint_record(x: field) -> Example {
        return Example {
            owner: std::ctx::signer(),
            x,
        };
    }
    
    fn set_mapping(x: field) -> Final {
        return final {
            Mapping::set(map, 0field, x);
        };
    }
}
