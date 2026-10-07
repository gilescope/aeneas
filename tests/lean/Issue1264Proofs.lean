import Issue1264Closure
import Issue1264Join

/-!
# aeneas#1264: the extracted models of functions recursing through closures are right

The functions below recurse through a closure's `FnOnce` impl, which Aeneas extracts by
inlining the impl as a structure literal inside a `partial_fixpoint` group. These theorems
check that the resulting models compute what the Rust computes:
* `f_ok`: the recursion through `call(|| f(false))` returns `()` for every input.
* `tree_eq`: recursing into both halves through two closures and `join` computes exactly what
  the same recursion without closures (`tree_direct`, which Aeneas always supported) does.
-/

open Aeneas Aeneas.Std Result

namespace issue_1264_closure

theorem f_ok (b : Bool) : f b = ok () := by
  cases b
  · unfold f; simp
  · unfold f
    simp only [call, f.closure.Insts.CoreOpsFunctionFnOnceTupleTuple.call_once, ite_true]
    unfold f; simp

end issue_1264_closure

namespace issue_1264_join

theorem sub_one_ok (n : Std.U32) (h : n ≠ 0#u32) :
    ∃ i : Std.U32, n - 1#u32 = ok i ∧ i.val < n.val := by
  have he := UScalar.sub_equiv n 1#u32
  split at he
  · rename_i z hz
    exact ⟨z, Result.match.isOk.mp hz, by simp at he; omega⟩
  · exfalso; apply h; simp at he; scalar_tac
  · exact he.elim

theorem tree_eq (n : Std.U32) : tree n = tree_direct n := by
  induction hn : n.val using Nat.strong_induction_on generalizing n with
  | _ k ih =>
    unfold tree tree_direct
    split
    · rfl
    · rename_i h0
      obtain ⟨i, hi, hlt⟩ := sub_one_ok n h0
      simp only [join, tree.closure.Insts.CoreOpsFunctionFnOnceTupleU32.call_once,
        tree.closure_1.Insts.CoreOpsFunctionFnOnceTupleU32.call_once, hi, bind_ok]
      rw [ih i.val (by omega) i rfl]
      simp

end issue_1264_join

#print axioms issue_1264_closure.f_ok
#print axioms issue_1264_join.tree_eq
