//@ [!lean] skip
//! `zip` on a generic iterator, called through its `Iterator` instance - the PLONK verifier's
//! `l_i_range`. The library's `Iterator` has no `zip` field (its `IntoIterator` bound would
//! hold an `Iterator`), so the call goes to the model of the provided body.

pub fn dot<I: IntoIterator<Item = u32>>(xs: I, ys: &[u32]) -> u32 {
    xs.into_iter()
        .zip(ys.iter())
        .fold(0, |a, (x, y)| a.wrapping_add(x.wrapping_mul(*y)))
}
