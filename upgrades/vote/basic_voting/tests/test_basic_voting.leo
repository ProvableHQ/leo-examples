// The 'test_basic_voting' test program.
import basic_voting.aleo;
program test_basic_voting.aleo {
    @test
    script test_it() {
        let result: u32 = basic_voting.aleo/main(1u32, 2u32);
        assert_eq(result, 3u32);
    }

    @test
    @should_fail
    transition do_nothing() {
        let result: u32 = basic_voting.aleo/main(2u32, 3u32);
        assert_eq(result, 3u32);
    }
}
