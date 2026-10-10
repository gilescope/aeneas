//@ [!lean] skip
//@ [lean] subdir=ZipIterMut
//@ [lean] aeneas-args=-split-files
//@ [lean] aeneas-args=-filter-trait-methods
//! A loop over a generic iterator zipped with `iter_mut()`, writing through the `&mut` items -
//! the PLONK verifier's `l_i_range`. `Zip::next` gives back each `&mut` item with a backward
//! function (`ZipIterMut/Properties.lean` checks the writes land).

pub fn scale<I: IntoIterator<Item = u32>>(xs: I, ys: &mut [u32]) {
    for (x, y) in xs.into_iter().zip(ys.iter_mut()) {
        *y = y.wrapping_mul(x);
    }
}
