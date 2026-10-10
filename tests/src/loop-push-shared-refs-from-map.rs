//@ [!lean] skip
//! A loop pushing shared references, looked up in a map of shared references, into a vector
//! of vectors - the KZG verifier's `multi_prepare` grouping commitments by point set
//! (`q_coms[set].push(label_to_commitment[&label].clone())`).
use std::collections::BTreeMap;

pub struct C {
    pub x: u64,
}

pub fn group(cs: &[C], keys: Vec<(u32, usize)>, n: usize) -> Vec<Vec<u64>> {
    let m: BTreeMap<u32, &C> = cs.iter().enumerate().map(|(i, c)| (i as u32, c)).collect();
    let mut q: Vec<Vec<&C>> = vec![vec![]; n];
    for (k, i) in keys.into_iter() {
        q[i].push(m[&k]);
    }
    q.iter().map(|v| v.iter().map(|c| c.x).collect()).collect()
}
