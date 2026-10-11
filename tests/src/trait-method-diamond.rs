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
    type Params;
    type Guard;
    fn write<T: Transcript>(t: &mut T, c: &Self::Commitment, g: &Self::Guard)
    where
        Self::Commitment: Hashable<T::Hash>;
    fn size() -> usize;
}

pub struct Kzg;

impl Scheme for Kzg {
    type Commitment = u32;
    type Params = ();
    type Guard = u8;
    fn write<T: Transcript>(t: &mut T, c: &u32, _g: &u8)
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

/// Calls the method through the instance: the trait's parameters (`Self::Guard`, free) and the
/// method's (bound) share indices, which must not make the method's unused diamond parameter
/// implicit (it could not be inferred)
pub fn write_through<S: Scheme, T: Transcript>(t: &mut T, c: &S::Commitment, g: &S::Guard)
where
    S::Commitment: Hashable<T::Hash>,
{
    S::write(t, c, g)
}

/// Recurses through `Kzg`'s impl, which is then inlined as a literal
pub fn sizes<S: Scheme>(n: usize) -> usize {
    if n == 0 { 0 } else { S::size() }
}
