//@ [!lean] skip
//@ [lean] subdir=ClosureMutCaptureSibling
//! Extraction-only (no root module: std's `Iterator::map` has no Lean model yet): a `map`
//! closure capturing a `&mut` next to a shared borrow of a local which is dropped after the
//! `collect` - the PLONK verifier's instance evaluations. The closure's regions are siblings:
//! ending the shared one gives back nothing which lives in the `&mut` one.

pub trait Read {
    fn read(&mut self) -> Result<u32, u32>;
}

pub fn evals<T: Read>(columns: &[usize], t: &mut T) -> Result<u32, u32> {
    let table = &vec![1u32, 2, 3];
    let evals: Vec<u32> = columns
        .iter()
        .map(|c| if *c == 0 { t.read() } else { Ok(table[*c]) })
        .collect::<Result<Vec<_>, _>>()?;
    Ok(evals.len() as u32)
}
