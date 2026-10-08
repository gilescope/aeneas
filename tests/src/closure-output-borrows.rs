//@ [!lean] skip
//! Closures whose result borrows from what they receive. Charon gives the result's
//! lifetimes as fresh parameters (charon#1040); the `fix_closure_output_outlives`
//! prepass lets them borrow from the closure's arguments and captures.

/// The result borrows the argument (aeneas#1266).
pub fn identity(v: &u32) -> &u32 {
    (|v| v)(v)
}

/// The result borrows a capture.
pub fn pick(xs: &[u32], i: usize) -> &u32 {
    let pick = |j: usize| &xs[j];
    pick(i)
}

/// Gives a closure the higher-ranked signature Rust would not infer for it.
fn hr<F: for<'a> Fn(&'a [u32]) -> (u32, &'a u32)>(f: F) -> F {
    f
}

/// A structured result borrows the argument.
pub fn first_pair(v: &[u32]) -> (u32, &u32) {
    let first = hr(|w| (w[0], &w[0]));
    first(v)
}
