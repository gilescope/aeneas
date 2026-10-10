//@ [!lean] skip
//! Traits naming each other through their associated types' bounds - the KZG verifier's
//! `CurveAffine` and `CurveExt` - with an equality on one of them in a where clause
//! (`E::G1Affine: CurveAffine<ScalarExt = E::Fr>`). Charon lifts the associated types to
//! parameters; one of the two bounds is dropped so that the Lean structures are not mutually
//! recursive.

pub trait Proj: Sized {
    type Scalar: Copy;
    type Affine: Affine<ScalarA = Self::Scalar, ProjA = Self>;
}

pub trait Affine: Sized {
    type ScalarA: Copy;
    type ProjA: Proj<Scalar = Self::ScalarA, Affine = Self>;

    fn get(&self) -> Self::ScalarA;
}

pub fn scalar<F: Copy, A: Affine<ScalarA = F>>(a: &A) -> F {
    a.get()
}
