/- Hand-written: the `Aeneas.Std.IterSpecs` lemmas on concrete inputs. -/
import Aeneas
open Aeneas Aeneas.Std Result

-- `-2..1` over `i32` yields `-2, -1, 0`
example : ∃ rs : List I32, rs.map (·.val) = [-2, -1, 0] ∧
    Yields (core.iter.traits.iterator.IteratorRange core.iter.range.StepI32) ⟨(-2)#i32, 1#i32⟩ rs := by
  obtain ⟨rs, h, hy⟩ := core.iter.range.IteratorRange.yields_I32 ⟨(-2)#i32, 1#i32⟩
  exact ⟨rs, by rw [h]; simp [intRange]; decide, hy⟩

-- `-1..=0` over `i64` yields `-1, 0`
example : ∃ rs : List I64, rs.map (·.val) = [-1, 0] ∧
    Yields (core.ops.range.RangeInclusive.Insts.CoreIterTraitsIteratorIterator
      core.iter.range.StepI64) ⟨(-1)#i64, 0#i64, false⟩ rs := by
  obtain ⟨rs, h, hy⟩ := core.ops.range.RangeInclusive.yields_I64 ⟨(-1)#i64, 0#i64, false⟩ rfl
  exact ⟨rs, by rw [h]; simp [intRange]; decide, hy⟩

-- an empty range yields nothing
example : Yields (core.iter.traits.iterator.IteratorRange core.iter.range.StepI32)
    ⟨3#i32, 3#i32⟩ [] := by
  obtain ⟨rs, h, hy⟩ := core.iter.range.IteratorRange.yields_I32 ⟨3#i32, 3#i32⟩
  have : rs = [] := by simpa [intRange] using h
  exact this ▸ hy

-- `foldlM` with a step that keeps the running sum
example (l : List ℕ) : l.foldlM (fun acc x => (ok (acc + x) : Result ℕ)) 0 ⦃ s => s = l.sum ⦄ := by
  have := List.foldlM_spec (fun acc x => (ok (acc + x) : Result ℕ))
    (fun i s => s = (l.take i).sum) l 0 (by simp) (by
      intro i hi s hs
      simp [hs, List.sum_take_succ _ _ hi])
  simpa using this

example : [1, 2, 3].overwrite [7, 8] = [7, 8, 3] := rfl
example : [1, 2].overwrite [7, 8, 9] = [7, 8] := rfl

-- the scalar specs
example : core.num.I64.unsigned_abs ((-5)#i64) ⦃ y => y.val = 5 ⦄ := by
  have := core.num.I64.unsigned_abs_spec ((-5)#i64); simpa using this
example : core.num.I32.abs ((-7)#i32) ⦃ y => y.val = 7 ⦄ := by
  have := core.num.I32.abs_spec ((-7)#i32) (by scalar_tac); simpa using this
