//@ [!lean] skip
//@ [lean] subdir=IterMutRev
//@ [lean] aeneas-args=-split-files
//@ [lean] aeneas-args=-filter-trait-methods
//! `rev()` over `iter_mut()`: `Rev::next` reaches the item through the `DoubleEndedIterator`
//! impl's parent `Iterator` clause, whose region Charon used to erase, so the item was never
//! given back (the loop's writes were lost). `IterMutRev/Properties.lean` checks they land.

pub fn rev_set(a: &mut [u32]) {
    let mut i = 0;
    for x in a.iter_mut().rev() {
        *x = i;
        i += 1;
    }
}

pub fn rev_enumerate(a: &mut [u32]) {
    for (i, x) in a.iter_mut().rev().enumerate() {
        *x = i as u32;
    }
}

pub fn rev_bump_sum(a: &mut [u32]) -> u32 {
    let mut s = 0;
    for x in a.iter_mut().rev() {
        *x += 1;
        s += *x;
    }
    s
}
