program example_program.aleo;

record Example:
    owner as address.private;
    x as field.private;

mapping map:
    key as field.public;
    value as field.public;

function simple_addition:
    input r0 as u32.public;
    input r1 as u32.private;
    add r0 r1 into r2;
    output r2 as u32.private;

function mint_record:
    input r0 as field.private;
    cast self.signer r0 into r1 as Example.record;
    output r1 as Example.record;

function set_mapping:
    input r0 as field.private;
    async set_mapping r0 into r1;
    output r1 as example_program.aleo/set_mapping.future;

finalize set_mapping:
    input r0 as field.public;
    set r0 into map[0field];
