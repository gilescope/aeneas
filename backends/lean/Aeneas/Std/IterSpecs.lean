/- Specs for iterating: `foldlM`, the `Yields` predicate for generic loops, signed-integer
ranges, and `List.overwrite` (what an `iter_mut()` loop's backward function writes). -/
module
public import Aeneas.Std.RangeIter
public import Aeneas.Std.Core.IterAdapters
public import Aeneas.Std.VecIter
public section

namespace Aeneas.Std

open Result core.ops.range WP ScalarElab

/-! ## Specs are equations

`Result` is deterministic: a spec says the computation succeeds with a value satisfying it. -/

theorem spec_eq_ok {α : Type} {m : Result α} {P : α → Prop} (h : m ⦃ x => P x ⦄) :
    ∃ v, m = ok v ∧ P v := by
  cases m using Result.cases with
  | ret r => exact ⟨r, rfl, (spec_ok r).1 h⟩
  | vis i k => exact absurd h (by simp)
  | div => exact absurd h (by simp)

/-- A spec's post holds of the value an accepted run returns. -/
theorem spec_of_eq_ok {α : Type} {m : Result α} {P : α → Prop} {x : α} (hs : m ⦃ v => P v ⦄)
    (h : m = ok x) : P x := by
  obtain ⟨v, hv, hp⟩ := spec_eq_ok hs
  rw [h, Result.ok.injEq] at hv
  exact hv ▸ hp

/-- An accepted bind ran its first step to a value: `?` succeeded. -/
theorem bind_eq_ok_inv {α β : Type} {m : Result α} {f : α → Result β} {y : β}
    (h : Std.bind m f = ok y) : ∃ x, m = ok x ∧ f x = ok y := by
  cases m using Result.cases with
  | ret r => exact ⟨r, rfl, by simpa using h⟩
  | vis i k => simp at h
  | div => simp at h

/-- Re-associate a two-step bind to use a spec of the first two steps together. -/
theorem spec_bind_assoc {α β γ : Type} {m : Result α} {f : α → Result β} {g : β → Result γ}
    {P : β → Prop} {Q : γ → Prop} (h : (m >>= f) ⦃ y => P y ⦄)
    (hg : ∀ y, P y → g y ⦃ z => Q z ⦄) : (m >>= fun x => f x >>= g) ⦃ z => Q z ⦄ := by
  rw [← bind_assoc_eq]
  exact WP.spec_bind h hg

/-! ## Accepted scalar and `Vec` ops

Ok-conditional inversions: what an accepted run of an op tells about its operands. -/

theorem UScalar.add_ok {ty : UScalarTy} {x y z : UScalar ty} (h : x + y = ok z) :
    z.val = x.val + y.val := by
  have h' := UScalar.add_equiv x y
  rw [h] at h'
  exact h'.2.1

theorem UScalar.sub_ok {ty : UScalarTy} {x y r : UScalar ty} (h : (x - y : Result _) = ok r) :
    y.val ≤ x.val ∧ r.val = x.val - y.val := by
  have hle : y.val ≤ x.val := by
    have h' := h
    change UScalar.sub x y = ok r at h'
    unfold UScalar.sub at h'
    split at h'
    · simp at h'
    · omega
  exact ⟨hle, (spec_of_eq_ok (UScalar.sub_spec (x := x) (y := y) hle) h).1⟩

theorem UScalar.tryMk_ok {ty : UScalarTy} {x : ℕ} {r : UScalar ty}
    (h : UScalar.tryMk ty x = ok r) : r.val = x := by
  have := UScalar.tryMk_eq ty x
  rw [h] at this
  exact this.1

theorem IScalar.tryMk_ok {ty : IScalarTy} {x : ℤ} {r : IScalar ty}
    (h : IScalar.tryMk ty x = ok r) : r.val = x := by
  have := IScalar.tryMk_eq ty x
  rw [h] at this
  exact this.1

theorem alloc.vec.Vec.push_ok {α : Type} {v r : alloc.vec.Vec α} {x : α} (h : v.push x = ok r) :
    r.val = v.val ++ [x] := by
  unfold alloc.vec.Vec.push at h
  dsimp only at h
  split at h
  · simp only [ok.injEq] at h
    subst h
    simp
  · simp at h

/-- An accepted `v[i]` is in range and returns that item. -/
theorem alloc.vec.Vec.index_ok {T : Type} {v : alloc.vec.Vec T} {i : Usize} {x : T}
    (h : alloc.vec.Vec.index (core.slice.index.SliceIndexUsizeSlice T) v i = ok x) :
    ∃ hi : i.val < v.val.length, x = v.val[i.val] := by
  rw [alloc.vec.Vec.index_slice_index] at h
  unfold alloc.vec.Vec.index_usize at h
  split at h
  · simp at h
  · rename_i y hy
    simp only [ok.injEq] at h
    subst h
    rw [alloc.vec.Vec.getElem?_Nat_eq] at hy
    obtain ⟨hi, hv⟩ := List.getElem?_eq_some_iff.mp hy
    exact ⟨hi, hv.symm⟩

/-- An accepted `&mut v[i]` is in range, borrows that item, and writes back with `set`. -/
theorem alloc.vec.Vec.index_mut_ok {T : Type} {v : alloc.vec.Vec T} {i : Usize} {x : T}
    {back : T → alloc.vec.Vec T}
    (h : alloc.vec.Vec.index_mut (core.slice.index.SliceIndexUsizeSlice T) v i = ok (x, back)) :
    ∃ hi : i.val < v.val.length, x = v.val[i.val] ∧ back = v.set i := by
  rw [alloc.vec.Vec.index_mut_slice_index] at h
  unfold alloc.vec.Vec.index_mut_usize at h
  obtain ⟨y, hy, h⟩ := bind_eq_ok_inv h
  simp only [ok.injEq, Prod.mk.injEq] at h
  obtain ⟨rfl, rfl⟩ := h
  unfold alloc.vec.Vec.index_usize at hy
  split at hy
  · simp at hy
  · rename_i z hz
    simp only [ok.injEq] at hy
    subst hy
    rw [alloc.vec.Vec.getElem?_Nat_eq] at hz
    obtain ⟨hi, hv⟩ := List.getElem?_eq_some_iff.mp hz
    exact ⟨hi, hv.symm, rfl⟩

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

/-- `next` yields `xs` in order, and nothing is claimed after: unlike `Yields`, an unbounded
iterator (`successors`, `repeat`) satisfies it for every finite prefix. -/
@[expose] def YieldsAtLeast {I Item : Type} (inst : core.iter.traits.iterator.Iterator I Item) :
    I → List Item → Prop
  | _, [] => True
  | it, x :: xs => inst.next it ⦃ o it' => o = some x ∧ YieldsAtLeast inst it' xs ⦄

theorem YieldsAtLeast.of_yields {I Item : Type} (inst : core.iter.traits.iterator.Iterator I Item) :
    ∀ (xs : List Item) (it : I), Yields inst it xs → YieldsAtLeast inst it xs
  | [], _, _ => trivial
  | x :: xs, it, h => by
    simp only [Yields] at h
    simp only [YieldsAtLeast]
    exact spec_mono h (fun ⟨o, it'⟩ ⟨ho, hy⟩ => ⟨ho, YieldsAtLeast.of_yields inst xs it' hy⟩)

/-- `take(n)` of an iterator yielding at least `n` items yields exactly those. -/
theorem core.iter.adapters.take.Take.yields_atLeast {I Item : Type}
    (IA : core.iter.traits.iterator.Iterator I Item) :
    ∀ (xs : List Item) (it : I) (n : Usize), xs.length = n.val → YieldsAtLeast IA it xs →
    Yields (core.iter.traits.iterator.IteratorTake IA) ⟨it, n⟩ xs
  | [], it, n, hn, _ => by
    simp only [Yields, core.iter.traits.iterator.IteratorTake, core.iter.adapters.take.IteratorTake.nextPlain]
    simp [show n.val = 0 by simpa using hn.symm, spec_ok]
  | x :: xs, it, n, hn, h => by
    simp only [YieldsAtLeast] at h
    obtain ⟨⟨o, it'⟩, hnx, ho, hy⟩ := spec_eq_ok h
    subst ho
    simp only [Yields, core.iter.traits.iterator.IteratorTake,
      core.iter.adapters.take.IteratorTake.nextPlain]
    have hn0 : ¬ n.val = 0 := by simp at hn; omega
    simp only [hn0, ↓reduceIte]
    obtain ⟨n', hn', hn'v, -⟩ := spec_eq_ok (UScalar.sub_spec (x := n) (y := 1#usize) (by simp; omega))
    simp only [hn', hnx, bind_tc_ok, spec_ok]
    exact ⟨rfl, core.iter.adapters.take.Take.yields_atLeast IA xs it' n' (by simp at hn hn'v; omega) hy⟩

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

-- Per-type `IteratorRange.next` on signed ranges (`for _ in 0..n` with an untyped `n` is
-- `i32`), in the unsigned specs' shape (`RangeIter.lean`).
iscalar
theorem core.iter.range.IteratorRange.next_'S_some_spec
    (range : core.ops.range.Range «%S»)
    (hlt : range.start.val < range.end.val) :
    core.iter.range.IteratorRange.next core.iter.range.Step'S range
    ⦃ (opt : Option «%S») (range' : core.ops.range.Range «%S») =>
      opt = some range.start ∧
      range'.start.val = range.start.val + 1 ∧
      range'.end = range.end ⦄ := by
  apply spec_mono (core.iter.range.IteratorRange.next_IScalar_some_spec
    (by simp) (by intros; rfl) range hlt)
  rintro ⟨o, r'⟩ ⟨rfl, rfl⟩
  simp

iscalar
theorem core.iter.range.IteratorRange.next_'S_none_spec
    (range : core.ops.range.Range «%S»)
    (hge : range.start.val ≥ range.end.val) :
    core.iter.range.IteratorRange.next core.iter.range.Step'S range
    ⦃ (opt : Option «%S») (range' : core.ops.range.Range «%S») =>
      opt = none ∧ range' = range ⦄ :=
  core.iter.range.IteratorRange.next_IScalar_none_spec (by intros; rfl) range hge

iscalar
@[step]
theorem core.iter.range.IteratorRange.next_'S_spec
    (range : core.ops.range.Range «%S») :
    core.iter.range.IteratorRange.next core.iter.range.Step'S range
    ⦃ (opt : Option «%S») (range' : core.ops.range.Range «%S») =>
      (if range.start.val < range.end.val then
         opt = some range.start ∧ range'.start.val = range.start.val + 1
       else
         opt = none ∧ range'.start = range.start) ∧
      range'.end = range.end ⦄ := by
  by_cases h : range.start.val < range.end.val
  · simp only [h, ↓reduceIte]
    apply spec_mono (core.iter.range.IteratorRange.next_'S_some_spec range h)
    rintro ⟨o, r'⟩ ⟨h1, h2, h3⟩
    simp only [uncurry'_pair]
    exact ⟨⟨h1, h2⟩, h3⟩
  · simp only [h, ↓reduceIte]
    apply spec_mono (core.iter.range.IteratorRange.next_'S_none_spec range (by omega))
    rintro ⟨o, r'⟩ ⟨rfl, rfl⟩
    simp [uncurry'_pair]

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

/-! ## Unsigned-integer ranges -/

/-- `start..end` over `UScalar ty` yields `[start, end)`. -/
theorem core.iter.range.IteratorRange.yields_UScalar {ty : UScalarTy}
    {cloneInst : core.clone.Clone (UScalar ty)}
    {partialOrdInst : core.cmp.PartialOrd (UScalar ty) (UScalar ty)}
    (h_clone : ∀ x : UScalar ty, cloneInst.clone x = ok x)
    (h_lt : ∀ a b : UScalar ty, partialOrdInst.lt a b = ok (decide (a.val < b.val))) :
    ∀ (n : ℕ) (r : core.ops.range.Range (UScalar ty)), r.end.val - r.start.val = n →
    ∃ rs : List (UScalar ty), rs.map (·.val) = List.range' r.start.val n ∧
      Yields (core.iter.traits.iterator.IteratorRange
        (core.iter.range.UScalarStep ty cloneInst partialOrdInst)) r rs
  | 0, r, hn => ⟨[], by simp,
      spec_mono (core.iter.range.IteratorRange.next_UScalar_none_spec h_lt r (by omega))
        fun _ h => h.1⟩
  | n + 1, r, hn => by
    obtain ⟨⟨o, r'⟩, hnext, hpost⟩ := spec_eq_ok
      (core.iter.range.IteratorRange.next_UScalar_some_spec h_clone h_lt r (by omega))
    simp only [uncurry'_pair] at hpost
    obtain ⟨rfl, hs', he'⟩ := hpost
    obtain ⟨rs, hrs, hy⟩ := core.iter.range.IteratorRange.yields_UScalar h_clone h_lt n r'
      (by rw [he', hs']; omega)
    refine ⟨r.start :: rs, by simp [hrs, hs', List.range'_succ], ?_⟩
    simp only [Yields, core.iter.traits.iterator.IteratorRange]
    rw [hnext, spec_ok]
    exact ⟨rfl, hy⟩

-- Per-type `Yields` for every unsigned scalar.
uscalar
theorem core.iter.range.IteratorRange.yields_'S (r : core.ops.range.Range «%S») :
    ∃ rs : List «%S», rs.map (·.val) = List.range' r.start.val (r.end.val - r.start.val) ∧
      Yields (core.iter.traits.iterator.IteratorRange core.iter.range.Step'S) r rs :=
  core.iter.range.IteratorRange.yields_UScalar (by simp) (by intros; rfl) _ r rfl

/-! ## Slices, `map` and `collect` -/

/-- `slice.iter()` at index `i` yields the items from `i`. -/
theorem core.slice.iter.IteratorSliceIter.yields {T : Type} :
    ∀ (n : ℕ) (it : core.slice.iter.Iter T), it.slice.val.length - it.i = n →
    Yields (core.iter.traits.iterator.IteratorSliceIter T) it (it.slice.val.drop it.i)
  | 0, it, hn => by
    have h : ¬ it.i < it.slice.val.length := by omega
    rw [List.drop_of_length_le (by omega)]
    simp [Yields, core.iter.traits.iterator.IteratorSliceIter, core.slice.iter.IteratorSliceIter.next,
      h]
  | n + 1, it, hn => by
    have hi : it.i < it.slice.val.length := by omega
    rw [List.drop_eq_getElem_cons hi]
    simp only [Yields, core.iter.traits.iterator.IteratorSliceIter_next,
      core.slice.iter.IteratorSliceIter.next, Slice.len_val, Slice.length, hi, ↓reduceDIte, spec_ok]
    refine ⟨rfl, ?_⟩
    simpa using core.slice.iter.IteratorSliceIter.yields n { it with i := it.i + 1 } (by simp; omega)

/-- `s.iter()` yields `s`. -/
theorem core.slice.Slice.iter_yields {T : Type} (s : Slice T) :
    core.slice.Slice.iter s ⦃ it => Yields (core.iter.traits.iterator.IteratorSliceIter T) it s.val ⦄ := by
  simpa [core.slice.Slice.iter] using core.slice.iter.IteratorSliceIter.yields _ ⟨s, 0⟩ rfl

/-- A `vec::IntoIter` yields the elements left. -/
theorem alloc.vec.into_iter.IntoIter.yields {T : Type} :
    ∀ (xs : List T) (it : alloc.vec.into_iter.IntoIter T), it.val = xs →
      Yields (core.iter.traits.iterator.IteratorVecIntoIter T) it xs
  | [], it, hv => by
    have hn : alloc.vec.into_iter.IteratorIntoIter.next it = ok (none, it) := by
      unfold alloc.vec.into_iter.IteratorIntoIter.next
      split
      · rfl
      · rename_i hd tl h; rw [hv] at h; exact absurd h.symm (List.cons_ne_nil hd tl)
    simp only [Yields, hn, spec_ok, uncurry'_pair]
  | hd :: tl, it, hv => by
    have hbound : tl.length ≤ Usize.max := by
      have h := alloc.vec.Vec.property it; simp only [hv, List.length_cons] at h; omega
    have hn : alloc.vec.into_iter.IteratorIntoIter.next it =
        (ok (some hd, alloc.vec.Vec.from tl hbound) :
          Result (Option T × alloc.vec.into_iter.IntoIter T)) := by
      unfold alloc.vec.into_iter.IteratorIntoIter.next
      split
      · rename_i h; rw [hv] at h; exact absurd h (List.cons_ne_nil hd tl)
      · rename_i hd' tl' h; rw [hv] at h
        obtain ⟨rfl, rfl⟩ := List.cons.inj h; rfl
    simp only [Yields, hn, spec_ok]
    exact ⟨rfl, alloc.vec.into_iter.IntoIter.yields tl _ (alloc.vec.Vec.from_val tl hbound)⟩

/-- `v.into_iter()` yields `v`. -/
theorem alloc.vec.IntoIteratorVec.into_iter_yields {T : Type} (v : alloc.vec.Vec T) :
    alloc.vec.IntoIteratorVec.into_iter v ⦃ it =>
      Yields (core.iter.traits.iterator.IteratorVecIntoIter T) it v.val ⦄ := by
  simp only [alloc.vec.IntoIteratorVec.into_iter, spec_ok]
  exact alloc.vec.into_iter.IntoIter.yields _ v rfl

/-- `fold.default`'s loop over an iterator yielding `xs`, through denotations `σB`/`σItem`. -/
private theorem fold_loop_yields_spec
    {I G B Item K : Type}
    (σB : B → K) (σItem : Item → K)
    (IA : core.iter.traits.iterator.Iterator I Item)
    (GI : core.ops.function.FnMut G (B × Item) B)
    (step : K → K → K) (g : G)
    (hstep : ∀ acc x, GI.call_mut g (acc, x) ⦃ r g' => σB r = step (σB acc) (σItem x) ∧ g' = g ⦄) :
    ∀ (xs : List Item) (it : I) (init : B),
    Yields IA it xs →
    loop (fun ((it, acc, g) : I × B × G) => do
      let (o, it) ← IA.next it
      match o with
      | none => ok (.done (acc, g))
      | some x =>
        let (acc, g) ← GI.call_mut g (acc, x)
        ok (.cont (it, acc, g))) (it, init, g)
    ⦃ (acc, g') => σB acc = (xs.map σItem).foldl step (σB init) ∧ g' = g ⦄ := by
  intro xs
  induction xs with
  | nil =>
    intro it init hy
    simp only [Yields] at hy
    obtain ⟨⟨o, it'⟩, hnext, ho⟩ := spec_eq_ok hy
    simp only [uncurry'_pair] at ho; subst ho
    rw [loop]; simp only [hnext, Std.bind_ok]
    simp [spec_ok]
  | cons x xs' ih =>
    intro it init hy
    simp only [Yields] at hy
    obtain ⟨⟨o, it'⟩, hnext, hpost⟩ := spec_eq_ok hy
    simp only [uncurry'_pair] at hpost
    obtain ⟨rfl, hys'⟩ := hpost
    have hst := hstep init x
    obtain ⟨⟨v, g'⟩, hcall, hvg⟩ := spec_eq_ok hst
    simp only [uncurry'_pair] at hvg
    obtain ⟨hrv, hrg⟩ := hvg; subst hrg
    rw [loop]
    -- split: one-step body / continuation
    apply WP.spec_bind (Pₘ := fun r => r = ControlFlow.cont (it', v, g'))
    · -- body (it, init, g') ⦃ r => r = .cont (it', v, g') ⦄
      simp [hnext, hcall, Std.bind_ok, spec_ok]
    · intro r hr; rw [hr]
      simp only [List.map_cons, List.foldl_cons, ← hrv]
      exact ih it' v hys'

/-- `fold(init, f)` over an iterator yielding `xs`, when each call denotes `step` and leaves the
closure as it was: the result denotes `(xs.map σItem).foldl step (σB init)`. -/
theorem core.iter.traits.iterator.Iterator.fold.default_yields_spec
    {I G B Item K : Type}
    (σB : B → K) (σItem : Item → K)
    (IA : core.iter.traits.iterator.Iterator I Item)
    (GI : core.ops.function.FnMut G (B × Item) B)
    (step : K → K → K) (g : G)
    (hstep : ∀ acc x, GI.call_mut g (acc, x) ⦃ r g' => σB r = step (σB acc) (σItem x) ∧ g' = g ⦄) :
    ∀ (xs : List Item) (it : I) (init : B),
    Yields IA it xs →
    core.iter.traits.iterator.Iterator.fold.default (S := inferInstance) IA GI it init g
    ⦃ r => σB r = (xs.map σItem).foldl step (σB init) ⦄ := by
  intro xs it init hy
  simp only [core.iter.traits.iterator.Iterator.fold.default, bind_tc_eq]
  apply spec_bind (fold_loop_yields_spec σB σItem IA GI step g hstep xs it init hy)
  rintro ⟨acc, g'⟩ ⟨hacc, -⟩
  -- FoldShape B G B (low-priority instance) has ofFold := fun b _ => b
  change ok acc ⦃ r => σB r = (xs.map σItem).foldl step (σB init) ⦄
  simp [hacc, spec_ok]

/-- `fold.default`'s loop over an iterator yielding `xs`, by an invariant `P done acc g` over the
prefix `done` of `all` already folded. -/
private theorem fold_loop_inv
    {I G B Item : Type}
    (IA : core.iter.traits.iterator.Iterator I Item)
    (GI : core.ops.function.FnMut G (B × Item) B)
    (all : List Item) (P : List Item → B → G → Prop)
    (hstep : ∀ done x rest acc g, all = done ++ x :: rest → P done acc g →
      GI.call_mut g (acc, x) ⦃ r g' => P (done ++ [x]) r g' ⦄) :
    ∀ (xs done : List Item) (it : I) (acc : B) (g : G),
    all = done ++ xs → Yields IA it xs → P done acc g →
    loop (fun ((it, acc, g) : I × B × G) => do
      let (o, it) ← IA.next it
      match o with
      | none => ok (.done (acc, g))
      | some x =>
        let (acc, g) ← GI.call_mut g (acc, x)
        ok (.cont (it, acc, g))) (it, acc, g)
    ⦃ (acc', g') => P all acc' g' ⦄ := by
  intro xs
  induction xs with
  | nil =>
    intro done it acc g hall hy hP
    simp only [Yields] at hy
    obtain ⟨⟨o, it'⟩, hnext, ho⟩ := spec_eq_ok hy
    simp only [uncurry'_pair] at ho; subst ho
    rw [loop]; simp only [hnext, Std.bind_ok]
    simpa [spec_ok, hall] using hP
  | cons x xs' ih =>
    intro done it acc g hall hy hP
    simp only [Yields] at hy
    obtain ⟨⟨o, it'⟩, hnext, hpost⟩ := spec_eq_ok hy
    simp only [uncurry'_pair] at hpost
    obtain ⟨rfl, hys'⟩ := hpost
    obtain ⟨⟨v, g'⟩, hcall, hvg⟩ := spec_eq_ok (hstep done x xs' acc g hall hP)
    simp only [uncurry'_pair] at hvg
    rw [loop]
    apply WP.spec_bind (Pₘ := fun r => r = ControlFlow.cont (it', v, g'))
    · simp [hnext, hcall, Std.bind_ok, spec_ok]
    · intro r hr; rw [hr]
      exact ih (done ++ [x]) it' v g' (by simp [hall]) hys' hvg

/-- `fold(init, f)` with a closure that may change its state, by an invariant `P done acc g` over
the prefix `done` of `xs` already folded. -/
theorem core.iter.traits.iterator.Iterator.fold.default_inv_spec
    {I G B Item Out : Type} [S : FoldShape B G Out]
    (IA : core.iter.traits.iterator.Iterator I Item)
    (GI : core.ops.function.FnMut G (B × Item) B)
    (xs : List Item) (P : List Item → B → G → Prop)
    (hstep : ∀ done x rest acc g, xs = done ++ x :: rest → P done acc g →
      GI.call_mut g (acc, x) ⦃ r g' => P (done ++ [x]) r g' ⦄)
    (it : I) (init : B) (g : G)
    (hy : Yields IA it xs) (h0 : P [] init g) :
    core.iter.traits.iterator.Iterator.fold.default (S := S) IA GI it init g
    ⦃ o => ∃ acc g', P xs acc g' ∧ o = S.ofFold acc g' ⦄ := by
  simp only [core.iter.traits.iterator.Iterator.fold.default, bind_tc_eq]
  apply spec_bind (fold_loop_inv IA GI xs P hstep xs [] it init g rfl hy h0)
  rintro ⟨acc, g'⟩ hP
  simp only [spec_ok]
  exact ⟨acc, g', hP, rfl⟩

/-- Threads a state through `g` over `xs`, listing the outputs. -/
@[expose] def _root_.List.mapState {S A B : Type} (g : S → A → B × S) : S → List A → List B
  | _, [] => []
  | s, x :: xs => (g s x).1 :: List.mapState g (g s x).2 xs

/-- `map(f)` over an iterator yielding `xs` yields the outputs of `f`'s calls, its state
threaded through: `P rest f` is the invariant with `rest` still to come. -/
theorem core.iter.adapters.map.Map.yields {I F Item B : Type}
    (IA : core.iter.traits.iterator.Iterator I Item) (FI : core.ops.function.FnMut F Item B)
    (g : F → Item → B × F) (P : List Item → F → Prop)
    (hg : ∀ x xs f, P (x :: xs) f → FI.call_mut f x = ok (g f x) ∧ P xs (g f x).2) :
    ∀ (xs : List Item) (it : I) (f : F), Yields IA it xs → P xs f →
    Yields (core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator IA FI) ⟨it, f⟩
      (List.mapState g f xs)
  | [], it, f, hy, _ => by
    simp only [Yields, core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator,
      core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator.next, List.mapState]
    rw [bind_tc_eq]
    refine spec_bind hy ?_
    rintro ⟨o, it'⟩ ho
    simp only [uncurry'_pair] at ho
    subst ho; simp
  | x :: xs, it, f, hy, hP => by
    obtain ⟨hc, hP'⟩ := hg x xs f hP
    simp only [Yields] at hy
    simp only [Yields, core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator,
      core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator.next, List.mapState]
    rw [bind_tc_eq]
    refine spec_bind hy ?_
    rintro ⟨o, it'⟩ ⟨ho, hy'⟩
    subst ho
    simp only [hc, bind_tc_ok, spec_ok]
    exact ⟨rfl, core.iter.adapters.map.Map.yields IA FI g P hg xs it' (g f x).2 hy' hP'⟩

/-- `map(f)` with a closure that is a pure function `h` and keeps its state yields `xs.map h`. -/
theorem core.iter.adapters.map.Map.yields_of_pure {I F Item B : Type}
    (IA : core.iter.traits.iterator.Iterator I Item) (FI : core.ops.function.FnMut F Item B)
    (f : F) (h : Item → B) (hc : ∀ x, FI.call_mut f x = ok (h x, f)) :
    ∀ (xs : List Item) (it : I), Yields IA it xs →
    Yields (core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator IA FI) ⟨it, f⟩
      (xs.map h) := by
  intro xs it hy
  have hY := core.iter.adapters.map.Map.yields IA FI (fun c x => (h x, c)) (fun _ c => c = f)
    (fun x _ c hc' => by subst hc'; exact ⟨hc x, rfl⟩) xs it f hy rfl
  have hms : ∀ ys : List Item, List.mapState (fun c x => (h x, c)) f ys = ys.map h := by
    intro ys; induction ys with
    | nil => rfl
    | cons y ys ih => simp [List.mapState, ih]
  rwa [hms] at hY

/-- `map(f)` over an iterator yielding `xs`, when `f`'s calls are known only by a spec: it yields
some `ys` as long as `xs` with `R j ys[j]`; `P j f` is the closure's invariant before item `j`. -/
theorem core.iter.adapters.map.Map.yields_spec {I F Item B : Type}
    (IA : core.iter.traits.iterator.Iterator I Item) (FI : core.ops.function.FnMut F Item B) :
    ∀ (xs : List Item) (R : ℕ → B → Prop) (P : ℕ → F → Prop)
    (it : I) (f : F), Yields IA it xs → P 0 f →
    (∀ j (hj : j < xs.length) f, P j f → FI.call_mut f xs[j] ⦃ y f' => R j y ∧ P (j + 1) f' ⦄) →
    ∃ ys : List B, ys.length = xs.length ∧ (∀ j (hj : j < ys.length), R j ys[j]) ∧
      Yields (core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator IA FI) ⟨it, f⟩ ys
  | [], R, P, it, f, hy, _, _ => ⟨[], rfl, by simp, by
      simp only [Yields, core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator,
        core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator.next]
      rw [bind_tc_eq]
      refine spec_bind hy ?_
      rintro ⟨o, it'⟩ ho
      simp only [uncurry'_pair] at ho
      subst ho; simp⟩
  | x :: xs, R, P, it, f, hy, h0, hs => by
    simp only [Yields] at hy
    obtain ⟨⟨o, it'⟩, hnext, hpost⟩ := spec_eq_ok hy
    simp only [uncurry'_pair] at hpost
    obtain ⟨rfl, hy'⟩ := hpost
    obtain ⟨⟨y, f'⟩, hcall, hpost'⟩ := spec_eq_ok (hs 0 (by simp) f h0)
    simp only [uncurry'_pair] at hpost'
    obtain ⟨hR, hP⟩ := hpost'
    obtain ⟨ys, hl, hRs, hys⟩ := core.iter.adapters.map.Map.yields_spec IA FI xs
      (fun j => R (j + 1)) (fun j => P (j + 1)) it' f' hy' hP
      fun j hj g hg => by
        have h := hs (j + 1) (by simp; omega) g hg
        rwa [List.getElem_cons_succ] at h
    refine ⟨y :: ys, by simp [hl], fun j hj => ?_, ?_⟩
    · cases j with
      | zero => simpa using hR
      | succ j => simpa using hRs j (by simpa using hj)
    · simp only [Yields, core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator_next,
        core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator.next]
      simp only [List.getElem_cons_zero] at hcall
      simp [hnext, hcall, hys]

theorem alloc.vec.FromIteratorVec.iterToList_spec {T I : Type}
    (IA : core.iter.traits.iterator.Iterator I T) :
    ∀ (xs : List T) (it : I) (acc : List T), Yields IA it xs →
    alloc.vec.FromIteratorVec.iterToList IA it acc ⦃ l => l = acc.reverse ++ xs ⦄
  | [], it, acc, hy => by
    rw [alloc.vec.FromIteratorVec.iterToList, bind_tc_eq]
    refine spec_bind hy ?_
    rintro ⟨o, it'⟩ ho
    simp only [uncurry'_pair] at ho
    subst ho; simp
  | x :: xs, it, acc, hy => by
    simp only [Yields] at hy
    rw [alloc.vec.FromIteratorVec.iterToList, bind_tc_eq]
    refine spec_bind hy ?_
    rintro ⟨o, it'⟩ ⟨ho, hy'⟩
    subst ho
    simpa using alloc.vec.FromIteratorVec.iterToList_spec IA xs it' (x :: acc) hy'

theorem alloc.vec.FromIteratorVec.iterToListBack_spec {T I : Type}
    (IA : core.iter.traits.iterator.Iterator I T) :
    ∀ (xs : List T) (it : I) (acc : List T), Yields IA it xs →
    alloc.vec.FromIteratorVec.iterToListBack IA it acc ⦃ l _ => l = acc.reverse ++ xs ⦄
  | [], it, acc, hy => by
    rw [alloc.vec.FromIteratorVec.iterToListBack, bind_tc_eq]
    refine spec_bind hy ?_
    rintro ⟨o, it'⟩ ho
    simp only [uncurry'_pair] at ho
    subst ho; simp
  | x :: xs, it, acc, hy => by
    simp only [Yields] at hy
    rw [alloc.vec.FromIteratorVec.iterToListBack, bind_tc_eq]
    refine spec_bind hy ?_
    rintro ⟨o, it'⟩ ⟨ho, hy'⟩
    subst ho
    simpa using alloc.vec.FromIteratorVec.iterToListBack_spec IA xs it' (x :: acc) hy'

/-- `collect::<Vec<_>>()` of an iterator yielding `xs` is `xs`. -/
theorem core.iter.traits.iterator.Iterator.collect_vec_spec {I T : Type}
    (IA : core.iter.traits.iterator.Iterator I T) (it : I) (xs : List T)
    (hy : Yields IA it xs) (hl : xs.length ≤ Usize.max) :
    core.iter.traits.iterator.Iterator.collect.default (S := instCollectShape) IA
      (core.iter.traits.collect.FromIteratorVec T) it ⦃ v => v.val = xs ⦄ := by
  simp only [core.iter.traits.iterator.Iterator.collect.default, CollectShape.collect,
    core.iter.traits.collect.FromIteratorVec, alloc.vec.FromIteratorVec.from_iter,
    core.iter.traits.collect.IntoIterator.Blanket,
    core.iter.traits.collect.IntoIterator.Blanket.into_iter, bind_tc_ok]
  rw [bind_tc_eq]
  refine spec_bind (alloc.vec.FromIteratorVec.iterToList_spec IA xs it [] hy) ?_
  rintro l rfl
  simp [hl]

/-- `collect::<Vec<_>>()` of an iterator that gives back (it holds a `&mut`) is `xs`. -/
theorem core.iter.traits.iterator.Iterator.collect_vec_back_spec {I T : Type} [GivesBack I]
    (IA : core.iter.traits.iterator.Iterator I T) (it : I) (xs : List T)
    (hy : Yields IA it xs) (hl : xs.length ≤ Usize.max) :
    core.iter.traits.iterator.Iterator.collect.default IA
      (core.iter.traits.collect.FromIteratorVec T) it ⦃ v _ => v.val = xs ⦄ := by
  simp only [core.iter.traits.iterator.Iterator.collect.default, CollectShape.collect,
    FromIterBack.fromIterBack]
  rw [bind_tc_eq]
  refine spec_bind (alloc.vec.FromIteratorVec.iterToListBack_spec IA xs it [] hy) ?_
  rintro ⟨l, it'⟩ hl'
  simp only [uncurry'_pair] at hl'
  subst hl'
  simp [hl]

/-- Ok-conditional `iterToList` over `map(f)`, for a closure that keeps its state: one output per
input, each what the closure returned on it. Unlike `Map.yields_spec`, the closure may panic on
inputs the run never reached. -/
theorem alloc.vec.FromIteratorVec.iterToList_map_ok {I F Item B : Type}
    (IA : core.iter.traits.iterator.Iterator I Item) (FI : core.ops.function.FnMut F Item B) (f : F)
    (hst : ∀ x y f', FI.call_mut f x = ok (y, f') → f' = f) :
    ∀ (xs : List Item) (it : I) (acc l : List B), Yields IA it xs →
    alloc.vec.FromIteratorVec.iterToList
      (core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator IA FI) ⟨it, f⟩ acc = ok l →
    ∃ ys, l = acc.reverse ++ ys ∧ List.Forall₂ (fun x y => FI.call_mut f x = ok (y, f)) xs ys
  | [], it, acc, l, hy, h => by
    simp only [Yields] at hy
    obtain ⟨⟨o, it'⟩, hn, ho⟩ := spec_eq_ok hy
    simp only [uncurry'_pair] at ho; subst ho
    rw [alloc.vec.FromIteratorVec.iterToList] at h
    simp only [core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator,
      core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator.next, hn, bind_tc_ok,
      ok.injEq] at h
    exact ⟨[], by simp [h], .nil⟩
  | x :: xs, it, acc, l, hy, h => by
    simp only [Yields] at hy
    obtain ⟨⟨o, it'⟩, hn, ho, hy'⟩ := spec_eq_ok hy
    subst ho
    rw [alloc.vec.FromIteratorVec.iterToList] at h
    simp only [core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator,
      core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator.next, hn, bind_tc_ok] at h
    obtain ⟨⟨o', m'⟩, hm, h⟩ := bind_eq_ok_inv h
    obtain ⟨⟨y, f'⟩, hc, hm2⟩ := bind_eq_ok_inv hm
    have hf := hst _ _ _ hc
    rw [hf] at hc hm2
    simp only [ok.injEq, Prod.mk.injEq] at hm2
    obtain ⟨rfl, rfl⟩ := hm2
    obtain ⟨ys, rfl, h2⟩ :=
      alloc.vec.FromIteratorVec.iterToList_map_ok IA FI f hst xs it' (y :: acc) l hy' h
    exact ⟨y :: ys, by simp, .cons hc h2⟩

/-- Ok-conditional `map(f).collect::<Vec<_>>()`, for a closure that keeps its state. -/
theorem core.iter.traits.iterator.Iterator.collect_vec_map_ok {I F Item B : Type}
    (IA : core.iter.traits.iterator.Iterator I Item) (FI : core.ops.function.FnMut F Item B) (f : F)
    (hst : ∀ x y f', FI.call_mut f x = ok (y, f') → f' = f) (xs : List Item) (it : I)
    (hy : Yields IA it xs) (v : alloc.vec.Vec B)
    (h : core.iter.traits.iterator.Iterator.collect.default (S := instCollectShape)
      (core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator IA FI)
      (core.iter.traits.collect.FromIteratorVec B) ⟨it, f⟩ = ok v) :
    List.Forall₂ (fun x y => FI.call_mut f x = ok (y, f)) xs v.val := by
  simp only [core.iter.traits.iterator.Iterator.collect.default, CollectShape.collect,
    alloc.vec.FromIteratorVec.from_iter,
    core.iter.traits.collect.IntoIterator.Blanket.into_iter, bind_tc_ok] at h
  obtain ⟨l, hl, h⟩ := bind_eq_ok_inv h
  obtain ⟨ys, rfl, h2⟩ := alloc.vec.FromIteratorVec.iterToList_map_ok IA FI f hst xs it [] l hy hl
  split at h
  · simp only [ok.injEq] at h
    subst h
    simpa using h2
  · simp at h

/-- `iterToListBack` over `map(f)`, `f` known by a spec as in `Map.yields_spec`: the list gained
`ys` with `R j ys[j]`, and the given-back `Map`'s closure meets the invariant at the end. -/
theorem alloc.vec.FromIteratorVec.iterToListBack_map_spec {I F Item B : Type}
    (IA : core.iter.traits.iterator.Iterator I Item) (FI : core.ops.function.FnMut F Item B) :
    ∀ (xs : List Item) (R : ℕ → B → Prop) (P : ℕ → F → Prop) (it : I) (f : F) (acc : List B),
    Yields IA it xs → P 0 f →
    (∀ j (hj : j < xs.length) f, P j f → FI.call_mut f xs[j] ⦃ y f' => R j y ∧ P (j + 1) f' ⦄) →
    alloc.vec.FromIteratorVec.iterToListBack
      (core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator IA FI) ⟨it, f⟩ acc
    ⦃ l back => ∃ ys : List B, l = acc.reverse ++ ys ∧ ys.length = xs.length ∧
      (∀ j (hj : j < ys.length), R j ys[j]) ∧ P xs.length back.f ⦄
  | [], R, P, it, f, acc, hy, h0, _ => by
    simp only [Yields] at hy
    obtain ⟨⟨o, it'⟩, hnext, ho⟩ := spec_eq_ok hy
    simp only [uncurry'_pair] at ho; subst ho
    rw [alloc.vec.FromIteratorVec.iterToListBack]
    simp [core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator,
      core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator.next, hnext, h0]
  | x :: xs, R, P, it, f, acc, hy, h0, hs => by
    simp only [Yields] at hy
    obtain ⟨⟨o, it'⟩, hnext, hpost⟩ := spec_eq_ok hy
    simp only [uncurry'_pair] at hpost
    obtain ⟨rfl, hy'⟩ := hpost
    obtain ⟨⟨y, f'⟩, hcall, hpost'⟩ := spec_eq_ok (hs 0 (by simp) f h0)
    simp only [uncurry'_pair] at hpost'
    obtain ⟨hR, hP⟩ := hpost'
    simp only [List.getElem_cons_zero] at hcall
    rw [alloc.vec.FromIteratorVec.iterToListBack]
    simp only [core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator,
      core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator.next, hnext, hcall,
      bind_tc_ok, Std.bind_ok]
    refine WP.spec_mono (alloc.vec.FromIteratorVec.iterToListBack_map_spec IA FI xs
      (fun j => R (j + 1)) (fun j => P (j + 1)) it' f' (y :: acc) hy' hP
      fun j hj g hg => by
        have h := hs (j + 1) (by simp; omega) g hg
        rwa [List.getElem_cons_succ] at h) ?_
    rintro ⟨l, back⟩ ⟨ys, hl, hlen, hRs, hPb⟩
    refine ⟨y :: ys, by simp [hl], by simp [hlen], fun j hj => ?_, by simpa using hPb⟩
    cases j with
    | zero => simpa using hR
    | succ j => simpa using hRs j (by simpa using hj)

/-- `map(f).collect::<Vec<_>>()` where `f` gives back (it holds a `&mut`), `f` known by a spec as
in `Map.yields_spec`: the caller learns the outputs and the closure's final state. -/
theorem core.iter.traits.iterator.Iterator.collect_vec_map_back_spec {I F Item B : Type}
    [GivesBack F] (IA : core.iter.traits.iterator.Iterator I Item)
    (FI : core.ops.function.FnMut F Item B) (xs : List Item) (R : ℕ → B → Prop)
    (P : ℕ → F → Prop) (it : I) (f : F) (hy : Yields IA it xs) (hl : xs.length ≤ Usize.max)
    (h0 : P 0 f)
    (hs : ∀ j (hj : j < xs.length) f, P j f → FI.call_mut f xs[j] ⦃ y f' => R j y ∧ P (j + 1) f' ⦄) :
    core.iter.traits.iterator.Iterator.collect.default
      (core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator IA FI)
      (core.iter.traits.collect.FromIteratorVec B) ⟨it, f⟩
    ⦃ v back => ∃ ys : List B, v.val = ys ∧ ys.length = xs.length ∧
      (∀ j (hj : j < ys.length), R j ys[j]) ∧ P xs.length back.f ⦄ := by
  simp only [core.iter.traits.iterator.Iterator.collect.default, CollectShape.collect,
    FromIterBack.fromIterBack]
  rw [bind_tc_eq]
  refine spec_bind (alloc.vec.FromIteratorVec.iterToListBack_map_spec IA FI xs R P it f [] hy h0 hs) ?_
  rintro ⟨l, back⟩ ⟨ys, rfl, hlen, hR, hP⟩
  simp only [List.reverse_nil, List.nil_append] at hR ⊢
  simp [hlen, hl]
  exact ⟨fun j hj => hR j (by omega), hP⟩

/-- `any(p)` with a stateless predicate over an iterator yielding `xs` is `xs.any p`. -/
theorem core.iter.traits.iterator.Iterator.any_spec {I F Item : Type}
    (IA : core.iter.traits.iterator.Iterator I Item) (FI : core.ops.function.FnMut F Item Bool)
    (p : Item → Bool) (f : F) (hp : ∀ x, FI.call_mut f x = ok (p x, f)) :
    ∀ (xs : List Item) (it : I), Yields IA it xs →
    core.iter.traits.iterator.Iterator.any.default IA FI it f ⦃ b _ => b = xs.any p ⦄
  | [], it, hy => by
    simp only [Yields] at hy
    obtain ⟨⟨o, it'⟩, hnext, ho⟩ := spec_eq_ok hy
    simp only [uncurry'_pair] at ho
    subst ho
    unfold core.iter.traits.iterator.Iterator.any.default
    rw [loop]
    simp [hnext]
  | x :: xs, it, hy => by
    simp only [Yields] at hy
    obtain ⟨⟨o, it'⟩, hnext, hpost⟩ := spec_eq_ok hy
    simp only [uncurry'_pair] at hpost
    obtain ⟨rfl, hy'⟩ := hpost
    unfold core.iter.traits.iterator.Iterator.any.default
    rw [loop]
    simp only [hnext, hp, bind_tc_ok, Std.bind_ok]
    cases hpx : p x
    · simp only [Bool.false_eq_true, ↓reduceIte, Std.bind_ok, List.any_cons, hpx, Bool.false_or]
      exact core.iter.traits.iterator.Iterator.any_spec IA FI p f hp xs it' hy'
    · simp [hpx]

/-- `Yields` depends only on what `next` returns. -/
theorem Yields_congr {I Item : Type} (inst : core.iter.traits.iterator.Iterator I Item) {s1 s2 : I}
    (h : inst.next s1 = inst.next s2) (ys : List Item) : Yields inst s1 ys ↔ Yields inst s2 ys := by
  cases ys <;> simp [Yields, h]

/-- `chain`'s second half, once the first is dropped, yields what it yields. -/
theorem core.iter.adapters.chain.Chain.yields_b {A B Item : Type}
    (IA : core.iter.traits.iterator.Iterator A Item) (IB : core.iter.traits.iterator.Iterator B Item) :
    ∀ (ys : List Item) (b : B), Yields IB b ys →
    Yields (core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator IA IB) ⟨none, some b⟩ ys
  | [], b, hy => by
    simp only [Yields] at hy
    obtain ⟨⟨o, b'⟩, hnext, ho⟩ := spec_eq_ok hy
    simp only [uncurry'_pair] at ho
    subst ho
    simp [Yields, core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator_next,
      core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator.nextPlain, hnext]
  | y :: ys, b, hy => by
    simp only [Yields] at hy
    obtain ⟨⟨o, b'⟩, hnext, hpost⟩ := spec_eq_ok hy
    simp only [uncurry'_pair] at hpost
    obtain ⟨rfl, hy'⟩ := hpost
    simp only [Yields, core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator_next,
      core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator.nextPlain, hnext, bind_tc_ok,
      spec_ok]
    exact ⟨rfl, core.iter.adapters.chain.Chain.yields_b IA IB ys b' hy'⟩

/-- `a.chain(b)` yields `a`'s items, then `b`'s. -/
theorem core.iter.adapters.chain.Chain.yields {A B Item : Type}
    (IA : core.iter.traits.iterator.Iterator A Item) (IB : core.iter.traits.iterator.Iterator B Item)
    (ys : List Item) (b : B) (hb : Yields IB b ys) :
    ∀ (xs : List Item) (a : A), Yields IA a xs →
    Yields (core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator IA IB)
      ⟨some a, some b⟩ (xs ++ ys)
  | [], a, hy => by
    simp only [Yields] at hy
    obtain ⟨⟨o, a'⟩, hnext, ho⟩ := spec_eq_ok hy
    simp only [uncurry'_pair] at ho
    subst ho
    refine (Yields_congr _ ?_ ys).2 (core.iter.adapters.chain.Chain.yields_b IA IB ys b hb)
    simp [core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator_next,
      core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator.nextPlain, hnext]
  | x :: xs, a, hy => by
    simp only [Yields] at hy
    obtain ⟨⟨o, a'⟩, hnext, hpost⟩ := spec_eq_ok hy
    simp only [uncurry'_pair] at hpost
    obtain ⟨rfl, hy'⟩ := hpost
    simp only [List.cons_append, Yields, core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator_next,
      core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator.nextPlain, hnext, bind_tc_ok,
      spec_ok]
    exact ⟨rfl, core.iter.adapters.chain.Chain.yields IA IB ys b hb xs a' hy'⟩

section FlatMap
variable {I U F Item0 Item IntoIter : Type}
  (IA : core.iter.traits.iterator.Iterator I Item0)
  (II : core.iter.traits.collect.IntoIterator U Item IntoIter)
  (FI : core.ops.function.FnMut F Item0 U)

local notation "FM" => core.iter.adapters.flatten.FlatMap.Insts.CoreIterTraitsIteratorIterator IA II FI

/-- A `flat_map` draining its front iterator yields what is left of it, then the rest. -/
theorem core.iter.adapters.flatten.FlatMap.yields_front (it : Option I) (f : F)
    (R : List Item) (hR : Yields FM ⟨it, f, none, none⟩ R) :
    ∀ (zs : List Item) (front : IntoIter), Yields II.iteratorInst front zs →
    Yields FM ⟨it, f, some front, none⟩ (zs ++ R)
  | [], front, hy => by
    simp only [Yields] at hy
    obtain ⟨⟨o, front'⟩, hnext, ho⟩ := spec_eq_ok hy
    simp only [uncurry'_pair] at ho
    subst ho
    refine (Yields_congr _ ?_ R).2 hR
    simp only [core.iter.adapters.flatten.FlatMap.Insts.CoreIterTraitsIteratorIterator,
      core.iter.adapters.flatten.FlatMap.Insts.CoreIterTraitsIteratorIterator.next]
    conv => lhs; rw [loop]
    simp [hnext]
  | z :: zs, front, hy => by
    simp only [Yields] at hy
    obtain ⟨⟨o, front'⟩, hnext, hpost⟩ := spec_eq_ok hy
    simp only [uncurry'_pair] at hpost
    obtain ⟨rfl, hy'⟩ := hpost
    simp only [List.cons_append, Yields, core.iter.adapters.flatten.FlatMap.Insts.CoreIterTraitsIteratorIterator,
      core.iter.adapters.flatten.FlatMap.Insts.CoreIterTraitsIteratorIterator.next]
    rw [loop]
    simp only [hnext, bind_tc_ok, Std.bind_ok, spec_ok]
    exact ⟨rfl, core.iter.adapters.flatten.FlatMap.yields_front it f R hR zs front' hy'⟩

/-- `flat_map(f)` over an iterator yielding `xs`, with a stateless `f` whose results each yield
some `ys` with `Q x ys`, yields their concatenation. -/
theorem core.iter.adapters.flatten.FlatMap.yields (f : F) (Q : Item0 → List Item → Prop) :
    ∀ (xs : List Item0) (it : I), Yields IA it xs →
    (∀ x ∈ xs, ∃ u ii ys, FI.call_mut f x = ok (u, f) ∧ II.into_iter u = ok ii ∧
      Yields II.iteratorInst ii ys ∧ Q x ys) →
    ∃ yss : List (List Item), yss.length = xs.length ∧
      (∀ i (hi : i < xs.length) (hi' : i < yss.length), Q xs[i] yss[i]) ∧
      Yields FM ⟨some it, f, none, none⟩ yss.flatten
  | [], it, hy, _ => by
    simp only [Yields] at hy
    obtain ⟨⟨o, it'⟩, hnext, ho⟩ := spec_eq_ok hy
    simp only [uncurry'_pair] at ho
    subst ho
    refine ⟨[], rfl, by simp, ?_⟩
    simp only [List.flatten_nil, Yields, core.iter.adapters.flatten.FlatMap.Insts.CoreIterTraitsIteratorIterator,
      core.iter.adapters.flatten.FlatMap.Insts.CoreIterTraitsIteratorIterator.next]
    rw [loop]
    simp only [hnext, bind_tc_ok, Std.bind_ok]
    rw [loop]
    simp
  | x :: xs, it, hy, hx => by
    simp only [Yields] at hy
    obtain ⟨⟨o, it'⟩, hnext, hpost⟩ := spec_eq_ok hy
    simp only [uncurry'_pair] at hpost
    obtain ⟨rfl, hy'⟩ := hpost
    obtain ⟨u, ii, ys, hc, hii, hys, hQ⟩ := hx x (by simp)
    obtain ⟨yss, hl, hQs, hY⟩ := core.iter.adapters.flatten.FlatMap.yields f Q xs it' hy'
      fun x' hx' => hx x' (by simp [hx'])
    refine ⟨ys :: yss, by simp [hl], fun i hi hi' => ?_, ?_⟩
    · cases i with
      | zero => simpa using hQ
      | succ i => simpa using hQs i (by simpa using hi) (by simpa using hi')
    · rw [List.flatten_cons]
      refine (Yields_congr _ ?_ _).2
        (core.iter.adapters.flatten.FlatMap.yields_front IA II FI (some it') f _ hY ys ii hys)
      simp only [core.iter.adapters.flatten.FlatMap.Insts.CoreIterTraitsIteratorIterator,
        core.iter.adapters.flatten.FlatMap.Insts.CoreIterTraitsIteratorIterator.next]
      conv => lhs; rw [loop]
      simp [hnext, hc, hii]

end FlatMap

/-! ## `OkYields`: `Yields` for iterators that may panic -/

/-- Ok-conditional `Yields`: whenever `next` succeeds it returns the next of `xs`, then `none`.
A panicking `next` satisfies it, so it suits soundness (Ok-conditional) proofs. -/
@[expose] def OkYields {I Item : Type} (inst : core.iter.traits.iterator.Iterator I Item) :
    I → List Item → Prop
  | it, [] => ∀ o it', inst.next it = ok (o, it') → o = none
  | it, x :: xs => ∀ o it', inst.next it = ok (o, it') → o = some x ∧ OkYields inst it' xs

theorem OkYields.of_yields {I Item : Type} (inst : core.iter.traits.iterator.Iterator I Item) :
    ∀ (xs : List Item) (it : I), Yields inst it xs → OkYields inst it xs
  | [], it, hy => fun o it' hn => by simpa using spec_of_eq_ok hy hn
  | x :: xs, it, hy => fun o it' hn => by
    have := spec_of_eq_ok hy hn
    simp only [uncurry'_pair] at this
    exact ⟨this.1, OkYields.of_yields inst xs it' this.2⟩

/-- `chain`'s second half, once the first is dropped, Ok-yields what it Ok-yields. -/
theorem core.iter.adapters.chain.Chain.okYields_b {A B Item : Type}
    (IA : core.iter.traits.iterator.Iterator A Item) (IB : core.iter.traits.iterator.Iterator B Item) :
    ∀ (ys : List Item) (b : B), OkYields IB b ys →
    OkYields (core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator IA IB)
      ⟨none, some b⟩ ys
  | [], b, hy => fun o c hn => by
    simp only [core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator,
      core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator.next] at hn
    obtain ⟨⟨o', b'⟩, hb, hn⟩ := bind_eq_ok_inv hn
    simp only [ok.injEq, Prod.mk.injEq] at hn
    exact hn.1 ▸ hy o' b' hb
  | y :: ys, b, hy => fun o c hn => by
    simp only [core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator,
      core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator.next] at hn
    obtain ⟨⟨o', b'⟩, hb, hn⟩ := bind_eq_ok_inv hn
    simp only [ok.injEq, Prod.mk.injEq] at hn
    obtain ⟨rfl, rfl⟩ := hn
    obtain ⟨h1, h2⟩ := hy o' b' hb
    exact ⟨h1, core.iter.adapters.chain.Chain.okYields_b IA IB ys b' h2⟩

/-- `a.chain(b)` Ok-yields `a`'s items, then `b`'s. -/
theorem core.iter.adapters.chain.Chain.okYields {A B Item : Type}
    (IA : core.iter.traits.iterator.Iterator A Item) (IB : core.iter.traits.iterator.Iterator B Item)
    (ys : List Item) (b : B) (hb : OkYields IB b ys) :
    ∀ (xs : List Item) (a : A), OkYields IA a xs →
    OkYields (core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator IA IB)
      ⟨some a, some b⟩ (xs ++ ys)
  | [], a, ha => by
    have hb' := core.iter.adapters.chain.Chain.okYields_b IA IB ys b hb
    cases ys <;>
    · intro o c hn
      simp only [core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator,
        core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator.next] at hn
      obtain ⟨⟨o', a'⟩, hna, hn⟩ := bind_eq_ok_inv hn
      obtain rfl := ha o' a' hna
      exact hb' o c hn
  | x :: xs, a, ha => fun o c hn => by
    simp only [core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator,
      core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator.next] at hn
    obtain ⟨⟨o', a'⟩, hna, hn⟩ := bind_eq_ok_inv hn
    obtain ⟨rfl, ha'⟩ := ha o' a' hna
    simp only [ok.injEq, Prod.mk.injEq] at hn
    obtain ⟨rfl, rfl⟩ := hn
    exact ⟨rfl, core.iter.adapters.chain.Chain.okYields IA IB ys b hb xs a' ha'⟩

theorem alloc.vec.FromIteratorVec.iterToList_okYields {I T : Type}
    (IA : core.iter.traits.iterator.Iterator I T) :
    ∀ (xs : List T) (it : I) (acc l : List T), OkYields IA it xs →
    alloc.vec.FromIteratorVec.iterToList IA it acc = ok l → l = acc.reverse ++ xs
  | [], it, acc, l, hy, h => by
    rw [alloc.vec.FromIteratorVec.iterToList] at h
    obtain ⟨⟨o, it'⟩, hn, h⟩ := bind_eq_ok_inv h
    obtain rfl := hy o it' hn
    simp only [ok.injEq] at h
    simp [h]
  | x :: xs, it, acc, l, hy, h => by
    rw [alloc.vec.FromIteratorVec.iterToList] at h
    obtain ⟨⟨o, it'⟩, hn, h⟩ := bind_eq_ok_inv h
    obtain ⟨rfl, hy'⟩ := hy o it' hn
    simpa using alloc.vec.FromIteratorVec.iterToList_okYields IA xs it' (x :: acc) l hy' h

/-- Ok-conditional `collect::<Vec<_>>()`: the vector of what the iterator Ok-yields. -/
theorem core.iter.traits.iterator.Iterator.collect_vec_okYields {I T : Type}
    (IA : core.iter.traits.iterator.Iterator I T) (it : I) (xs : List T) (hy : OkYields IA it xs)
    (v : alloc.vec.Vec T)
    (h : core.iter.traits.iterator.Iterator.collect.default (S := instCollectShape) IA
      (core.iter.traits.collect.FromIteratorVec T) it = ok v) : v.val = xs := by
  simp only [core.iter.traits.iterator.Iterator.collect.default, CollectShape.collect,
    alloc.vec.FromIteratorVec.from_iter,
    core.iter.traits.collect.IntoIterator.Blanket.into_iter, bind_tc_ok] at h
  obtain ⟨l, hl, h⟩ := bind_eq_ok_inv h
  obtain rfl : l = xs := by simpa using alloc.vec.FromIteratorVec.iterToList_okYields IA xs it [] l hy hl
  split at h
  · simp only [ok.injEq] at h
    subst h
    simp
  · simp at h

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

/-! ## List sums and folds -/

/-- `Forall₂`-related lists give the same `zipIdx`-weighted sum when related items agree. -/
theorem _root_.List.Forall₂.sum_map_zipIdx {α β M : Type} [AddCommMonoid M] {R : α → β → Prop}
    {l1 : List α} {l2 : List β} (h : List.Forall₂ R l1 l2) (f : α → ℕ → M) (g : β → ℕ → M)
    (hfg : ∀ a b k, R a b → f a k = g b k) (k : ℕ) :
    ((l1.zipIdx k).map fun p => f p.1 p.2).sum = ((l2.zipIdx k).map fun p => g p.1 p.2).sum := by
  induction h generalizing k with
  | nil => rfl
  | cons hab _ ih =>
    simp only [List.zipIdx_cons, List.map_cons, List.sum_cons]
    rw [hfg _ _ k hab, ih (k + 1)]

/-- Every right-hand member has a `Forall₂` partner. -/
theorem _root_.List.Forall₂.exists_of_mem_right {α β : Type} {R : α → β → Prop}
    {l₁ : List α} {l₂ : List β} (h : List.Forall₂ R l₁ l₂) {b : β} (hb : b ∈ l₂) :
    ∃ a ∈ l₁, R a b := by
  induction h with
  | nil => simp at hb
  | @cons a b' _ _ hr _ ih =>
    rcases List.mem_cons.mp hb with rfl | hb
    · exact ⟨a, List.mem_cons_self, hr⟩
    · obtain ⟨a', ha', hr'⟩ := ih hb
      exact ⟨a', List.mem_cons_of_mem _ ha', hr'⟩

/-- Adjacent items of a duplicate-free list differ. -/
theorem _root_.List.Nodup.ne_of_mem_zip_tail {α : Type} :
    ∀ {l : List α}, l.Nodup → ∀ p ∈ l.zip l.tail, p.1 ≠ p.2
  | [], _, _, hp => by simp at hp
  | [_], _, _, hp => by simp at hp
  | a :: b :: l, hnd, p, hp => by
    simp only [List.tail_cons, List.zip_cons_cons, List.mem_cons] at hp
    rcases hp with rfl | hp
    · simp only [List.nodup_cons, List.mem_cons, not_or] at hnd
      exact hnd.1.1
    · exact List.Nodup.ne_of_mem_zip_tail (List.nodup_cons.mp hnd).2 p (by simpa using hp)

/-- `anyM` of a predicate false on every item. -/
theorem List.anyM_ok_false {α : Type} (f : α → Result Bool) :
    ∀ (l : List α), (∀ x ∈ l, f x = ok false) → l.anyM f = ok false
  | [], _ => by rw [List.anyM_nil]; rfl
  | x :: l, h => by
    simp [List.anyM_cons, h x (by simp), List.anyM_ok_false f l (fun y hy => h y (by simp [hy]))]

/-- Horner's rule from the back (`rev().fold(0, |acc, e| acc·x + e)`) as a power-weighted sum. -/
theorem _root_.List.foldl_reverse_horner {α K : Type} [CommSemiring K] (x : K) (t : α → K) :
    ∀ l : List α, l.reverse.foldl (fun k a => k * x + t a) 0 =
      ((List.range l.length).map fun j => x ^ j * (l[j]?.elim 0 t)).sum
  | [] => by simp
  | a :: l => by
    rw [List.reverse_cons, List.foldl_append, List.foldl_reverse_horner x t l]
    simp only [List.foldl_cons, List.foldl_nil, List.length_cons]
    rw [List.range_succ_eq_map, List.map_cons, List.map_map, List.sum_cons]
    simp only [pow_zero, one_mul, List.getElem?_cons_zero, Option.elim_some,
      Function.comp_def, pow_succ, List.getElem?_cons_succ]
    rw [← List.sum_map_mul_right, add_comm]
    congr 2
    apply List.map_congr_left
    intro j _
    ring

/-- `zip` commutes with `reverse` on equal lengths. -/
theorem _root_.List.zip_reverse {α β : Type} (l1 : List α) (l2 : List β)
    (h : l1.length = l2.length) : l1.reverse.zip l2.reverse = (l1.zip l2).reverse := by
  apply List.ext_getElem (by simp [h])
  intro i h1 h2
  simp only [List.length_zip, List.length_reverse] at h1
  simp [List.getElem_reverse, List.getElem_zip, h]

/-- An inner product against the powers `xⁱ⁺ᵏ`, as a `zipIdx` sum. -/
theorem _root_.List.sum_zipWith_smul_pow {F K M α : Type} [CommSemiring K] [AddCommMonoid M]
    [Module K M] (σ : F → K) (φ : α → M) (x : K) :
    ∀ (l : List α) (ys : List F) (k : ℕ), l.length ≤ ys.length →
    (∀ i (h : i < ys.length), σ ys[i] = x ^ (i + k)) →
    (List.zipWith (fun c s => σ s • φ c) l ys).sum =
      ((l.zipIdx k).map fun (c, m) => x ^ m • φ c).sum
  | [], _, _, _, _ => by simp
  | _ :: _, [], _, h, _ => by simp at h
  | c :: l, y :: ys, k, hl, hy => by
    simp only [List.zipWith_cons_cons, List.sum_cons, List.zipIdx_cons, List.map_cons]
    have h0 := hy 0 (by simp)
    simp only [List.getElem_cons_zero, zero_add] at h0
    rw [h0, List.sum_zipWith_smul_pow σ φ x l ys (k + 1) (by simpa using hl) (fun i h => by
      have := hy (i + 1) (by simpa using h)
      simp only [List.getElem_cons_succ] at this
      rw [this]; ring_nf)]

end Aeneas.Std
