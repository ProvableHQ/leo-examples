import basic_voting.aleo;

program vote_example.aleo {
    @checksum(mapping="basic_voting.aleo/approved_checksum", key="true")
    async constructor() {}

    transition main(public a: u32, b: u32) -> u32 {
        let c: u32 = a + b;
        return c;
    }

    // Uncomment me to test the upgrade.
    // transition foo() {}
}
