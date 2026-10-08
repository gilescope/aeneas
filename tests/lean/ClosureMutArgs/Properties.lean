import ClosureMutArgs.Funs

/-!
The closure's `FnMut` instance gives back the `&mut u32` it received, so `incr` really adds one
to every element: a dropped or misplaced given back value would leave `s` unchanged.
-/

open Aeneas Aeneas.Std Result

namespace closure_mut_args

theorem eachList_map {F O : Type} (call : F → Std.U32 → Result ((O × Std.U32) × F))
    (g : Std.U32 → Std.U32) (o : O) (hc : ∀ c x, call c x = ok ((o, g x), c)) :
    ∀ (l : List Std.U32) (c : F), eachList call l c = ok (l.map g) := by
  intro l
  induction l with
  | nil => intro c; rfl
  | cons x xs ih => intro c; simp only [eachList, hc, bind_ok, ih, List.map_cons]; rfl

theorem incr_spec (s : Slice Std.U32) :
    ∃ s', incr s = ok s' ∧ s'.val = s.val.map (core.num.U32.wrapping_add · 1#u32) := by
  have h : (s.val.map (core.num.U32.wrapping_add · 1#u32)).length ≤ Std.Usize.max := by
    simp
  refine ⟨Slice.from _ h, ?_, Slice.from_val _ _⟩
  unfold incr each
  rw [eachList_map _ (core.num.U32.wrapping_add · 1#u32) () (fun c x => by
    simp [incr.closure.Insts.CoreOpsFunctionFnMutTupleMut0U32Tuple.call_mut, lift])]
  first | rw [bind_tc_ok, dif_pos h] | rw [bind_ok, dif_pos h]

end closure_mut_args
