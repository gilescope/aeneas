import ZipIterMut.Funs

/-!
`Zip::next` gives back each `&mut` item and `zip` the `IterMut`, so `scale` really writes:
`2..4` scales the first two elements of `[5, 6, 7]` by `2` and `3`. A dropped or misplaced
given back value would leave the slice unchanged.
-/

open Aeneas Aeneas.Std Result

namespace zip_iter_mut

/-- `2..4` scales the first two elements of `[5, 6, 7]` by `2` and `3` (evaluated: the
give-back path is concrete) -/
theorem scale_spec :
    (scale (core.iter.traits.collect.IntoIterator.Blanket
        (core.iter.traits.iterator.IteratorRange core.iter.range.StepU32))
      { start := 2#u32, «end» := 4#u32 }
      (Slice.from [5#u32, 6#u32, 7#u32] (by scalar_tac))).reducesTo
      (Slice.from [10#u32, 18#u32, 7#u32] (by scalar_tac)) = true := by
  native_decide

end zip_iter_mut
