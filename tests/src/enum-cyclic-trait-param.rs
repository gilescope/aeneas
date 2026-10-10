//@ [!lean] skip
//! An enum bounded by a trait in a cycle (midnight-curves' `CurveExt`/`CurveAffine`) whose
//! clause Charon keeps, since a path around the cycle stays an associated type. The enum's type
//! parameters are then implicit (inferred from the clause), so its constructors' result type
//! must apply the explicit parameters and the clause only (midnight-proofs
//! `KZGCommitment<E: MultiMillerLoop>`).
pub trait Field: Copy {
    type Repr;
}

pub trait Group: Sized {
    type Scalar: Field;
}

pub trait Proj: Group {
    type Affine: Affine<Proj = Self>;
}

pub trait Affine: Sized {
    type Proj: Proj<Affine = Self>;
}

pub enum Commitment<A: Affine> {
    Simple(A),
    Linear(Vec<A>, Vec<<A::Proj as Group>::Scalar>),
}

pub fn count<A: Affine>(c: &Commitment<A>) -> usize {
    match c {
        Commitment::Simple(_) => 1,
        Commitment::Linear(ps, _) => ps.len(),
    }
}

/// The closure's state type keeps the clause too, so its `GivesBack` instance must apply the
/// explicit parameters only.
pub fn count_first<A: Affine>(cs: &[Commitment<A>], n: &mut usize) {
    let mut add = |c| *n += count(c);
    add(&cs[0]);
}
