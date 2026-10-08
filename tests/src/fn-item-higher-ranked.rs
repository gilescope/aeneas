//@ [!lean] skip
//@ [lean] subdir=FnItemHigherRanked
//! Extraction-only (std's `Iterator::max_by` has no Lean model yet): a function item with
//! higher-ranked lifetimes, `for<'a, 'b> Ord::cmp<'a, 'b>`, used as a closure. Its lifetimes
//! met several "no regions in function items" checks; it holds no data, so they do not matter.
pub fn longest(lens: &[usize]) -> Option<&usize> {
    lens.iter().max_by(Ord::cmp)
}
