//@ [!lean] skip
//! Small `core`/`alloc` functions the PLONK verifier calls, which Aeneas Std left as axioms.
//! Overflow and out-of-bounds cases panic, as in debug Rust (Aeneas' arithmetic convention).
use std::borrow::Borrow;
use std::cmp::Ordering;
use std::marker::PhantomData;

pub fn option_order(a: &Option<u32>, b: &Option<u32>) -> Ordering {
    a.cmp(b)
}

pub fn option_partial_order(a: &Option<u32>, b: &Option<u32>) -> Option<Ordering> {
    a.partial_cmp(b)
}

pub fn option_same(a: &Option<u32>, b: &Option<u32>) -> bool {
    a == b
}

pub fn or_default(a: Option<u32>) -> u32 {
    a.unwrap_or_default()
}

pub fn pair_same(a: &(u32, u64), b: &(u32, u64)) -> bool {
    a == b
}

/// `Ord` for `&A`
pub fn ref_order(a: &u32, b: &u32) -> Ordering {
    Ord::cmp(&a, &b)
}

pub fn abs(x: i32) -> i32 {
    x.abs()
}

pub fn unsigned_abs(x: i64) -> u64 {
    x.unsigned_abs()
}

pub fn div_ceil(a: usize, b: usize) -> usize {
    a.div_ceil(b)
}

pub fn next_power_of_two(x: usize) -> usize {
    x.next_power_of_two()
}

pub fn swap_remove(v: &mut Vec<u32>, i: usize) -> u32 {
    v.swap_remove(i)
}

/// `Option<&T>::copied`
pub fn copied(x: Option<&u32>) -> Option<u32> {
    x.copied()
}

/// The head and the tail's length
pub fn split_first(s: &[u32]) -> Option<(u32, usize)> {
    s.split_first().map(|(h, t)| (*h, t.len()))
}

pub fn from_ref(x: &u32) -> usize {
    std::slice::from_ref(x).len()
}

pub fn phantom() -> PhantomData<u32> {
    PhantomData::default()
}

pub fn borrowed(x: &u32) -> u32 {
    *Borrow::<u32>::borrow(x)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn values() {
        assert_eq!(option_order(&None, &Some(0)), Ordering::Less);
        assert_eq!(option_order(&Some(2), &Some(1)), Ordering::Greater);
        assert_eq!(option_order(&None, &None), Ordering::Equal);
        assert_eq!(option_partial_order(&Some(1), &Some(2)), Some(Ordering::Less));
        assert!(option_same(&Some(3), &Some(3)));
        assert!(!option_same(&Some(3), &None));
        assert_eq!(or_default(None), 0);
        assert_eq!(or_default(Some(5)), 5);
        assert!(pair_same(&(1, 2), &(1, 2)));
        assert!(!pair_same(&(1, 2), &(1, 3)));
        assert_eq!(ref_order(&1, &2), Ordering::Less);
        assert_eq!(abs(-7), 7);
        assert!(std::panic::catch_unwind(|| abs(i32::MIN)).is_err());
        assert_eq!(unsigned_abs(i64::MIN), 1 << 63);
        assert_eq!(div_ceil(7, 2), 4);
        assert_eq!(div_ceil(8, 2), 4);
        assert_eq!(div_ceil(0, 3), 0);
        assert_eq!(div_ceil(usize::MAX, 2), usize::MAX / 2 + 1);
        assert!(std::panic::catch_unwind(|| div_ceil(1, 0)).is_err());
        assert_eq!(next_power_of_two(0), 1);
        assert_eq!(next_power_of_two(5), 8);
        assert_eq!(next_power_of_two(8), 8);
        assert!(std::panic::catch_unwind(|| next_power_of_two(usize::MAX)).is_err());
        let mut v = vec![10, 20, 30, 40];
        assert_eq!(swap_remove(&mut v, 1), 20);
        assert_eq!(v, vec![10, 40, 30]);
        assert_eq!(swap_remove(&mut v, 2), 30);
        assert_eq!(v, vec![10, 40]);
        assert!(std::panic::catch_unwind(|| swap_remove(&mut vec![1], 1)).is_err());
        assert_eq!(split_first(&[4, 5, 6]), Some((4, 2)));
        assert_eq!(split_first(&[]), None);
        assert_eq!(copied(Some(&4)), Some(4));
        assert_eq!(copied(None), None);
        assert_eq!(from_ref(&9), 1);
        let _ = phantom();
        assert_eq!(borrowed(&11), 11);
    }
}
