//@ [!lean] skip
//! A `for` loop over a generic `IntoIterator`: the loop function needs `I` for the
//! `IntoIterator<I>` clause it calls `next` through, although nothing else names `I`.
pub fn sum<I: IntoIterator<Item = u32>>(xs: I) -> u32 {
    let mut s = 0u32;
    for x in xs {
        s = s.wrapping_add(x);
    }
    s
}
