// Returns true when n is a perfect square (i.e., floor(sqrt(n))^2 == n).
fn is_perfect_square(n: u32) -> bool {
    let s: u32 = sqrt_math::newton::isqrt(n);
    return s * s == n;
}
