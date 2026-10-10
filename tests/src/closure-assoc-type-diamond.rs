//@ [!lean] skip
//! A closure in a function bounded by two traits with a common supertrait which has an
//! associated type - the PLONK verifier's `F: WithSmallOrderMulGroup<3> + FromUniformBytes<64>`,
//! both `PrimeField` (`type Repr`). The closure type and its impls keep one parameter per
//! path to `Repr` (`Clause0_Clause0_Repr`, `Clause1_Clause0_Repr`); its methods' signatures
//! must too.

pub trait Prime: Copy {
    type Repr;
    fn double(self) -> Self;
}

pub trait Small: Prime {}

pub trait Uniform: Prime {}

pub fn doubles<F: Small + Uniform>(xs: &[F]) -> Vec<F> {
    xs.iter().map(|x| x.double()).collect()
}
