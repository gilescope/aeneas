//@ [!lean] skip
//@ [lean] known-failure
//! A generic associated type with a trait bound. GAT-lite translates GATs with type
//! parameters only; a bound on the GAT (here `: Clone`) is rejected with a clear error rather
//! than the `Unimplemented` crash of AeneasVerif/aeneas#1195. This test locks in that error
//! path: the expected output is the error message.

pub trait Shape {
    type Layer<X>: Clone;
    fn wrap<X>(x: X) -> Self::Layer<X>;
}

pub struct ListF;

impl Shape for ListF {
    type Layer<X> = Option<u32>;
    fn wrap<X>(_x: X) -> Option<u32> {
        Some(0)
    }
}

pub fn wrap_list(x: u32) -> Option<u32> {
    ListF::wrap(x)
}
