program example_program.aleo {
    transition simple_addition(public a: u32, b: u32) -> u32 {
        let c: u32 = a + b;
        return c;
    }

    mapping map: field => field;

    record Example {
        owner: address,
        x: field,
    }

    transition mint_record(x: field) -> Example {
        return Example {
            owner: self.signer,
            x,
        };
    }
    
    async transition set_mapping(x: field) -> Future {
        let future_1: Future = finalize_set_mapping(x);
        return future_1;
    }

    async function finalize_set_mapping(x: field) {
        Mapping::set(map, 0field, x);
    }
}
