// Returns floor(sqrt(n)) for any n: u32, including 0 and 1.
// Result is always in [0, 65_535] since sqrt(2^32 − 1) = 65_535.
//
// Uses twenty iterations of Newton's method: x ← (x + n/x) / 2.
// Starting from n/2 + 1 guarantees x ≥ 1 initially; twenty iterations
// are sufficient to converge for all n: u32.
// Because Aleo executes all loop iterations in circuit mode (no early exit),
// the divisor must be guarded so that x = 0 (reachable only when n = 0)
// never causes integer division by zero.
fn isqrt(n: u32) -> u32 {
    let x: u32 = n / 2u32 + 1u32;
    for i: u8 in 0u8..20u8 {
        let divisor: u32 = x == 0u32 ? 1u32 : x;
        let next: u32 = (x + n / divisor) / 2u32;
        x = next < x ? next : x;
    }
    assert(x <= sqrt_math::ISQRT_MAX);
    return x;
}
