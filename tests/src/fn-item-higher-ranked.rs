//@ [!lean] skip
//@ [lean] subdir=FnItemHigherRanked
//! Extraction-only (std's `Iterator::max_by` has no Lean model yet): a function item with
//! higher-ranked lifetimes, `for<'a, 'b> Ord::cmp<'a, 'b>`, used as a closure. Its lifetimes
//! met several "no regions in function items" checks; it holds no data, so they do not matter.
pub fn longest(lens: &[usize]) -> Option<&usize> {
    lens.iter().max_by(Ord::cmp)
}

/// Over owned values, as `verify_algebraic_constraints` does: `usize::cmp` is pure (not in
/// `Result`), which the function item's type and value assumed it was.
pub fn longest_len(xss: &[Vec<u8>]) -> usize {
    xss.iter()
        .map(|xs| xs.len())
        .max_by(Ord::cmp)
        .unwrap_or_default()
}
