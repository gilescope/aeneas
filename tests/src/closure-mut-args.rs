//@ [!lean] skip
//@ charon-args=--opaque=crate::each
//@ [lean] subdir=ClosureMutArgs
//@ [lean] aeneas-args=-split-files
//! A closure taking a `&mut` argument, handed to an opaque function: the closure's `FnMut`
//! instance gives the argument back in its output (`Output × u32`), and the hand-written model
//! of `each` (`ClosureMutArgs/FunsExternal.lean`) writes it back.

pub fn each<F: FnMut(&mut u32)>(s: &mut [u32], mut f: F) {
    for x in s.iter_mut() {
        f(x)
    }
}

pub fn incr(s: &mut [u32]) {
    each(s, |x| *x = x.wrapping_add(1));
}
