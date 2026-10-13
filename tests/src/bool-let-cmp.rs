//@ [!lean] skip
//! Regression test: a comparison bound by a `let` (here through `||`, whose short-circuit
//! extracts as `if c then ok true else ok (a >= b)`). Lean prints the comparison as a `Prop`,
//! so an untyped `let bit ← ...` elaborated as one and `if bit` failed: "failed to synthesize
//! Decidable bit".

pub fn step(rem: u128, lam: u128) -> u128 {
    let carry = rem >> 127;
    let rem = rem << 1;
    let bit = carry == 1 || rem >= lam;
    if bit { rem.wrapping_sub(lam) } else { rem }
}

pub fn ge_let(a: u32, b: u32) -> u32 {
    let ge = a >= b;
    if ge { a } else { b }
}
