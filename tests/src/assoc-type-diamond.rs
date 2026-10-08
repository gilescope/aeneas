//@ [!lean] skip
//! An associated type reached through two bounds (a diamond): Charon makes one type parameter
//! per path; the `unify_diamond_assoc_types` prepass identifies them.
pub trait Base {
    type Repr: Copy;
}
pub trait Left: Base {}
pub trait Right: Base {}

pub fn via_left<F: Left>(r: <F as Base>::Repr) -> <F as Base>::Repr {
    r
}

pub fn via_right<F: Right>(r: <F as Base>::Repr) -> <F as Base>::Repr {
    r
}

/// `<F as Base>::Repr` is reached through `Left` and through `Right`.
pub fn both<F: Left + Right>(r: <F as Base>::Repr) -> <F as Base>::Repr {
    via_right::<F>(via_left::<F>(r))
}
