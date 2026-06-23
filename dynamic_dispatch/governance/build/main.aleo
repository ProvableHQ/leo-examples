program governance.aleo;

function get_voting_power:
    input r0 as identifier.private;
    input r1 as u64.private;
    call.dynamic r0 'aleo' 'compute_power' with r1 (as u64.private) into r2 (as u64.private);
    output r2 as u64.private;

function proposal_passes:
    input r0 as identifier.private;
    input r1 as u64.private;
    input r2 as u64.private;
    call.dynamic r0 'aleo' 'compute_power' with r1 (as u64.private) into r3 (as u64.private);
    call.dynamic r0 'aleo' 'compute_power' with r2 (as u64.private) into r4 (as u64.private);
    gt r3 r4 into r5;
    output r5 as boolean.private;

function compare_strategies:
    input r0 as u64.private;
    call.dynamic 'voting_power' 'aleo' 'compute_power' with r0 (as u64.private) into r1 (as u64.private);
    call.dynamic 'quadratic_power' 'aleo' 'compute_power' with r0 (as u64.private) into r2 (as u64.private);
    output r1 as u64.private;
    output r2 as u64.private;

constructor:
    assert.eq edition 0u16;
