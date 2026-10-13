import quadratic_power.aleo;

program test_quadratic_power.aleo {
    @test
    fn test_sqrt_boundaries() {
        let inputs: [u64; 15] = [0u64, 1u64, 2u64, 3u64, 99u64, 100u64, 101u64,
            10_000u64, 1_000_000u64, 4_294_967_295u64, 4_294_967_296u64,
            18_446_744_065_119_617_024u64, 18_446_744_065_119_617_025u64,
            18_446_744_065_119_617_026u64, 18_446_744_073_709_551_615u64];
        let expected: [u64; 15] = [0u64, 1u64, 1u64, 1u64, 9u64, 10u64, 10u64,
            100u64, 1_000u64, 65_535u64, 65_536u64,
            4_294_967_294u64, 4_294_967_295u64, 4_294_967_295u64, 4_294_967_295u64];
        for i: u8 in 0u8..15u8 {
            assert_eq(quadratic_power.aleo::compute_power(inputs[i]), expected[i]);
        }
    }

    @noupgrade
    constructor() {}
}
