//@ [!lean] skip
//@ [lean] aeneas-args=-filter-trait-methods
//! Std iterators' own `count`, `fold`, `max`, `size_hint` (array, `Vec` and range iterators,
//! `Enumerate`, `Zip`, `Chunks`, `IterMut`), `Range` clones, `&Vec` iteration and `collect` into
//! a `Result`: the remaining iterator items the PLONK verifier uses.

pub fn array_sum(a: [u32; 3]) -> u32 {
    a.into_iter().fold(0, |s, x| s + x)
}

pub fn array_len(a: [u32; 3]) -> usize {
    a.into_iter().count()
}

pub fn array_hint(a: [u32; 3]) -> (usize, Option<usize>) {
    let mut it = a.into_iter();
    it.next();
    it.size_hint()
}

pub fn vec_sum(v: Vec<u32>) -> u32 {
    v.into_iter().fold(0, |s, x| s + x)
}

pub fn vec_len(v: Vec<u32>) -> usize {
    v.into_iter().count()
}

pub fn ref_vec_sum(v: &Vec<u32>) -> u32 {
    let mut s = 0;
    for x in v {
        s += x;
    }
    s
}

pub fn indexed(v: &[u32]) -> usize {
    v.iter().enumerate().fold(0, |s, (i, x)| s + i * (*x as usize))
}

pub fn indexed_len(v: &[u32]) -> usize {
    v.iter().enumerate().count()
}

pub fn dot(a: &[u32], b: &[u32]) -> u32 {
    a.iter().zip(b.iter()).fold(0, |s, (x, y)| s + x * y)
}

pub fn zip_hint(a: &[u32], b: &[u32]) -> (usize, Option<usize>) {
    a.iter().zip(b.iter()).size_hint()
}

pub fn flat_len(v: &[u32]) -> usize {
    v.iter().flat_map(|x| 0..*x).count()
}

pub fn range_len(a: usize, b: usize) -> usize {
    (a..b).count()
}

pub fn range_max(a: usize, b: usize) -> Option<usize> {
    (a..b).max()
}

pub fn incl_len(a: usize, b: usize) -> usize {
    (a..=b).count()
}

pub fn incl_sum(a: usize, b: usize) -> usize {
    (a..=b).fold(0, |s, x| s + x)
}

pub fn incl_max(a: usize, b: usize) -> Option<usize> {
    (a..=b).max()
}

pub fn range_twice(r: std::ops::Range<usize>) -> usize {
    r.clone().count() + r.count()
}

pub fn incl_twice(r: std::ops::RangeInclusive<usize>) -> usize {
    r.clone().count() + r.count()
}

pub fn chunk_count(v: &[u32], n: usize) -> usize {
    v.chunks(n).count()
}

pub fn chunk_hint(v: &[u32], n: usize) -> (usize, Option<usize>) {
    v.chunks(n).size_hint()
}

/// The length of the last chunk
pub fn last_chunk(v: &[u32], n: usize) -> usize {
    let mut last = 0;
    for c in v.chunks(n) {
        last = c.len();
    }
    last
}

// Not `iter_mut().fold(..)`: its closure writes through `&mut T`, which the extracted `FnMut`
// signature cannot give back, so it has no model.

pub fn mut_len(v: &mut [u32]) -> usize {
    v.iter_mut().count()
}

pub fn mut_hint(v: &mut [u32]) -> (usize, Option<usize>) {
    v.iter_mut().size_hint()
}

pub fn halve_checked(v: &[u32]) -> Result<Vec<u32>, u32> {
    v.iter().map(|x| if x % 2 == 0 { Ok(x / 2) } else { Err(*x) }).collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn values() {
        assert_eq!(array_sum([1, 2, 3]), 6);
        assert_eq!(array_len([1, 2, 3]), 3);
        assert_eq!(array_hint([1, 2, 3]), (2, Some(2)));
        assert_eq!(vec_sum(vec![1, 2, 3]), 6);
        assert_eq!(vec_len(vec![1, 2, 3]), 3);
        assert_eq!(ref_vec_sum(&vec![1, 2, 3]), 6);
        assert_eq!(indexed(&[5, 6, 7]), 20);
        assert_eq!(indexed_len(&[5, 6, 7]), 3);
        assert_eq!(dot(&[1, 2, 3], &[4, 5]), 14);
        assert_eq!(zip_hint(&[1, 2, 3], &[4, 5]), (2, Some(2)));
        assert_eq!(flat_len(&[2, 0, 3]), 5);
        assert_eq!(range_len(3, 7), 4);
        assert_eq!(range_len(7, 3), 0);
        assert_eq!(range_max(3, 7), Some(6));
        assert_eq!(range_max(3, 3), None);
        assert_eq!(incl_len(3, 7), 5);
        assert_eq!(incl_len(7, 3), 0);
        assert_eq!(incl_sum(1, 4), 10);
        assert_eq!(incl_max(3, 7), Some(7));
        assert_eq!(incl_max(7, 3), None);
        assert_eq!(range_twice(2..5), 6);
        assert_eq!(incl_twice(2..=5), 8);
        assert_eq!(chunk_count(&[1, 2, 3, 4, 5], 2), 3);
        assert_eq!(chunk_count(&[], 2), 0);
        assert_eq!(chunk_hint(&[1, 2, 3, 4, 5], 2), (3, Some(3)));
        assert_eq!(last_chunk(&[1, 2, 3, 4, 5], 2), 1);
        assert!(std::panic::catch_unwind(|| chunk_count(&[1], 0)).is_err());
        assert_eq!(mut_len(&mut [1, 2]), 2);
        assert_eq!(mut_hint(&mut [1, 2]), (2, Some(2)));
        assert_eq!(halve_checked(&[2, 4]), Ok(vec![1, 2]));
        assert_eq!(halve_checked(&[2, 3, 5]), Err(3));
    }
}
