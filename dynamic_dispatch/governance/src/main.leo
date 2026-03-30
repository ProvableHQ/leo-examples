// governance.aleo is the dynamic dispatch hub.
//
// It holds no voting logic itself — instead it delegates power computation
// to whichever VotingStrategy program the caller names at runtime.  Adding
// a new strategy (e.g., a conviction-voting program) requires no changes
// to this contract: deploy the new program, pass its name as `strategy`,
// and governance.aleo routes to it automatically.
//
// Dynamic call syntax (unqualified — interface declared locally):
//   VotingStrategy@(strategy)::compute_power(balance)
//   ├─ VotingStrategy  → the interface (must be declared in this file)
//   ├─ @(strategy)     → the runtime target (an `identifier` value)
//   └─ ::compute_power → the function to invoke on that target
//
// The interface is re-declared here so Leo's type checker can verify the
// call signature.  At the AVM level, the dispatch checks that the named
// program has a matching `compute_power(u64) -> u64` function.
interface VotingStrategy {
    fn compute_power(balance: u64) -> u64;
}

program governance.aleo {
    // Returns the voting power for `balance` tokens under the given strategy.
    //
    // `strategy` is an `identifier` resolved at runtime — e.g.:
    //   'voting_power'    → linear:    10 000 tokens → 10 000 votes
    //   'quadratic_power' → quadratic: 10 000 tokens →    100 votes
    fn get_voting_power(strategy: identifier, balance: u64) -> u64 {
        return VotingStrategy@(strategy)::compute_power(balance);
    }

    // Returns true when the weighted "for" side outweighs the "against" side.
    //
    // The same balance figures yield very different margins depending on the
    // strategy: under linear voting a whale dominates; under quadratic voting
    // their edge is shrunk to the square root of the difference.
    fn proposal_passes(
        strategy: identifier,
        for_balance: u64,
        against_balance: u64
    ) -> bool {
        let for_power: u64 = VotingStrategy@(strategy)::compute_power(for_balance);
        let against_power: u64 = VotingStrategy@(strategy)::compute_power(against_balance);
        return for_power > against_power;
    }

    // Evaluates the same balance under both strategies and returns the results
    // side-by-side.  This function uses *identifier literals* ('voting_power'
    // and 'quadratic_power') rather than a variable, showing that the target
    // can be fixed at compile time when desired.
    fn compare_strategies(balance: u64) -> (u64, u64) {
        let linear_power: u64 = VotingStrategy@('voting_power')::compute_power(balance);
        let quadratic_power: u64 = VotingStrategy@('quadratic_power')::compute_power(balance);
        return (linear_power, quadratic_power);
    }

    @noupgrade
    constructor() {}
}
