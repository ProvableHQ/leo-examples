import voting_power.aleo;

program quadratic_power.aleo : voting_power.aleo::VotingStrategy {
    // Calculate floor(sqrt(balance)) for every u64 input.
    // Start at 2^32, above every possible integer square root.
    // Each step above the result reduces the remaining gap by at least half.
    // Thirty-three fixed steps also handle zero.
    fn compute_power(balance: u64) -> u64 {
        let x: u64 = 4_294_967_296u64;
        for i: u8 in 0u8..33u8 {
            let divisor: u64 = x == 0u64 ? 1u64 : x;
            let next: u64 = (x + balance / divisor) / 2u64;
            x = next < x ? next : x;
        }
        return x;
    }

    @noupgrade
    constructor() {}
}
