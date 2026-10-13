// A weight calculated from a supplied balance.
export struct VoterProfile {
    weight: u32,
}

// Calculate votes squared. Reject inputs whose square exceeds u32.
export fn credits_for_votes(votes: u32) -> u32 {
    assert(votes <= sqrt_math::ISQRT_MAX);
    return votes * votes;
}

// Build a profile with the capped weight from another submodule.
export fn build_profile(token_balance: u32) -> VoterProfile {
    let w: u32 = vote_math::weight::compute(token_balance);
    return VoterProfile { weight: w };
}
