/- `BTreeMap` and `BTreeSet` as sorted lists -/
module
public import Aeneas.Std.Core.IterOverrides
public import Aeneas.Std.CoreMisc
public import Aeneas.Std.Alloc
public section

set_option linter.dupNamespace false

namespace Aeneas.Std

open Result

/-! Each collection is the list of its entries in ascending key order, which every operation
keeps. Lookups scan the list with the key's `Ord`; core searches the tree instead, which finds
the same entry for any lawful `Ord` (core leaves the result unspecified otherwise). The
allocator parameter `A` is kept for the types but unused. -/

@[rust_trait "core::alloc::AllocatorClone" (parentClauses := ["cloneCloneInst"])]
structure core.alloc.AllocatorClone (Self : Type) where
  cloneCloneInst : core.clone.Clone Self

@[reducible, rust_trait_impl "core::alloc::AllocatorClone<alloc::alloc::Global>"]
def alloc.alloc.Global.Insts.CoreAllocAllocatorClone : core.alloc.AllocatorClone Global where
  cloneCloneInst := { clone := alloc.alloc.CloneGlobal.clone }

@[rust_trait "core::borrow::Borrow"]
structure core.borrow.Borrow (Self : Type) (Borrowed : Type) where
  borrow : Self → Result Borrowed

@[reducible, rust_trait_impl "core::borrow::Borrow<@T, @T>"]
def core.borrow.Borrow.Blanket (T : Type) : core.borrow.Borrow T T where
  borrow := core.borrow.Borrow.Blanket.borrow

/-! ## `BTreeMap` -/

@[rust_type "alloc::collections::btree::map::BTreeMap" (body := .opaque)]
structure alloc.collections.btree.map.BTreeMap (K : Type u) (V : Type v) (A : Type w) where
  entries : List (K × V)

@[rust_fun
  "alloc::collections::btree::map::{alloc::collections::btree::map::BTreeMap<@K, @V, alloc::alloc::Global>}::new"]
def alloc.collections.btree.map.BTreeMapKVGlobal.new (K : Type) (V : Type) :
  Result (alloc.collections.btree.map.BTreeMap K V Global) :=
  ok { entries := [] }

/-- The value of the first entry whose key, borrowed as `Q`, equals `q` -/
def alloc.collections.btree.map.BTreeMap.lookup {K V Q : Type}
  (BorrowInst : core.borrow.Borrow K Q) (OrdQInst : core.cmp.Ord Q) :
  List (K × V) → Q → Result (Option V)
  | [], _ => ok none
  | (k, v) :: es, q => do
    match ← OrdQInst.cmp q (← BorrowInst.borrow k) with
    | .eq => ok (some v)
    | _ => alloc.collections.btree.map.BTreeMap.lookup BorrowInst OrdQInst es q

@[rust_fun
  "alloc::collections::btree::map::{alloc::collections::btree::map::BTreeMap<@K, @V, @A>}::get"]
def alloc.collections.btree.map.BTreeMap.get {K V A Q : Type}
  (_AllocInst : core.alloc.AllocatorClone A) (BorrowInst : core.borrow.Borrow K Q)
  (_OrdInst : core.cmp.Ord K) (OrdQInst : core.cmp.Ord Q)
  (m : alloc.collections.btree.map.BTreeMap K V A) (q : Q) : Result (Option V) :=
  alloc.collections.btree.map.BTreeMap.lookup BorrowInst OrdQInst m.entries q

/-- `map[&q]`: panics if absent -/
@[rust_fun
  "alloc::collections::btree::map::{core::ops::index::Index<alloc::collections::btree::map::BTreeMap<@K, @V, @A>, &'0 @Q, @V>}::index"]
def alloc.collections.btree.map.BTreeMap.Insts.CoreOpsIndexIndexShared0QV.index {K Q V A : Type}
  (_AllocInst : core.alloc.AllocatorClone A) (BorrowInst : core.borrow.Borrow K Q)
  (_OrdInst : core.cmp.Ord K) (OrdQInst : core.cmp.Ord Q)
  (m : alloc.collections.btree.map.BTreeMap K V A) (q : Q) : Result V := do
  match ← alloc.collections.btree.map.BTreeMap.lookup BorrowInst OrdQInst m.entries q with
  | some v => ok v
  | none => fail .panic

