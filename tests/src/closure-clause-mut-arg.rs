//@ [!lean] skip
//@ [lean] aeneas-args=-filter-trait-methods
//! A closure *parameter* taking a `&mut` argument, called through its `FnOnce`/`FnMut`/`Fn`
//! clause (midnight-ledger's `GcState::run(.., db_roots: impl FnOnce(&mut D) -> Vec<_>)`).
//! The call site gives the argument back (`let (v, x1) ← call_once f x`), so the clause's
//! `Output` must be `Output × Arg`, as a closure *impl*'s already is (`closure-mut-args.rs`).
//! Aeneas succeeds but the generated Lean is ill-typed: `apply_once`'s body has type
//! `Result Bool` against a declared `Result (Bool × U32)`, and `apply_mut` destructures
//! `(b, _, x1)` from `Result (Bool × F)`. The fix is to type the `Fn*` clause's lifted
//! `Output` as `Output × backs`, and shape `call_mut`'s result as the impls do,
//! `((Output × backs) × Self)`.

pub fn apply_once<F: FnOnce(&mut u32) -> bool>(f: F, x: &mut u32) -> bool {
    f(x)
}

pub fn apply_mut<F: FnMut(&mut u32) -> bool>(mut f: F, x: &mut u32) -> bool {
    f(x)
}

pub fn apply_fn<F: Fn(&mut u32) -> bool>(f: F, x: &mut u32) -> bool {
    f(x)
}
