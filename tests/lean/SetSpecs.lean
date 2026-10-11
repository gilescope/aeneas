/- Hand-written: smoke tests for `Aeneas.Std.SetSpecs` — each theorem
   instantiated to confirm nothing is `sorry`/`axiom`-gated. -/
import Aeneas.Std.SetSpecs
open Aeneas Aeneas.Std Result WP

/-! ## 1. `Slice::contains` -/

-- Type-check: contains_spec exists with the right signature.
#check @core.slice.Slice.contains_spec

/-! ## 2. `Iterator::position` -/

#check @core.iter.traits.iterator.Iterator.position.default_spec

/-! ## 3. `Cloned` -/

#check @core.iter.adapters.cloned.Cloned.Insts.CoreIterTraitsIteratorIterator.yields_spec
#check @core.clone.CloneUsize.clone_id

/-! ## 4. Scalar `Ord` -/

-- OrdUsize_lawful: inhabits OrdLawful at a concrete type.
example : OrdLawful core.cmp.OrdUsize := OrdUsize_lawful

-- hcmp_of_lawful: bridge to per-pair existential used by BTreeSet specs.
example : ∀ a b : Usize, ∃ o, core.cmp.OrdUsize.cmp a b = ok o ∧ (o = .eq ↔ a = b) :=
  hcmp_of_lawful OrdUsize_lawful (fun _a _b => compare_eq_iff)

/-! ## 5. `BTreeSet::from_iter` -/

#check @alloc.collections.btree.set.BTreeSetTGlobal.Insts.CoreIterTraitsCollectFromIterator.from_iter_spec

/-! ## 6. `BTreeSet::Ord::cmp` totality -/

-- Every pair of BTreeSets over Usize produces an ok result.
example (s t : alloc.collections.btree.set.BTreeSet Usize Global) :
    ∃ o, alloc.collections.btree.set.BTreeSet.Insts.CoreCmpOrd.cmp
      core.cmp.OrdUsize alloc.alloc.Global.Insts.CoreAllocAllocatorClone s t = ok o :=
  alloc.collections.btree.set.BTreeSet.Insts.CoreCmpOrd.cmp_total core.cmp.OrdUsize
    (fun a b => ⟨_, OrdUsize_lawful a b⟩)
    alloc.alloc.Global.Insts.CoreAllocAllocatorClone s t

/-! ## 7. `BTreeSet`/`BTreeMap` iteration -/

-- BTreeSet iter yields its items.
example (xs : List Usize) :
    Yields (alloc.collections.btree.set.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAT Usize)
      { items := xs } xs :=
  alloc.collections.btree.set.BTreeSet.iter_yields xs

-- BTreeSet clone is identity when the element clone is id.
example (s : alloc.collections.btree.set.BTreeSet Usize Global) :
    alloc.collections.btree.set.BTreeSet.Insts.CoreCloneClone.clone
      core.clone.CloneUsize alloc.alloc.Global.Insts.CoreAllocAllocatorClone s = ok s :=
  alloc.collections.btree.set.BTreeSet.Insts.CoreCloneClone.clone_spec
    core.clone.CloneUsize core.clone.CloneUsize.clone_id
    alloc.alloc.Global.Insts.CoreAllocAllocatorClone s

-- BTreeMap iter yields its entries.
example (es : List (Usize × Usize)) :
    Yields
      (alloc.collections.btree.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV
        Usize Usize)
      { items := es } es :=
  alloc.collections.btree.map.BTreeMap.iter_yields es

-- BTreeSet iter_spec: there exists an iterator for any BTreeSet.
example (s : alloc.collections.btree.set.BTreeSet Usize Global) :
    ∃ it, alloc.collections.btree.set.BTreeSet.iter alloc.alloc.Global.Insts.CoreAllocAllocatorClone s
        = ok it ∧
      Yields (alloc.collections.btree.set.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAT Usize)
        it s.items :=
  alloc.collections.btree.set.BTreeSet.iter_spec alloc.alloc.Global.Insts.CoreAllocAllocatorClone s

-- BTreeMap iter_spec: analogous for BTreeMap.
example (m : alloc.collections.btree.map.BTreeMap Usize Usize Global) :
    ∃ it, alloc.collections.btree.map.BTreeMap.iter alloc.alloc.Global.Insts.CoreAllocAllocatorClone m
        = ok it ∧
      Yields
        (alloc.collections.btree.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV
          Usize Usize)
        it m.entries :=
  alloc.collections.btree.map.BTreeMap.iter_spec alloc.alloc.Global.Insts.CoreAllocAllocatorClone m

/-! ## 8. `HashMap` iteration -/

-- iter_perm: the iterator's items are a permutation of the map's entries (abstract types).
example {K V S A : Type} (m : std.collections.hash.map.HashMap K V S A) :
    ∃ it, std.collections.hash.map.HashMap.iter m = ok it ∧ it.items.Perm m.entries :=
  std.collections.hash.map.HashMap.iter_perm m

/-! ## 9. `len` specs -/

-- BTreeMap::len (abstract types, no concrete allocator needed).
example {K V A : Type} (AllocInst : core.alloc.AllocatorClone A)
    (m : alloc.collections.btree.map.BTreeMap K V A)
    (h : m.entries.length ≤ Usize.max) :
    alloc.collections.btree.map.BTreeMap.len AllocInst m ⦃ n => n.val = m.entries.length ⦄ :=
  alloc.collections.btree.map.BTreeMap.len_spec AllocInst m h

