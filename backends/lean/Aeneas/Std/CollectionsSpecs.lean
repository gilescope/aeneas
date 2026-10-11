/- Specs for the `HashMap` and `BTreeMap` models as finite maps: through `lookupL` (the value of the
first entry with the key), `get`, `entry().or_insert()` and writing through its `&mut V` behave
as Rust's do, given keys compared by a lawful `Eq`/`Ord`. -/
module
public import Aeneas.Std.BTree
public import Aeneas.Std.HashMap
public import Aeneas.Std.CollectionsExtra
public import Aeneas.Std.IterSpecs
public section

namespace Aeneas.Std

open Result WP

open Classical in
/-- The value of the first entry with key `k`: what a map's entries denote at `k`. -/
@[expose] noncomputable def lookupL {K V : Type} (es : List (K × V)) (k : K) : Option V :=
  (es.find? fun e => decide (e.1 = k)).map (·.2)

open Classical in
@[simp] theorem lookupL_nil {K V : Type} (k : K) : lookupL ([] : List (K × V)) k = none := rfl

open Classical in
theorem lookupL_cons {K V : Type} (k' : K) (v : V) (es : List (K × V)) (k : K) :
    lookupL ((k', v) :: es) k = if k' = k then some v else lookupL es k := by
  by_cases h : k' = k <;> simp [lookupL, List.find?_cons, h]

open Classical in
theorem lookupL_append_fresh {K V : Type} (k : K) (v' : V) :
    ∀ (es : List (K × V)), lookupL es k = none → ∀ k',
      lookupL (es ++ [(k, v')]) k' = if k' = k then some v' else lookupL es k'
  | [], _, k' => by simp [lookupL_cons, eq_comm]
  | (a, b) :: es, h, k' => by
    rw [lookupL_cons] at h
    by_cases ha : a = k
    · simp [ha] at h
    · simp only [ha, ↓reduceIte] at h
      rw [List.cons_append, lookupL_cons, lookupL_cons, lookupL_append_fresh k v' es h k']
      by_cases h1 : a = k' <;> by_cases h2 : k' = k <;> simp_all

open Classical in
/-- At the first index with key `k`: the value, and setting it rewrites just `k`. -/
theorem lookupL_findIdx {K V : Type} (k : K) :
    ∀ (es : List (K × V)) (i : ℕ), (es.findIdx? fun e => decide (e.1 = k)) = some i →
      ∃ hi : i < es.length, es[i].1 = k ∧ lookupL es k = some es[i].2 ∧
        ∀ v' k', lookupL (es.set i (k, v')) k' = if k' = k then some v' else lookupL es k'
  | [], i, h => by simp at h
  | (a, b) :: es, i, h => by
    rw [List.findIdx?_cons] at h
    by_cases ha : a = k
    · simp only [ha, decide_true, ↓reduceIte, Option.some.injEq] at h
      subst h ha
      refine ⟨by simp, rfl, by simp [lookupL_cons], fun v' k' => ?_⟩
      simp only [List.set_cons_zero, lookupL_cons]
      by_cases h2 : a = k' <;> simp_all [eq_comm]
    · simp only [ha, decide_false, Bool.false_eq_true, ↓reduceIte] at h
      obtain ⟨j, hj, rfl⟩ : ∃ j, (es.findIdx? fun e => decide (e.1 = k)) = some j ∧ i = j + 1 := by
        cases hj : (es.findIdx? fun e => decide (e.1 = k)) <;> simp_all
      obtain ⟨hjl, hk, hl, hset⟩ := lookupL_findIdx k es j hj
      refine ⟨by simp; omega, by simpa using hk, by simpa [lookupL_cons, ha] using hl, fun v' k' => ?_⟩
      simp only [List.set_cons_succ, lookupL_cons, hset]
      by_cases h1 : a = k' <;> by_cases h2 : k' = k <;> simp_all

open Classical in
theorem lookupL_eq_none_of_findIdx {K V : Type} (k : K) :
    ∀ (es : List (K × V)), (es.findIdx? fun e => decide (e.1 = k)) = none → lookupL es k = none
  | [], _ => rfl
  | (a, b) :: es, h => by
    rw [List.findIdx?_cons] at h
    by_cases ha : a = k
    · simp [ha] at h
    · simp only [ha, decide_false, Bool.false_eq_true, ↓reduceIte] at h
      rw [lookupL_cons, if_neg ha]
      exact lookupL_eq_none_of_findIdx k es (by cases hj : (es.findIdx? fun e => decide (e.1 = k)) <;> simp_all)

/-! ## Further `lookupL` lemmas -/

open Classical in
/-- If the keys are nodup and `(k, v) ∈ es`, then `lookupL es k = some v`. -/
theorem lookupL_of_mem_nodup {K V : Type} : ∀ {es : List (K × V)} {k : K} {v : V},
    (es.map (·.1)).Nodup → (k, v) ∈ es → lookupL es k = some v
  | [], _, _, _, h => by simp at h
  | (k', v') :: es, k, v, hnd, h => by
    rw [lookupL_cons]
    rw [List.map_cons, List.nodup_cons] at hnd
    rcases List.mem_cons.mp h with h | h
    · simp only [Prod.mk.injEq] at h; obtain ⟨rfl, rfl⟩ := h; simp
    · have hne : k' ≠ k := fun e => hnd.1 (by rw [e]; exact List.mem_map_of_mem (f := (·.1)) h)
      rw [ite_eq_right hne]; exact lookupL_of_mem_nodup hnd.2 h

open Classical in
/-- `lookupL es k = some v` implies `(k, v) ∈ es`. -/
theorem lookupL_mem {K V : Type} : ∀ {es : List (K × V)} {k : K} {v : V},
    lookupL es k = some v → (k, v) ∈ es
  | [], _, _, h => by simp at h
  | (k', v') :: es, k, v, h => by
    rw [lookupL_cons] at h
    by_cases hk : k' = k
    · rw [ite_eq_left hk] at h; obtain rfl := Option.some.inj h; subst hk; simp
    · rw [ite_eq_right hk] at h; exact List.mem_cons_of_mem _ (lookupL_mem h)

open Classical in
/-- `lookupL es k` is some iff `k` appears as a key in `es`. -/
theorem lookupL_isSome_iff {K V : Type} (es : List (K × V)) (k : K) :
    (lookupL es k).isSome ↔ k ∈ es.map (·.1) := by
  induction es with
  | nil => simp
  | cons e es ih =>
    rw [lookupL_cons]
    by_cases h : e.1 = k
    · simp [h]
    · rw [ite_eq_right h, ih]
      simp only [List.map_cons, List.mem_cons]
      constructor
      · exact Or.inr
      · rintro (h' | h')
        · exact absurd h'.symm h
        · exact h'

/-! ## `List.filterMap` length/zip lemmas -/

/-- `filterMap f l` has the same length as `l` when `f x` is always `some`. -/
theorem length_filterMap_of_isSome {α β : Type} (f : α → Option β) :
    ∀ (l : List α), (∀ x ∈ l, (f x).isSome) → (l.filterMap f).length = l.length
  | [], _ => rfl
  | x :: l, h => by
    obtain ⟨y, hy⟩ := Option.isSome_iff_exists.mp (h x (by simp))
    simp [hy, length_filterMap_of_isSome f l fun z hz => h z (by simp [hz])]

/-- `zip (filterMap f l) m = filterMap (fun xe => (f xe.1).map (·, xe.2)) (zip l m)`
    when `f` is always `some` on `l`. -/
theorem zip_filterMap_of_isSome {α β γ : Type} (f : α → Option β) :
    ∀ (l : List α) (m : List γ), (∀ x ∈ l, (f x).isSome) →
      (l.filterMap f).zip m = (l.zip m).filterMap (fun xe => (f xe.1).map (·, xe.2))
  | [], _, _ => rfl
  | _ :: _, [], _ => by simp
  | x :: l, e :: m, h => by
    obtain ⟨y, hy⟩ := Option.isSome_iff_exists.mp (h x (by simp))
    simp [hy, zip_filterMap_of_isSome f l m fun z hz => h z (by simp [hz])]

/-! ## `List.mapState` with unit state -/

/-- `List.mapState g ()` equals `List.map (fun x => (g () x).1)`. -/
theorem mapState_unit {A B : Type} (g : Unit → A → B × Unit) :
    ∀ xs : List A, List.mapState g () xs = xs.map (fun x => (g () x).1)
  | [] => rfl
  | x :: xs => by simp [List.mapState, mapState_unit g xs]

/-! ## `HashMap`, keys compared by `Eq` -/

section HashMap
variable {K V : Type} (EqInst : core.cmp.Eq K)
  (hEq : ∀ a b, ∃ r, EqInst.partialEqInst.eq a b = ok r ∧ (r = true ↔ a = b))
include hEq

open Classical in
omit hEq in
theorem core.cmp.Eq.eq_ok_decide (hEq : ∀ a b, ∃ r, EqInst.partialEqInst.eq a b = ok r ∧ (r = true ↔ a = b))
    (a b : K) : EqInst.partialEqInst.eq a b = ok (decide (a = b)) := by
  obtain ⟨r, hr, hiff⟩ := hEq a b
  rw [hr]; cases r <;> simp_all

open Classical in
theorem std.collections.hash.map.HashMap.position_eq :
    ∀ (es : List (K × V)) (k : K), std.collections.hash.map.HashMap.position EqInst es k =
      ok (es.findIdx? fun e => decide (e.1 = k))
  | [], k => rfl
  | (k', v) :: es, k => by
    rw [std.collections.hash.map.HashMap.position]
    simp only [core.cmp.Eq.eq_ok_decide EqInst hEq, bind_tc_ok, std.collections.hash.map.HashMap.position_eq es k, List.findIdx?_cons]
    by_cases h : k' = k
    · simp [h]
    · simp only [h, decide_false, Bool.false_eq_true, ↓reduceIte]
      cases (es.findIdx? fun e => decide (e.1 = k)) <;> simp

theorem std.collections.hash.map.HashMap.lookup_eq :
    ∀ (es : List (K × V)) (q : K),
    std.collections.hash.map.HashMap.lookup (core.borrow.Borrow.Blanket K) EqInst es q =
      ok (lookupL es q)
  | [], q => rfl
  | (k, v) :: es, q => by
    classical
    rw [std.collections.hash.map.HashMap.lookup]
    simp only [core.borrow.Borrow.Blanket, core.borrow.Borrow.Blanket.borrow, bind_tc_ok, core.cmp.Eq.eq_ok_decide EqInst hEq,
      std.collections.hash.map.HashMap.lookup_eq es q, lookupL_cons]
    by_cases h : k = q <;> simp [h]

/-- `map.get(&k)`: the value at `k`. -/
theorem std.collections.hash.map.HashMap.get_eq {S A Hasher : Type} (hI : core.hash.Hash K)
    (bI : core.hash.BuildHasher S Hasher) (m : std.collections.hash.map.HashMap K V S A) (k : K) :
    std.collections.hash.map.HashMap.get EqInst hI bI (core.borrow.Borrow.Blanket K) hI EqInst m k =
      ok (lookupL m.entries k) :=
  std.collections.hash.map.HashMap.lookup_eq EqInst hEq m.entries k

open Classical in
/-- `map.entry(k)`: the entries, the key and its position; giving it back gives the map back. -/
theorem std.collections.hash.map.HashMap.entry_eq {S A Hasher : Type} (hI : core.hash.Hash K)
    (bI : core.hash.BuildHasher S Hasher) (m : std.collections.hash.map.HashMap K V S A) (k : K) :
    std.collections.hash.map.HashMap.entry EqInst hI bI m k =
      ok (⟨m.entries, k, m.entries.findIdx? fun e => decide (e.1 = k)⟩, fun e => { entries := e.entries }) := by
  simp [std.collections.hash.map.HashMap.entry, std.collections.hash.map.HashMap.position_eq EqInst hEq]

end HashMap

open Classical in
/-- `entry.or_insert(d)` on an entry `map.entry(k)` made: the value at `k`, else `d`; writing `v'`
through the result leaves `k` mapped to `v'` and every other key as it was. -/
theorem std.collections.hash.map.Entry.or_insert_spec {K V A : Type}
    (e : std.collections.hash.map.Entry K V A) (hpos : e.pos = e.entries.findIdx? fun x => decide (x.1 = e.key))
    (d : V) :
    std.collections.hash.map.Entry.or_insert e d ⦃ v back => v = (lookupL e.entries e.key).getD d ∧
      ∀ v' k', lookupL (back v').entries k' = if k' = e.key then some v' else lookupL e.entries k' ⦄ := by
  unfold std.collections.hash.map.Entry.or_insert
  rw [hpos]
  cases hf : (e.entries.findIdx? fun x => decide (x.1 = e.key)) with
  | none =>
    have hn := lookupL_eq_none_of_findIdx e.key e.entries hf
    simp only [List.getElem?_append_right (le_refl _), Nat.sub_self, List.getElem?_cons_zero,
      spec_ok, uncurry'_pair, hn, Option.getD_none, true_and]
    intro v' k'
    rw [List.set_append_right _ _ (le_refl _), Nat.sub_self, List.set_cons_zero]
    exact lookupL_append_fresh e.key v' e.entries hn k'
  | some i =>
    obtain ⟨hi, hk, hl, hset⟩ := lookupL_findIdx e.key e.entries i hf
    simp only [List.getElem?_eq_getElem hi, spec_ok, uncurry'_pair, hl, Option.getD_some, true_and]
    intro v' k'
    rw [show e.entries[i].1 = e.key from hk]
    exact hset v' k'

/-! ## `BTreeMap`, keys compared by `Ord` -/

section BTreeMap
variable {K V : Type} (OrdInst : core.cmp.Ord K)
  (hcmp : ∀ a b, ∃ o, OrdInst.cmp a b = ok o ∧ (o = .eq ↔ a = b))
include hcmp

open Classical in
/-- `position` finds the first entry with the key; `setVal` at it rewrites just that key. -/
theorem alloc.collections.btree.map.BTreeMap.position_spec :
    ∀ (es : List (K × V)) (k : K), alloc.collections.btree.map.BTreeMap.position OrdInst es k
      ⦃ r => match r with
        | none => lookupL es k = none
        | some (i, v) => lookupL es k = some v ∧ ∀ v' k',
            lookupL (alloc.collections.btree.map.BTreeMap.setVal es i v') k' =
              if k' = k then some v' else lookupL es k' ⦄
  | [], k => by simp [alloc.collections.btree.map.BTreeMap.position]
  | (k', v) :: es, k => by
    obtain ⟨o, ho, hiff⟩ := hcmp k k'
    rw [alloc.collections.btree.map.BTreeMap.position]
    simp only [ho, bind_tc_ok]
    by_cases h : k' = k
    · have : o = .eq := hiff.mpr h.symm
      subst this; subst h
      simp only [spec_ok, lookupL_cons, ↓reduceIte, true_and]
      intro v'' k''
      simp only [alloc.collections.btree.map.BTreeMap.setVal, lookupL_cons]
      by_cases h : k' = k''
      · subst h; simp
      · simp [h, Ne.symm h]
    · have hne : o ≠ .eq := fun h' => h (hiff.mp h').symm
      obtain ⟨r, hr, hpost⟩ := spec_eq_ok (alloc.collections.btree.map.BTreeMap.position_spec es k)
      cases o
      all_goals first
        | exact absurd rfl hne
        | (simp only [hr, bind_tc_ok]
           cases r with
           | none => simpa [lookupL_cons, h] using hpost
           | some p =>
             obtain ⟨i, w⟩ := p
             obtain ⟨hl, hset⟩ := hpost
             simp only [spec_ok]
             refine ⟨by simpa [lookupL_cons, h] using hl, fun v'' k'' => ?_⟩
             simp only [alloc.collections.btree.map.BTreeMap.setVal, lookupL_cons, hset]
             by_cases h2 : k' = k'' <;> by_cases h3 : k'' = k <;> simp_all)

open Classical in
/-- Inserting `(k, d)`: `k` maps to `d`, every other key as it was. -/
theorem alloc.collections.btree.map.BTreeMap.insertList_spec :
    ∀ (es : List (K × V)) (k : K) (d : V), alloc.collections.btree.map.BTreeMap.insertList OrdInst es k d
      ⦃ _ es' => ∀ k', lookupL es' k' = if k' = k then some d else lookupL es k' ⦄
  | [], k, d => by
    simp [alloc.collections.btree.map.BTreeMap.insertList, lookupL_cons, eq_comm]
  | (k', v) :: es, k, d => by
    obtain ⟨o, ho, hiff⟩ := hcmp k k'
    rw [alloc.collections.btree.map.BTreeMap.insertList]
    simp only [ho, bind_tc_ok]
    cases o with
    | lt =>
      have h : k ≠ k' := fun h => by simpa using hiff.mpr h
      simp only [spec_ok]; intro k''
      simp only [lookupL_cons]
      by_cases h2 : k'' = k
      · subst h2; simp
      · by_cases h3 : k' = k'' <;> simp_all [Ne.symm h2]
    | eq =>
      have h : k = k' := hiff.mp rfl
      subst h
      simp only [spec_ok]; intro k''
      simp only [lookupL_cons]
      by_cases h2 : k = k'' <;> simp_all [eq_comm]
    | gt =>
      have h : k ≠ k' := fun h => by simpa using hiff.mpr h
      obtain ⟨⟨old, es'⟩, hr, hpost⟩ := spec_eq_ok (alloc.collections.btree.map.BTreeMap.insertList_spec es k d)
      simp only [uncurry'_pair] at hpost
      simp only [hr, bind_tc_ok, spec_ok]; intro k''
      simp only [lookupL_cons, hpost]
      by_cases h2 : k' = k'' <;> by_cases h3 : k'' = k <;> simp_all

/-- `map.get(&k)`: the value at `k`. -/
theorem alloc.collections.btree.map.BTreeMap.get_eq {A : Type} (aI : core.alloc.AllocatorClone A)
    (m : alloc.collections.btree.map.BTreeMap K V A) (k : K) :
    alloc.collections.btree.map.BTreeMap.get aI (core.borrow.Borrow.Blanket K) OrdInst OrdInst m k =
      ok (lookupL m.entries k) := by
  unfold alloc.collections.btree.map.BTreeMap.get lookupL
  exact alloc.collections.btree.map.BTreeMap.lookup_eq OrdInst k (fun k' => by
    obtain ⟨o, ho, hiff⟩ := hcmp k k'
    exact ⟨o, ho, by rw [hiff]; exact eq_comm⟩) m.entries

open Classical in
/-- `map.entry(k).or_insert(d)`: the value at `k`, else `d`; writing `v'` through the result
leaves `k` mapped to `v'` and every other key as it was. -/
theorem alloc.collections.btree.map.entry.Entry.or_insert_spec {A : Type}
    (aI : core.alloc.AllocatorClone A) (e : alloc.collections.btree.map.entry.Entry K V A) (d : V) :
    alloc.collections.btree.map.entry.Entry.or_insert OrdInst aI e d ⦃ v back =>
      v = (lookupL e.map.entries e.key).getD d ∧ ∀ v' k',
        lookupL (back v').map.entries k' = if k' = e.key then some v' else lookupL e.map.entries k' ⦄ := by
  unfold alloc.collections.btree.map.entry.Entry.or_insert
  obtain ⟨r, hr, hpost⟩ := spec_eq_ok
    (alloc.collections.btree.map.BTreeMap.position_spec OrdInst hcmp e.map.entries e.key)
  cases r with
  | none =>
    obtain ⟨⟨old, es'⟩, hins, hl'⟩ := spec_eq_ok
      (alloc.collections.btree.map.BTreeMap.insertList_spec OrdInst hcmp e.map.entries e.key d)
    simp only [uncurry'_pair] at hl'
    obtain ⟨r', hr', hpost'⟩ := spec_eq_ok
      (alloc.collections.btree.map.BTreeMap.position_spec OrdInst hcmp es' e.key)
    cases r' with
    | none => simp [hl'] at hpost'
    | some p =>
      obtain ⟨i, w⟩ := p
      obtain ⟨hw, hset⟩ := hpost'
      simp only [hr, hins, hr', bind_tc_ok, spec_ok]
      refine ⟨?_, fun v' k' => ?_⟩
      · simp only [hl', ↓reduceIte, Option.some.injEq] at hw
        simp [hpost, hw]
      · rw [hset, hl']
        by_cases h : k' = e.key <;> simp [h]
  | some p =>
    obtain ⟨i, w⟩ := p
    obtain ⟨hw, hset⟩ := hpost
    simp only [hr, bind_tc_ok, spec_ok]
    exact ⟨by simp [hw], fun v' k' => hset v' k'⟩

end BTreeMap

end Aeneas.Std
