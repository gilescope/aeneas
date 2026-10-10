//@ [!lean] skip
//@ [lean] subdir=VecExtra
//@ [lean] aeneas-args=-split-files
//! `Vec`'s API and `Hash` impls met by midnight-proofs: every call below has a model in Std, so
//! the extraction declares no external.
use std::hash::{Hash, Hasher};

pub fn vec_ops(mut v: Vec<u32>, mut w: Vec<u32>) -> (Vec<u32>, bool) {
    v.reserve(4);
    v.extend(vec![1u32, 2]);
    v.append(&mut w);
    v.truncate(3);
    let empty = v.as_slice().is_empty() || v.is_empty() || w.is_empty();
    let d: Vec<u32> = Vec::default();
    v.extend(d);
    (v, empty)
}

pub fn longest(v: &Vec<Vec<u32>>) -> usize {
    v.iter().map(Vec::len).max().unwrap_or(0)
}

#[derive(Hash)]
pub enum Label {
    Fixed(usize),
    Offset(isize),
    Collection(Vec<Label>),
}

pub fn hash_label<H: Hasher>(l: &Label, h: &mut H) {
    l.hash(h)
}

pub fn hash_ref<H: Hasher>(x: &u32, h: &mut H) {
    (&x).hash(h)
}
