//@ [!lean] skip
//! The shape of a parallel divide-and-conquer (`rayon::join`): a function recursing into both
//! halves of a slice through two closures (aeneas#1264). `sum_direct` is the same computation
//! without closures, which Aeneas always supported.

fn join<A: FnOnce() -> RA, B: FnOnce() -> RB, RA, RB>(a: A, b: B) -> (RA, RB) {
    (a(), b())
}

pub fn sum(s: &[u32]) -> u32 {
    if s.len() <= 1 {
        if s.len() == 1 { s[0] } else { 0 }
    } else {
        let (l, r) = s.split_at(s.len() / 2);
        let (x, y) = join(|| sum(l), || sum(r));
        x.wrapping_add(y)
    }
}

pub fn sum_direct(s: &[u32]) -> u32 {
    if s.len() <= 1 {
        if s.len() == 1 { s[0] } else { 0 }
    } else {
        let (l, r) = s.split_at(s.len() / 2);
        let x = sum_direct(l);
        let y = sum_direct(r);
        x.wrapping_add(y)
    }
}

/// Recursion through both closures on a counter, for an equivalence proof by induction.
pub fn tree(n: u32) -> u32 {
    if n == 0 {
        1
    } else {
        let (a, b) = join(|| tree(n - 1), || tree(n - 1));
        a.wrapping_add(b)
    }
}

pub fn tree_direct(n: u32) -> u32 {
    if n == 0 {
        1
    } else {
        let a = tree_direct(n - 1);
        let b = tree_direct(n - 1);
        a.wrapping_add(b)
    }
}
