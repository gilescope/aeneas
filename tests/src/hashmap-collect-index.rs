//@ [!lean] skip
//@ [lean] subdir=HashmapCollectIndex
//@ [lean] aeneas-args=-split-files
//! A `HashMap` collected from an iterator (through `Result`) and indexed - the KZG verifier's
//! `label_to_commitment`. Only order-independent operations: a later entry for a key replaces
//! an earlier one, and lookups don't depend on the (random) iteration order.
use std::collections::HashMap;

pub fn lookup(keys: &[u32], vals: &[u32], k: u32) -> Result<u32, u32> {
    let m: HashMap<u32, u32> = keys
        .iter()
        .zip(vals.iter())
        .map(|(k, v)| if *v == 0 { Err(*k) } else { Ok((*k, *v)) })
        .collect::<Result<_, u32>>()?;
    Ok(m[&k])
}
