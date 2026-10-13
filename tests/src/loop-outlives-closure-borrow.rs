//@ [!lean] skip
//@ known-failure
//@ no-check-output
//@ [lean] aeneas-args=-filter-trait-methods
//! A `for` over `flat_map` inside a loop whose body mutates `&'b mut self`, where `'b: 'a` and
//! the loop reads a borrow `&'a Obj` handed back by a closure: midnight-ledger's
//! `GcState::run<'a, 'b: 'a>` mark loop (`storage-core/src/gc.rs:165-178`). The loop join
//! fails with "Could not match the contexts" (`InterpJoin.match_ctx_with_target`); on the real
//! crate it is "Internal error" from `InterpMatchCtxs.compute_abs_borrows_loans_maps`. Without
//! the `'b: 'a` bound, or with the `flat_map` written as nested `for`s, the same loop
//! translates: see `loop-closure-borrow.rs`.

pub struct Key(pub u32);

impl Key {
    pub fn refs(&self) -> Vec<u32> {
        vec![self.0]
    }
}

pub struct Obj {
    pub children: Vec<Key>,
}

pub struct Marker {
    pub grey: Vec<u32>,
    pub marked: Vec<u32>,
}

impl Marker {
    pub fn mark<'a, 'b: 'a>(
        &'b mut self,
        cache_read: impl Fn(u32) -> Option<&'a Obj>,
        to_process: Vec<u32>,
    ) -> Vec<u32> {
        let mut next = Vec::new();
        for hash in to_process.into_iter() {
            if let Some(obj) = cache_read(hash) {
                self.marked.push(hash);
                for child in obj.children.iter().flat_map(|c| c.refs().into_iter()) {
                    self.grey.push(child);
                    next.push(child);
                }
            }
        }
        next
    }
}
