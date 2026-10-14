//@ [!lean] skip
//@ [lean] subdir=MiscExtra
//@ [lean] aeneas-args=-split-files
//! `str`/`String`, formatting and misc std functions met by midnight-proofs: every call below has
//! a model in Std, so the extraction declares no external.
use std::fmt;
use std::hash::{Hash, Hasher};
use std::marker::PhantomData;

pub struct Label(pub u32);

impl fmt::Display for Label {
    fn fmt(&self, f: &mut fmt::Formatter<'_>) -> fmt::Result {
        f.write_str("label")
    }
}

#[derive(Debug, Clone)]
pub struct Tagged<T> {
    pub name: String,
    pub marker: PhantomData<T>,
}

pub fn strings<H: Hasher>(l: &Label, h: &mut H) -> (String, String) {
    let s = String::from("π");
    s.hash(h);
    let t = (&l).to_string();
    (s, t)
}

pub fn misc(b: bool, x: usize) -> (Option<u32>, u32) {
    (b.then_some(7), x.ilog2())
}

pub fn conv(x: u64) -> Result<u32, String> {
    u32::try_from(x).map_err(|e| format!("{e:?}"))
}

pub fn tagged(t: &Tagged<u8>) -> Tagged<u8> {
    let _ = format!("{t:?}");
    t.clone()
}
