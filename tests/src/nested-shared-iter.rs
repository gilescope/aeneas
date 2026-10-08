//@ [!lean] skip
//! Iterating slices of shared slices (`&[&[T]]`): shared borrows nested in shared borrows, as in
//! the PLONK verifier's `parse_trace`, which absorbs `instances: &[&[F]]` into the transcript.
//! The inner region's abstractions nest in the outer one's (they have it as parent), and give
//! nothing back.

/// One loop over the outer slice.
pub fn total_len(xss: &[&[u32]]) -> u32 {
    let mut s = 0u32;
    for xs in xss.iter() {
        s = s.wrapping_add(xs.len() as u32);
    }
    s
}

/// Nested loops, reading through both levels.
pub fn total(xss: &[&[u32]]) -> u32 {
    let mut s = 0u32;
    for xs in xss {
        for x in *xs {
            s = s.wrapping_add(*x);
        }
    }
    s
}

fn check(x: u32) -> Result<u32, u32> {
    if x == 0 {
        Err(7)
    } else {
        Ok(x)
    }
}

/// `parse_trace`'s shape: a `?` before and inside the inner loop.
pub fn absorb(xss: &[&[u32]]) -> Result<u32, u32> {
    let mut s = 0u32;
    for xs in xss.iter() {
        s = s.wrapping_add(check(xs.len() as u32)?);
        for x in xs.iter() {
            s = s.wrapping_add(check(*x)?);
        }
    }
    Ok(s)
}

/// A value which can be absorbed by a transcript
pub trait Hashable {
    fn bytes(&self) -> u32;
}

/// A field
pub trait Field: Hashable + Copy {
    fn from_u128(x: u128) -> Self;
}

/// A transcript
pub trait Transcript {
    fn common<V: Hashable>(&mut self, x: &V) -> Result<(), u32>;
}

/// The value returned, with drop glue (which makes Charon nest the loops)
pub struct Trace {
    pub v: Vec<u32>,
}

/// `parse_trace` itself, generic: committed instances then instances, each length then values.
pub fn parse<F: Field, C: Hashable, T: Transcript>(
    committed: &[C],
    instances: &[&[F]],
    t: &mut T,
) -> Result<Trace, u32> {
    let trace = Trace { v: vec![1] };
    for c in committed.iter() {
        t.common(c)?
    }
    for instance in instances.iter() {
        t.common(&F::from_u128(instance.len() as u128))?;
        for value in instance.iter() {
            t.common(value)?;
        }
    }
    Ok(trace)
}

// Concrete results, checked against the extracted Lean in tests/lean/Differential.lean.
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn values() {
        assert_eq!(total_len(&[&[1, 2], &[], &[3]]), 3);
        assert_eq!(total(&[&[1, 2], &[], &[3]]), 6);
        assert_eq!(absorb(&[&[1, 2], &[3]]), Ok(9));
        assert_eq!(absorb(&[&[1, 2], &[]]), Err(7));
        assert_eq!(absorb(&[&[1, 0]]), Err(7));
    }
}
