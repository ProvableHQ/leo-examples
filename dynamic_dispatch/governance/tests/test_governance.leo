import governance.aleo;

program test_governance.aleo {
    @test
    fn test_variable_linear() {
        assert_eq(governance.aleo::get_voting_power('voting_power', 10_000u64), 10_000u64);
    }

    @test
    fn test_variable_quadratic() {
        assert_eq(governance.aleo::get_voting_power('quadratic_power', 1_000_000u64), 1_000u64);
    }

    @test
    fn test_identifier_literals() {
        let (linear, quadratic): (u64, u64) = governance.aleo::compare_strategies(10_000u64);
        assert_eq(linear, 10_000u64);
        assert_eq(quadratic, 100u64);
    }

    @test
    fn test_dynamic_zero() {
        assert_eq(governance.aleo::get_voting_power('quadratic_power', 0u64), 0u64);
    }

    @test
    fn test_dynamic_u64_max() {
        assert_eq(governance.aleo::get_voting_power('quadratic_power', 18_446_744_073_709_551_615u64), 4_294_967_295u64);
    }

    @test
    fn test_linear_narrow_win() {
        assert(governance.aleo::proposal_passes('voting_power', 101u64, 100u64));
    }

    @test
    fn test_quadratic_narrow_tie() {
        assert(!governance.aleo::proposal_passes('quadratic_power', 101u64, 100u64));
    }

    @test
    fn test_proposal_ties() {
        assert(!governance.aleo::proposal_passes('voting_power', 100u64, 100u64));
        assert(!governance.aleo::proposal_passes('quadratic_power', 100u64, 100u64));
    }

    @test
    fn test_proposal_rejection() {
        assert(!governance.aleo::proposal_passes('voting_power', 100u64, 101u64));
        assert(!governance.aleo::proposal_passes('quadratic_power', 100u64, 121u64));
    }

    @test
    fn test_zero_totals() {
        assert(!governance.aleo::proposal_passes('quadratic_power', 0u64, 0u64));
    }

    @test
    @should_fail
    fn test_missing_program() {
        let power: u64 = governance.aleo::get_voting_power('missing_strategy', 100u64);
    }

    @test
    @should_fail
    fn test_missing_function() {
        let power: u64 = governance.aleo::get_voting_power('governance', 100u64);
    }

    @noupgrade
    constructor() {}
}
