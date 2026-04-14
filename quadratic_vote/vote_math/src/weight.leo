// Returns the quadratic-voting weight for `token_balance`.
// Weight equals floor(sqrt(token_balance)), capped at vote_math::MAX_WEIGHT.
fn compute(token_balance: u32) -> u32 {
    let raw: u32 = sqrt_math::newton::isqrt(token_balance);
    return raw < vote_math::MAX_WEIGHT ? raw : vote_math::MAX_WEIGHT;
}

// Returns true when `token_balance` meets the minimum participation threshold.
fn is_eligible(token_balance: u32) -> bool {
    return token_balance >= vote_math::MIN_BALANCE;
}
