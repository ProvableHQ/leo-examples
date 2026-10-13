// Calculate floor(sqrt(n)) for every u32 input.
// Twenty fixed Newton iterations are sufficient for this input range.
// Keep the smaller estimate to prevent oscillation near the result.
// Use a nonzero divisor when n is zero.
export fn isqrt(n: u32) -> u32 {
    let x: u32 = n / 2u32 + 1u32;
    for i: u8 in 0u8..20u8 {
        let divisor: u32 = x == 0u32 ? 1u32 : x;
        let next: u32 = (x + n / divisor) / 2u32;
        x = next < x ? next : x;
    }
    assert(x <= sqrt_math::ISQRT_MAX);
    return x;
}
