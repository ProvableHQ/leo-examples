import basic_voting.aleo;

program test_basic_voting.aleo {
    @test
    @should_fail
    fn test_vote_without_proposal() -> Final {
        let fin: Final = basic_voting.aleo::vote([0u8; 32], true);
        return final {
            fin.run();
        };
    }

    @test
    fn test_propose() -> Final {
        let fin: Final = basic_voting.aleo::propose([0u8; 32]);
        return final {
            fin.run();
        };
    }

    @noupgrade
    constructor() {}
}
