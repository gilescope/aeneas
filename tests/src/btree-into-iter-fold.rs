//@ [!lean] skip
//! Folding over a `BTreeMap`'s and a `BTreeSet`'s `into_iter`, through their `Iterator`
//! instances - the PLONK verifier's linearization. The instances' key and value types are
//! explicit arguments (only the allocator's is inferred from the instance's argument).
use std::collections::{BTreeMap, BTreeSet};

pub fn sum_map(m: BTreeMap<u32, u32>) -> u32 {
    m.into_iter().fold(0, |a, (k, v)| a.wrapping_add(k).wrapping_add(v))
}

pub fn sum_set(s: BTreeSet<u32>) -> u32 {
    s.into_iter().fold(0, |a, x| a.wrapping_add(x))
}
