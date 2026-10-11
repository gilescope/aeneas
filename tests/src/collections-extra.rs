//@ [!lean] skip
//@ [lean] subdir=CollectionsExtra
//@ [lean] aeneas-args=-split-files
//! `HashMap`, `HashSet`, `BTreeMap` and `BTreeSet` operations met by midnight-proofs'
//! `construct_intermediate_sets`: every call below has a model in Std.
use std::collections::{BTreeMap, BTreeSet, HashMap, HashSet};

pub fn counts(keys: &[u32]) -> (usize, Option<u32>, usize) {
    let mut m: HashMap<u32, u32> = HashMap::new();
    for k in keys {
        *m.entry(*k).or_insert(0) += 1;
    }
    let total = m.iter().fold(0usize, |acc, (_, v)| acc + *v as usize);
    let n = m.iter().count();
    (m.len(), m.get(&1).copied(), total + n)
}

pub fn dedup(keys: &[u32]) -> usize {
    let mut s: HashSet<u32> = HashSet::default();
    let mut fresh = 0;
    for k in keys {
        if s.insert(*k) {
            fresh += 1;
        }
    }
    fresh
}

pub fn sets(a: &BTreeSet<u32>, b: &BTreeSet<u32>, m: &BTreeMap<u32, u32>) -> (bool, bool, Option<u32>, usize) {
    let c = a.clone();
    let same = c == *b && a.cmp(b).is_eq() && a.partial_cmp(b).is_some();
    let largest = a.iter().max().copied();
    let mut n = 0;
    for x in b {
        n += *x as usize;
    }
    (same, a.is_empty(), largest, n + m.len())
}
