//@ [!lean] skip
//! Slice patterns, which read the slice's length through its pointer metadata - the KZG
//! verifier's `match inners.as_slice() { [single @ Linear(..)] => .., _ => .. }`.

pub fn single(s: &[u32]) -> u32 {
    match s {
        [x] => *x,
        _ => 0,
    }
}

pub fn first_of_two(s: &[u32]) -> Option<u32> {
    match s {
        [x, _] => Some(*x),
        _ => None,
    }
}
