import ZipIterMut.Funs

/-!
`Zip::next` gives back each `&mut` item and `zip` the `IterMut`, so `scale` really writes:
`2..4` scales the first two elements of `[5, 6, 7]` by `2` and `3`. A dropped or misplaced
given back value would leave the slice unchanged.
-/

open Aeneas Aeneas.Std Result

namespace zip_iter_mut

set_option maxHeartbeats 1000000 in
theorem scale_spec :
    ∃ s, scale (core.iter.traits.collect.IntoIterator.Blanket
        (core.iter.traits.iterator.IteratorRange core.iter.range.StepU32))
      { start := 2#u32, «end» := 4#u32 } (Slice.from [5#u32, 6#u32, 7#u32] (by scalar_tac))
      = ok s ∧ s.val = [10#u32, 18#u32, 7#u32] := by
  unfold scale scale_loop
  simp only [core.iter.traits.iterator.Iterator.zip.trait_default,
    core.iter.traits.iterator.Iterator.zip.default, ZipShape.ofZip,
    core.iter.traits.collect.IntoIterator.Blanket,
    core.iter.traits.collect.IntoIterator.Blanket.into_iter, core.slice.Slice.iter_mut,
    bind_tc_ok, bind_ok]
  iterate 3
    try unfold loop
    simp only [scale_loop.body,
      core.iter.adapters.zip.Zip.Insts.CoreIterTraitsIteratorIteratorPair.next,
      ZipNextShape.next, core.slice.iter.IteratorIterMut.next, core.iter.range.IteratorRange.next,
      core.iter.range.UScalarStep, core.iter.range.UScalarStep.forward_checked,
      core.num.U32.wrapping_mul, UScalar.wrapping_mul, U32.max_eq, lift, bind_tc_ok, bind_ok]
    try simp (config := { decide := true })

end zip_iter_mut
