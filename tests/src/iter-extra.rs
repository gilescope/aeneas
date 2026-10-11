//@ [!lean] skip
//@ [lean] subdir=IterExtra
//@ [lean] aeneas-args=-split-files
//! Iterator adapters met by midnight-proofs' KZG verifier (`powers`, `multi_prepare`, ...): every
//! call below has a model in Std, so the extraction declares no external.

pub fn powers(base: u32) -> impl Iterator<Item = u32> {
    std::iter::successors(Some(1u32), move |p| p.checked_mul(base))
}

pub fn first_powers(base: u32) -> Vec<u32> {
    powers(base).take(4).collect()
}

pub fn sum_cloned(v: &[u32]) -> u32 {
    v.iter().cloned().fold(0u32, |a, x| a.wrapping_add(x))
}

pub fn horner(coeffs: &[u32], x: u32) -> u32 {
    coeffs.iter().rev().fold(0u32, |acc, c| acc.wrapping_mul(x).wrapping_add(*c))
}

pub fn last_pair(a: &[u32], b: &[u32]) -> Option<(u32, u32)> {
    a.iter().zip(b.iter()).rev().next().map(|(x, y)| (*x, *y))
}

pub fn split(v: &[(u32, u64)]) -> (Vec<u32>, Vec<u64>) {
    v.iter().cloned().unzip()
}

pub fn total(v: &[u32]) -> Option<u32> {
    v.iter().cloned().reduce(|a, b| a.wrapping_add(b))
}

pub fn order(lens: &[usize]) -> Vec<usize> {
    let mut order: Vec<usize> = (0..lens.len()).collect();
    order.sort_by_key(|&i| (lens[i], i));
    order
}
