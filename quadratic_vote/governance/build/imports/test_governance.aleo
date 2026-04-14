import governance.aleo;
program test_governance.aleo;

struct VoterProfile__BuQNrNoHlO8:
    weight as u32;

function test_cast_vote_weight_10:
    call governance.aleo/cast_vote 1field 100u32 true into r0;
    assert.eq r0.weight 10u32;
    assert.eq r0.approve true;

function test_cast_vote_weight_31:
    call governance.aleo/cast_vote 1field 1000u32 false into r0;
    assert.eq r0.weight 31u32;
    assert.eq r0.approve false;

function test_cast_vote_cap:
    call governance.aleo/cast_vote 1field 10000u32 true into r0;
    assert.eq r0.weight 100u32;

function test_cast_vote_min_balance:
    call governance.aleo/cast_vote 2field 1u32 true into r0;
    assert.eq r0.weight 1u32;

function test_cast_vote_ineligible:
    call governance.aleo/cast_vote 1field 0u32 true into r0;

function test_qv_cost_5:
    call governance.aleo/qv_cost 5u32 into r0;
    assert.eq r0 25u32;

function test_qv_cost_1:
    call governance.aleo/qv_cost 1u32 into r0;
    assert.eq r0 1u32;

function test_qv_cost_10:
    call governance.aleo/qv_cost 10u32 into r0;
    assert.eq r0 100u32;

function test_perfect_square_1024:
    call governance.aleo/has_perfect_sqrt 1024u32 into r0;
    assert.eq r0 true;

function test_perfect_square_0:
    call governance.aleo/has_perfect_sqrt 0u32 into r0;
    assert.eq r0 true;

function test_not_perfect_square_1000:
    call governance.aleo/has_perfect_sqrt 1000u32 into r0;
    not r0 into r1;
    assert.eq r1 true;

function test_not_perfect_square_2:
    call governance.aleo/has_perfect_sqrt 2u32 into r0;
    not r0 into r1;
    assert.eq r1 true;

function test_perfect_square_40000:
    call governance.aleo/has_perfect_sqrt 40000u32 into r0;
    assert.eq r0 true;

function test_perfect_square_65536:
    call governance.aleo/has_perfect_sqrt 65536u32 into r0;
    assert.eq r0 true;

function test_not_perfect_square_40001:
    call governance.aleo/has_perfect_sqrt 40001u32 into r0;
    not r0 into r1;
    assert.eq r1 true;

function test_is_passing_true:
    call governance.aleo/is_passing 131u32 15u32 into r0;
    assert.eq r0 true;

function test_is_passing_tie:
    call governance.aleo/is_passing 15u32 15u32 into r0;
    not r0 into r1;
    assert.eq r1 true;

function test_is_passing_false:
    call governance.aleo/is_passing 10u32 20u32 into r0;
    not r0 into r1;
    assert.eq r1 true;

constructor:
    assert.eq edition 0u16;
