// The VotingStrategy interface specifies how a program computes voting power
// from a token balance.
//
// Any deployed program that satisfies this interface can be used as a
// dynamic dispatch target: governance.aleo identifies the strategy at runtime
// using the `identifier` type and routes the call accordingly.
interface VotingStrategy {
    fn compute_power(balance: u64) -> u64;
}

// LinearVoting is the reference implementation: one token = one vote.
program voting_power.aleo : VotingStrategy {
    // Linear voting: one token = one vote.
    fn compute_power(balance: u64) -> u64 {
        return balance;
    }

    @noupgrade
    constructor() {}
}
