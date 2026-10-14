//@ [!lean] skip
//@ [lean] aeneas-args=-filter-trait-methods
//! `BTreeMap` and `BTreeSet` as the PLONK verifier uses them: `new`, `insert`, `get`, `[]`,
//! `entry().or_insert()`, iteration in key order, `iter().max()` and `collect` (sorted, the
//! last of duplicate keys winning).
use std::collections::{BTreeMap, BTreeSet};

/// The value inserted last for each key, and what `insert` returned
pub fn insert_twice(k: u32) -> (Option<u32>, Option<u32>, Option<u32>) {
    let mut m = BTreeMap::new();
    let a = m.insert(k, 1);
    let b = m.insert(k, 2);
    (a, b, m.get(&k).copied())
}

pub fn lookup(m: &BTreeMap<u32, u32>, k: u32) -> Option<u32> {
    m.get(&k).copied()
}

pub fn index(m: &BTreeMap<u32, u32>, k: u32) -> u32 {
    m[&k]
}

/// Counts occurrences with `entry().or_insert()`
pub fn histogram(v: &[u32]) -> BTreeMap<u32, u32> {
    let mut m = BTreeMap::new();
    for x in v {
        *m.entry(*x).or_insert(0) += 1;
    }
    m
}

/// Keys then values, in key order
pub fn flatten(m: BTreeMap<u32, u32>) -> Vec<u32> {
    let mut out = Vec::new();
    for (k, v) in m {
        out.push(k);
        out.push(v);
    }
    out
}

pub fn largest(m: &BTreeMap<u32, u32>) -> Option<(u32, u32)> {
    m.iter().max().map(|(k, v)| (*k, *v))
}

pub fn from_pairs(v: &[(u32, u32)]) -> BTreeMap<u32, u32> {
    v.iter().map(|p| *p).collect()
}

pub fn sorted_unique(v: &[u32]) -> Vec<u32> {
    let s: BTreeSet<u32> = v.iter().map(|p| *p).collect();
    let mut out = Vec::new();
    for x in s {
        out.push(x);
    }
    out
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn values() {
        assert_eq!(insert_twice(5), (None, Some(1), Some(2)));
        let m = histogram(&[3, 1, 3, 2, 3]);
        assert_eq!(flatten(m.clone()), vec![1, 1, 2, 1, 3, 3]);
        assert_eq!(lookup(&m, 3), Some(3));
        assert_eq!(lookup(&m, 4), None);
        assert_eq!(index(&m, 2), 1);
        assert!(std::panic::catch_unwind(|| index(&m, 4)).is_err());
        assert_eq!(largest(&m), Some((3, 3)));
        assert_eq!(largest(&BTreeMap::new()), None);
        assert_eq!(flatten(from_pairs(&[(2, 20), (1, 10), (2, 21)])), vec![1, 10, 2, 21]);
        assert_eq!(sorted_unique(&[3, 1, 3, 2]), vec![1, 2, 3]);
    }
}
