//@ [!lean] skip
//@ aeneas-args=-join-early-exits
//! Joins where a local is initialised in one branch only, or a borrow is reassigned in one
//! branch only (the shapes of `atoi_radix10::parse`).

/// A `Copy` local lives in the `then` block only; after the join it is dead.
pub fn copy_local(s: &[u8], a: bool) -> u32 {
    let mut res = 0u32;
    for _ in 0..1 {
        if a {
            let v = s[0] as u32;
            res = v;
            if s.len() == 1 {
                break;
            }
            res = v * 2;
        }
        res += 1;
    }
    res
}

/// The slice is reborrowed in the `then` block only.
pub fn reborrow_one_side(mut s: &[u8], a: bool) -> usize {
    let mut res = 0usize;
    for _ in 0..1 {
        if a {
            let v = s[0] as usize;
            s = &s[1..];
            if s.is_empty() {
                res = v;
                break;
            }
            res = v * s.len();
        }
        res += s.len();
    }
    res
}

/// Both, with a `return` instead of a `break`.
pub fn reborrow_return(mut s: &[u8], a: bool) -> usize {
    let mut res = 0usize;
    if a {
        let v = s[0] as usize;
        s = &s[1..];
        if s.is_empty() {
            return v;
        }
        res = v * s.len();
    }
    res + s.len()
}
