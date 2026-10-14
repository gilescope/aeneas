//@ [!lean] skip
//@ [lean] subdir=ClosureMutCaptureNested
//! A `map` closure that accumulates into a captured `&mut` while holding a reference to another
//! closure that holds references, consumed by `collect` - logup's helper constraints. Giving the
//! `&mut` back met a "no nested borrows" check that shared-under-shared nesting does not
//! concern.
use std::collections::BTreeMap;
use std::ops::{Add, Mul};

/// The shape of logup's helper constraints: a `map` closure that reads a captured map, calls a
/// captured closure (itself holding references) and accumulates into a captured `&mut`.
pub fn helpers<'a, F: Copy + Default + Add<Output = F> + Mul<Output = F>>(
    chunks: &'a [Vec<F>],
    evals: &BTreeMap<usize, F>,
    theta: F,
) -> impl Iterator<Item = F> + 'a {
    let compress = |xs: &[F]| xs.iter().fold(F::default(), |acc, x| acc * theta + *x);
    let mut sum = F::default();
    let out: Vec<F> = chunks
        .iter()
        .enumerate()
        .map(|(j, chunk)| {
            let h = evals.get(&j).copied().unwrap_or_default();
            sum = sum + h;
            h * compress(chunk)
        })
        .collect();
    std::iter::once(sum).chain(out)
}
