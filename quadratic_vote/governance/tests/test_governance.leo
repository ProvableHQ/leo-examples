import governance.aleo;

program test_governance.aleo {
    // A supplied balance of 100 gives weight 10.
    @test
    fn test_cast_vote_weight_10() {
        let v: governance.aleo::Vote = governance.aleo::cast_vote(1field, 100u32, true);
        assert_eq(v.weight, 10u32);
        assert_eq(v.approve, true);
        assert_eq(v.proposal_id, 1field);
        assert_eq(v.owner, std::ctx::signer());
    }

    // A supplied balance of 1000 gives weight 31.
    @test
    fn test_cast_vote_weight_31() {
        let v: governance.aleo::Vote = governance.aleo::cast_vote(1field, 1000u32, false);
        assert_eq(v.weight, 31u32);
        assert_eq(v.approve, false);
    }

    // The weight reaches MAX_WEIGHT at a supplied balance of 10000.
    @test
    fn test_cast_vote_cap() {
        let v: governance.aleo::Vote = governance.aleo::cast_vote(1field, 10000u32, true);
        assert_eq(v.weight, 100u32);
    }

    // A supplied balance at MIN_BALANCE gives weight 1.
    @test
    fn test_cast_vote_min_balance() {
        let v: governance.aleo::Vote = governance.aleo::cast_vote(2field, 1u32, true);
        assert_eq(v.weight, 1u32);
    }

    // A supplied balance below MIN_BALANCE is rejected.
    @test
    @should_fail
    fn test_cast_vote_ineligible() {
        let v: governance.aleo::Vote = governance.aleo::cast_vote(1field, 0u32, true);
    }

    // Casting 5 votes costs 5² = 25 credits.
    @test
    fn test_qv_cost_5() {
        assert_eq(governance.aleo::qv_cost(5u32), 25u32);
    }

    // Casting 1 vote costs 1² = 1 credit.
    @test
    fn test_qv_cost_1() {
        assert_eq(governance.aleo::qv_cost(1u32), 1u32);
    }

    // Casting 10 votes costs 10² = 100 credits.
    @test
    fn test_qv_cost_10() {
        assert_eq(governance.aleo::qv_cost(10u32), 100u32);
    }

    // 1 024 = 32² is a perfect square.
    @test
    fn test_perfect_square_1024() {
        assert(governance.aleo::has_perfect_sqrt(1024u32));
    }

    // 0 = 0² is a perfect square.
    @test
    fn test_perfect_square_0() {
        assert(governance.aleo::has_perfect_sqrt(0u32));
    }

    // 1 000 is not a perfect square (31² = 961, 32² = 1 024).
    @test
    fn test_not_perfect_square_1000() {
        assert(!governance.aleo::has_perfect_sqrt(1000u32));
    }

    // 2 is not a perfect square.
    @test
    fn test_not_perfect_square_2() {
        assert(!governance.aleo::has_perfect_sqrt(2u32));
    }

    // 40 000 = 200² is a perfect square (covers convergence for larger inputs).
    @test
    fn test_perfect_square_40000() {
        assert(governance.aleo::has_perfect_sqrt(40000u32));
    }

    // 65 536 = 256² is a perfect square (covers convergence near the u16 boundary).
    @test
    fn test_perfect_square_65536() {
        assert(governance.aleo::has_perfect_sqrt(65536u32));
    }

    // 40 001 is not a perfect square (200² = 40 000, 201² = 40 401).
    @test
    fn test_not_perfect_square_40001() {
        assert(!governance.aleo::has_perfect_sqrt(40001u32));
    }

    // A proposal with more approvals than rejections is passing.
    @test
    fn test_is_passing_true() {
        assert(governance.aleo::is_passing(131u32, 15u32));
    }

    // A tied proposal is not passing (strict majority required).
    @test
    fn test_is_passing_tie() {
        assert(!governance.aleo::is_passing(15u32, 15u32));
    }

    // A proposal with fewer approvals than rejections is not passing.
    @test
    fn test_is_passing_false() {
        assert(!governance.aleo::is_passing(10u32, 20u32));
    }

    @test
    fn test_isqrt_boundaries() {
        let inputs: [u32; 12] = [0u32, 1u32, 2u32, 3u32, 4u32, 15u32, 16u32, 17u32,
            4_294_836_224u32, 4_294_836_225u32, 4_294_836_226u32, 4_294_967_295u32];
        let expected: [u32; 12] = [0u32, 1u32, 1u32, 1u32, 2u32, 3u32, 4u32, 4u32,
            65_534u32, 65_535u32, 65_535u32, 65_535u32];
        for i: u8 in 0u8..12u8 {
            assert_eq(sqrt_math::newton::isqrt(inputs[i]), expected[i]);
        }
    }

    @test
    fn test_cast_vote_below_cap() {
        let v: governance.aleo::Vote = governance.aleo::cast_vote(1field, 9_999u32, true);
        assert_eq(v.weight, 99u32);
    }

    @test
    fn test_cast_vote_above_cap() {
        let v: governance.aleo::Vote = governance.aleo::cast_vote(1field, 10_201u32, true);
        assert_eq(v.weight, 100u32);
    }

    @test
    fn test_cast_vote_u32_max() {
        let v: governance.aleo::Vote = governance.aleo::cast_vote(1field, 4_294_967_295u32, false);
        assert_eq(v.weight, 100u32);
        assert_eq(v.approve, false);
    }

    @test
    fn test_qv_cost_zero() {
        assert_eq(governance.aleo::qv_cost(0u32), 0u32);
    }

    @test
    fn test_qv_cost_max() {
        assert_eq(governance.aleo::qv_cost(65_535u32), 4_294_836_225u32);
    }

    @test
    @should_fail
    fn test_qv_cost_overflow() {
        let cost: u32 = governance.aleo::qv_cost(65_536u32);
    }

    @test
    fn test_perfect_square_u32_limits() {
        assert(governance.aleo::has_perfect_sqrt(4_294_836_225u32));
        assert(!governance.aleo::has_perfect_sqrt(4_294_836_224u32));
        assert(!governance.aleo::has_perfect_sqrt(4_294_836_226u32));
        assert(!governance.aleo::has_perfect_sqrt(4_294_967_295u32));
    }

    @test
    fn test_is_passing_zero_totals() {
        assert(!governance.aleo::is_passing(0u32, 0u32));
    }

    @noupgrade
    constructor() {}
}
