//@ [!lean] skip
//@ [lean] aeneas-args=-filter-trait-methods
//! Adapters over `iter_mut()` give the `&mut` items back: a constructor gives the inner
//! iterator back, `next` each item (one backward function per mutable region, so two for
//! `Zip<IterMut, IterMut>`), a consumer the final iterator, and a closure handed a `&mut` item
//! returns it. These shapes are what Aeneas emits; the library's shape classes must match them.
//! The `#[verify::test]` functions check the writes land (`#guard`s in the extracted code).
#![feature(register_tool)]
#![register_tool(verify)]

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
    left.iter_mut()
        .zip(right.iter_mut())
        .enumerate()
        .for_each(|(i, (a, b))| {
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

#[verify::test]
pub fn test_enumerate_set() {
    let mut a = [9u32, 9, 9];
    enumerate_set(&mut a);
    assert!(a[0] == 0 && a[1] == 1 && a[2] == 2);
}

#[verify::test]
pub fn test_take_bump() {
    let mut a = [1u32, 1, 1];
    take_bump(&mut a);
    assert!(a[0] == 2 && a[1] == 2 && a[2] == 1);
}

#[verify::test]
pub fn test_step_by_bump() {
    let mut a = [0u32, 0, 0, 0, 0];
    step_by_bump(&mut a);
    assert!(a[0] == 1 && a[1] == 0 && a[2] == 1 && a[3] == 0 && a[4] == 1);
}

#[verify::test]
pub fn test_skip_bump() {
    let mut a = [0u32, 0, 0];
    skip_bump(&mut a);
    assert!(a[0] == 0 && a[1] == 1 && a[2] == 1);
}

#[verify::test]
pub fn test_chain_bump() {
    let mut a = [0u32, 0];
    let mut b = [5u32, 5, 5];
    let n = chain_bump(&mut a, &mut b);
    assert!(n == 5 && a[0] == 1 && a[1] == 1 && b[0] == 6 && b[1] == 6 && b[2] == 6);
}

#[verify::test]
pub fn test_chain_count() {
    let mut a = [0u32, 0];
    let mut b = [0u32, 0, 0];
    assert!(chain_count(&mut a, &mut b) == 5);
}

#[verify::test]
pub fn test_zip_enumerate() {
    let mut a = [0u32, 0, 0];
    let mut b = [10u32, 20, 30];
    zip_enumerate(&mut a, &mut b);
    assert!(a[0] == 10 && a[1] == 21 && a[2] == 32 && b[0] == 0 && b[1] == 0 && b[2] == 0);
}

#[verify::test]
pub fn test_butterflies() {
    let mut l = [10u64, 50];
    let mut r = [3u64, 4];
    butterflies(&mut l, &mut r, &[1, 10]);
    assert!(l[0] == 13 && l[1] == 90 && r[0] == 7 && r[1] == 10);
}

#[verify::test]
pub fn test_for_each_bump() {
    let mut a = [1u32, 2];
    for_each_bump(&mut a);
    assert!(a[0] == 2 && a[1] == 3);
}

#[verify::test]
pub fn test_fold_bump_sum() {
    let mut a = [1u32, 2];
    let s = fold_bump_sum(&mut a);
    assert!(s == 5 && a[0] == 2 && a[1] == 3);
}

#[verify::test]
pub fn test_count_mut() {
    let mut a = [0u32, 0, 0, 0];
    assert!(count_mut(&mut a) == 4);
}
