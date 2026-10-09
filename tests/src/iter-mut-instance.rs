//@ [!lean] skip
//@ [lean] aeneas-args=-filter-trait-methods
//@ [lean] subdir=IterMutInstance
//! Iterating `iter_mut()` and `chunks_mut()`, as the curves' FFT does: the crate's `Iterator` instance for
//! `IterMut` lacks the methods it never calls, including `size_hint`, which the library's
//! `Iterator` requires. Extraction only: no library model takes a `&mut` iterator
//! instance yet (zk3 models them by hand), so the Lean check is zk3's build.

pub fn bump(a: &mut [u32]) {
    for x in a.iter_mut() {
        *x += 1;
    }
}

/// Passes the `IterMut` and `ChunksMut` instances to library models
pub fn pairs(a: &mut [u32], b: &[u32]) -> usize {
    a.iter_mut().zip(b.iter()).count() + a.chunks_mut(2).zip(b.iter()).count()
}

// Not a `for` loop over `a.iter_mut().zip(b.iter_mut())`: the call expects `Zip::next` to
// give back the inner iterators' borrows, which the library's `Zip` model does not.

pub fn bump_chunks(a: &mut [u32]) {
    for c in a.chunks_mut(2) {
        c[0] += 1;
    }
}
