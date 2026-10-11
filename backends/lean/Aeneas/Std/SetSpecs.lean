/- Specs for `Slice::contains`, `Iterator::position`, `Cloned`, scalar `Ord`,
   `BTreeSet::from_iter`/iter/clone, `BTreeMap::iter`,
   `HashMap::iter`/from_iter, and the `len` functions. -/
module
public import Aeneas.Std.CollectionsSpecs
public import Aeneas.Std.IterExtra
public section

namespace Aeneas.Std

open Result WP

/-! ## 1. `Slice::contains` -/

/-- `slice.contains` returns `some b` with `b = true ↔ x ∈ s`. -/
theorem core.slice.Slice.contains_spec {T : Type}
    (partialEqInst : core.cmp.PartialEq T T)
    (hEq : ∀ a b, ∃ r, partialEqInst.eq a b = ok r ∧ (r = true ↔ a = b))
    (s : Slice T) (x : T) :
    ∃ b, core.slice.Slice.contains partialEqInst s x = ok b ∧ (b = true ↔ x ∈ s.val) := by
  simp only [core.slice.Slice.contains]
  induction s.val with
  | nil =>
    exact ⟨false, by simp [pure], by simp⟩
  | cons y ys ih =>
    obtain ⟨ry, hry, hryiff⟩ := hEq x y
    obtain ⟨rs, hrs, hrsiff⟩ := ih
    by_cases hxy : x = y
    · subst hxy
      exact ⟨true, by simp [List.anyM_cons, hry, hryiff.mpr rfl, bind_tc_ok, pure],
             by simp⟩
    · have hry_false : ry = false := Bool.eq_false_iff.mpr (fun h => hxy (hryiff.mp h))
      exact ⟨rs, by simp [List.anyM_cons, hry, hry_false, bind_tc_ok, hrs],
             by simp [List.mem_cons, hxy, hrsiff]⟩

/-! ## 2. `Iterator::position` -/

/-- The loop body of `Iterator::position`, matching its definition exactly. -/
@[reducible] private def positionLoopBody {I F Item : Type}
    (IA : core.iter.traits.iterator.Iterator I Item)
    (FI : core.ops.function.FnMut F Item Bool) :
    I × F × ℕ → Result (ControlFlow (I × F × ℕ) ((Option Usize) × I)) :=
  fun ((it, p, i) : I × F × ℕ) => do
    let (o, it) ← IA.next it
    match o with
    | none => ok (ControlFlow.done (none, it))
    | some x =>
      let (b, p) ← FI.call_mut p x
      if b then
        let i ← UScalar.tryMk .Usize i
        ok (ControlFlow.done (some i, it))
      else ok (ControlFlow.cont (it, p, i + 1))

private theorem position_default_eq {I F Item : Type}
    (IA : core.iter.traits.iterator.Iterator I Item)
    (FI : core.ops.function.FnMut F Item Bool) (it : I) (p : F) :
    core.iter.traits.iterator.Iterator.position.default IA FI it p =
    loop (positionLoopBody IA FI) (it, p, 0) := by
  unfold core.iter.traits.iterator.Iterator.position.default; rfl

