//@ [!lean] skip
//! `Iterator::rev`'s default, whose `Iterator` and `DoubleEndedIterator` bounds reach `Item`
//! twice (a diamond), modelled in the Lean library with both: the diamond prepass must leave
//! library functions' signatures alone, or calls pass the merged `Item` explicitly.
pub fn sum_rev(xs: &[u64]) -> u64 {
    let mut s = 0u64;
    for x in xs.iter().rev() {
        let mut i = 0;
        for _ in (0..4i32).rev() {
            i += 1;
        }
        s = s.wrapping_add(*x).wrapping_add(i);
    }
    s
}
