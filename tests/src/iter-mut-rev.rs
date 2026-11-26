//@ [!lean] skip
//@ [lean] aeneas-args=-filter-trait-methods
//! `rev()` over `iter_mut()`: `Rev::next` reaches the item through the `DoubleEndedIterator`
//! impl's parent `Iterator` clause, whose region Charon used to erase, so the item was never
//! given back (the loop's writes were lost). The `#[verify::test]` functions check they land.
#![feature(register_tool)]
#![register_tool(verify)]

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

#[verify::test]
pub fn test_rev_set() {
    let mut a = [9u32, 9, 9];
    rev_set(&mut a);
    assert!(a[0] == 2 && a[1] == 1 && a[2] == 0);
}

#[verify::test]
pub fn test_rev_enumerate() {
    let mut a = [9u32, 9, 9];
    rev_enumerate(&mut a);
    assert!(a[0] == 2 && a[1] == 1 && a[2] == 0);
}

#[verify::test]
pub fn test_rev_bump_sum() {
    let mut a = [1u32, 2, 3];
    let s = rev_bump_sum(&mut a);
    assert!(s == 9 && a[0] == 2 && a[1] == 3 && a[2] == 4);
}
