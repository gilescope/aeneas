//@ [!lean] skip
//! Closures returning closures that borrow both what the outer closure captured and its
//! argument, and an `impl Fn` result: the inner closure types (and the `&'_ T`s around them)
//! have erased lifetimes, which Aeneas needs to name.
pub trait Pcs {
    type Commitment;
}

pub struct Evaluated<F, C: Pcs> {
    pub evals: Vec<(u32, Vec<F>)>,
    pub commitment: C::Commitment,
}

impl<F: Copy, C: Pcs> Evaluated<F, C> {
    /// The outer closure returns an inner one borrowing `label` (from its argument) and
    /// `self.commitment` (from its capture).
    pub fn first<'s>(&'s self) -> (u32, F, &'s C::Commitment) {
        let pick =
            move |(label, _): &'s (u32, Vec<F>)| move |e: &'s F| (*label, *e, &self.commitment);
        let inner = pick(&self.evals[0]);
        inner(&self.evals[0].1[0])
    }

    /// An `impl Fn` result whose closure borrows `self`.
    pub fn query<'s>(&'s self) -> impl Fn(&F) -> (u32, F, &'s C::Commitment) + 's {
        let label = self.evals[0].0;
        move |e| (label, *e, &self.commitment)
    }
}

// Concrete results, checked against the extracted Lean in tests/lean/Differential.lean.
#[cfg(test)]
mod tests {
    use super::*;

    pub struct Unit;
    impl Pcs for Unit {
        type Commitment = u32;
    }

    #[test]
    fn values() {
        let e = Evaluated::<u32, Unit> {
            evals: vec![(3, vec![9, 8])],
            commitment: 42,
        };
        assert_eq!(e.first(), (3, 9, &42));
        assert_eq!(e.query()(&8), (3, 8, &42));
    }
}
