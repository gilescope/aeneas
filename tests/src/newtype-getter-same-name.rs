//@ [!lean] skip
//! A newtype over a reference to a struct, with a getter named after the struct's field - the
//! PLONK verifier's `AbsorbedVk(&VerifyingKey)::phase0_commitment`. The newtype is an alias
//! of the struct, so `self.field` resolved to the getter itself; the projection is qualified.

pub struct Key {
    pub commitment: u32,
}

pub struct Absorbed<'a>(&'a Key);

impl<'a> Absorbed<'a> {
    pub fn commitment(&self) -> u32 {
        self.0.commitment
    }
}
