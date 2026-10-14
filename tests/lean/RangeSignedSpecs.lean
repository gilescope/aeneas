import Aeneas
open Aeneas Aeneas.Std Result WP

/-! `IteratorRange.next` on signed ranges (`for _ in 0..256` defaults to `i32`). -/

example (r : core.ops.range.Range I32) (h : r.start.val < r.end.val) :
    core.iter.range.IteratorRange.next core.iter.range.StepI32 r
    ⦃ o r' => o = some r.start ∧ r'.start.val = r.start.val + 1 ∧ r'.end = r.end ⦄ :=
  core.iter.range.IteratorRange.next_I32_some_spec r h

example (r : core.ops.range.Range I64) (h : r.start.val ≥ r.end.val) :
    core.iter.range.IteratorRange.next core.iter.range.StepI64 r
    ⦃ o r' => o = none ∧ r' = r ⦄ :=
  core.iter.range.IteratorRange.next_I64_none_spec r h

example (r : core.ops.range.Range Isize) :
    core.iter.range.IteratorRange.next core.iter.range.StepIsize r
    ⦃ o r' => (if r.start.val < r.end.val then o = some r.start ∧ r'.start.val = r.start.val + 1
      else o = none ∧ r'.start = r.start) ∧ r'.end = r.end ⦄ :=
  core.iter.range.IteratorRange.next_Isize_spec r