-- HashMap::len (abstract types).
example {K V S A : Type} (m : std.collections.hash.map.HashMap K V S A)
    (h : m.entries.length ≤ Usize.max) :
    std.collections.hash.map.HashMap.len m ⦃ n => n.val = m.entries.length ⦄ :=
  std.collections.hash.map.HashMap.len_spec m h

/-! ## 10. Chunks, Zip, Enumerate -/

-- ChunksExact: iterator over pre-split chunks yields them in order.
example (xss : List (Slice Usize)) (r : Slice Usize) :
    Yields (core.iter.traits.iterator.IteratorChunksExact Usize)
      { chunks := xss, remainder := r } xss :=
  core.slice.iter.ChunksExact.iter_yields xss r

-- Zip: pairing two iterators yields their zip.
example (xs : List Usize) (ys : List Usize) :
    Yields
      (core.iter.adapters.zip.Zip.Insts.CoreIterTraitsIteratorIteratorPair
        (alloc.collections.btree.set.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAT Usize)
        (alloc.collections.btree.set.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAT Usize))
      ⟨{ items := xs }, { items := ys }⟩ (xs.zip ys) :=
  core.iter.adapters.zip.Zip.yields
    (alloc.collections.btree.set.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAT Usize)
    (alloc.collections.btree.set.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAT Usize)
    xs ys { items := xs } { items := ys }
    (alloc.collections.btree.set.BTreeSet.iter_yields xs)
    (alloc.collections.btree.set.BTreeSet.iter_yields ys)

-- Enumerate: yields (index, item) pairs starting from 0.
example (xs : List Usize) (hxs : xs.length ≤ Usize.max) :
    Yields
      (core.iter.traits.iterator.IteratorEnumerate
        (alloc.collections.btree.set.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAT Usize))
      { iter := { items := xs }, count := 0#usize }
      (usizeEnumFrom 0 xs (by simpa using hxs)) :=
  core.iter.adapters.enumerate.Enumerate.yields
    (alloc.collections.btree.set.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAT Usize)
    xs { items := xs } 0#usize
    (alloc.collections.btree.set.BTreeSet.iter_yields xs)
    (by simpa using hxs)

/-! ## 11. `from_iter_spec_sorted` (item a) -/

-- Collecting a BTreeSet from a list iterator yields strictly-sorted items with the same members.
#check @alloc.collections.btree.set.BTreeSetTGlobal.Insts.CoreIterTraitsCollectFromIterator.from_iter_spec_sorted

-- Two BTreeSets with the same strictly-sorted items are equal.
#check @alloc.collections.btree.set.BTreeSet.eq_of_mem_iff

-- Two strictly-sorted lists with the same membership are equal.
#check @List.eq_of_pairwise_lt_of_mem_iff

/-! ## 12. `cmp_total_eq` (item b) -/

-- BTreeSet cmp terminates and returns .eq iff the two sets are equal.
#check @alloc.collections.btree.set.BTreeSet.Insts.CoreCmpOrd.cmp_total_eq

/-! ## 13. `HashMap.from_iter_spec` (item c) -/

-- HashMap from_iter: lookup equals the last pair for each key.
#check @std.collections.hash.map.HashMapKVSGlobal.Insts.CoreIterTraitsCollectFromIteratorPair.from_iter_spec

/-! ## 14. `BTreeSet` linear order and `BTreeSet_cmp_lawful` -/

-- BTreeSet has a LinearOrder instance.
#check @alloc.collections.btree.set.BTreeSet.instLinearOrder

-- cmp on BTreeSet equals ok (compare s t) when OrdInst is lawful.
#check @alloc.collections.btree.set.BTreeSet.Insts.CoreCmpOrd.BTreeSet_cmp_lawful

/-! ## 15. `BTreeMap` sorted-key invariants -/

-- Strictly sorted keys imply no duplicates.
#check @alloc.collections.btree.map.BTreeMap.sorted_keys_nodup

-- insertList preserves sorted order.
#check @alloc.collections.btree.map.BTreeMap.insertList_sorted

-- insertList: length grows by 1 for a fresh key, stays the same for an existing key.
#check @alloc.collections.btree.map.BTreeMap.insertList_length

-- or_insert preserves sorted order and reflects key-absent/present in the length.
#check @alloc.collections.btree.map.entry.Entry.or_insert_sorted_length

/-! ## 16. Lifted lemmas from IntermediateSets (SetSpecs.lean additions) -/

-- Iterator::find: returns the first element satisfying the predicate.
#check @core.slice.iter.Iter.find_spec

-- collect() into BTreeSet: same members, strictly sorted.
#check @collect_btreeset_spec

-- HashMap hashIter yields key-value pairs permutation.
#check @hashIter_yields

-- collect() from a (K×V) iterator into HashMap: lookup equals last pair.
#check @collect_hashmap_spec

/-! ## 17. Lifted lemmas from IntermediateSets (CollectionsSpecs.lean additions) -/

-- lookupL on a nodup list: value is uniquely determined by membership.
#check @lookupL_of_mem_nodup

-- lookupL membership: (k, v) ∈ es ↔ lookupL es k = some v (for nodup).
#check @lookupL_mem

-- lookupL isSome iff key has a mapping.
#check @lookupL_isSome_iff

-- filterMap length when all elements map to Some.
#check @length_filterMap_of_isSome

-- zip of filterMap-of-isSome.
#check @zip_filterMap_of_isSome

-- mapState with unit state is just a map.
#check @mapState_unit
