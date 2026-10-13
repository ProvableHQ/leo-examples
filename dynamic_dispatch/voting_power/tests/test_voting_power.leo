import voting_power.aleo;

program test_voting_power.aleo {
    @test
    fn test_linear_boundaries() {
        assert_eq(voting_power.aleo::compute_power(0u64), 0u64);
        assert_eq(voting_power.aleo::compute_power(1u64), 1u64);
        assert_eq(voting_power.aleo::compute_power(10_000u64), 10_000u64);
        assert_eq(voting_power.aleo::compute_power(18_446_744_073_709_551_615u64), 18_446_744_073_709_551_615u64);
    }

    @noupgrade
    constructor() {}
}
