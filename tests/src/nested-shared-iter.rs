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
