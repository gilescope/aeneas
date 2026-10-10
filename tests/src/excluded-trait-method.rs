//@ [!lean] skip
//@ charon-args=--exclude=crate::Circuit --exclude=crate::Params::size_for
//! A trait with a provided method whose signature names an excluded trait (as
//! midnight-proofs' `Params::downsize_from_circuit` names `Circuit`): Charon keeps the
//! method's signature in the trait declaration, with a clause to a trait that is not in the
//! crate. The method must go with it, and the rest of the trait still be modelled.
pub trait Circuit {
    fn rows(&self) -> u32;
}

pub trait Params {
    fn k(&self) -> u32;

    fn size_for<C: Circuit>(&self, circuit: &C) -> u32 {
        circuit.rows().max(self.k())
    }
}

pub struct Srs {
    pub k: u32,
}

impl Params for Srs {
    fn k(&self) -> u32 {
        self.k
    }
}

pub fn double_k<P: Params>(p: &P) -> u32 {
    p.k() * 2
}
