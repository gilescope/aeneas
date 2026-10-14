//@ [!lean] skip
//@ [lean] aeneas-args=-filter-trait-methods
//! `chain` on an iterator holding a `&mut` (`iter_mut()`) gives `self` and `other` back:
//! Aeneas expects `(Chain, back)` from `Iterator::chain`, as midnight-proofs'
//! `EvaluationDomain::new` does when it chains `Some(&mut x)`s for `batch_invert`.
//! (`count` and `for` over such a chain need give-back models of their own, not yet written.)

pub fn chain_then_drop(a: &mut [u32], b: &mut [u32]) {
    let _c = a.iter_mut().chain(b.iter_mut());
}

pub fn chain_twice(a: &mut [u32], b: &mut [u32], c: &mut [u32]) {
    let _d = a.iter_mut().chain(b.iter_mut()).chain(c.iter_mut());
}
