//@ [!lean] skip
//@ [lean] aeneas-args=-filter-trait-methods
//! A closure *parameter* taking a `&mut` argument, called through its `FnOnce`/`FnMut`/`Fn`
//! clause (midnight-ledger's `GcState::run(.., db_roots: impl FnOnce(&mut D) -> Vec<_>)`).
//! The clause's lifted `Output` is typed like a closure impl's (`closure-mut-args.rs`):
//! `Output × backs`, the `&mut` arguments given back after the output. So `call_once f x`
//! has type `Result (Bool × U32)`, and `call_mut` destructures `((b, x1), f')`.

pub fn apply_once<F: FnOnce(&mut u32) -> bool>(f: F, x: &mut u32) -> bool {
    f(x)
}

pub fn apply_mut<F: FnMut(&mut u32) -> bool>(mut f: F, x: &mut u32) -> bool {
    f(x)
}

pub fn apply_fn<F: Fn(&mut u32) -> bool>(f: F, x: &mut u32) -> bool {
    f(x)
}
