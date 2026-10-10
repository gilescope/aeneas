import ClosureMutCaptureCall.Funs

/-!
`map` calls the closure through its `FnMut` instance and `collect` gives the final `Map` back,
so both reads of the captured `&mut` land: the counter goes `5 → 6 → 7` and the items are
`6 + 0`, `7 + 1`. An instance which failed, or a `collect` which dropped the closure's final
state, would not compute this.
-/

open Aeneas Aeneas.Std Result

namespace closure_mut_capture_call

theorem reads_spec : ∃ v, reads ⟨5#u32⟩ = ok (v, ⟨7#u32⟩) ∧ v.val = [6#u32, 8#u32] := by
  unfold reads
  simp only [core.iter.traits.iterator.Iterator.map.default,
    core.iter.traits.iterator.Iterator.collect.default, CollectShape.collect, MapShape.ofMap,
    FromIterBack.fromIterBack]
  repeat (first
    | rw [alloc.vec.FromIteratorVec.iterToListBack]
    | simp only [core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator,
        core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator.next,
        core.iter.traits.iterator.IteratorRange, core.iter.range.IteratorRange.next,
        core.iter.range.UScalarStep, core.iter.range.UScalarStep.forward_checked,
        reads.closure.Insts.CoreOpsFunctionFnMutTupleU32U32,
        reads.closure.Insts.CoreOpsFunctionFnMutTupleU32U32.call_mut, Counter.read,
        core.num.U32.wrapping_add, UScalar.wrapping_add, U32.max_eq,
        bind_tc_ok, lift] at *
    | simp (config := { decide := true }) at *)
  have h : 2 ≤ Usize.max := by scalar_tac
  simp only [h, ↓reduceDIte, bind_ok]
  refine ⟨_, rfl, ?_⟩
  rfl

end closure_mut_capture_call
