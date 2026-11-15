//@ [!lean] skip
//! Generic associated types with type parameters only ("GAT-lite"): no lifetimes, const
//! generics, bounds or where-clauses on the GAT. Charon keeps such types as associated types
//! when it lifts the plain ones to trait parameters; Aeneas extracts them as a field of kind
//! `Type → Type`, the impl's value as `fun X => ...`, and a projection applied to its arguments.
//!
//! No closures and no recursion through trait methods, so this isolates GAT translation from
//! the other limitations (mixed recursive groups).

pub trait Shape {
    type Layer<X>;
    fn wrap<X>(x: X) -> Self::Layer<X>;
    fn unwrap<X>(l: Self::Layer<X>) -> Option<X>;
}

/// Nil | Cons(head, rest) with a `u32` head.
pub struct ListF;

impl Shape for ListF {
    type Layer<X> = Option<(u32, X)>;
    fn wrap<X>(x: X) -> Option<(u32, X)> {
        Some((0, x))
    }
    fn unwrap<X>(l: Option<(u32, X)>) -> Option<X> {
        match l {
            None => None,
            Some((_, x)) => Some(x),
        }
    }
}

/// Generic over the shape: the signature and the body mention `S::Layer<X>`.
pub fn roundtrip<S: Shape, X>(x: X) -> Option<X> {
    let l: S::Layer<X> = S::wrap(x);
    S::unwrap(l)
}

/// Concrete instantiation.
pub fn roundtrip_list(x: u32) -> Option<u32> {
    roundtrip::<ListF, u32>(x)
}
