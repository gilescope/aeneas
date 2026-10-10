//@ [!lean] skip
//! An equality between associated types in a where clause, on traits Charon cannot expand
//! (mutually recursive through their associated types) - the KZG verifier's
//! `E::G1Affine: CurveAffine<ScalarExt = E::Fr>`, `CurveAffine` and `CurveExt` naming each
//! other. The constraint stays in the LLBC; the projection is rewritten to its right-hand side.

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
