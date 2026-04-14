program governance.aleo {
    // Private on-chain receipt proving a participant voted on a proposal.
    record Vote {
        owner: address,
        proposal_id: field,
        weight: u32,
        approve: bool,
    }

    // Cast a private vote on proposal `proposal_id`.
    //
    // `token_balance` is the caller's private holding; the quadratic voting
    // weight is derived from it via vote_math::weight.  Returns a Vote receipt
    // that proves participation without revealing the token balance on-chain.
    fn cast_vote(public proposal_id: field, token_balance: u32, approve: bool) -> Vote {
        assert(vote_math::weight::is_eligible(token_balance));
        let profile: vote_math::cost::VoterProfile = vote_math::cost::build_profile(token_balance);
        return Vote { owner: self.signer, proposal_id, weight: profile.weight, approve };
    }

    // Returns the credit cost of casting `votes` weighted votes under QV.
    fn qv_cost(votes: u32) -> u32 {
        return vote_math::cost::credits_for_votes(votes);
    }

    // Returns true when `token_balance` is a perfect square.
    // Delegates directly to sqrt_math::checks, bypassing vote_math entirely,
    // to illustrate that a program can reach into any library submodule.
    fn has_perfect_sqrt(token_balance: u32) -> bool {
        return sqrt_math::checks::is_perfect_square(token_balance);
    }

    // Returns true when weighted approvals exceed weighted rejections.
    fn is_passing(public approvals: u32, public rejections: u32) -> bool {
        return approvals > rejections;
    }

    @noupgrade
    constructor() {}
}
