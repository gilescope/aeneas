//@ [!lean] skip
//@ [lean] aeneas-args=-filter-trait-methods
//! The two shapes of `loop-outlives-closure-borrow.rs`'s mark loop that do translate: the same
//! `&'b mut self` with the `'b: 'a` bound but nested `for`s instead of `flat_map`, and the
//! `flat_map` loop without the bound.

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
    /// `'b: 'a`, nested `for`s.
    pub fn mark_nested<'a, 'b: 'a>(
        &'b mut self,
        cache_read: impl Fn(u32) -> Option<&'a Obj>,
        to_process: Vec<u32>,
    ) -> Vec<u32> {
        let mut next = Vec::new();
        for hash in to_process.into_iter() {
            if let Some(obj) = cache_read(hash) {
                self.marked.push(hash);
                self.grey.retain(|g| *g != hash);
                for c in obj.children.iter() {
                    for child in c.refs() {
                        if !self.marked.contains(&child) && !self.grey.contains(&child) {
                            self.grey.push(child);
                            next.push(child);
                        }
                    }
                }
            }
        }
        next
    }

    /// `flat_map`, no bound between the two lifetimes.
    pub fn mark_flat_map<'a>(
        &mut self,
        cache_read: impl Fn(u32) -> Option<&'a Obj>,
        to_process: Vec<u32>,
    ) -> Vec<u32> {
        let mut next = Vec::new();
        for hash in to_process.into_iter() {
            if let Some(obj) = cache_read(hash) {
                self.marked.push(hash);
                self.grey.retain(|g| *g != hash);
                for child in obj.children.iter().flat_map(|c| c.refs().into_iter()) {
                    if !self.marked.contains(&child) && !self.grey.contains(&child) {
                        self.grey.push(child);
                        next.push(child);
                    }
                }
            }
        }
        next
    }
}
