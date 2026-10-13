// Check whether n is an integer square.
export fn is_perfect_square(n: u32) -> bool {
    let s: u32 = sqrt_math::newton::isqrt(n);
    return s * s == n;
}
