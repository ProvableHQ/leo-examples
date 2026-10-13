program voting_power.aleo;

function compute_power:
    input r0 as u64.private;
    output r0 as u64.private;

constructor:
    assert.eq edition 0u16;
