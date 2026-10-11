//@ [!lean] skip
//! A trait method whose bounds reach one associated type twice (`T: Transcript` and
//! `Self::Commitment: Hashable<T::Hash>`, both implying `T::Hash: TranscriptHash`), in an impl
//! inlined as a structure literal (a function recursing through it, aeneas#1264): the trait's
//! field type must identify the two parameters as the impl's method does (midnight-proofs
//! `PolynomialCommitmentScheme::write_commitment`).
pub trait TranscriptHash {
    type Input;
    fn absorb(&mut self, x: &Self::Input);
}

pub trait Hashable<H: TranscriptHash> {
    fn to_input(&self) -> H::Input;
}

pub trait Transcript {
    type Hash: TranscriptHash;
    fn hasher(&mut self) -> &mut Self::Hash;
}

pub trait Scheme {
    type Commitment;
    fn write<T: Transcript>(t: &mut T, c: &Self::Commitment)
    where
        Self::Commitment: Hashable<T::Hash>;
    fn size() -> usize;
}

pub struct Kzg;

impl Scheme for Kzg {
    type Commitment = u32;
    fn write<T: Transcript>(t: &mut T, c: &u32)
    where
        u32: Hashable<T::Hash>,
    {
        let x = c.to_input();
        t.hasher().absorb(&x)
    }
    fn size() -> usize {
        sizes::<Kzg>(1)
    }
}

/// Recurses through `Kzg`'s impl, which is then inlined as a literal
pub fn sizes<S: Scheme>(n: usize) -> usize {
    if n == 0 { 0 } else { S::size() }
}
