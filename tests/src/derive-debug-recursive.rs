//@ [!lean] skip
//! A derived `Debug` recursing through its own impl as `dyn Debug` (`Collection(Vec<Label>)`):
//! `fmt` and the impl form one recursive group (midnight-proofs `PolynomialLabel`).
#[derive(Debug)]
pub enum Label {
    Fixed(usize),
    Collection(Vec<Label>),
    Helper(usize, Vec<Label>),
    Named { inner: Vec<Label> },
}