/-- Insert in order; an equal key keeps its old key and gets the new value, and the old value
is returned (`BTreeMap::insert`) -/
def alloc.collections.btree.map.BTreeMap.insertList {K V : Type} (OrdInst : core.cmp.Ord K) :
  List (K × V) → K → V → Result ((Option V) × List (K × V))
  | [], k, v => ok (none, [(k, v)])
  | (k', v') :: es, k, v => do
    match ← OrdInst.cmp k k' with
    | .lt => ok (none, (k, v) :: (k', v') :: es)
    | .eq => ok (some v', (k', v) :: es)
    | .gt =>
      let (old, es) ← alloc.collections.btree.map.BTreeMap.insertList OrdInst es k v
      ok (old, (k', v') :: es)

@[rust_fun
  "alloc::collections::btree::map::{alloc::collections::btree::map::BTreeMap<@K, @V, @A>}::insert"]
def alloc.collections.btree.map.BTreeMap.insert {K V A : Type}
  (_AllocInst : core.alloc.AllocatorClone A) (OrdInst : core.cmp.Ord K)
  (m : alloc.collections.btree.map.BTreeMap K V A) (k : K) (v : V) :
  Result ((Option V) × alloc.collections.btree.map.BTreeMap K V A) := do
  let (old, entries) ← alloc.collections.btree.map.BTreeMap.insertList OrdInst m.entries k v
  ok (old, { entries })

/-! ### `entry` -/

