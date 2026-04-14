// Computed voting parameters for a participant.
struct VoterProfile {
    weight: u32,
}

// Returns the credit cost of casting `votes` weighted votes under QV.
// Cost equals votes², so each additional vote is progressively more expensive.
// votes must be ≤ 65_535 to avoid u32 overflow (65_535² = 4_294_836_225 < 2^32).
fn credits_for_votes(votes: u32) -> u32 {
    assert(votes <= 65535u32);
    return votes * votes;
}

// Builds a VoterProfile for `token_balance`.
// Uses vote_math::weight::compute for the capped QV weight.
fn build_profile(token_balance: u32) -> VoterProfile {
    let w: u32 = vote_math::weight::compute(token_balance);
    return VoterProfile { weight: w };
}
