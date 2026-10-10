import SliceIterFind.Funs

/-!
`find` on `iter_mut()` gives back the item it found: `bump_first_even` really increments the
first even element.
-/

open Aeneas Aeneas.Std Result

namespace slice_iter_find

set_option maxHeartbeats 1000000 in
theorem bump_first_even_spec :
    ∃ s, bump_first_even (Slice.from [1#u32, 2#u32, 4#u32] (by scalar_tac)) = ok s ∧
      s.val = [1#u32, 3#u32, 4#u32] := by
  unfold bump_first_even
  simp only [core.slice.Slice.iter_mut,
    core.slice.iter.IterMut.Insts.CoreIterTraitsIteratorIteratorMutAT.find, bind_ok]
  iterate 4 all_goals
    try unfold loop
    try simp only [core.slice.iter.IteratorIterMut.next,
      bump_first_even.closure.Insts.CoreOpsFunctionFnMutTupleShared0Mut1U32Bool.call_mut]
    try simp (config := { decide := true }) [HMod.hMod, UScalar.rem]
  simp only [HAdd.hAdd, UScalar.add, UScalar.tryMk]
  simp (config := { decide := true }) [Slice.setAtNat]
  simp (config := { decide := true }) [UScalar.tryMkOpt]

end slice_iter_find