/-- The map and the key; core's `Vacant`/`Occupied` is whether the key is present -/
@[rust_type "alloc::collections::btree::map::entry::Entry" (mutRegions := #[0]) (body := .opaque)]
structure alloc.collections.btree.map.entry.Entry (K : Type u) (V : Type v) (A : Type w) where
  map : alloc.collections.btree.map.BTreeMap K V A
  key : K

/-- Core's payloads of `Entry`; `Entry` here does without them -/
@[rust_type "alloc::collections::btree::map::entry::OccupiedEntry" (mutRegions := #[0]) (body := .opaque)]
structure alloc.collections.btree.map.entry.OccupiedEntry (K : Type u) (V : Type v) (A : Type w) where
  entry : alloc.collections.btree.map.entry.Entry K V A

@[rust_type "alloc::collections::btree::map::entry::VacantEntry" (mutRegions := #[0]) (body := .opaque)]
structure alloc.collections.btree.map.entry.VacantEntry (K : Type u) (V : Type v) (A : Type w) where
  entry : alloc.collections.btree.map.entry.Entry K V A

/-- The entry, and giving it back gives back the map -/
@[rust_fun
  "alloc::collections::btree::map::{alloc::collections::btree::map::BTreeMap<@K, @V, @A>}::entry"]
def alloc.collections.btree.map.BTreeMap.entry {K V A : Type}
  (_AllocInst : core.alloc.AllocatorClone A) (_OrdInst : core.cmp.Ord K)
  (m : alloc.collections.btree.map.BTreeMap K V A) (key : K) :
  Result ((alloc.collections.btree.map.entry.Entry K V A) ×
    (alloc.collections.btree.map.entry.Entry K V A → alloc.collections.btree.map.BTreeMap K V A)) :=
  ok ({ map := m, key }, fun e => e.map)

/-- The position and value of the first entry whose key equals `k` -/
def alloc.collections.btree.map.BTreeMap.position {K V : Type} (OrdInst : core.cmp.Ord K) :
  List (K × V) → K → Result (Option (Nat × V))
  | [], _ => ok none
  | (k', v) :: es, k => do
    match ← OrdInst.cmp k k' with
    | .eq => ok (some (0, v))
    | _ => do
      match ← alloc.collections.btree.map.BTreeMap.position OrdInst es k with
      | some (i, v) => ok (some (i + 1, v))
      | none => ok none

/-- The entries with the value at position `i` replaced -/
def alloc.collections.btree.map.BTreeMap.setVal {K V : Type} : List (K × V) → Nat → V → List (K × V)
  | [], _, _ => []
  | (k, _) :: es, 0, v => (k, v) :: es
  | e :: es, i + 1, v => e :: alloc.collections.btree.map.BTreeMap.setVal es i v

/-- The value at the key, inserting `default` if absent; writing through the returned `&mut V`
replaces that entry's value -/
@[rust_fun
  "alloc::collections::btree::map::entry::{alloc::collections::btree::map::entry::Entry<'a, @K, @V, @A>}::or_insert"]
def alloc.collections.btree.map.entry.Entry.or_insert {K V A : Type}
  (OrdInst : core.cmp.Ord K) (_AllocInst : core.alloc.AllocatorClone A)
  (e : alloc.collections.btree.map.entry.Entry K V A) (default : V) :
  Result (V × (V → alloc.collections.btree.map.entry.Entry K V A)) := do
  let entries ← match ← alloc.collections.btree.map.BTreeMap.position OrdInst e.map.entries e.key with
    | some _ => ok e.map.entries
    | none => do
      let (_, entries) ← alloc.collections.btree.map.BTreeMap.insertList OrdInst e.map.entries e.key default
      ok entries
  match ← alloc.collections.btree.map.BTreeMap.position OrdInst entries e.key with
  | some (i, v) =>
    ok (v, fun v' => { e with map := { entries := alloc.collections.btree.map.BTreeMap.setVal entries i v' } })
  | none => fail .panic -- unreachable: the key was just found or inserted

/-! ### Iteration, ascending by key -/

@[rust_type "alloc::collections::btree::map::Iter" (body := .opaque)]
structure alloc.collections.btree.map.Iter (K : Type u) (V : Type v) where
  items : List (K × V)

@[rust_fun
  "alloc::collections::btree::map::{alloc::collections::btree::map::BTreeMap<@K, @V, @A>}::iter"]
def alloc.collections.btree.map.BTreeMap.iter {K V A : Type}
  (_AllocInst : core.alloc.AllocatorClone A) (m : alloc.collections.btree.map.BTreeMap K V A) :
  Result (alloc.collections.btree.map.Iter K V) :=
  ok { items := m.entries }

@[rust_fun
  "alloc::collections::btree::map::{core::iter::traits::iterator::Iterator<alloc::collections::btree::map::Iter<'a, @K, @V>, (&'a @K, &'a @V)>}::next"]
def alloc.collections.btree.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV.next
  {K V : Type} (it : alloc.collections.btree.map.Iter K V) :
  Result ((Option (K × V)) × alloc.collections.btree.map.Iter K V) :=
  match it.items with
  | [] => ok (none, it)
  | x :: items => ok (some x, { items })

/-- Exact -/
@[rust_fun
  "alloc::collections::btree::map::{core::iter::traits::iterator::Iterator<alloc::collections::btree::map::Iter<'a, @K, @V>, (&'a @K, &'a @V)>}::size_hint"]
def alloc.collections.btree.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV.size_hint
  {K V : Type} (it : alloc.collections.btree.map.Iter K V) : Result (Usize × Option Usize) := do
  let n ← UScalar.tryMk .Usize it.items.length
  ok (n, some n)

/-- `self.next_back()`: the entry with the greatest key -/
@[rust_fun
  "alloc::collections::btree::map::{core::iter::traits::iterator::Iterator<alloc::collections::btree::map::Iter<'a, @K, @V>, (&'a @K, &'a @V)>}::max"]
def alloc.collections.btree.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV.max
  {K V : Type} (_OrdInst : core.cmp.Ord (K × V)) (it : alloc.collections.btree.map.Iter K V) :
  Result (Option (K × V)) :=
  ok it.items.getLast?

@[reducible, rust_trait_impl
  "core::iter::traits::iterator::Iterator<alloc::collections::btree::map::Iter<'a, @K, @V>, (&'a @K, &'a @V)>"]
def alloc.collections.btree.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV
  (K : Type) (V : Type) :
  core.iter.traits.iterator.Iterator (alloc.collections.btree.map.Iter K V) (K × V) where
  next := alloc.collections.btree.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV.next
  size_hint :=
    alloc.collections.btree.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV.size_hint

@[rust_type "alloc::collections::btree::map::IntoIter" (body := .opaque)]
structure alloc.collections.btree.map.IntoIter (K : Type u) (V : Type v) (A : Type w) where
  items : List (K × V)

@[rust_fun
  "alloc::collections::btree::map::{core::iter::traits::collect::IntoIterator<alloc::collections::btree::map::BTreeMap<@K, @V, @A>, (@K, @V), alloc::collections::btree::map::IntoIter<@K, @V, @A>>}::into_iter"]
def alloc.collections.btree.map.BTreeMap.Insts.CoreIterTraitsCollectIntoIteratorPairIntoIter.into_iter
  {K V A : Type} (_AllocInst : core.alloc.AllocatorClone A)
  (m : alloc.collections.btree.map.BTreeMap K V A) : Result (alloc.collections.btree.map.IntoIter K V A) :=
  ok { items := m.entries }

@[rust_fun
  "alloc::collections::btree::map::{core::iter::traits::iterator::Iterator<alloc::collections::btree::map::IntoIter<@K, @V, @A>, (@K, @V)>}::next"]
def alloc.collections.btree.map.IntoIter.Insts.CoreIterTraitsIteratorIteratorPair.next
  {K V A : Type} (_AllocInst : core.alloc.AllocatorClone A)
  (it : alloc.collections.btree.map.IntoIter K V A) :
  Result ((Option (K × V)) × alloc.collections.btree.map.IntoIter K V A) :=
  match it.items with
  | [] => ok (none, it)
  | x :: items => ok (some x, { items })

/-- Exact -/
@[rust_fun
  "alloc::collections::btree::map::{core::iter::traits::iterator::Iterator<alloc::collections::btree::map::IntoIter<@K, @V, @A>, (@K, @V)>}::size_hint"]
def alloc.collections.btree.map.IntoIter.Insts.CoreIterTraitsIteratorIteratorPair.size_hint
  {K V A : Type} (_AllocInst : core.alloc.AllocatorClone A)
  (it : alloc.collections.btree.map.IntoIter K V A) : Result (Usize × Option Usize) := do
  let n ← UScalar.tryMk .Usize it.items.length
  ok (n, some n)

@[reducible, rust_trait_impl
  "core::iter::traits::iterator::Iterator<alloc::collections::btree::map::IntoIter<@K, @V, @A>, (@K, @V)>"]
def alloc.collections.btree.map.IntoIter.Insts.CoreIterTraitsIteratorIteratorPair {K V A : Type}
  (AllocInst : core.alloc.AllocatorClone A) :
  core.iter.traits.iterator.Iterator (alloc.collections.btree.map.IntoIter K V A) (K × V) where
  next := alloc.collections.btree.map.IntoIter.Insts.CoreIterTraitsIteratorIteratorPair.next AllocInst
  size_hint :=
    alloc.collections.btree.map.IntoIter.Insts.CoreIterTraitsIteratorIteratorPair.size_hint AllocInst

@[reducible, rust_trait_impl
  "core::iter::traits::collect::IntoIterator<alloc::collections::btree::map::BTreeMap<@K, @V, @A>, (@K, @V), alloc::collections::btree::map::IntoIter<@K, @V, @A>>"]
def alloc.collections.btree.map.BTreeMap.Insts.CoreIterTraitsCollectIntoIteratorPairIntoIter
  {K V A : Type} (AllocInst : core.alloc.AllocatorClone A) :
  core.iter.traits.collect.IntoIterator (alloc.collections.btree.map.BTreeMap K V A) (K × V)
    (alloc.collections.btree.map.IntoIter K V A) where
  iteratorInst := alloc.collections.btree.map.IntoIter.Insts.CoreIterTraitsIteratorIteratorPair AllocInst
  into_iter :=
    alloc.collections.btree.map.BTreeMap.Insts.CoreIterTraitsCollectIntoIteratorPairIntoIter.into_iter
      AllocInst

/-! ### `collect` -/

/-- A stable insertion sort by `cmp` on `key` (core sorts the input with a stable sort) -/
def alloc.collections.btree.sortBy {T K : Type} (OrdInst : core.cmp.Ord K) (key : T → K) :
  List T → Result (List T)
  | [] => ok []
  | x :: xs => do
    let sorted ← alloc.collections.btree.sortBy OrdInst key xs
    -- `x` came first, so it goes before every equal element
    let rec ins : List T → Result (List T)
      | [] => ok [x]
      | y :: ys => do
        match ← OrdInst.cmp (key x) (key y) with
        | .gt => ok (y :: (← ins ys))
        | _ => ok (x :: y :: ys)
    ins sorted

/-- Of each run of equal keys, the last (core's `DedupSortedIter`) -/
def alloc.collections.btree.dedupLast {T K : Type} (OrdInst : core.cmp.Ord K) (key : T → K) :
  List T → Result (List T)
  | [] => ok []
  | [x] => ok [x]
  | x :: y :: ys => do
    match ← OrdInst.cmp (key x) (key y) with
    | .eq => alloc.collections.btree.dedupLast OrdInst key (y :: ys)
    | _ => ok (x :: (← alloc.collections.btree.dedupLast OrdInst key (y :: ys)))

/-- Every item, in order -/
def alloc.collections.btree.toList {I T : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I T) (it : I) : Result (List T) := do
  let rev ← loop (fun ((it, acc) : I × List T) => do
    let (o, it) ← IteratorInst.next it
    match o with
    | none => ok (.done acc)
    | some x => ok (.cont (it, x :: acc))) (it, [])
  ok rev.reverse

/-- Sort the pairs stably by key, then keep the last of equal keys -/
@[rust_fun
  "alloc::collections::btree::map::{core::iter::traits::collect::FromIterator<alloc::collections::btree::map::BTreeMap<@K, @V, alloc::alloc::Global>, (@K, @V)>}::from_iter"]
def alloc.collections.btree.map.BTreeMapKVGlobal.Insts.CoreIterTraitsCollectFromIteratorPair.from_iter
  {K V I IntoIter : Type} (OrdInst : core.cmp.Ord K)
  (IntoIteratorInst : core.iter.traits.collect.IntoIterator I (K × V) IntoIter) (input : I) :
  Result (alloc.collections.btree.map.BTreeMap K V Global) := do
  let items ← alloc.collections.btree.toList IntoIteratorInst.iteratorInst
    (← IntoIteratorInst.into_iter input)
  let items ← alloc.collections.btree.sortBy OrdInst Prod.fst items
  ok { entries := ← alloc.collections.btree.dedupLast OrdInst Prod.fst items }

@[reducible, rust_trait_impl
  "core::iter::traits::collect::FromIterator<alloc::collections::btree::map::BTreeMap<@K, @V, alloc::alloc::Global>, (@K, @V)>"]
def alloc.collections.btree.map.BTreeMapKVGlobal.Insts.CoreIterTraitsCollectFromIteratorPair
  {K : Type} (V : Type) (OrdInst : core.cmp.Ord K) :
  core.iter.traits.collect.FromIterator (alloc.collections.btree.map.BTreeMap K V Global) (K × V) where
  from_iter := fun IntoIteratorInst =>
    alloc.collections.btree.map.BTreeMapKVGlobal.Insts.CoreIterTraitsCollectFromIteratorPair.from_iter
      OrdInst IntoIteratorInst

/-! ## `BTreeSet` -/

@[rust_type "alloc::collections::btree::set::BTreeSet" (body := .opaque)]
structure alloc.collections.btree.set.BTreeSet (T : Type u) (A : Type v) where
  items : List T

@[rust_type "alloc::collections::btree::set::IntoIter" (body := .opaque)]
structure alloc.collections.btree.set.IntoIter (T : Type u) (A : Type v) where
  items : List T

/-- Sort stably, then keep the last of equal items -/
@[rust_fun
  "alloc::collections::btree::set::{core::iter::traits::collect::FromIterator<alloc::collections::btree::set::BTreeSet<@T, alloc::alloc::Global>, @T>}::from_iter"]
def alloc.collections.btree.set.BTreeSetTGlobal.Insts.CoreIterTraitsCollectFromIterator.from_iter
  {T I IntoIter : Type} (OrdInst : core.cmp.Ord T)
  (IntoIteratorInst : core.iter.traits.collect.IntoIterator I T IntoIter) (input : I) :
  Result (alloc.collections.btree.set.BTreeSet T Global) := do
  let items ← alloc.collections.btree.toList IntoIteratorInst.iteratorInst
    (← IntoIteratorInst.into_iter input)
  let items ← alloc.collections.btree.sortBy OrdInst id items
  ok { items := ← alloc.collections.btree.dedupLast OrdInst id items }

@[reducible, rust_trait_impl
  "core::iter::traits::collect::FromIterator<alloc::collections::btree::set::BTreeSet<@T, alloc::alloc::Global>, @T>"]
def alloc.collections.btree.set.BTreeSetTGlobal.Insts.CoreIterTraitsCollectFromIterator
  {T : Type} (OrdInst : core.cmp.Ord T) :
  core.iter.traits.collect.FromIterator (alloc.collections.btree.set.BTreeSet T Global) T where
  from_iter := fun IntoIteratorInst =>
    alloc.collections.btree.set.BTreeSetTGlobal.Insts.CoreIterTraitsCollectFromIterator.from_iter
      OrdInst IntoIteratorInst

@[rust_fun
  "alloc::collections::btree::set::{core::iter::traits::collect::IntoIterator<alloc::collections::btree::set::BTreeSet<@T, @A>, @T, alloc::collections::btree::set::IntoIter<@T, @A>>}::into_iter"]
def alloc.collections.btree.set.BTreeSet.Insts.CoreIterTraitsCollectIntoIteratorTIntoIter.into_iter
  {T A : Type} (_AllocInst : core.alloc.AllocatorClone A)
  (s : alloc.collections.btree.set.BTreeSet T A) : Result (alloc.collections.btree.set.IntoIter T A) :=
  ok { items := s.items }

@[rust_fun
  "alloc::collections::btree::set::{core::iter::traits::iterator::Iterator<alloc::collections::btree::set::IntoIter<@T, @A>, @T>}::next"]
def alloc.collections.btree.set.IntoIter.Insts.CoreIterTraitsIteratorIterator.next {T A : Type}
  (_AllocInst : core.alloc.AllocatorClone A) (it : alloc.collections.btree.set.IntoIter T A) :
  Result ((Option T) × alloc.collections.btree.set.IntoIter T A) :=
  match it.items with
  | [] => ok (none, it)
  | x :: items => ok (some x, { items })

/-- Exact -/
@[rust_fun
  "alloc::collections::btree::set::{core::iter::traits::iterator::Iterator<alloc::collections::btree::set::IntoIter<@T, @A>, @T>}::size_hint"]
def alloc.collections.btree.set.IntoIter.Insts.CoreIterTraitsIteratorIterator.size_hint {T A : Type}
  (_AllocInst : core.alloc.AllocatorClone A) (it : alloc.collections.btree.set.IntoIter T A) :
  Result (Usize × Option Usize) := do
  let n ← UScalar.tryMk .Usize it.items.length
  ok (n, some n)

@[reducible, rust_trait_impl
  "core::iter::traits::iterator::Iterator<alloc::collections::btree::set::IntoIter<@T, @A>, @T>"]
def alloc.collections.btree.set.IntoIter.Insts.CoreIterTraitsIteratorIterator {T A : Type}
  (AllocInst : core.alloc.AllocatorClone A) :
  core.iter.traits.iterator.Iterator (alloc.collections.btree.set.IntoIter T A) T where
  next := alloc.collections.btree.set.IntoIter.Insts.CoreIterTraitsIteratorIterator.next AllocInst
  size_hint := alloc.collections.btree.set.IntoIter.Insts.CoreIterTraitsIteratorIterator.size_hint AllocInst

@[reducible, rust_trait_impl
  "core::iter::traits::collect::IntoIterator<alloc::collections::btree::set::BTreeSet<@T, @A>, @T, alloc::collections::btree::set::IntoIter<@T, @A>>"]
def alloc.collections.btree.set.BTreeSet.Insts.CoreIterTraitsCollectIntoIteratorTIntoIter {T A : Type}
  (AllocInst : core.alloc.AllocatorClone A) :
  core.iter.traits.collect.IntoIterator (alloc.collections.btree.set.BTreeSet T A) T
    (alloc.collections.btree.set.IntoIter T A) where
  iteratorInst := alloc.collections.btree.set.IntoIter.Insts.CoreIterTraitsIteratorIterator AllocInst
  into_iter :=
    alloc.collections.btree.set.BTreeSet.Insts.CoreIterTraitsCollectIntoIteratorTIntoIter.into_iter
      AllocInst

end Aeneas.Std
