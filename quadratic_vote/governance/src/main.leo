program governance.aleo {
    // A vote record for the signer.
    record Vote {
        owner: address,
        proposal_id: field,
        weight: u32,
        approve: bool,
    }

    // Derive a capped weight from a supplied balance and return a vote record.
    // The balance is not verified, and repeat votes are not prevented.
    fn cast_vote(public proposal_id: field, token_balance: u32, approve: bool) -> Vote {
        assert(vote_math::weight::is_eligible(token_balance));
        let profile: vote_math::cost::VoterProfile = vote_math::cost::build_profile(token_balance);
        return Vote { owner: std::ctx::signer(), proposal_id, weight: profile.weight, approve };
    }

    // Calculate votes squared without spending credits.
    fn qv_cost(votes: u32) -> u32 {
        return vote_math::cost::credits_for_votes(votes);
    }

    // Call sqrt_math directly to check whether the supplied number is a square.
    fn has_perfect_sqrt(token_balance: u32) -> bool {
        return sqrt_math::checks::is_perfect_square(token_balance);
    }

    // Compare supplied totals. No vote records are counted.
    fn is_passing(public approvals: u32, public rejections: u32) -> bool {
        return approvals > rejections;
    }

    @noupgrade
    constructor() {}
}
