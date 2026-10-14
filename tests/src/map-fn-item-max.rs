//@ [!lean] skip
//! `max` over a `map` by a function item - the KZG verifier's
//! `q_coms.iter().map(Vec::len).max().unwrap_or(0)`.

pub fn longest(v: &Vec<Vec<u32>>) -> usize {
    v.iter().map(Vec::len).max().unwrap_or(0)
}
