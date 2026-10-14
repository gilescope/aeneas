//@ [!lean] skip
//@ [lean] subdir=CtorClosureAdapter
//! Extraction-only (no root module: std's `Iterator::filter` has no Lean model yet): an enum
//! constructor used as a closure after an adapter holding a borrow, as in the PLONK verifier's
//! `ConstraintSystem::fixed_polys_labels`. The constructor's function item type appears in
//! `Map<Filter<Range<usize>, {closure}<'a>>, Label::Fixed>`, and comparing projections over it
//! met an unexpected type.

pub enum Label {
    Fixed(usize),
    NoLabel,
}

pub struct Columns {
    n: usize,
    simple: Vec<usize>,
}

impl Columns {
    fn is_simple(&self, i: usize) -> bool {
        self.simple.len() > i
    }

    pub fn first_fixed(&self) -> Option<Label> {
        (0..self.n).filter(|&i| !self.is_simple(i)).map(Label::Fixed).next()
    }
}