private theorem positionLoop_spec {I F Item : Type}
    (IA : core.iter.traits.iterator.Iterator I Item)
    (FI : core.ops.function.FnMut F Item Bool)
    (P : Item → Bool) (f : F)
    (hp : ∀ x, FI.call_mut f x = ok (P x, f)) :
    ∀ (xs : List Item) (it : I) (n : ℕ),
    Yields IA it xs → n + xs.length ≤ Usize.max →
    loop (positionLoopBody IA FI) (it, f, n) ⦃ b _ => (b : Option Usize).map (·.val) = (xs.findIdx? P).map (· + n) ⦄ := by
  intro xs
  induction xs with
  | nil =>
    intro it n hy hn
    simp only [Yields] at hy
    obtain ⟨⟨o, it'⟩, hnext, ho⟩ := spec_eq_ok hy
    simp only [uncurry'_pair] at ho; subst ho
    rw [loop]; simp [positionLoopBody, hnext, bind_tc_ok, spec_ok, uncurry'_pair]
  | cons xv xs ih =>
    intro it n hy hn
    simp only [Yields] at hy
    obtain ⟨⟨o, it'⟩, hnext, hpost⟩ := spec_eq_ok hy
    simp only [uncurry'_pair] at hpost; obtain ⟨rfl, hy'⟩ := hpost
    rw [loop]; simp only [positionLoopBody, hnext, hp xv, Std.bind_ok, bind_tc_ok]
    cases hPx : P xv
    · simp only [hPx, Bool.false_eq_true, ↓reduceIte, Std.bind_ok, bind_tc_ok]
      have hn' : (n + 1) + xs.length ≤ Usize.max := by simp at hn; omega
      refine spec_mono (ih it' (n + 1) hy' hn') ?_
      rintro ⟨b, _⟩ h; simp only [uncurry'_pair] at *
      simp only [List.findIdx?_cons, hPx, Bool.false_eq_true, ↓reduceIte]
      rw [h, Option.map_map]; congr 1; funext j; simp [Function.comp]; omega
    · simp only [hPx, ↓reduceIte]
      have hn_le : n ≤ Usize.max := by simp at hn; omega
      obtain ⟨u, hu_eq, hu_val⟩ := spec_eq_ok (UScalar.tryMk_spec .Usize n (by
        rw [UScalar.max_USize_eq]; exact hn_le))
      simp [hu_eq, bind_tc_ok, spec_ok, uncurry'_pair, List.findIdx?_cons, hPx, hu_val]

/-- `position` returns the index of the first element satisfying a stateless predicate. -/
theorem core.iter.traits.iterator.Iterator.position.default_spec {I F Item : Type}
    (IA : core.iter.traits.iterator.Iterator I Item)
    (FI : core.ops.function.FnMut F Item Bool)
    (P : Item → Bool) (f : F)
    (hp : ∀ x, FI.call_mut f x = ok (P x, f))
    (xs : List Item) (it : I) (hy : Yields IA it xs) (hn : xs.length ≤ Usize.max) :
    core.iter.traits.iterator.Iterator.position.default IA FI it f
    ⦃ b _ => (b : Option Usize).map (·.val) = xs.findIdx? P ⦄ := by
  rw [position_default_eq]
  refine spec_mono (positionLoop_spec IA FI P f hp xs it 0 hy (by simp [hn])) ?_
  rintro ⟨b, _⟩ h; simp only [uncurry'_pair] at *; simp [h]

/-! ## 2b. `Iter::find` -/

private def findLoopBody {T Pst : Type} (FI : core.ops.function.FnMut Pst T Bool) :
    core.slice.iter.Iter T × Pst →
    Result (ControlFlow (core.slice.iter.Iter T × Pst) ((Option T) × core.slice.iter.Iter T)) :=
  fun ((it, p) : core.slice.iter.Iter T × Pst) => do
    let (o, it) ← core.slice.iter.IteratorSliceIter.next it
    match o with
    | none => ok (.done (none, it))
    | some x =>
      let (b, p) ← FI.call_mut p x
      if b then ok (.done (some x, it)) else ok (.cont (it, p))

private theorem findLoopBody_eq {T P : Type} (FI : core.ops.function.FnMut P T Bool)
    (it : core.slice.iter.Iter T) (p : P) :
    core.slice.iter.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAT.find FI it p =
    loop (findLoopBody FI) (it, p) := by
  unfold core.slice.iter.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAT.find findLoopBody; rfl

private theorem findLoop_spec {T Pst : Type} (FI : core.ops.function.FnMut Pst T Bool)
    (P : T → Bool) (p : Pst) (hp : ∀ x, FI.call_mut p x = ok (P x, p)) :
    ∀ (xs : List T) (it : core.slice.iter.Iter T),
    Yields (core.iter.traits.iterator.IteratorSliceIter T) it xs →
    loop (findLoopBody FI) (it, p) ⦃ r _ => r = xs.find? P ⦄
  | [], it, hy => by
    simp only [Yields] at hy
    obtain ⟨⟨opt, it'⟩, hn, hpost⟩ := spec_eq_ok hy
    simp only [uncurry'_pair] at hpost; subst hpost
    rw [loop]; simp [findLoopBody, hn]
  | x :: xs, it, hy => by
    simp only [Yields] at hy
    obtain ⟨⟨opt, it'⟩, hn, hpost⟩ := spec_eq_ok hy
    simp only [uncurry'_pair] at hpost; obtain ⟨rfl, hy'⟩ := hpost
    rw [loop]; simp only [findLoopBody, hn, hp x, bind_tc_ok, Std.bind_ok]
    cases hP : P x
    · simp only [hP, Bool.false_eq_true, ↓reduceIte, Std.bind_ok, List.find?_cons]
      exact findLoop_spec FI P p hp xs it' hy'
    · simp [hP, spec_ok, List.find?_cons]

/-- `slice::Iter::find` with a pure predicate: the first item from the iterator's position on. -/
theorem core.slice.iter.Iter.find_spec {T Pst : Type} (FI : core.ops.function.FnMut Pst T Bool)
    (P : T → Bool) (p : Pst) (hp : ∀ x, FI.call_mut p x = ok (P x, p)) (it : core.slice.iter.Iter T)
    (hi : it.i ≤ it.slice.val.length) :
    core.slice.iter.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAT.find FI it p ⦃ r _ =>
      r = (it.slice.val.drop it.i).find? P ⦄ := by
  rw [findLoopBody_eq]
  exact findLoop_spec FI P p hp _ it
    (core.slice.iter.IteratorSliceIter.yields _ it rfl)

/-! ## 3. `Cloned` iterator -/

/-- `Cloned` yields the same items as the inner iterator when `clone = id`. -/
theorem core.iter.adapters.cloned.Cloned.Insts.CoreIterTraitsIteratorIterator.yields_spec
    {I T : Type}
    (IterInst : core.iter.traits.iterator.Iterator I T)
    (CloneInst : core.clone.Clone T)
    (hclone : ∀ x, CloneInst.clone x = ok x)
    (xs : List T) (it : I) (h : Yields IterInst it xs) :
    Yields (core.iter.adapters.cloned.Cloned.Insts.CoreIterTraitsIteratorIterator IterInst CloneInst)
      ⟨it⟩ xs := by
  induction xs generalizing it with
  | nil =>
    simp only [Yields] at h ⊢
    obtain ⟨⟨o, it'⟩, hn, ho⟩ := spec_eq_ok h
    simp only [uncurry'_pair] at ho; subst ho
    simp only [core.iter.adapters.cloned.Cloned.Insts.CoreIterTraitsIteratorIterator.next,
               hn, bind_tc_ok, spec_ok, uncurry'_pair]
  | cons xv xs ih =>
    simp only [Yields] at h ⊢
    obtain ⟨⟨o, it'⟩, hn, hpost⟩ := spec_eq_ok h
    simp only [uncurry'_pair] at hpost; obtain ⟨rfl, hy'⟩ := hpost
    simp only [core.iter.adapters.cloned.Cloned.Insts.CoreIterTraitsIteratorIterator.next,
               hn, bind_tc_ok, hclone xv, spec_ok, uncurry'_pair]
    exact ⟨trivial, ih it' hy'⟩

/-- `clone` on a scalar (like `Usize`) is identity. -/
theorem core.clone.CloneUsize.clone_id (x : Usize) :
    core.clone.CloneUsize.clone x = ok x := by
  simp [core.clone.CloneUsize, liftFun1, core.clone.impls.CloneUsize.clone]

/-! ## 4. Scalar `Ord` lawfulness -/

/-- An `Ord` instance is *lawful* when `cmp` returns `ok (compare a b)` for all inputs. -/
@[expose] def OrdLawful {T : Type} [Ord T] (OrdInst : core.cmp.Ord T) : Prop :=
  ∀ a b, OrdInst.cmp a b = ok (compare a b)

/-- `OrdUsize` is lawful: `cmp x y = ok (compare x y)`. -/
theorem OrdUsize_lawful : OrdLawful core.cmp.OrdUsize := by
  intro x y
  simp only [liftFun2, core.cmp.impls.OrdUsize.cmp, compare, compareOfLessAndEq,
             UScalar.lt_equiv, UScalar.eq_equiv]

/-- A lawful `Ord` satisfies the CollectionsSpecs `hcmp` hypothesis. -/
theorem hcmp_of_lawful {T : Type} [Ord T] {OrdInst : core.cmp.Ord T} (h : OrdLawful OrdInst)
    (heq : ∀ a b : T, compare a b = Ordering.eq ↔ a = b) :
    ∀ a b, ∃ o, OrdInst.cmp a b = ok o ∧ (o = Ordering.eq ↔ a = b) :=
  fun a b => ⟨compare a b, h a b, heq a b⟩

/-- `compare a b = Ordering.eq ↔ a = b` for any `LinearOrder`. -/
theorem compare_eq_iff {T : Type} [LinearOrder T] {a b : T} :
    compare a b = Ordering.eq ↔ a = b := compare_eq_iff_eq

/-! ## 5. `BTreeSet::from_iter` -/

/-- The loop body used by `alloc.collections.btree.toList`. -/
@[reducible] private def toListBody {I T : Type} (IA : core.iter.traits.iterator.Iterator I T) :
    I × List T → Result (ControlFlow (I × List T) (List T)) :=
  fun ((it, acc) : I × List T) => do
    let (o, it) ← IA.next it
    match o with
    | none => ok (ControlFlow.done acc)
    | some x => ok (ControlFlow.cont (it, x :: acc))

/-- `alloc.collections.btree.toList` equals a loop over `toListBody`. -/
private theorem toList_eq_loop {I T : Type} (IA : core.iter.traits.iterator.Iterator I T) (it : I) :
    alloc.collections.btree.toList IA it =
    (do let rev ← loop (toListBody IA) (it, []); ok rev.reverse) := by
  unfold alloc.collections.btree.toList; rfl

/-- The `toListBody` loop accumulates `xs.reverse ++ acc`. -/
private theorem toListBody_loop_spec {I T : Type}
    (IA : core.iter.traits.iterator.Iterator I T) :
    ∀ (xs : List T) (it : I) (acc : List T),
    Yields IA it xs →
    loop (toListBody IA) (it, acc) = ok (xs.reverse ++ acc) := by
  intro xs
  induction xs with
  | nil =>
    intro it acc hy; simp only [Yields] at hy
    obtain ⟨⟨opt, it'⟩, hn, ho⟩ := spec_eq_ok hy
    simp [uncurry'_pair] at ho; subst ho
    rw [loop]; simp [toListBody, hn, bind_tc_ok]
  | cons xv xs ih =>
    intro it acc hy; simp only [Yields] at hy
    obtain ⟨⟨opt, it'⟩, hn, hpost⟩ := spec_eq_ok hy
    simp [uncurry'_pair] at hpost; obtain ⟨rfl, hy'⟩ := hpost
    rw [loop]; simp only [toListBody, hn, Std.bind_ok, bind_tc_ok]
    rw [ih it' (xv :: acc) hy']
    simp [List.reverse_cons, List.append_assoc]

theorem toList_spec {I T : Type} (IA : core.iter.traits.iterator.Iterator I T)
    (xs : List T) (it : I) (h : Yields IA it xs) :
    alloc.collections.btree.toList IA it = ok xs := by
  rw [toList_eq_loop]
  rw [toListBody_loop_spec IA xs it [] h]
  simp

/-- `sortBy_ins` returns a permutation of `x :: sorted`. -/
private theorem sortBy_ins_perm {T K : Type} (OrdInst : core.cmp.Ord K) (key : T → K)
    (hcmp : ∀ a b, ∃ o, OrdInst.cmp (key a) (key b) = ok o)
    (x : T) : ∀ (sorted : List T),
    ∃ sorted', alloc.collections.btree.sortBy_ins OrdInst key x sorted = ok sorted' ∧
               sorted'.Perm (x :: sorted) := by
  intro sorted
  induction sorted with
  | nil => exact ⟨[x], by simp [alloc.collections.btree.sortBy_ins], List.Perm.refl _⟩
  | cons y ys ih =>
    obtain ⟨o, ho⟩ := hcmp x y
    simp only [alloc.collections.btree.sortBy_ins, ho, bind_tc_ok]
    rcases o with _ | _ | _
    · exact ⟨x :: y :: ys, rfl, List.Perm.refl _⟩
    · exact ⟨x :: y :: ys, rfl, List.Perm.refl _⟩
    · obtain ⟨ys', hys', hperm⟩ := ih
      exact ⟨y :: ys', by simp [hys'], (List.Perm.cons y hperm).trans (List.Perm.swap x y ys)⟩

/-- `sortBy` returns a permutation of the input. -/
private theorem sortBy_perm {T K : Type} (OrdInst : core.cmp.Ord K) (key : T → K)
    (hcmp : ∀ a b, ∃ o, OrdInst.cmp (key a) (key b) = ok o) :
    ∀ (xs : List T),
    ∃ sorted, alloc.collections.btree.sortBy OrdInst key xs = ok sorted ∧ sorted.Perm xs := by
  intro xs
  induction xs with
  | nil =>
    exact ⟨[], by unfold alloc.collections.btree.sortBy; rfl, List.Perm.nil⟩
  | cons xv xs ih =>
    obtain ⟨sorted, hsorted, hperm⟩ := ih
    obtain ⟨sorted', hins, hperm'⟩ := sortBy_ins_perm OrdInst key hcmp xv sorted
    refine ⟨sorted', ?_, hperm'.trans (List.Perm.cons xv hperm)⟩
    unfold alloc.collections.btree.sortBy
    simp [hsorted, bind_tc_ok, hins]

/-- `dedupLast` terminates and membership is equivalent for all elements simultaneously. -/
private theorem dedupLast_mem_all_iff {T : Type} (OrdInst : core.cmp.Ord T)
    (hcmp : ∀ a b, ∃ o, OrdInst.cmp a b = ok o ∧ (o = Ordering.eq ↔ a = b)) :
    ∀ xs : List T,
    alloc.collections.btree.dedupLast OrdInst id xs ⦃ ys => ∀ x, x ∈ ys ↔ x ∈ xs ⦄ := by
  intro xs
  induction xs using List.rec with
  | nil => simp [alloc.collections.btree.dedupLast, spec_ok]
  | cons y rest ih =>
    cases rest with
    | nil => simp [alloc.collections.btree.dedupLast, spec_ok]
    | cons z ys =>
      obtain ⟨ord, hord, hordEq⟩ := hcmp y z
      simp only [alloc.collections.btree.dedupLast, id, hord, bind_tc_ok]
      obtain ⟨ws, hws, hmem⟩ := spec_eq_ok ih
      rcases ord with _ | _ | _
      · simp only [hws, bind_tc_ok, spec_ok]; intro x; simp [List.mem_cons, hmem]
      · have hyz : y = z := hordEq.mp rfl; subst hyz
        simp only [hws, spec_ok]; intro x; simp only [List.mem_cons, hmem]; tauto
      · simp only [hws, bind_tc_ok, spec_ok]; intro x; simp [List.mem_cons, hmem]

private theorem dedupLast_mem_iff {T : Type} (OrdInst : core.cmp.Ord T)
    (hcmp : ∀ a b, ∃ o, OrdInst.cmp a b = ok o ∧ (o = Ordering.eq ↔ a = b))
    (x : T) :
    ∀ xs : List T,
    alloc.collections.btree.dedupLast OrdInst id xs ⦃ ys => x ∈ ys ↔ x ∈ xs ⦄ := by
  intro xs
  induction xs using List.rec with
  | nil =>
    unfold alloc.collections.btree.dedupLast; simp [spec_ok]
  | cons y rest ih =>
    cases rest with
    | nil =>
      unfold alloc.collections.btree.dedupLast; simp [spec_ok]
    | cons z ys =>
      obtain ⟨ord, hord, hordEq⟩ := hcmp y z
      unfold alloc.collections.btree.dedupLast
      simp only [id, hord, bind_tc_ok]
      obtain ⟨rest2, hrest2, hmem⟩ := spec_eq_ok ih
      simp only [List.mem_cons] at hmem
      rcases ord with _ | _ | _
      · simp only [hrest2, bind_tc_ok, spec_ok, List.mem_cons, hmem]
      · have hyz : y = z := hordEq.mp rfl; subst hyz
        simp only [hrest2, spec_ok, List.mem_cons, hmem]; tauto
      · simp only [hrest2, bind_tc_ok, spec_ok, List.mem_cons, hmem]

/-! Private helpers for the strictly-sorted postcondition. -/

/-- `sortBy_ins` preserves `Pairwise (· ≤ ·)` and returns a permutation of `x :: ys`. -/
private theorem sortBy_ins_sorted_perm {T : Type} [LinearOrder T]
    {OrdInst : core.cmp.Ord T} (hlaw : OrdLawful OrdInst) (x : T) :
    ∀ (ys : List T), ys.Pairwise (· ≤ ·) →
    ∃ zs, alloc.collections.btree.sortBy_ins OrdInst id x ys = ok zs ∧
          zs.Pairwise (· ≤ ·) ∧ zs.Perm (x :: ys) := by
  intro ys hys
  induction ys with
  | nil => exact ⟨[x], rfl, List.pairwise_singleton _ _, List.Perm.refl _⟩
  | cons y ys ih =>
    simp only [alloc.collections.btree.sortBy_ins, id, hlaw x y, bind_tc_ok]
    rcases lt_trichotomy x y with hxy | rfl | hxy
    · simp only [show compare x y = .lt from compare_lt_iff_lt.mpr hxy]
      refine ⟨x :: y :: ys, rfl, List.pairwise_cons.mpr ⟨fun z hz => ?_, hys⟩, List.Perm.refl _⟩
      rcases List.mem_cons.mp hz with rfl | hz'
      · exact le_of_lt hxy
      · exact le_of_lt (lt_of_lt_of_le hxy ((List.pairwise_cons.mp hys).1 z hz'))
    · simp only [show compare x x = .eq from compare_eq_iff_eq.mpr rfl]
      refine ⟨x :: x :: ys, rfl, List.pairwise_cons.mpr ⟨fun z hz => ?_, hys⟩, List.Perm.refl _⟩
      rcases List.mem_cons.mp hz with rfl | hz'
      · exact le_refl _
      · exact (List.pairwise_cons.mp hys).1 z hz'
    · simp only [show compare x y = .gt from compare_gt_iff_gt.mpr hxy]
      have hys_sorted : ys.Pairwise (· ≤ ·) := (List.pairwise_cons.mp hys).2
      have hys_lb : ∀ z ∈ ys, y ≤ z := (List.pairwise_cons.mp hys).1
      obtain ⟨zs, hzs, hzs_sorted, hzs_perm⟩ := ih hys_sorted
      simp only [hzs, bind_tc_ok]
      refine ⟨y :: zs, rfl, List.pairwise_cons.mpr ⟨fun z hz => ?_, hzs_sorted⟩, ?_⟩
      · rcases List.mem_cons.mp (hzs_perm.mem_iff.mp hz) with rfl | hz_ys
        · exact le_of_lt hxy
        · exact hys_lb z hz_ys
      · exact (List.Perm.cons y hzs_perm).trans (List.Perm.swap y x ys).symm

/-- `sortBy` produces a `Pairwise (· ≤ ·)` permutation of the input. -/
private theorem sortBy_sorted_perm {T : Type} [LinearOrder T]
    {OrdInst : core.cmp.Ord T} (hlaw : OrdLawful OrdInst) :
    ∀ (xs : List T),
    ∃ ys, alloc.collections.btree.sortBy OrdInst id xs = ok ys ∧
          ys.Pairwise (· ≤ ·) ∧ ys.Perm xs := by
  intro xs
  induction xs with
  | nil => exact ⟨[], by simp [alloc.collections.btree.sortBy], List.Pairwise.nil, List.Perm.nil⟩
  | cons x xs ih =>
    obtain ⟨ys, hys, hys_sorted, hys_perm⟩ := ih
    obtain ⟨zs, hzs, hzs_sorted, hzs_perm⟩ := sortBy_ins_sorted_perm hlaw x ys hys_sorted
    refine ⟨zs, ?_, hzs_sorted, hzs_perm.trans (List.Perm.cons x hys_perm)⟩
    simp only [alloc.collections.btree.sortBy, hys, bind_tc_ok, hzs]

/-- `dedupLast` of a `Pairwise (· ≤ ·)` list produces a `Pairwise (· < ·)` list with the same
    membership. -/
private theorem dedupLast_pairwise_lt {T : Type} [LinearOrder T]
    {OrdInst : core.cmp.Ord T} (hlaw : OrdLawful OrdInst) :
    ∀ (xs : List T), xs.Pairwise (· ≤ ·) →
    alloc.collections.btree.dedupLast OrdInst id xs
      ⦃ ys => ys.Pairwise (· < ·) ∧ ∀ z, z ∈ ys ↔ z ∈ xs ⦄ := by
  intro xs hxs
  induction xs using List.rec with
  | nil => simp [alloc.collections.btree.dedupLast, spec_ok]
  | cons x rest ih =>
    cases rest with
    | nil => simp [alloc.collections.btree.dedupLast, spec_ok]
    | cons y ys =>
      simp only [alloc.collections.btree.dedupLast, id, hlaw x y, bind_tc_ok]
      rcases lt_trichotomy x y with hxy | rfl | hxy
      · -- x < y: keep x, recurse on y :: ys
        simp only [show compare x y = .lt from compare_lt_iff_lt.mpr hxy]
        have hys : (y :: ys).Pairwise (· ≤ ·) := (List.pairwise_cons.mp hxs).2
        obtain ⟨zs, hzs, hzs_pw, hzs_mem⟩ := spec_eq_ok (ih hys)
        simp only [hzs, bind_tc_ok, spec_ok]
        refine ⟨List.pairwise_cons.mpr ⟨fun z hz => ?_, hzs_pw⟩, fun z => ?_⟩
        · rcases List.mem_cons.mp ((hzs_mem z).mp hz) with rfl | hz'
          · exact hxy
          · exact lt_of_lt_of_le hxy ((List.pairwise_cons.mp hys).1 z hz')
        · simp [List.mem_cons, hzs_mem]
      · -- x = y: skip x (duplicate), recurse on x :: ys
        simp only [show compare x x = .eq from compare_eq_iff_eq.mpr rfl]
        obtain ⟨zs, hzs, hzs_pw, hzs_mem⟩ := spec_eq_ok (ih (List.pairwise_cons.mp hxs).2)
        simp only [hzs, spec_ok]
        refine ⟨hzs_pw, fun z => ?_⟩
        simp only [List.mem_cons, hzs_mem]; tauto
      · -- y < x: impossible (sorted input says x ≤ y)
        exact absurd ((List.pairwise_cons.mp hxs).1 y (List.mem_cons.mpr (Or.inl rfl))) (not_le.mpr hxy)

/-- `BTreeSet::from_iter` produces a set whose membership equals the input list's membership.

    Requires a terminating `OrdInst` (`hcmp`). -/
theorem alloc.collections.btree.set.BTreeSetTGlobal.Insts.CoreIterTraitsCollectFromIterator.from_iter_spec
    {T I IntoIter : Type} (OrdInst : core.cmp.Ord T)
    (hcmp : ∀ a b, ∃ o, OrdInst.cmp a b = ok o ∧ (o = Ordering.eq ↔ a = b))
    (IntoIteratorInst : core.iter.traits.collect.IntoIterator I T IntoIter)
    (input : I)
    (iter : IntoIter) (hits : IntoIteratorInst.into_iter input = ok iter)
    (xs : List T) (hy : Yields IntoIteratorInst.iteratorInst iter xs) :
    alloc.collections.btree.set.BTreeSetTGlobal.Insts.CoreIterTraitsCollectFromIterator.from_iter
      OrdInst IntoIteratorInst input ⦃ s => ∀ x, x ∈ s.items ↔ x ∈ xs ⦄ := by
  simp only [alloc.collections.btree.set.BTreeSetTGlobal.Insts.CoreIterTraitsCollectFromIterator.from_iter,
             hits, bind_tc_ok]
  rw [toList_spec IntoIteratorInst.iteratorInst xs iter hy, bind_tc_ok]
  have hcmp' : ∀ a b, ∃ o, OrdInst.cmp (id a) (id b) = ok o := fun a b =>
    ⟨_, (hcmp a b).choose_spec.1⟩
  obtain ⟨sorted, hsorted, hperm⟩ := sortBy_perm OrdInst id hcmp' xs
  rw [hsorted, bind_tc_ok]
  refine spec_bind (dedupLast_mem_all_iff OrdInst hcmp sorted) (fun deduped hmem => ?_)
  simp only [spec_ok]
  intro x
  exact (hmem x).trans hperm.mem_iff

/-- Like `from_iter_spec` but also guarantees the items list is strictly sorted; requires
    a `LinearOrder` with a lawful `OrdInst`. -/
theorem alloc.collections.btree.set.BTreeSetTGlobal.Insts.CoreIterTraitsCollectFromIterator.from_iter_spec_sorted
    {T I IntoIter : Type} [LinearOrder T] (OrdInst : core.cmp.Ord T)
    (hlaw : OrdLawful OrdInst)
    (IntoIteratorInst : core.iter.traits.collect.IntoIterator I T IntoIter)
    (input : I)
    (iter : IntoIter) (hits : IntoIteratorInst.into_iter input = ok iter)
    (xs : List T) (hy : Yields IntoIteratorInst.iteratorInst iter xs) :
    alloc.collections.btree.set.BTreeSetTGlobal.Insts.CoreIterTraitsCollectFromIterator.from_iter
      OrdInst IntoIteratorInst input
      ⦃ s => (∀ x, x ∈ s.items ↔ x ∈ xs) ∧ s.items.Pairwise (· < ·) ⦄ := by
  simp only [alloc.collections.btree.set.BTreeSetTGlobal.Insts.CoreIterTraitsCollectFromIterator.from_iter,
             hits, bind_tc_ok]
  rw [toList_spec IntoIteratorInst.iteratorInst xs iter hy, bind_tc_ok]
  obtain ⟨sorted, hsorted, hsorted_pw, hperm⟩ := sortBy_sorted_perm hlaw xs
  rw [hsorted, bind_tc_ok]
  refine spec_bind (dedupLast_pairwise_lt hlaw sorted hsorted_pw) (fun deduped hpost => ?_)
  obtain ⟨hpw, hmem⟩ := hpost
  simp only [spec_ok]
  exact ⟨fun x => (hmem x).trans hperm.mem_iff, hpw⟩

/-- `collect()` into a `BTreeSet<usize>` from any yielding iterator: same members, strictly sorted.
Corollary of `from_iter_spec_sorted`; pass `IntoIterator.Blanket IA` explicitly to avoid the
metavariable ambiguity that arises with `_` for the IntoIterator argument. -/
theorem collect_btreeset_spec {I : Type} (IA : core.iter.traits.iterator.Iterator I Usize) (it : I)
    (xs : List Usize) (hy : Yields IA it xs) :
    core.iter.traits.iterator.Iterator.collect.default IA
      (alloc.collections.btree.set.BTreeSetTGlobal.Insts.CoreIterTraitsCollectFromIterator core.cmp.OrdUsize)
      it ⦃ S => (∀ x, x ∈ S.items ↔ x ∈ xs) ∧ S.items.Pairwise (· < ·) ⦄ := by
  simp only [core.iter.traits.iterator.Iterator.collect.default, CollectShape.collect]
  exact alloc.collections.btree.set.BTreeSetTGlobal.Insts.CoreIterTraitsCollectFromIterator.from_iter_spec_sorted
    core.cmp.OrdUsize OrdUsize_lawful _ it it rfl xs hy

/-- Two strictly-sorted lists with the same membership are equal. -/
theorem List.eq_of_pairwise_lt_of_mem_iff {T : Type} [LinearOrder T] {xs ys : List T}
    (hxs : xs.Pairwise (· < ·)) (hys : ys.Pairwise (· < ·))
    (hmem : ∀ z, z ∈ xs ↔ z ∈ ys) : xs = ys := by
  induction xs generalizing ys with
  | nil =>
    rcases ys with _ | ⟨y, ys⟩
    · rfl
    · exact absurd ((hmem y).mpr (List.mem_cons.mpr (Or.inl rfl))) (by simp)
  | cons x xs ih =>
    rcases ys with _ | ⟨y, ys⟩
    · exact absurd ((hmem x).mp (List.mem_cons.mpr (Or.inl rfl))) (by simp)
    · have hxhead := (List.pairwise_cons.mp hxs).1
      have hyhead := (List.pairwise_cons.mp hys).1
      have hxy : x = y := by
        rcases List.mem_cons.mp ((hmem x).mp (List.mem_cons.mpr (Or.inl rfl))) with rfl | hx_ys
        · rfl
        · rcases List.mem_cons.mp ((hmem y).mpr (List.mem_cons.mpr (Or.inl rfl))) with rfl | hy_xs
          · rfl
          · exact absurd (hyhead x hx_ys) (lt_asymm (hxhead y hy_xs))
      subst hxy
      congr 1
      apply ih (List.pairwise_cons.mp hxs).2 (List.pairwise_cons.mp hys).2
      intro z; constructor
      · intro hz
        rcases List.mem_cons.mp ((hmem z).mp (List.mem_cons.mpr (Or.inr hz))) with rfl | hz'
        · exact absurd (hxhead _ hz) (lt_irrefl _)
        · exact hz'
      · intro hz
        rcases List.mem_cons.mp ((hmem z).mpr (List.mem_cons.mpr (Or.inr hz))) with rfl | hz'
        · exact absurd (hyhead _ hz) (lt_irrefl _)
        · exact hz'

/-- Two `BTreeSet`s with strictly-sorted `items` and the same membership are equal. -/
theorem alloc.collections.btree.set.BTreeSet.eq_of_mem_iff {T A : Type} [LinearOrder T]
    {s t : alloc.collections.btree.set.BTreeSet T A}
    (hs : s.items.Pairwise (· < ·)) (ht : t.items.Pairwise (· < ·))
    (hmem : ∀ x, x ∈ s.items ↔ x ∈ t.items) : s = t := by
  cases s; cases t
  simp only [alloc.collections.btree.set.BTreeSet.mk.injEq]
  exact List.eq_of_pairwise_lt_of_mem_iff hs ht hmem

/-! ## 6. `BTreeSet::Ord::cmp` termination -/

/-- `BTreeSet`'s `Ord::cmp` always terminates. -/
theorem alloc.collections.btree.set.BTreeSet.Insts.CoreCmpOrd.cmp_total
    {T A : Type} (OrdInst : core.cmp.Ord T)
    (hcmp : ∀ a b, ∃ o, OrdInst.cmp a b = ok o)
    (AllocInst : core.alloc.AllocatorClone A)
    (s t : alloc.collections.btree.set.BTreeSet T A) :
    ∃ o, alloc.collections.btree.set.BTreeSet.Insts.CoreCmpOrd.cmp OrdInst AllocInst s t = ok o := by
  simp only [alloc.collections.btree.set.BTreeSet.Insts.CoreCmpOrd.cmp]
  induction s.items generalizing t with
  | nil =>
    cases t.items <;> simp [List.lexCmpM, spec_ok]
  | cons x xs ih =>
    cases t.items with
    | nil => simp [List.lexCmpM, spec_ok]
    | cons y ys =>
      simp only [List.lexCmpM]
      obtain ⟨o, ho⟩ := hcmp x y
      simp only [ho, bind_tc_ok]
      rcases o with _ | _ | _
      · simp [spec_ok]
      · exact ih { items := ys }
      · simp [spec_ok]

private theorem lexCmpM_eq_iff {T : Type} [LinearOrder T]
    {OrdInst : core.cmp.Ord T} (hlaw : OrdLawful OrdInst) :
    ∀ (xs ys : List T),
    List.lexCmpM OrdInst.cmp xs ys ⦃ o => o = .eq ↔ xs = ys ⦄ := by
  intro xs
  induction xs with
  | nil =>
    intro ys; cases ys <;> simp [List.lexCmpM, spec_ok]
  | cons x xs ih =>
    intro ys; cases ys with
    | nil => simp [List.lexCmpM, spec_ok]
    | cons y ys =>
      simp only [List.lexCmpM, hlaw x y, bind_tc_ok]
      rcases lt_trichotomy x y with hxy | rfl | hxy
      · simp only [compare_lt_iff_lt.mpr hxy, spec_ok]
        exact ⟨fun h => by simp at h, fun h => absurd (List.cons.inj h).1 hxy.ne⟩
      · simp only [compare_eq_iff_eq.mpr rfl]
        exact spec_mono (ih ys) (fun o ho =>
          ho.trans ⟨fun h => congr_arg (x :: ·) h, fun h => (List.cons.inj h).2⟩)
      · simp only [compare_gt_iff_gt.mpr hxy, spec_ok]
        exact ⟨fun h => by simp at h, fun h => absurd (List.cons.inj h).1 hxy.ne'⟩

/-- Under a lawful `OrdInst`, `BTreeSet::Ord::cmp` always terminates and returns `.eq`
    exactly when the two sets are structurally equal. -/
theorem alloc.collections.btree.set.BTreeSet.Insts.CoreCmpOrd.cmp_total_eq
    {T A : Type} [LinearOrder T] (OrdInst : core.cmp.Ord T)
    (hlaw : OrdLawful OrdInst)
    (AllocInst : core.alloc.AllocatorClone A)
    (s t : alloc.collections.btree.set.BTreeSet T A) :
    ∃ o, alloc.collections.btree.set.BTreeSet.Insts.CoreCmpOrd.cmp OrdInst AllocInst s t = ok o ∧
         (o = .eq ↔ s = t) := by
  simp only [alloc.collections.btree.set.BTreeSet.Insts.CoreCmpOrd.cmp]
  have hlaw' : OrdLawful OrdInst := hlaw
  have hspec := lexCmpM_eq_iff hlaw' s.items t.items
  obtain ⟨o, ho, hiff⟩ := spec_eq_ok hspec
  refine ⟨o, ho, ?_⟩
  rw [hiff]
  constructor
  · intro h; cases s; cases t; simp_all
  · intro h; cases s; cases t; simp_all

/-! ## 7. `BTreeSet`/`BTreeMap` iteration -/

/-- The `BTreeSet::Iter` iterator yields the set's items in order. -/
theorem alloc.collections.btree.set.BTreeSet.iter_yields {T : Type}
    (xs : List T) :
    Yields (alloc.collections.btree.set.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAT T)
      { items := xs } xs := by
  induction xs with
  | nil =>
    simp only [Yields, alloc.collections.btree.set.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAT.next,
               spec_ok, uncurry'_pair]
  | cons xv xs ih =>
    simp only [Yields, alloc.collections.btree.set.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAT.next,
               spec_ok, uncurry'_pair]
    exact ⟨trivial, ih⟩

/-- `BTreeSet::iter` succeeds and yields the set's items. -/
theorem alloc.collections.btree.set.BTreeSet.iter_spec {T A : Type}
    (AllocInst : core.alloc.AllocatorClone A)
    (s : alloc.collections.btree.set.BTreeSet T A) :
    ∃ it, alloc.collections.btree.set.BTreeSet.iter AllocInst s = ok it ∧
          Yields (alloc.collections.btree.set.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAT T) it s.items :=
  ⟨_, by simp [alloc.collections.btree.set.BTreeSet.iter], alloc.collections.btree.set.BTreeSet.iter_yields s.items⟩

/-- `BTreeSet::clone` returns an equal set when element clone is identity. -/
theorem alloc.collections.btree.set.BTreeSet.Insts.CoreCloneClone.clone_spec
    {T A : Type} (CloneInst : core.clone.Clone T)
    (hclone : ∀ x, CloneInst.clone x = ok x)
    (AllocInst : core.alloc.AllocatorClone A)
    (s : alloc.collections.btree.set.BTreeSet T A) :
    alloc.collections.btree.set.BTreeSet.Insts.CoreCloneClone.clone CloneInst AllocInst s = ok s := by
  simp only [alloc.collections.btree.set.BTreeSet.Insts.CoreCloneClone.clone]
  suffices h : s.items.mapM CloneInst.clone = ok s.items by simp [h]
  induction s.items with
  | nil => simp [List.mapM_nil, pure]
  | cons x xs ih =>
    rw [List.mapM_cons]
    simp [hclone x, bind_tc_ok, ih, pure]

/-- The `BTreeMap::Iter` iterator yields the map's entries in order. -/
theorem alloc.collections.btree.map.BTreeMap.iter_yields {K V : Type}
    (xs : List (K × V)) :
    Yields (alloc.collections.btree.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV K V)
      { items := xs } xs := by
  induction xs with
  | nil =>
    simp only [Yields, alloc.collections.btree.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV.next,
               spec_ok, uncurry'_pair]
  | cons xv xs ih =>
    simp only [Yields, alloc.collections.btree.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV.next,
               spec_ok, uncurry'_pair]
    exact ⟨trivial, ih⟩

/-- `BTreeMap::iter` succeeds and yields the map's entries. -/
theorem alloc.collections.btree.map.BTreeMap.iter_spec {K V A : Type}
    (AllocInst : core.alloc.AllocatorClone A)
    (m : alloc.collections.btree.map.BTreeMap K V A) :
    ∃ it, alloc.collections.btree.map.BTreeMap.iter AllocInst m = ok it ∧
          Yields (alloc.collections.btree.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV K V) it m.entries :=
  ⟨_, by simp [alloc.collections.btree.map.BTreeMap.iter], alloc.collections.btree.map.BTreeMap.iter_yields m.entries⟩

/-! ## 8. `HashMap` iteration -/

/-- `HashMap::iter` returns an iterator whose items are a permutation of the map's entries. -/
theorem std.collections.hash.map.HashMap.iter_perm {K V S A : Type}
    (m : std.collections.hash.map.HashMap K V S A) :
    ∃ it, std.collections.hash.map.HashMap.iter m = ok it ∧ it.items.Perm m.entries :=
  ⟨{ items := (std.collections.hash.hashOrder m.entries).val },
      by simp [std.collections.hash.map.HashMap.iter],
      (std.collections.hash.hashOrder m.entries).property⟩

/-- `HashMap` iteration yields a permutation of the map's entries. -/
theorem std.collections.hash.map.HashMap.iter_yields_perm {K V S A : Type}
    (m : std.collections.hash.map.HashMap K V S A) :
    ∃ xs, xs.Perm m.entries ∧
          Yields (std.collections.hash.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV K V)
            { items := xs } xs := by
  refine ⟨(std.collections.hash.hashOrder m.entries).val,
          (std.collections.hash.hashOrder m.entries).property, ?_⟩
  generalize (std.collections.hash.hashOrder m.entries).val = xs
  induction xs with
  | nil =>
    simp only [Yields,
               std.collections.hash.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV.next,
               spec_ok, uncurry'_pair]
  | cons xv xs ih =>
    simp only [Yields,
               std.collections.hash.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV.next,
               spec_ok, uncurry'_pair]
    exact ⟨trivial, ih⟩

/-- `HashMap::Iter` built directly from a list yields that list. -/
theorem hashIter_yields {K V : Type} : ∀ (xs : List (K × V)),
    Yields (std.collections.hash.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV K V)
      { items := xs } xs
  | [] => by
    simp [Yields, std.collections.hash.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV.next]
  | x :: xs => by
    simp only [Yields, std.collections.hash.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV,
      std.collections.hash.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV.next, spec_ok]
    exact ⟨rfl, hashIter_yields xs⟩

/-! ## 9. `len` specs -/

/-- `BTreeMap::len` spec. -/
theorem alloc.collections.btree.map.BTreeMap.len_spec {K V A : Type}
    (AllocInst : core.alloc.AllocatorClone A)
    (m : alloc.collections.btree.map.BTreeMap K V A)
    (h : m.entries.length ≤ Usize.max) :
    alloc.collections.btree.map.BTreeMap.len AllocInst m ⦃ n => n.val = m.entries.length ⦄ := by
  simp only [alloc.collections.btree.map.BTreeMap.len]
  exact spec_mono (UScalar.tryMk_spec .Usize m.entries.length (by rwa [UScalar.max_USize_eq])) (by
    intro n hn; exact hn)

/-- `HashMap::len` spec. -/
theorem std.collections.hash.map.HashMap.len_spec {K V S A : Type}
    (m : std.collections.hash.map.HashMap K V S A)
    (h : m.entries.length ≤ Usize.max) :
    std.collections.hash.map.HashMap.len m ⦃ n => n.val = m.entries.length ⦄ := by
  simp only [std.collections.hash.map.HashMap.len]
  exact spec_mono (UScalar.tryMk_spec .Usize m.entries.length (by rwa [UScalar.max_USize_eq])) (by
    intro n hn; exact hn)

/-! ## Slice chunks, zip, enumerate -/

/-- `ChunksExact` already stores its chunks in order: yielding `chunks` in sequence. -/
theorem core.slice.iter.ChunksExact.iter_yields {T : Type} :
    ∀ (xss : List (Slice T)) (r : Slice T),
    Yields (core.iter.traits.iterator.IteratorChunksExact T)
      { chunks := xss, remainder := r } xss
  | [], _ => by
    simp only [Yields, core.iter.traits.iterator.IteratorChunksExact,
               core.slice.iter.IteratorChunksExact.next, spec_ok, uncurry'_pair]
  | chunk :: rest, r => by
    simp only [Yields, core.iter.traits.iterator.IteratorChunksExact,
               core.slice.iter.IteratorChunksExact.next, spec_ok, uncurry'_pair]
    exact ⟨trivial, core.slice.iter.ChunksExact.iter_yields rest r⟩

/-- Slice chunks that `Chunks(xs, n)` yields (n > 0), using `min xs.length n`
    at each step to match the model exactly. -/
def toSliceChunks {T : Type} (n : Nat) (hn : 0 < n) :
    (xs : List T) → xs.length ≤ Usize.max → List (Slice T)
  | [], _ => []
  | x :: xs_tail, hxs =>
    let m := min (x :: xs_tail).length n
    Slice.from ((x :: xs_tail).take m)
        (Nat.le_trans (by rw [List.length_take]; exact Nat.min_le_right _ _) hxs) ::
    toSliceChunks n hn ((x :: xs_tail).drop m) (by
      simp only [List.length_drop]; omega)
termination_by xs _ => xs.length
decreasing_by
  simp only [List.length_drop]
  have hpos : 0 < (x :: xs_tail).length := Nat.succ_pos _
  have hm : 0 < min (x :: xs_tail).length n := by
    apply Nat.lt_min.mpr; exact ⟨hpos, hn⟩
  omega

/-- `Slice::chunks` iterator (n > 0) yields the slice's list split into chunks of
    at most `n` elements. -/
theorem core.slice.iter.Chunks.iter_yields {T : Type} (n : Usize) (hn : 0 < n.val) :
    ∀ (xs : List T) (hxs : xs.length ≤ Usize.max),
    Yields (core.slice.iter.Chunks.Insts.CoreIterTraitsIteratorIteratorSharedASlice T)
      { v := Slice.from xs hxs, chunk_size := n }
      (toSliceChunks n.val hn xs hxs)
  | [], hxs => by
    simp only [toSliceChunks, Yields,
               core.slice.iter.Chunks.Insts.CoreIterTraitsIteratorIteratorSharedASlice,
               core.slice.iter.Chunks.Insts.CoreIterTraitsIteratorIteratorSharedASlice.next,
               Slice.from_val, spec_ok, uncurry'_pair, if_true]
  | x :: xs_tail, hxs => by
    simp only [toSliceChunks, Yields,
               core.slice.iter.Chunks.Insts.CoreIterTraitsIteratorIteratorSharedASlice,
               core.slice.iter.Chunks.Insts.CoreIterTraitsIteratorIteratorSharedASlice.next,
               Slice.from_val, show x :: xs_tail ≠ [] from List.cons_ne_nil x xs_tail,
               not_false_eq_true, ↓reduceIte, spec_ok, uncurry'_pair]
    have hdrop : ((x :: xs_tail).drop (min (x :: xs_tail).length n.val)).length ≤ Usize.max := by
      simp only [List.length_drop]; omega
    exact ⟨trivial, core.slice.iter.Chunks.iter_yields n hn
        ((x :: xs_tail).drop (min (x :: xs_tail).length n.val)) hdrop⟩
termination_by xs _ => xs.length
decreasing_by
  simp only [List.length_drop]
  have hpos : 0 < (x :: xs_tail).length := Nat.succ_pos _
  have hm : 0 < min (x :: xs_tail).length n.val := by
    apply Nat.lt_min.mpr; exact ⟨hpos, hn⟩
  omega

/-- `Zip` of two iterators yielding `as` and `bs` yields `as.zip bs`.
    When A exhausts first B is *not* advanced (per model `nextPlain`). -/
theorem core.iter.adapters.zip.Zip.yields {A B ItemA ItemB : Type}
    (IA : core.iter.traits.iterator.Iterator A ItemA)
    (IB : core.iter.traits.iterator.Iterator B ItemB) :
    ∀ (as : List ItemA) (bs : List ItemB) (a : A) (b : B),
    Yields IA a as → Yields IB b bs →
    Yields (core.iter.adapters.zip.Zip.Insts.CoreIterTraitsIteratorIteratorPair IA IB)
      ⟨a, b⟩ (as.zip bs)
  | [], _bs, a, _b, ha, _ => by
    simp only [Yields, List.zip_nil_left] at ha ⊢
    obtain ⟨⟨o, a'⟩, hnext_a, ho⟩ := spec_eq_ok ha
    simp only [uncurry'_pair] at ho; subst ho
    simp [core.iter.adapters.zip.Zip.Insts.CoreIterTraitsIteratorIteratorPair,
          core.iter.adapters.zip.Zip.nextPlain, hnext_a, bind_tc_ok, spec_ok, uncurry'_pair]
  | _a0 :: _as', [], a, b, ha, hb => by
    simp only [Yields, List.zip_nil_right] at ha hb ⊢
    obtain ⟨⟨o_a, a'⟩, hnext_a, hpost_a⟩ := spec_eq_ok ha
    simp only [uncurry'_pair] at hpost_a; obtain ⟨rfl, _⟩ := hpost_a
    obtain ⟨⟨o_b, b'⟩, hnext_b, ho_b⟩ := spec_eq_ok hb
    simp only [uncurry'_pair] at ho_b; subst ho_b
    simp [core.iter.adapters.zip.Zip.Insts.CoreIterTraitsIteratorIteratorPair,
          core.iter.adapters.zip.Zip.nextPlain, hnext_a, hnext_b, bind_tc_ok, spec_ok,
          uncurry'_pair]
  | a0 :: as', b0 :: bs', a, b, ha, hb => by
    simp only [Yields, List.zip_cons_cons] at ha hb ⊢
    obtain ⟨⟨o_a, a'⟩, hnext_a, hpost_a⟩ := spec_eq_ok ha
    simp only [uncurry'_pair] at hpost_a; obtain ⟨rfl, ha'⟩ := hpost_a
    obtain ⟨⟨o_b, b'⟩, hnext_b, hpost_b⟩ := spec_eq_ok hb
    simp only [uncurry'_pair] at hpost_b; obtain ⟨rfl, hb'⟩ := hpost_b
    simp only [core.iter.adapters.zip.Zip.Insts.CoreIterTraitsIteratorIteratorPair,
               core.iter.adapters.zip.Zip.nextPlain, hnext_a, hnext_b, bind_tc_ok, spec_ok,
               uncurry'_pair]
    exact ⟨trivial, core.iter.adapters.zip.Zip.yields IA IB as' bs' a' b' ha' hb'⟩

/-- Indexed pairs starting from `start`, bounded so each index fits in `Usize`. -/
def usizeEnumFrom {Item : Type} :
    (start : Nat) → (xs : List Item) → start + xs.length ≤ Usize.max → List (Usize × Item)
  | _, [], _ => []
  | start, x :: xs, h =>
    let hstart : start < 2 ^ UScalarTy.Usize.numBits := by
      simp only [List.length_cons] at h
      simp only [Usize.max, Usize.numBits] at h; omega
    (Usize.ofNatCore start hstart, x) ::
    usizeEnumFrom (start + 1) xs (by simp only [List.length_cons] at h; omega)

/-- `usizeEnumFrom` is proof-irrelevant in its bound argument. -/
theorem usizeEnumFrom_irrel {Item : Type} {s : Nat} {xs : List Item}
    (h1 h2 : s + xs.length ≤ Usize.max) :
    usizeEnumFrom s xs h1 = usizeEnumFrom s xs h2 := by
  induction xs generalizing s with
  | nil => simp [usizeEnumFrom]
  | cons x xs ih => simp [usizeEnumFrom, ih]

/-- `Enumerate` (count from `c`, `c.val + xs.length ≤ Usize.max`) yields
    `(c, x₀), (c+1, x₁), …` as `(Usize, item)` pairs. -/
theorem core.iter.adapters.enumerate.Enumerate.yields {I Item : Type}
    (IterInst : core.iter.traits.iterator.Iterator I Item) :
    ∀ (xs : List Item) (it : I) (c : Usize),
    Yields IterInst it xs →
    (hbound : c.val + xs.length ≤ Usize.max) →
    Yields (core.iter.traits.iterator.IteratorEnumerate IterInst)
      { iter := it, count := c }
      (usizeEnumFrom c.val xs hbound)
  | [], it, c, hy, _ => by
    simp only [usizeEnumFrom, Yields] at hy ⊢
    obtain ⟨⟨o, it'⟩, hnext, ho⟩ := spec_eq_ok hy
    simp only [uncurry'_pair] at ho; subst ho
    simp [core.iter.traits.iterator.IteratorEnumerate,
          core.iter.adapters.enumerate.IteratorEnumerate.next, hnext, bind_tc_ok, spec_ok,
          uncurry'_pair]
  | x :: xs, it, c, hy, hcount => by
    simp only [usizeEnumFrom, Yields] at hy ⊢
    obtain ⟨⟨o, it'⟩, hnext, hpost⟩ := spec_eq_ok hy
    simp only [uncurry'_pair] at hpost; obtain ⟨rfl, hy'⟩ := hpost
    have hbound1 : c.val + 1 ≤ Usize.max := by
      simp only [List.length_cons] at hcount; omega
    -- Extract c1 from c + 1#usize using the UScalar.add_equiv pattern
    have hadd_raw := @UScalar.add_equiv UScalarTy.Usize c (1#usize)
    split at hadd_raw
    · rename_i c1 hadd_eq
      simp at hadd_eq
      obtain ⟨_, hc1_val, _⟩ := hadd_raw
      simp only [show (1#usize).val = 1 from rfl] at hc1_val
      -- hadd_eq : c + 1#usize = ok c1;  hc1_val : ↑c1 = ↑c + 1
      simp only [core.iter.traits.iterator.IteratorEnumerate,
                 core.iter.adapters.enumerate.IteratorEnumerate.next,
                 hnext, bind_tc_ok, hadd_eq, spec_ok, uncurry'_pair]
      constructor
      · -- head: c = Usize.ofNatCore c.val _
        simp [UScalar.eq_equiv, Usize.ofNatCore_val_eq]
      · -- tail: recursive call with c1
        have hcount' : c1.val + xs.length ≤ Usize.max := by
          simp only [List.length_cons] at hcount; omega
        have hrec := core.iter.adapters.enumerate.Enumerate.yields IterInst xs it' c1 hy' hcount'
        -- goal has usizeEnumFrom (↑c+1) xs _, hrec has usizeEnumFrom ↑c1 xs _
        -- reconcile via hc1_val : ↑c1 = ↑c + 1
        convert hrec using 1
        simp only [← hc1_val]
    · exfalso
      simp [UScalar.inBounds, UScalar.max_USize_eq] at hadd_raw
      simp [Usize.max, Usize.numBits] at hbound1
      omega
    · exact hadd_raw.elim

/-! ## 9. `HashMap::from_iter` spec -/

private theorem lookupL_append {K V : Type} (xs ys : List (K × V)) (k : K) :
    lookupL (xs ++ ys) k =
      match lookupL xs k with
      | some v => some v
      | none   => lookupL ys k := by
  induction xs with
  | nil => simp [lookupL_nil]
  | cons e es ih =>
    rcases e with ⟨k', v'⟩
    simp only [List.cons_append, lookupL_cons]
    by_cases h : k' = k
    · simp [h]
    · rw [if_neg h, ih]
      simp [h]

/-- `insertList` writes `v` for key `k`, and is transparent to all other keys. -/
private theorem insertList_lookupL {K V : Type} (EqInst : core.cmp.Eq K)
    (hEq : ∀ a b, ∃ r, EqInst.partialEqInst.eq a b = ok r ∧ (r = true ↔ a = b))
    (acc : List (K × V)) (k : K) (v : V) :
    std.collections.hash.map.HashMap.insertList EqInst acc k v
      ⦃ entries => lookupL entries k = some v ∧
                   ∀ k', k' ≠ k → lookupL entries k' = lookupL acc k' ⦄ := by
  induction acc with
  | nil =>
    simp only [std.collections.hash.map.HashMap.insertList, spec_ok]
    exact ⟨by simp [lookupL_cons],
           fun k' hne => by simp [lookupL_cons, lookupL_nil, (Ne.symm hne)]⟩
  | cons e es ih =>
    rcases e with ⟨k', v'⟩
    simp only [std.collections.hash.map.HashMap.insertList]
    obtain ⟨r, hr, hriff⟩ := hEq k' k
    simp only [hr, bind_tc_ok]
    by_cases heq : k' = k
    · -- update in-place: result is ok ((k', v) :: es)
      simp only [hriff.mpr heq, ite_true, spec_ok]
      refine ⟨by rw [lookupL_cons, if_pos heq], fun k'' hne'' => ?_⟩
      rw [lookupL_cons, lookupL_cons]
      by_cases heq' : k' = k''
      · exact absurd (heq'.symm.trans heq) hne''
      · simp [heq']
    · -- key not found in head, recurse into es
      have hr_false : r = false := by
        cases r
        · rfl
        · exact absurd (hriff.mp rfl) heq
      simp only [hr_false, ite_false]
      refine spec_bind ih (fun entries ⟨hlook, hother⟩ => ?_)
      simp only [spec_ok]
      refine ⟨by rw [lookupL_cons, if_neg heq]; exact hlook, fun k'' hne'' => ?_⟩
      rw [lookupL_cons, lookupL_cons]
      by_cases heq' : k' = k''
      · simp [heq']
      · simp [heq', hother k'' hne'']

/-- `foldlM insertList` postcondition: for every key `k`, the result maps `k` to its last
    occurrence in `pairs`, or falls back to `acc`. -/
private theorem foldlM_insertList_lookupL {K V : Type} (EqInst : core.cmp.Eq K)
    (hEq : ∀ a b, ∃ r, EqInst.partialEqInst.eq a b = ok r ∧ (r = true ↔ a = b)) :
    ∀ (pairs : List (K × V)) (acc : List (K × V)),
    pairs.foldlM (fun es p => std.collections.hash.map.HashMap.insertList EqInst es p.1 p.2) acc
      ⦃ entries => ∀ k, lookupL entries k =
          match lookupL pairs.reverse k with
          | some v => some v
          | none   => lookupL acc k ⦄ := by
  intro pairs
  induction pairs with
  | nil =>
    intro acc
    simp [List.foldlM_nil, pure_tc_eq, List.reverse_nil, lookupL_nil, spec_ok]
  | cons p ps ih =>
    intro acc
    rcases p with ⟨pk, pv⟩
    simp only [List.foldlM_cons]
    refine spec_bind (insertList_lookupL EqInst hEq acc pk pv)
        (fun acc' ⟨hlook_p, hother_p⟩ => ?_)
    refine spec_mono (ih acc') (fun entries hentries => ?_)
    simp only [List.reverse_cons]
    intro k
    rw [hentries k, lookupL_append, lookupL_cons]
    rcases h : lookupL ps.reverse k with _ | v
    · -- ps.reverse has no k, fall through to (pk, pv) and acc
      simp only [h]
      by_cases hpk : pk = k
      · simp only [hpk, ite_true]; exact hpk ▸ hlook_p
      · simp only [hpk, ite_false]; exact hother_p k (Ne.symm hpk)
    · -- ps.reverse found k → val v; IH gives some v; outer match gives some v
      simp only [h]

/-- `HashMap::from_iter` spec: for any key `k`, the map's entry equals the last pair with
    that key in the input iterator (`lookupL xs.reverse k`). -/
theorem std.collections.hash.map.HashMapKVSGlobal.Insts.CoreIterTraitsCollectFromIteratorPair.from_iter_spec
    {K V S I Hasher IntoIter : Type}
    (EqInst : core.cmp.Eq K) (HashInst : core.hash.Hash K)
    (BuildHasherInst : core.hash.BuildHasher S Hasher)
    (DefaultInst : core.default.Default S)
    (IntoIteratorInst : core.iter.traits.collect.IntoIterator I (K × V) IntoIter)
    (hEq : ∀ a b, ∃ r, EqInst.partialEqInst.eq a b = ok r ∧ (r = true ↔ a = b))
    (input : I)
    (iter : IntoIter) (hits : IntoIteratorInst.into_iter input = ok iter)
    (xs : List (K × V)) (hy : Yields IntoIteratorInst.iteratorInst iter xs) :
    std.collections.hash.map.HashMapKVSGlobal.Insts.CoreIterTraitsCollectFromIteratorPair.from_iter
      EqInst HashInst BuildHasherInst DefaultInst IntoIteratorInst input
      ⦃ m => ∀ k, lookupL m.entries k = lookupL xs.reverse k ⦄ := by
  simp only [
    std.collections.hash.map.HashMapKVSGlobal.Insts.CoreIterTraitsCollectFromIteratorPair.from_iter,
    hits, bind_tc_ok]
  rw [toList_spec IntoIteratorInst.iteratorInst xs iter hy, bind_tc_ok]
  refine spec_bind (foldlM_insertList_lookupL EqInst hEq xs []) (fun entries hentries => ?_)
  simp only [spec_ok]
  intro k
  rw [hentries k, lookupL_nil]
  cases lookupL xs.reverse k <;> rfl

/-- `FromIterator` instance for `HashMap`: wraps `from_iter` so `collect.default` can use it. -/
@[reducible, rust_trait_impl
  "core::iter::traits::collect::FromIterator<std::collections::hash::map::HashMap<@K, @V, @S, alloc::alloc::Global>, (@K, @V)>"]
def std.collections.hash.map.HashMapKVSGlobal.Insts.CoreIterTraitsCollectFromIteratorPair
    {K : Type} (V : Type) {S Hasher : Type}
    (EqInst : core.cmp.Eq K) (hI : core.hash.Hash K)
    (bI : core.hash.BuildHasher S Hasher) (dI : core.default.Default S) :
    core.iter.traits.collect.FromIterator (std.collections.hash.map.HashMap K V S Global) (K × V) :=
  { from_iter := fun IntoIteratorInst =>
      std.collections.hash.map.HashMapKVSGlobal.Insts.CoreIterTraitsCollectFromIteratorPair.from_iter
        EqInst hI bI dI IntoIteratorInst }

/-- `collect()` into a `HashMap` from an iterator yielding `xs`: later pairs win. -/
theorem collect_hashmap_spec {I K V S Hasher : Type} (IA : core.iter.traits.iterator.Iterator I (K × V))
    (EqInst : core.cmp.Eq K) (hI : core.hash.Hash K) (bI : core.hash.BuildHasher S Hasher)
    (dI : core.default.Default S)
    (hEq : ∀ a b, ∃ r, EqInst.partialEqInst.eq a b = ok r ∧ (r = true ↔ a = b))
    (it : I) (xs : List (K × V)) (hy : Yields IA it xs) :
    core.iter.traits.iterator.Iterator.collect.default IA
      (std.collections.hash.map.HashMapKVSGlobal.Insts.CoreIterTraitsCollectFromIteratorPair V EqInst hI bI dI)
      it ⦃ m => ∀ k, lookupL m.entries k = lookupL xs.reverse k ⦄ := by
  simp only [core.iter.traits.iterator.Iterator.collect.default, CollectShape.collect]
  exact std.collections.hash.map.HashMapKVSGlobal.Insts.CoreIterTraitsCollectFromIteratorPair.from_iter_spec
    EqInst hI bI dI (core.iter.traits.collect.IntoIterator.Blanket IA) hEq it it rfl xs hy

/-! ## 10. `BTreeSet` linear order and `OrdLawful` -/

/-- `BTreeSet` inherits `LinearOrder` from its item list via injection `·.items`. -/
instance alloc.collections.btree.set.BTreeSet.instLinearOrder {T A : Type} [LinearOrder T] :
    LinearOrder (alloc.collections.btree.set.BTreeSet T A) :=
  LinearOrder.lift' (·.items) fun a b h => by obtain ⟨_⟩ := a; obtain ⟨_⟩ := b; subst h; rfl

/-- `<` on `List T` (core `abbrev lt = Lex (· < ·)`) unfolds to `List.Lex`. -/
private theorem List.lt_iff_lex {T : Type} [LT T] {xs ys : List T} :
    xs < ys ↔ List.Lex (· < ·) xs ys := Iff.rfl

/-- A lawful element `Ord` gives `lexCmpM = ok ∘ compare` at the `BTreeSet` level,
    keeping `compare` at a single `Ord` instance throughout. -/
private theorem List.lexCmpM_cmp {T A : Type} [LinearOrder T]
    {OrdInst : core.cmp.Ord T} (hlaw : OrdLawful OrdInst) :
    ∀ xs ys : List T,
      List.lexCmpM OrdInst.cmp xs ys =
        ok (compare (⟨xs⟩ : alloc.collections.btree.set.BTreeSet T A) ⟨ys⟩)
  | [], [] => by simp [List.lexCmpM, compare_eq_iff_eq]
  | [], y :: ys => by
      simp only [List.lexCmpM]
      have h1 : (⟨[]⟩ : alloc.collections.btree.set.BTreeSet T A) < ⟨y :: ys⟩ :=
        List.lt_iff_lex.mpr List.Lex.nil
      exact congrArg ok (compare_lt_iff_lt.mpr h1).symm
  | x :: xs, [] => by
      simp only [List.lexCmpM]
      have h1 : (⟨[]⟩ : alloc.collections.btree.set.BTreeSet T A) < ⟨x :: xs⟩ :=
        List.lt_iff_lex.mpr List.Lex.nil
      exact congrArg ok (compare_gt_iff_gt.mpr h1).symm
  | a :: as, b :: bs => by
    simp only [List.lexCmpM, hlaw a b, bind_tc_ok]
    cases hcmp : compare a b with
    | lt =>
      simp only [hcmp]
      have hab : a < b := compare_lt_iff_lt.mp hcmp
      have h1 : (⟨a :: as⟩ : alloc.collections.btree.set.BTreeSet T A) < ⟨b :: bs⟩ :=
        List.lt_iff_lex.mpr (List.Lex.rel hab)
      exact congrArg ok (compare_lt_iff_lt.mpr h1).symm
    | eq =>
      simp only [hcmp]
      have hab : a = b := compare_eq_iff_eq.mp hcmp
      subst hab
      suffices hcc : compare (⟨a :: as⟩ : alloc.collections.btree.set.BTreeSet T A) ⟨a :: bs⟩ =
          compare (⟨as⟩ : alloc.collections.btree.set.BTreeSet T A) ⟨bs⟩ by
        rw [hcc]; exact List.lexCmpM_cmp hlaw as bs
      rcases lt_trichotomy (⟨as⟩ : alloc.collections.btree.set.BTreeSet T A) ⟨bs⟩ with h | h | h
      · have has : as < bs := h
        have h1 : (⟨a :: as⟩ : alloc.collections.btree.set.BTreeSet T A) < ⟨a :: bs⟩ :=
          List.lt_iff_lex.mpr (List.Lex.cons (List.lt_iff_lex.mp has))
        exact (compare_lt_iff_lt.mpr h1).trans (compare_lt_iff_lt.mpr h).symm
      · have hasbs : as = bs := congrArg (·.items) h
        subst hasbs; simp [compare_eq_iff_eq]
      · have hbs : bs < as := h
        have h1 : (⟨a :: bs⟩ : alloc.collections.btree.set.BTreeSet T A) < ⟨a :: as⟩ :=
          List.lt_iff_lex.mpr (List.Lex.cons (List.lt_iff_lex.mp hbs))
        exact (compare_gt_iff_gt.mpr h1).trans (compare_gt_iff_gt.mpr h).symm
    | gt =>
      simp only [hcmp]
      have hab : b < a := compare_gt_iff_gt.mp hcmp
      have h1 : (⟨b :: bs⟩ : alloc.collections.btree.set.BTreeSet T A) < ⟨a :: as⟩ :=
        List.lt_iff_lex.mpr (List.Lex.rel hab)
      exact congrArg ok (compare_gt_iff_gt.mpr h1).symm

/-- A lawful `Ord` on `T` gives `BTreeSet.Insts.CoreCmpOrd.cmp = ok ∘ compare`. -/
theorem alloc.collections.btree.set.BTreeSet.Insts.CoreCmpOrd.BTreeSet_cmp_lawful
    {T A : Type} [LinearOrder T] (OrdInst : core.cmp.Ord T) (hlaw : OrdLawful OrdInst)
    (aI : core.alloc.AllocatorClone A) :
    ∀ s t : alloc.collections.btree.set.BTreeSet T A,
      alloc.collections.btree.set.BTreeSet.Insts.CoreCmpOrd.cmp OrdInst aI s t =
        ok (compare s t) := fun ⟨xs⟩ ⟨ys⟩ => by
  simp only [alloc.collections.btree.set.BTreeSet.Insts.CoreCmpOrd.cmp]
  exact List.lexCmpM_cmp hlaw xs ys

/-! ## 11. `BTreeMap` sorted-key invariants -/

/-- A strictly sorted key list has no duplicate keys. -/
theorem alloc.collections.btree.map.BTreeMap.sorted_keys_nodup {K V : Type} [LinearOrder K]
    (es : List (K × V))
    (h : es.Pairwise (fun a b => a.1 < b.1)) :
    (es.map Prod.fst).Nodup := by
  rw [List.nodup_iff_pairwise_ne, List.pairwise_map]
  exact h.imp fun hab => ne_of_lt hab

/-- `setVal` preserves the keys list. -/
private theorem BTreeMap.setVal_keys_eq {K V : Type} (es : List (K × V)) (i : Nat) (v : V) :
    (alloc.collections.btree.map.BTreeMap.setVal es i v).map Prod.fst = es.map Prod.fst := by
  induction es generalizing i with
  | nil => simp [alloc.collections.btree.map.BTreeMap.setVal]
  | cons hd tl ih =>
    cases i with
    | zero => simp [alloc.collections.btree.map.BTreeMap.setVal]
    | succ n => simp [alloc.collections.btree.map.BTreeMap.setVal, ih]

/-- `setVal` preserves list length. -/
private theorem BTreeMap.setVal_length {K V : Type} (es : List (K × V)) (i : Nat) (v : V) :
    (alloc.collections.btree.map.BTreeMap.setVal es i v).length = es.length := by
  have h := congrArg List.length (BTreeMap.setVal_keys_eq es i v)
  simp only [List.length_map] at h
  exact h

/-- `setVal` preserves sorted order. -/
private theorem BTreeMap.setVal_sorted {K V : Type} [LinearOrder K]
    (es : List (K × V)) (i : Nat) (v : V)
    (h : es.Pairwise (fun a b => a.1 < b.1)) :
    (alloc.collections.btree.map.BTreeMap.setVal es i v).Pairwise (fun a b => a.1 < b.1) := by
  induction es generalizing i with
  | nil => simp [alloc.collections.btree.map.BTreeMap.setVal]
  | cons hd tl ih =>
    cases i with
    | zero =>
      simp only [alloc.collections.btree.map.BTreeMap.setVal]
      exact List.pairwise_cons.mpr (List.pairwise_cons.mp h)
    | succ n =>
      simp only [alloc.collections.btree.map.BTreeMap.setVal]
      apply List.pairwise_cons.mpr
      refine ⟨?_, ih n (List.pairwise_cons.mp h).2⟩
      intro x hx
      have hkeys : x.1 ∈ (alloc.collections.btree.map.BTreeMap.setVal tl n v).map Prod.fst :=
        List.mem_map.mpr ⟨x, hx, rfl⟩
      rw [BTreeMap.setVal_keys_eq] at hkeys
      obtain ⟨y, hy_mem, hy_eq⟩ := List.mem_map.mp hkeys
      rw [← hy_eq]
      exact (List.pairwise_cons.mp h).1 y hy_mem

private theorem lookupL_none_of_gt {K V : Type} [LinearOrder K]
    (k : K) (es : List (K × V)) (h : ∀ x ∈ es, k < x.1) :
    lookupL es k = none := by
  induction es with
  | nil => simp
  | cons hd tl ih =>
    obtain ⟨k', v'⟩ := hd
    rw [lookupL_cons, if_neg (ne_of_gt (h (k', v') List.mem_cons_self))]
    exact ih (fun x hx => h x (List.mem_cons.mpr (Or.inr hx)))

/-- Combined sorted + lower-bound + length invariant for `insertList`. -/
private theorem BTreeMap.insertList_sorted_lb {K V : Type} [LinearOrder K]
    {OrdInst : core.cmp.Ord K} (hlaw : OrdLawful OrdInst) :
    ∀ (es : List (K × V)) (k : K) (d : V),
      es.Pairwise (fun a b => a.1 < b.1) →
      alloc.collections.btree.map.BTreeMap.insertList OrdInst es k d
        ⦃ old es' =>
          es'.Pairwise (fun a b => a.1 < b.1) ∧
          (∀ lb : K, lb < k → (∀ x ∈ es, lb < x.1) → ∀ x ∈ es', lb < x.1) ∧
          es'.length = if old = none then es.length + 1 else es.length ⦄ := by
  intro es
  induction es with
  | nil =>
    intro k d _
    simp only [alloc.collections.btree.map.BTreeMap.insertList, spec_ok]
    refine ⟨List.pairwise_singleton _ _, ?_, by simp⟩
    intro lb hlb _ x hx
    simp only [List.mem_singleton] at hx; subst hx; exact hlb
  | cons hd tl ih =>
    intro k d hsorted
    obtain ⟨k', v'⟩ := hd
    have htl_sorted := (List.pairwise_cons.mp hsorted).2
    have htl_lb : ∀ x ∈ tl, k' < x.1 := (List.pairwise_cons.mp hsorted).1
    simp only [alloc.collections.btree.map.BTreeMap.insertList, hlaw k k', bind_tc_ok]
    rcases lt_trichotomy k k' with hlt | heq | hgt
    · simp only [compare_lt_iff_lt.mpr hlt, spec_ok]
      refine ⟨?_, ?_, by simp⟩
      · apply List.pairwise_cons.mpr
        refine ⟨fun x hx => ?_, hsorted⟩
        rcases List.mem_cons.mp hx with rfl | hx
        · exact hlt
        · exact lt_trans hlt (htl_lb x hx)
      · intro lb hlb_k hlb_all x hx
        rcases List.mem_cons.mp hx with rfl | hx
        · exact hlb_k
        · exact hlb_all x hx
    · subst heq
      simp only [compare_eq_iff_eq.mpr rfl, spec_ok]
      refine ⟨?_, ?_, by simp⟩
      · exact List.pairwise_cons.mpr ⟨htl_lb, htl_sorted⟩
      · intro lb hlb_k hlb_all x hx
        rcases List.mem_cons.mp hx with rfl | hx
        · exact hlb_all (k, v') List.mem_cons_self
        · exact hlb_all x (List.mem_cons.mpr (Or.inr hx))
    · simp only [compare_gt_iff_gt.mpr hgt]
      obtain ⟨r, hr, hpost⟩ := spec_eq_ok (ih k d htl_sorted)
      obtain ⟨old, tl'⟩ := r
      simp only [uncurry'_pair] at hpost
      obtain ⟨htl'_sorted, htl'_lb, htl'_len⟩ := hpost
      simp only [hr, bind_tc_ok, spec_ok]
      refine ⟨?_, ?_, ?_⟩
      · apply List.pairwise_cons.mpr
        exact ⟨htl'_lb k' hgt (fun x hx => htl_lb x hx), htl'_sorted⟩
      · intro lb hlb_k hlb_all x hx
        rcases List.mem_cons.mp hx with rfl | hx
        · exact hlb_all (k', v') List.mem_cons_self
        · exact htl'_lb lb hlb_k (fun y hy => hlb_all y (List.mem_cons.mpr (Or.inr hy))) x hx
      · simp only [List.length_cons, htl'_len]; split <;> omega

/-- `insertList` preserves sorted order. -/
theorem alloc.collections.btree.map.BTreeMap.insertList_sorted {K V : Type} [LinearOrder K]
    {OrdInst : core.cmp.Ord K} (hlaw : OrdLawful OrdInst)
    (es : List (K × V)) (k : K) (d : V)
    (hsorted : es.Pairwise (fun a b => a.1 < b.1)) :
    alloc.collections.btree.map.BTreeMap.insertList OrdInst es k d
      ⦃ _ es' => es'.Pairwise (fun a b => a.1 < b.1) ⦄ :=
  spec_mono (BTreeMap.insertList_sorted_lb hlaw es k d hsorted)
    (fun _ ⟨hsorted', _, _⟩ => hsorted')

/-- `insertList` with a fresh key grows the list by one; with an existing key keeps the length. -/
theorem alloc.collections.btree.map.BTreeMap.insertList_length {K V : Type} [LinearOrder K]
    {OrdInst : core.cmp.Ord K} (hlaw : OrdLawful OrdInst)
    (es : List (K × V)) (k : K) (d : V)
    (hsorted : es.Pairwise (fun a b => a.1 < b.1)) :
    alloc.collections.btree.map.BTreeMap.insertList OrdInst es k d
      ⦃ old es' =>
        es'.length = if lookupL es k = none then es.length + 1 else es.length ⦄ := by
  -- Prove old = lookupL es k alongside the length, by induction
  suffices h : ∀ (es : List (K × V)) (k : K) (d : V),
      es.Pairwise (fun a b => a.1 < b.1) →
      alloc.collections.btree.map.BTreeMap.insertList OrdInst es k d
        ⦃ old es' =>
          old = lookupL es k ∧
          es'.length = if old = none then es.length + 1 else es.length ⦄ by
    exact spec_mono (h es k d hsorted) (fun _ ⟨hold, hlen⟩ => hold ▸ hlen)
  intro es
  induction es with
  | nil =>
    intro k d _
    simp [alloc.collections.btree.map.BTreeMap.insertList, spec_ok, lookupL_nil]
  | cons hd tl ih =>
    intro k d hsorted
    obtain ⟨k', v'⟩ := hd
    have htl_sorted := (List.pairwise_cons.mp hsorted).2
    have htl_lb : ∀ x ∈ tl, k' < x.1 := (List.pairwise_cons.mp hsorted).1
    simp only [alloc.collections.btree.map.BTreeMap.insertList, hlaw k k', bind_tc_ok]
    rcases lt_trichotomy k k' with hlt | heq | hgt
    · simp only [compare_lt_iff_lt.mpr hlt, spec_ok, lookupL_cons, if_neg (ne_of_gt hlt)]
      exact ⟨(lookupL_none_of_gt k tl fun x hx => lt_trans hlt (htl_lb x hx)).symm, by simp⟩
    · subst heq
      simp only [compare_eq_iff_eq.mpr rfl, spec_ok, lookupL_cons, ↓reduceIte]
      exact ⟨rfl, by simp⟩
    · simp only [compare_gt_iff_gt.mpr hgt]
      obtain ⟨r, hr, hpost⟩ := spec_eq_ok (ih k d htl_sorted)
      obtain ⟨old, tl'⟩ := r
      simp only [uncurry'_pair] at hpost
      obtain ⟨hold, hlen⟩ := hpost
      simp only [hr, bind_tc_ok, spec_ok, lookupL_cons, if_neg (ne_of_lt hgt)]
      exact ⟨hold, by simp only [List.length_cons, hlen]; split <;> omega⟩

open Classical in
/-- `or_insert` preserves sorted order and grows the entry set by one iff the key was absent. -/
theorem alloc.collections.btree.map.entry.Entry.or_insert_sorted_length {K V A : Type}
    [LinearOrder K] (OrdInst : core.cmp.Ord K) (hlaw : OrdLawful OrdInst)
    (aI : core.alloc.AllocatorClone A)
    (e : alloc.collections.btree.map.entry.Entry K V A)
    (hsorted : e.map.entries.Pairwise (fun a b => a.1 < b.1)) (d : V) :
    alloc.collections.btree.map.entry.Entry.or_insert OrdInst aI e d
      ⦃ _ back =>
        ∀ v', (back v').map.entries.Pairwise (fun a b => a.1 < b.1) ∧
              (back v').map.entries.length =
                if lookupL e.map.entries e.key = none
                then e.map.entries.length + 1
                else e.map.entries.length ⦄ := by
  have hcmp : ∀ a b : K, ∃ o, OrdInst.cmp a b = ok o ∧ (o = .eq ↔ a = b) :=
    hcmp_of_lawful hlaw (fun a b => compare_eq_iff_eq)
  unfold alloc.collections.btree.map.entry.Entry.or_insert
  obtain ⟨r, hr, hpos⟩ :=
    spec_eq_ok (alloc.collections.btree.map.BTreeMap.position_spec OrdInst hcmp e.map.entries e.key)
  cases r with
  | none =>
    -- key absent: insertList then second position
    obtain ⟨⟨old, entries'⟩, hins, h_ins_spec⟩ :=
      spec_eq_ok (alloc.collections.btree.map.BTreeMap.insertList_spec OrdInst hcmp e.map.entries e.key d)
    simp only [uncurry'_pair] at h_ins_spec
    -- sortedness of entries'
    obtain ⟨⟨_, entries_s⟩, hins_s, h_sorted_spec⟩ :=
      spec_eq_ok (alloc.collections.btree.map.BTreeMap.insertList_sorted hlaw e.map.entries e.key d hsorted)
    have hes_eq : entries_s = entries' := (Prod.mk.inj (ok.injEq.mp (hins_s.symm.trans hins))).2
    rw [hes_eq] at h_sorted_spec
    -- length of entries'
    obtain ⟨⟨_, entries_l⟩, hins_l, h_len_spec⟩ :=
      spec_eq_ok (alloc.collections.btree.map.BTreeMap.insertList_length hlaw e.map.entries e.key d hsorted)
    have hel_eq : entries_l = entries' := (Prod.mk.inj (ok.injEq.mp (hins_l.symm.trans hins))).2
    rw [hel_eq] at h_len_spec
    -- second position on entries': key was just inserted, so it's found
    obtain ⟨r', hr', hpos'⟩ :=
      spec_eq_ok (alloc.collections.btree.map.BTreeMap.position_spec OrdInst hcmp entries' e.key)
    cases r' with
    | none =>
      exfalso
      exact absurd hpos' (by rw [h_ins_spec e.key]; simp)
    | some x =>
      obtain ⟨i, v⟩ := x
      obtain ⟨_, hsetval⟩ := hpos'
      simp only [hr, hins, hr', bind_tc_ok, spec_ok]
      intro v'
      exact ⟨BTreeMap.setVal_sorted entries' i v' h_sorted_spec,
             by simp only [uncurry'_pair] at h_len_spec
                simp [BTreeMap.setVal_length, hpos, h_len_spec]⟩
  | some x =>
    obtain ⟨i, w⟩ := x
    obtain ⟨hw, _⟩ := hpos
    -- key present: no insertList; second position finds same (i, w)
    simp only [hr, bind_tc_ok, spec_ok]
    intro v'
    exact ⟨BTreeMap.setVal_sorted e.map.entries i v' hsorted,
           by simp [BTreeMap.setVal_length, hw]⟩

end Aeneas.Std
