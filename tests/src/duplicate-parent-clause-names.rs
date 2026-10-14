//@ [!lean] skip
//! A trait bounding both `Self` and an associated type by the same trait - the PLONK
//! verifier's `PolynomialCommitmentScheme: Clone` with `type Commitment: Clone`. The two parent
//! clauses were both named `corecloneCloneInst`, a duplicate structure field in Lean.

pub trait Scheme: Clone {
    type Commitment: Clone;

    fn commit(&self) -> Self::Commitment;
}

pub fn commit_twice<S: Scheme>(s: &S) -> (S::Commitment, S::Commitment) {
    let c = s.clone().commit();
    (c.clone(), c)
}
