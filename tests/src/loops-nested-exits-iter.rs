//@ [!lean] skip
//! `?` out of `for` loops over iterators, in the shapes of the PLONK verifier's `parse_trace`
//! and `Committed::evaluate`: nested loops (the `next` of each iterator leaves a projection of the
//! iterator alive, which the join after the lifted exit must merge away), and sequential loops
//! which Charon or `update_loops` would nest. The inner loops use `xs.iter()`, whose Lean model
//! evaluates in `Differential.lean` (`&Vec`'s `into_iter` is an axiom). Labelled `break`/`continue`
//! out of iterator loops do not translate yet (see `loops-nested-exits.rs` for index loops).

fn check(x: u32) -> Result<u32, u32> {
    if x == 0 {
        Err(7)
    } else {
        Ok(x)
    }
}

/// `?` in an inner `for` loop.
pub fn sum_checked(xss: &[Vec<u32>]) -> Result<u32, u32> {
    let mut s = 0u32;
    for xs in xss {
        for x in xs.iter() {
            s = s.wrapping_add(check(*x)?);
        }
    }
    Ok(s)
}

/// Sequential loops, with a `?` in the first, while a value with drop glue (`v`) is live: Charon
/// puts the second loop, and the rest of the function, inside the first loop's exit branch, as
/// in `parse_trace` (upstream Aeneas: "Could not match the contexts").
pub fn absorb(cs: &[u32], rows: &[Vec<u32>]) -> Result<Vec<u32>, u32> {
    let mut v = vec![1u32];
    for c in cs.iter() {
        check(*c)?;
    }
    for r in rows {
        v.push(check(r.len() as u32)?);
        for x in r.iter() {
            v.push(check(*x)?);
        }
    }
    Ok(v)
}

/// Committed::evaluate: a `?` in an inner loop over a `Vec` by value, which the outer loop then
/// pushes.
pub fn evaluate(labels: &[u32], t: &mut Reader) -> Result<Vec<Vec<u32>>, u32> {
    let mut out = Vec::new();
    for label in labels.iter() {
        let points = vec![*label, *label + 1];
        let mut evals = Vec::with_capacity(points.len());
        for point in points {
            evals.push(point + t.read()?);
        }
        out.push(evals);
    }
    Ok(out)
}

/// Committed::evaluate with its check after the inner loop: a `return` in the outer loop's body
/// after the inner loop, which Charon puts in the inner loop's exit branch, and the outer loop's
/// `continue` with it (every exit of the inner loop is then lifted).
pub fn evaluate_checked(labels: &[u32], t: &mut Reader) -> Result<Vec<Vec<u32>>, u32> {
    let mut out = Vec::new();
    for label in labels.iter() {
        let points = vec![*label, *label + 1];
        let mut evals = Vec::with_capacity(points.len());
        for point in points {
            evals.push(point + t.read()?);
        }
        if evals[0] == evals[1] {
            return Err(2);
        }
        out.push(evals);
    }
    Ok(out)
}

/// A transcript
pub struct Reader {
    pub buf: Vec<u32>,
    pub pos: usize,
}

impl Reader {
    pub fn read(&mut self) -> Result<u32, u32> {
        if self.pos < self.buf.len() {
            let v = self.buf[self.pos];
            self.pos += 1;
            Ok(v)
        } else {
            Err(1)
        }
    }
}

// Concrete results, checked against the extracted Lean in tests/lean/Differential.lean.
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn values() {
        assert_eq!(sum_checked(&[vec![1, 2], vec![3]]), Ok(6));
        assert_eq!(sum_checked(&[vec![1, 2], vec![0, 3]]), Err(7));
        let mut t = Reader { buf: vec![10, 20, 30, 40], pos: 0 };
        assert_eq!(evaluate(&[1, 5], &mut t), Ok(vec![vec![11, 22], vec![35, 46]]));
        let mut t = Reader { buf: vec![10, 20, 30], pos: 0 };
        assert_eq!(evaluate(&[1, 5], &mut t), Err(1));
        let mut t = Reader { buf: vec![10, 20, 30, 40], pos: 0 };
        assert_eq!(evaluate_checked(&[1, 5], &mut t), Ok(vec![vec![11, 22], vec![35, 46]]));
        let mut t = Reader { buf: vec![10, 9, 30, 40], pos: 0 };
        assert_eq!(evaluate_checked(&[1, 5], &mut t), Err(2));
        let mut t = Reader { buf: vec![10, 20, 30], pos: 0 };
        assert_eq!(evaluate_checked(&[1, 5], &mut t), Err(1));
        assert_eq!(absorb(&[1, 2], &[vec![3], vec![4, 5]]), Ok(vec![1, 1, 3, 2, 4, 5]));
        assert_eq!(absorb(&[1, 0], &[vec![3]]), Err(7));
        assert_eq!(absorb(&[1], &[vec![3], vec![]]), Err(7));
        assert_eq!(absorb(&[1], &[vec![3, 0]]), Err(7));
    }
}
