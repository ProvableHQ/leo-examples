// Share this interface with programs that implement or call the strategy.
export interface VotingStrategy {
    fn compute_power(balance: u64) -> u64;
}

program voting_power.aleo : VotingStrategy {
    fn compute_power(balance: u64) -> u64 {
        return balance;
    }

    @noupgrade
    constructor() {}
}
