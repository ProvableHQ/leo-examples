// The 'test_vote_example' test program.
import vote_example.aleo;
program test_vote_example.aleo {
    @test
    script test_it() {
        let result: u32 = vote_example.aleo/main(1u32, 2u32);
        assert_eq(result, 3u32);
    }

    @test
    @should_fail
    transition do_nothing() {
        let result: u32 = vote_example.aleo/main(2u32, 3u32);
        assert_eq(result, 3u32);
    }
}
