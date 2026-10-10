//@ [!lean] skip
//@ [lean] subdir=SliceIterFind
//@ [lean] aeneas-args=-split-files
//! `find` on slice iterators - the KZG verifier's `inners.iter().find(|c| ..)`. Its predicate,
//! `for<'b> FnMut(&'b &'a T) -> bool`, implies `'a: 'b` between the higher-ranked `'b` and the
//! free `'a`; a shared borrow gives nothing back, so the bound constrains nothing Aeneas
//! tracks.

pub fn find_even(s: &[u32]) -> Option<u32> {
    s.iter().find(|x| **x % 2 == 0).copied()
}

pub fn bump_first_even(s: &mut [u32]) {
    if let Some(x) = s.iter_mut().find(|x| **x % 2 == 0) {
        *x += 1;
    }
}
