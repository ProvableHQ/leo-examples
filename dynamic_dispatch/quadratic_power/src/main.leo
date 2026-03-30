// QuadraticVoting reduces the influence of large token holders:
// a voter with N tokens receives floor(√N) votes instead of N.
//
// This program implements the VotingStrategy interface declared in
// voting_power.aleo.  Once both programs are deployed, governance.aleo
// can route power queries to either implementation at runtime simply by
// changing the `strategy` identifier — no redeployment required.

// Re-declare the interface so Leo's type checker can verify this program
// satisfies it at compile time.  The signature must match voting_power.aleo's
// declaration exactly.
interface VotingStrategy {
    fn compute_power(balance: u64) -> u64;
}

program quadratic_power.aleo : VotingStrategy {
    // Quadratic voting power: floor(√balance) votes.
    //
    // Uses Newton's method to compute the integer square root in 8 iterations.
    // The loop bound is a compile-time constant, which is required by the
    // underlying ZK circuit.
    fn compute_power(balance: u64) -> u64 {
        let x: u64 = balance / 2u64 + 1u64;
        for i: u8 in 0u8..8u8 {
            let divisor: u64 = x == 0u64 ? 1u64 : x;
            let next: u64 = (x + balance / divisor) / 2u64;
            x = next < x ? next : x;
        }
        return x;
    }

    @noupgrade
    constructor() {}
}
