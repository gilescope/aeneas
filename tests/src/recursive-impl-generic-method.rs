//@ [!lean] skip
//! Recursion through a trait impl whose method is generic - the derived `Hash` of the KZG
//! verifier's `PolynomialLabel`, whose `Collection(Vec<PolynomialLabel>)` variant hashes the
//! nested labels with `hash<H: Hasher>`. Inside the recursive group the impl is inlined
//! (aeneas#1264), including its generic method.

pub trait Visit {
    fn visit<V: Fn(u32) -> u32>(&self, v: &V) -> u32;
}

pub enum Tree {
    Leaf(u32),
    Node(Vec<Tree>),
}

impl Visit for Tree {
    fn visit<V: Fn(u32) -> u32>(&self, v: &V) -> u32 {
        match self {
            Tree::Leaf(x) => v(*x),
            Tree::Node(ts) => visit_all(ts, v),
        }
    }
}

pub fn visit_all<T: Visit, V: Fn(u32) -> u32>(ts: &[T], v: &V) -> u32 {
    let mut s = 0u32;
    for t in ts {
        s = s.wrapping_add(t.visit(v));
    }
    s
}
