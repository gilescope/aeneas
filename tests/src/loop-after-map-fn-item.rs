//@ [!lean] skip
//! A loop after `iter().map(Vec::len).max()`: the iterator's abstractions, whose fn-item type
//! keeps `'static` in its generics, must match at the loop's fixed point (midnight-proofs
//! `KZGCommitmentScheme::multi_prepare`).
pub fn sum_after_longest(v: &Vec<Vec<u32>>, n: u32) -> usize {
    let m = v.iter().map(Vec::len).max().unwrap_or(0);
    let mut acc = m;
    for _ in 0..n {
        acc += 1;
    }
    acc
}
