//@ [!lean] skip
//! A `position` on a temporary iterator (a `&mut self` method, which gives the iterator back),
//! then a loop over `iter_mut()` - the KZG verifier's `construct_intermediate_sets`. The
//! iterator's region abstraction is left with an ended loan projector, which the loop's
//! fixed point keeps: matching it with itself failed ("Could not match the contexts").

pub struct Data {
    pub label: u32,
    pub evals: Vec<u64>,
}

pub fn fill(ds: &mut Vec<Data>, v: &Vec<usize>, eval: &u64) {
    let p = &0usize;
    let pos = v.iter().position(|i| i == p).unwrap();
    for d in ds.iter_mut() {
        if d.label == 0 {
            d.evals[pos] = *eval;
        }
    }
}
