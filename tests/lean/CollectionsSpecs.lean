/- Hand-written: the `Aeneas.Std.CollectionsSpecs` lemmas composed as Rust uses them. -/
import Aeneas
open Aeneas Aeneas.Std Result WP

open Classical in
example : lookupL [(1, "a"), (2, "b"), (2, "c")] 2 = some "b" := by simp [lookupL_cons]

open Classical in
-- `*map.entry(k).or_insert(d) = f(..)` then `map.get(&k)`: `f` of the old value, else of `d`
example {K V A : Type} (OrdInst : core.cmp.Ord K)
    (hcmp : ∀ a b, ∃ o, OrdInst.cmp a b = ok o ∧ (o = .eq ↔ a = b))
    (aI : core.alloc.AllocatorClone A) (m : alloc.collections.btree.map.BTreeMap K V A)
    (k : K) (d : V) (f : V → V) :
    (do
      let e ← alloc.collections.btree.map.BTreeMap.entry aI OrdInst m k
      let v ← alloc.collections.btree.map.entry.Entry.or_insert OrdInst aI e.1 d
      alloc.collections.btree.map.BTreeMap.get aI (core.borrow.Borrow.Blanket K) OrdInst OrdInst
        (e.2 (v.2 (f v.1))) k) = ok (some (f ((lookupL m.entries k).getD d))) := by
  obtain ⟨⟨v, backE⟩, h, hv, hset⟩ := spec_eq_ok
    (alloc.collections.btree.map.entry.Entry.or_insert_spec OrdInst hcmp aI ⟨m, k⟩ d)
  simp only [alloc.collections.btree.map.BTreeMap.entry, Std.bind_ok, h,
    alloc.collections.btree.map.BTreeMap.get_eq OrdInst hcmp, hset, ↓reduceIte, hv]

open Classical in
-- The same through `HashMap`, keys compared by a lawful `Eq`
example {K V S A Hasher : Type} (EqInst : core.cmp.Eq K)
    (hEq : ∀ a b, ∃ r, EqInst.partialEqInst.eq a b = ok r ∧ (r = true ↔ a = b))
    (hI : core.hash.Hash K) (bI : core.hash.BuildHasher S Hasher)
    (m : std.collections.hash.map.HashMap K V S A) (k : K) (d : V) (f : V → V) :
    (do
      let e ← std.collections.hash.map.HashMap.entry EqInst hI bI m k
      let v ← std.collections.hash.map.Entry.or_insert e.1 d
      std.collections.hash.map.HashMap.get EqInst hI bI (core.borrow.Borrow.Blanket K) hI EqInst
        (e.2 (v.2 (f v.1))) k) = ok (some (f ((lookupL m.entries k).getD d))) := by
  obtain ⟨⟨v, backE⟩, h, hv, hset⟩ := spec_eq_ok
    (std.collections.hash.map.Entry.or_insert_spec (A := A) ⟨m.entries, k, m.entries.findIdx? fun x => decide (x.1 = k)⟩ rfl d)
  simp only [std.collections.hash.map.HashMap.entry_eq EqInst hEq, Std.bind_ok, h,
    std.collections.hash.map.HashMap.get_eq EqInst hEq, hset, ↓reduceIte, hv]

-- `v.clone()` with an identity element clone returns `v`
example {T : Type} (c : core.clone.Clone T) (hc : ∀ x, c.clone x = ok x) (v : alloc.vec.Vec T) :
    alloc.vec.CloneVec.clone c v = ok v :=
  alloc.vec.CloneVec.clone_eq_of_forall c v (fun x _ => hc x)

-- an element of a `ListN` is smaller than it (nested recursion through `Vec`)
example (l : Data.ListN.ListN ℕ 2) (x : ℕ) (hx : x ∈ l.toList) : sizeOf x < sizeOf l :=
  l.sizeOf_lt_of_mem hx
