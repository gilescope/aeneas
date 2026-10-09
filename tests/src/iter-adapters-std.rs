//@ [!lean] skip
//@ [lean] aeneas-args=-filter-trait-methods
//! The iterator adapters and consumers the PLONK verifier uses, over slice iterators:
//! `once`, `empty`, `map`, `filter`, `filter_map`, `chain`, `flat_map`, then `fold`, `count`,
//! `any`, `max`, `max_by(Ord::cmp)`, `sum` and `size_hint`. Closures capture nothing, so the
//! extracted Lean can be evaluated.

pub fn sum_doubled(v: &[u32]) -> u32 {
    v.iter().map(|x| x * 2).fold(0, |a, x| a + x)
}

pub fn count_even(v: &[u32]) -> usize {
    v.iter().filter(|x| **x % 2 == 0).count()
}

pub fn any_big(v: &[u32]) -> bool {
    v.iter().any(|x| *x > 10)
}

pub fn halves(v: &[u32]) -> u32 {
    v.iter()
        .filter_map(|x| if x % 2 == 0 { Some(x / 2) } else { None })
        .fold(0, |a, x| a + x)
}

pub fn chained(a: &[u32], b: &[u32]) -> usize {
    a.iter().chain(b.iter()).count()
}

pub fn chained_sum(a: &[u32], b: &[u32]) -> u32 {
    a.iter().chain(b.iter()).fold(0, |s, x| s + x)
}

/// Every element, then its successor
pub fn flat(v: &[u32]) -> u32 {
    v.iter()
        .flat_map(|x| std::iter::once(*x).chain(std::iter::once(x + 1)))
        .fold(0, |a, x| a * 10 + x)
}

pub fn once_then_empty(x: u32) -> usize {
    std::iter::once(x).chain(std::iter::empty()).count()
}

pub fn largest(v: &[usize]) -> Option<usize> {
    v.iter().map(|x| *x).max()
}

/// Ties go to the last maximum, as in `max_by`
pub fn largest_by(v: &[usize]) -> Option<usize> {
    v.iter().map(|x| *x).max_by(Ord::cmp)
}

pub fn total(v: &[usize]) -> usize {
    v.iter().map(|x| *x).sum()
}

pub fn hint(v: &[u32]) -> (usize, Option<usize>) {
    v.iter().map(|x| x + 1).size_hint()
}

pub fn filter_hint(v: &[u32]) -> (usize, Option<usize>) {
    v.iter().filter(|x| **x > 1).size_hint()
}

pub fn chain_hint(a: &[u32], b: &[u32]) -> (usize, Option<usize>) {
    a.iter().chain(b.iter()).size_hint()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn values() {
        assert_eq!(sum_doubled(&[1, 2, 3]), 12);
        assert_eq!(count_even(&[1, 2, 4, 5]), 2);
        assert!(any_big(&[1, 11]));
        assert!(!any_big(&[1, 2]));
        assert_eq!(halves(&[2, 3, 8]), 5);
        assert_eq!(chained(&[1, 2], &[3]), 3);
        assert_eq!(chained_sum(&[1, 2], &[3]), 6);
        assert_eq!(flat(&[1, 3]), 1234);
        assert_eq!(once_then_empty(7), 1);
        assert_eq!(largest(&[3, 9, 2]), Some(9));
        assert_eq!(largest(&[]), None);
        assert_eq!(largest_by(&[3, 9, 9, 2]), Some(9));
        assert_eq!(total(&[1, 2, 3]), 6);
        assert_eq!(hint(&[1, 2, 3]), (3, Some(3)));
        assert_eq!(filter_hint(&[1, 2, 3]), (0, Some(3)));
        assert_eq!(chain_hint(&[1, 2], &[3]), (3, Some(3)));
    }
}
