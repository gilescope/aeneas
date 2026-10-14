//@ [!lean] skip
//@ [lean] subdir=IterMutAdapters
//@ [lean] aeneas-args=-split-files
//@ [lean] aeneas-args=-filter-trait-methods
//! Adapters over `iter_mut()` give the `&mut` items back: a constructor gives the inner
//! iterator back, `next` each item (one backward function per mutable region, so two for
//! `Zip<IterMut, IterMut>`), a consumer the final iterator, and a closure handed a `&mut` item
//! returns it. These shapes are what Aeneas emits; the library's shape classes must match them.
//! `IterMutAdapters/Properties.lean` checks the writes land.

pub fn enumerate_set(a: &mut [u32]) {
    for (i, x) in a.iter_mut().enumerate() {
        *x = i as u32;
    }
}

pub fn take_bump(a: &mut [u32]) {
    for x in a.iter_mut().take(2) {
        *x += 1;
    }
}

pub fn step_by_bump(a: &mut [u32]) {
    for x in a.iter_mut().step_by(2) {
        *x += 1;
    }
}

pub fn skip_bump(a: &mut [u32]) {
    for x in a.iter_mut().skip(1) {
        *x += 1;
    }
}

/// `chain` merges its halves' regions: one backward function gives both back.
pub fn chain_bump(a: &mut [u32], b: &mut [u32]) -> usize {
    let mut n = 0;
    for x in a.iter_mut().chain(b.iter_mut()) {
        *x += 1;
        n += 1;
    }
    n
}

pub fn chain_count(a: &mut [u32], b: &mut [u32]) -> usize {
    a.iter_mut().chain(b.iter_mut()).count()
}

/// Two regions through `Enumerate`: a backward function per region.
pub fn zip_enumerate(a: &mut [u32], b: &mut [u32]) {
    for (i, (x, y)) in a.iter_mut().zip(b.iter_mut()).enumerate() {
        *x = *y + i as u32;
        *y = 0;
    }
}

/// The FFT butterfly loop's shape: two regions consumed by `for_each`.
pub fn butterflies(left: &mut [u64], right: &mut [u64], twiddles: &[u64]) {
    left.iter_mut().zip(right.iter_mut()).enumerate().for_each(|(i, (a, b))| {
        let t = b.wrapping_mul(twiddles[i]);
        *b = a.wrapping_sub(t);
        *a = a.wrapping_add(t);
    });
}

pub fn for_each_bump(a: &mut [u32]) {
    a.iter_mut().for_each(|x| *x += 1);
}

pub fn fold_bump_sum(a: &mut [u32]) -> u32 {
    a.iter_mut().fold(0u32, |s, x| {
        *x += 1;
        s.wrapping_add(*x)
    })
}

pub fn count_mut(a: &mut [u32]) -> usize {
    a.iter_mut().count()
}
