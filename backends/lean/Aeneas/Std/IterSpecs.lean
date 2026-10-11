/- Specs for iterating: `foldlM`, the `Yields` predicate for generic loops, signed-integer
ranges, and `List.overwrite` (what an `iter_mut()` loop's backward function writes). -/
module
public import Aeneas.Std.RangeIter
public section

namespace Aeneas.Std

open Result core.ops.range WP ScalarElab

/-! ## `foldlM` -/

/-- A fold whose step takes `P i` to `P (i+1)` ends in `P l.length`. -/
theorem List.foldlM_spec {α β : Type} (f : β → α → Result β) :
    ∀ (P : ℕ → β → Prop) (l : List α) (b : β), P 0 b →
    (∀ i (hi : i < l.length) b, P i b → f b l[i] ⦃ b' => P (i + 1) b' ⦄) →
    l.foldlM f b ⦃ b' => P l.length b' ⦄
  | _, [], b, h0, _ => by simpa [pure_tc_eq] using h0
  | P, a :: l, b, h0, hs => by
    rw [List.foldlM_cons, bind_tc_eq]
    refine spec_bind (hs 0 (by simp) b h0) fun b' hb' => ?_
    simpa using List.foldlM_spec f (fun i => P (i + 1)) l b' hb' fun i hi c hc => by
      have h := hs (i + 1) (by simp; omega) c hc
      rwa [List.getElem_cons_succ] at h

/-! ## `Yields` -/

/-- `next` yields `xs` in order, then `none`: a loop over a generic iterator is specified
against it once, and each instantiation proves it of its iterator. -/
@[expose] def Yields {I Item : Type} (inst : core.iter.traits.iterator.Iterator I Item) :
    I → List Item → Prop
  | it, [] => inst.next it ⦃ o _ => o = none ⦄
  | it, x :: xs => inst.next it ⦃ o it' => o = some x ∧ Yields inst it' xs ⦄

/-- The integers in `[a, b)`. -/
@[expose] def intRange (a b : ℤ) : List ℤ := (List.range (b - a).toNat).map fun j : ℕ => a + (j : ℤ)

theorem intRange_of_le {a b : ℤ} (h : b ≤ a) : intRange a b = [] := by
  simp [intRange, Int.toNat_eq_zero.mpr (by omega : b - a ≤ 0)]

theorem intRange_of_lt {a b : ℤ} (h : a < b) : intRange a b = a :: intRange (a + 1) b := by
  unfold intRange
  rw [show (b - a).toNat = (b - (a + 1)).toNat + 1 by omega, List.range_succ_eq_map]
  simp only [List.map_cons, List.map_map, Nat.cast_zero, Int.add_zero, List.cons.injEq, true_and]
  refine List.map_congr_left fun j _ => ?_
  simp only [Function.comp_apply, Nat.succ_eq_add_one]; push_cast; omega

/-! ## Signed-integer ranges -/

/-- `IteratorRange.next` on `Range (IScalar ty)`, none case (`start ≥ end`). -/
theorem core.iter.range.IteratorRange.next_IScalar_none_spec {ty : IScalarTy}
    {cloneInst : core.clone.Clone (IScalar ty)}
    {partialOrdInst : core.cmp.PartialOrd (IScalar ty) (IScalar ty)}
    (h_lt : ∀ a b : IScalar ty, partialOrdInst.lt a b = ok (decide (a.val < b.val)))
    (range : core.ops.range.Range (IScalar ty)) (hge : range.end.val ≤ range.start.val) :
    core.iter.range.IteratorRange.next
        (core.iter.range.IScalarStep ty cloneInst partialOrdInst) range
    ⦃ o range' => o = none ∧ range' = range ⦄ := by
  simp only [core.iter.range.IteratorRange.next, core.iter.range.IScalarStep, h_lt,
    show ¬ (range.start.val < range.end.val) from by omega, decide_false, bind_tc_ok,
    Bool.false_eq_true, ↓reduceIte]
  simp [spec_ok]

/-- `a + 1`, in bounds below `b`. -/
@[expose] def IScalar.succOfLt {ty : IScalarTy} (a b : IScalar ty) (h : a.val < b.val) :
    IScalar ty :=
  IScalar.ofIntCore (a.val + 1) ⟨by have := a.hmin; omega, by have := b.hBounds.2; omega⟩

@[simp] theorem IScalar.succOfLt_val {ty : IScalarTy} (a b : IScalar ty) (h : a.val < b.val) :
    (IScalar.succOfLt a b h).val = a.val + 1 := by
  simp [IScalar.succOfLt, IScalar.ofInt_val_eq]

/-- `IteratorRange.next` on `Range (IScalar ty)`, some case (`start < end`): yields `start`
and advances by one. -/
theorem core.iter.range.IteratorRange.next_IScalar_some_spec {ty : IScalarTy}
    {cloneInst : core.clone.Clone (IScalar ty)}
    {partialOrdInst : core.cmp.PartialOrd (IScalar ty) (IScalar ty)}
    (h_clone : ∀ x : IScalar ty, cloneInst.clone x = ok x)
    (h_lt : ∀ a b : IScalar ty, partialOrdInst.lt a b = ok (decide (a.val < b.val)))
    (range : core.ops.range.Range (IScalar ty)) (hlt : range.start.val < range.end.val) :
    core.iter.range.IteratorRange.next
        (core.iter.range.IScalarStep ty cloneInst partialOrdInst) range
    ⦃ o range' => o = some range.start ∧
      range' = { range with start := IScalar.succOfLt range.start range.end hlt } ⦄ := by
  simp only [core.iter.range.IteratorRange.next, core.iter.range.IScalarStep,
    core.iter.range.IScalarStep.forward_checked, bind_tc_ok, h_lt, h_clone, hlt, decide_true,
    ↓reduceIte]
  have hfwd : range.start.val + (1#usize).val ≤ IScalar.max ty := by
    have := range.end.hBounds.2; simp [IScalar.max]; omega
  simp only [hfwd, ↓reduceDIte, bind_tc_ok, spec_ok]
  simp [IScalar.succOfLt]

/-- `start..end` over `IScalar ty` yields `[start, end)`. -/
theorem core.iter.range.IteratorRange.yields_IScalar {ty : IScalarTy}
    {cloneInst : core.clone.Clone (IScalar ty)}
    {partialOrdInst : core.cmp.PartialOrd (IScalar ty) (IScalar ty)}
    (h_clone : ∀ x : IScalar ty, cloneInst.clone x = ok x)
    (h_lt : ∀ a b : IScalar ty, partialOrdInst.lt a b = ok (decide (a.val < b.val))) :
    ∀ (n : ℕ) (r : core.ops.range.Range (IScalar ty)),
    (r.end.val - r.start.val).toNat = n → ∃ rs : List (IScalar ty),
      rs.map (·.val) = intRange r.start.val r.end.val ∧
      Yields (core.iter.traits.iterator.IteratorRange
        (core.iter.range.IScalarStep ty cloneInst partialOrdInst)) r rs
  | 0, r, hn => ⟨[], by simp [intRange_of_le (show r.end.val ≤ r.start.val by omega)],
      spec_mono (core.iter.range.IteratorRange.next_IScalar_none_spec h_lt r (by omega))
        fun _ h => h.1⟩
  | n + 1, r, hn => by
    have hlt : r.start.val < r.end.val := by omega
    obtain ⟨rs, hrs, hy⟩ := core.iter.range.IteratorRange.yields_IScalar h_clone h_lt n
      { r with start := IScalar.succOfLt r.start r.end hlt } (by simp; omega)
    refine ⟨r.start :: rs, ?_, ?_⟩
    · simp only at hrs; simp [hrs, intRange_of_lt hlt]
    · refine spec_mono (core.iter.range.IteratorRange.next_IScalar_some_spec h_clone h_lt r hlt) ?_
      rintro ⟨o, r'⟩ ⟨rfl, rfl⟩
      exact ⟨rfl, hy⟩

/-- `RangeInclusive::next` on `IScalar ty`, empty case: exhausted, or `start > end`. -/
theorem core.ops.range.RangeInclusive.next_IScalar_none_spec {ty : IScalarTy}
    {cloneInst : core.clone.Clone (IScalar ty)}
    {partialOrdInst : core.cmp.PartialOrd (IScalar ty) (IScalar ty)}
    (h_le : ∀ a b : IScalar ty, partialOrdInst.le a b = ok (decide (a.val ≤ b.val)))
    (r : core.ops.range.RangeInclusive (IScalar ty))
    (h : r.exhausted = true ∨ r.end.val < r.start.val) :
    core.ops.range.RangeInclusive.Insts.CoreIterTraitsIteratorIterator.next
      (core.iter.range.IScalarStep ty cloneInst partialOrdInst) r ⦃ o _ => o = none ⦄ := by
  simp only [core.ops.range.RangeInclusive.Insts.CoreIterTraitsIteratorIterator.next,
    core.ops.range.RangeInclusive.is_empty, core.iter.range.IScalarStep, h_le]
  rcases h with h | h
  · simp [h]
  · cases hx : r.exhausted <;> simp [show ¬ r.start.val ≤ r.end.val by omega]

/-- `RangeInclusive::next` on `IScalar ty` with `start < end`: yields `start`, advances. -/
theorem core.ops.range.RangeInclusive.next_IScalar_lt_spec {ty : IScalarTy}
    {cloneInst : core.clone.Clone (IScalar ty)}
    {partialOrdInst : core.cmp.PartialOrd (IScalar ty) (IScalar ty)}
    (h_le : ∀ a b : IScalar ty, partialOrdInst.le a b = ok (decide (a.val ≤ b.val)))
    (h_lt : ∀ a b : IScalar ty, partialOrdInst.lt a b = ok (decide (a.val < b.val)))
    (r : core.ops.range.RangeInclusive (IScalar ty)) (hx : r.exhausted = false)
    (h : r.start.val < r.end.val) :
    core.ops.range.RangeInclusive.Insts.CoreIterTraitsIteratorIterator.next
      (core.iter.range.IScalarStep ty cloneInst partialOrdInst) r ⦃ o r' => o = some r.start ∧
      r' = ⟨IScalar.succOfLt r.start r.end h, r.end, false⟩ ⦄ := by
  simp only [core.ops.range.RangeInclusive.Insts.CoreIterTraitsIteratorIterator.next,
    core.ops.range.RangeInclusive.is_empty, core.iter.range.IScalarStep, h_le, h_lt,
    core.iter.range.IScalarStep.forward_checked]
  have hm : r.start.val + 1 ≤ IScalar.max ty := by
    have := r.end.hBounds.2; simp [IScalar.max]; omega
  simp [hx, h, show r.start.val ≤ r.end.val by omega]
  simp [hm, IScalar.succOfLt]

/-- `RangeInclusive::next` on `IScalar ty` with `start = end`: yields `start`, exhausts. -/
theorem core.ops.range.RangeInclusive.next_IScalar_eq_spec {ty : IScalarTy}
    {cloneInst : core.clone.Clone (IScalar ty)}
    {partialOrdInst : core.cmp.PartialOrd (IScalar ty) (IScalar ty)}
    (h_clone : ∀ x : IScalar ty, cloneInst.clone x = ok x)
    (h_le : ∀ a b : IScalar ty, partialOrdInst.le a b = ok (decide (a.val ≤ b.val)))
    (h_lt : ∀ a b : IScalar ty, partialOrdInst.lt a b = ok (decide (a.val < b.val)))
    (r : core.ops.range.RangeInclusive (IScalar ty)) (hx : r.exhausted = false)
    (h : r.start.val = r.end.val) :
    core.ops.range.RangeInclusive.Insts.CoreIterTraitsIteratorIterator.next
      (core.iter.range.IScalarStep ty cloneInst partialOrdInst) r ⦃ o r' => o = some r.start ∧
      r' = ⟨r.start, r.end, true⟩ ⦄ := by
  simp only [core.ops.range.RangeInclusive.Insts.CoreIterTraitsIteratorIterator.next,
    core.ops.range.RangeInclusive.is_empty, core.iter.range.IScalarStep, h_le, h_lt, h_clone]
  simp [hx, h]

/-- `start..=end` over `IScalar ty`, not yet exhausted, yields `[start, end]`. -/
theorem core.ops.range.RangeInclusive.yields_IScalar {ty : IScalarTy}
    {cloneInst : core.clone.Clone (IScalar ty)}
    {partialOrdInst : core.cmp.PartialOrd (IScalar ty) (IScalar ty)}
    (h_clone : ∀ x : IScalar ty, cloneInst.clone x = ok x)
    (h_le : ∀ a b : IScalar ty, partialOrdInst.le a b = ok (decide (a.val ≤ b.val)))
    (h_lt : ∀ a b : IScalar ty, partialOrdInst.lt a b = ok (decide (a.val < b.val))) :
    ∀ (n : ℕ) (r : core.ops.range.RangeInclusive (IScalar ty)),
    r.exhausted = false → (r.end.val + 1 - r.start.val).toNat = n → ∃ rs : List (IScalar ty),
      rs.map (·.val) = intRange r.start.val (r.end.val + 1) ∧
      Yields (core.ops.range.RangeInclusive.Insts.CoreIterTraitsIteratorIterator
        (core.iter.range.IScalarStep ty cloneInst partialOrdInst)) r rs
  | 0, r, _, hn => ⟨[], by simp [intRange_of_le (show r.end.val + 1 ≤ r.start.val by omega)],
      core.ops.range.RangeInclusive.next_IScalar_none_spec h_le r (Or.inr (by omega))⟩
  | n + 1, r, hx, hn => by
    rcases lt_or_eq_of_le (show r.start.val ≤ r.end.val by omega) with hlt | heq
    · obtain ⟨rs, hrs, hy⟩ := core.ops.range.RangeInclusive.yields_IScalar h_clone h_le h_lt n
        ⟨IScalar.succOfLt r.start r.end hlt, r.end, false⟩ rfl (by simp; omega)
      refine ⟨r.start :: rs, ?_, ?_⟩
      · simp only at hrs; simp [hrs, intRange_of_lt (show r.start.val < r.end.val + 1 by omega)]
      · refine spec_mono (core.ops.range.RangeInclusive.next_IScalar_lt_spec h_le h_lt r hx hlt) ?_
        rintro ⟨o, r'⟩ ⟨rfl, rfl⟩
        exact ⟨rfl, hy⟩
    · refine ⟨[r.start], ?_, ?_⟩
      · rw [intRange_of_lt (by omega), intRange_of_le (by omega)]; simp [heq]
      · refine spec_mono
          (core.ops.range.RangeInclusive.next_IScalar_eq_spec h_clone h_le h_lt r hx heq) ?_
        rintro ⟨o, r'⟩ ⟨rfl, rfl⟩
        exact ⟨rfl, core.ops.range.RangeInclusive.next_IScalar_none_spec h_le _ (Or.inl rfl)⟩

-- Per-type `Yields` for every signed scalar.
iscalar
theorem core.iter.range.IteratorRange.yields_'S (r : core.ops.range.Range «%S») :
    ∃ rs : List «%S», rs.map (·.val) = intRange r.start.val r.end.val ∧
      Yields (core.iter.traits.iterator.IteratorRange core.iter.range.Step'S) r rs :=
  core.iter.range.IteratorRange.yields_IScalar (by intros; rfl)
    (by intros; simp [core.cmp.impls.PartialOrd'S.lt]) _ r rfl

iscalar
theorem core.ops.range.RangeInclusive.yields_'S (r : core.ops.range.RangeInclusive «%S»)
    (hx : r.exhausted = false) :
    ∃ rs : List «%S», rs.map (·.val) = intRange r.start.val (r.end.val + 1) ∧
      Yields (core.ops.range.RangeInclusive.Insts.CoreIterTraitsIteratorIterator
        core.iter.range.Step'S) r rs :=
  core.ops.range.RangeInclusive.yields_IScalar (by intros; rfl)
    (by intros; simp [core.cmp.impls.PartialOrd'S.le])
    (by intros; simp [core.cmp.impls.PartialOrd'S.lt]) _ r hx rfl

/-! ## `List.overwrite` -/

/-- `l` with its first `vs.length` items replaced by `vs` (none past its end): what the
backward function of a loop writing through `iter_mut()` leaves. -/
@[expose] def _root_.List.overwrite {α : Type} (l vs : List α) : List α :=
  l.mapIdx fun j a => vs.getD j a

@[simp] theorem _root_.List.length_overwrite {α : Type} (l vs : List α) :
    (l.overwrite vs).length = l.length := by simp [List.overwrite]

@[simp] theorem _root_.List.overwrite_nil {α : Type} (l : List α) : l.overwrite [] = l :=
  List.ext_getElem (by simp) (by simp [List.overwrite])

/-- Writing `v` at `vs.length`, then `vs` below it, is writing `vs ++ [v]`. -/
theorem _root_.List.overwrite_set {α : Type} (l vs : List α) (v : α) :
    (l.set vs.length v).overwrite vs = l.overwrite (vs ++ [v]) := by
  apply List.ext_getElem (by simp)
  intro j h1 h2
  simp only [List.overwrite, List.getElem_mapIdx, List.getElem_set]
  rcases lt_trichotomy j vs.length with h | h | h
  · simp [List.getD_eq_getElem?_getD, List.getElem?_append_left h, List.getElem?_eq_getElem h,
      h.ne']
  · subst h; simp [List.getD_eq_getElem?_getD]
  · simp [List.getD_eq_getElem?_getD, show vs.length ≠ j by omega,
      List.getElem?_eq_none (by omega : vs.length ≤ j),
      List.getElem?_eq_none (by simp; omega : (vs ++ [v]).length ≤ j)]

theorem _root_.List.overwrite_of_length {α : Type} (l vs : List α) (h : vs.length = l.length) :
    l.overwrite vs = vs := by
  apply List.ext_getElem (by simp [h])
  intro j h1 h2
  simp [List.overwrite, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem h2]

end Aeneas.Std
