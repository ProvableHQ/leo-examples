import voting_power.aleo;

program governance.aleo {
    // Call the named program with the shared interface signature.
    fn get_voting_power(strategy: identifier, balance: u64) -> u64 {
        return voting_power.aleo::VotingStrategy@(strategy)::compute_power(balance);
    }

    // Apply one strategy to two supplied balances and compare the results.
    // No token balances or accepted votes are checked.
    fn proposal_passes(
        strategy: identifier,
        for_balance: u64,
        against_balance: u64
    ) -> bool {
        let for_power: u64 = voting_power.aleo::VotingStrategy@(strategy)::compute_power(for_balance);
        let against_power: u64 = voting_power.aleo::VotingStrategy@(strategy)::compute_power(against_balance);
        return for_power > against_power;
    }

    // Use identifier literals to select both targets in one call.
    fn compare_strategies(balance: u64) -> (u64, u64) {
        let linear_power: u64 = voting_power.aleo::VotingStrategy@('voting_power')::compute_power(balance);
        let quadratic_power: u64 = voting_power.aleo::VotingStrategy@('quadratic_power')::compute_power(balance);
        return (linear_power, quadratic_power);
    }

    @noupgrade
    constructor() {}
}
