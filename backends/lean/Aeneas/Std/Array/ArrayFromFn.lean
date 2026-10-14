module
public import Aeneas.Std.Array.Array
public import Aeneas.Std.Core.Ops
public import Aeneas.Std.Core.Iter
@[expose] public section

/-!
# `core::array::from_fn`

`from_fn::<T, N, F>(f)` is `[f(0), f(1), …, f(N - 1)]`, calling `f` in order with its state
(`FnMut`) threaded through. A closure holding a `&mut` (`GivesBack`) is given back in its final
state alongside the array (`FromFnShape`, as for `fold`). `from_fn_spec` is the usual case of a
closure that keeps its state.
-/

namespace Aeneas.Std

open Result

/-- `f(i), f(i + 1), …` for `k` indices, each below `N`, the closure's state threaded. -/
def core.array.from_fn_aux {T F : Type} (N : Usize) (inst : core.ops.function.FnMut F Usize T) :
    ℕ → ℕ → F → Result (List T × F)
  | 0, _, f => ok ([], f)
  | k + 1, i, f =>
    if h : i < N.val then do
      let (x, f) ← inst.call_mut f (Usize.ofNatCore i (by have := N.hBounds; omega))
      let (xs, f) ← core.array.from_fn_aux N inst k (i + 1) f
      ok (x :: xs, f)
    else fail .panic

/-- The output of `from_fn(f)`: the array, and the closure in its final state when it holds a
`&mut` to give back. -/
class FromFnShape (A F : Type) (Out : outParam Type) where
  ofFromFn : A → F → Out

instance (priority := low) {A F : Type} : FromFnShape A F A := ⟨fun a _ => a⟩

instance {A F : Type} [GivesBack F] : FromFnShape A F (A × F) := ⟨Prod.mk⟩

@[rust_fun "core::array::from_fn"]
def core.array.from_fn {T F Out : Type} (N : Usize) [S : FromFnShape (Array T N) F Out]
    (inst : core.ops.function.FnMut F Usize T) (f : F) : Result Out := do
  let (xs, f) ← core.array.from_fn_aux N inst N.val 0 f
  if h : xs.length = N.val then ok (S.ofFromFn (Array.make N xs h) f) else fail .panic

theorem core.array.from_fn_aux_pure {T F : Type} (N : Usize)
    (inst : core.ops.function.FnMut F Usize T) (g : ℕ → T)
    (hg : ∀ f (i : Usize), inst.call_mut f i = ok (g i.val, f)) :
    ∀ k i (f : F), i + k ≤ N.val →
      core.array.from_fn_aux N inst k i f = ok ((List.range' i k).map g, f)
  | 0, _, _, _ => rfl
  | k + 1, i, f, hk => by
    have hi : i < N.val := by omega
    simp only [core.array.from_fn_aux, hi, ↓reduceDIte, hg, bind_tc_ok,
      core.array.from_fn_aux_pure N inst g hg k (i + 1) f (by omega)]
    simp [List.range'_succ, Usize.ofNatCore, UScalar.ofNatCore_val_eq]

/-- **`from_fn` with a stateless closure**: `call_mut f i = ok (g i, f)` gives
`[g 0, …, g (N - 1)]`. -/
theorem core.array.from_fn_spec {T F Out : Type} (N : Usize) [S : FromFnShape (Array T N) F Out]
    (inst : core.ops.function.FnMut F Usize T) (g : ℕ → T)
    (hg : ∀ f (i : Usize), inst.call_mut f i = ok (g i.val, f)) (f : F) :
    ∃ a : Array T N, core.array.from_fn N inst f = ok (S.ofFromFn a f) ∧
      a.val = (List.range N.val).map g := by
  have := core.array.from_fn_aux_pure N inst g hg N.val 0 f (by omega)
  refine ⟨Array.make N ((List.range' 0 N.val).map g) (by simp), ?_, ?_⟩
  · simp only [core.array.from_fn, this, bind_tc_ok, List.length_map, List.length_range',
      ↓reduceDIte]
  · simp [List.range_eq_range']

end Aeneas.Std
