/- More of `HashMap`, `HashSet`, `BTreeMap` and `BTreeSet` -/
module
public import Aeneas.Std.HashMap
public import Aeneas.Std.VecExtra
public section

set_option linter.dupNamespace false

namespace Aeneas.Std

open Result

/-! ## `HashMap`

Iteration visits the entries in std's order, which depends on the random hasher keys: the model
is an unknown permutation of the entries (`hashOrder`), so proofs may use that every entry is
visited once, but no particular order. -/

/-- The order a `HashMap` (or `HashSet`) iterates in: some permutation, unknown -/
opaque std.collections.hash.hashOrder {α : Type} : (l : List α) → {l' : List α // l'.Perm l} :=
  fun l => ⟨l, List.Perm.refl l⟩

@[expose, rust_fun
  "std::collections::hash::map::{std::collections::hash::map::HashMap<@K, @V, std::hash::random::RandomState, alloc::alloc::Global>}::new"]
def std.collections.hash.map.HashMapKVRandomStateGlobal.new (K V : Type) :
    Result (std.collections.hash.map.HashMap K V std.hash.random.RandomState Global) :=
  ok { entries := [] }

@[expose, rust_fun
  "std::collections::hash::map::{std::collections::hash::map::HashMap<@K, @V, @S, @A>}::len"]
def std.collections.hash.map.HashMap.len {K V S A : Type}
    (m : std.collections.hash.map.HashMap K V S A) : Result Usize :=
  UScalar.tryMk .Usize m.entries.length

@[expose, rust_fun
  "std::collections::hash::map::{std::collections::hash::map::HashMap<@K, @V, @S, @A>}::get"]
def std.collections.hash.map.HashMap.get {K V S A Q Hasher : Type}
    (_EqKInst : core.cmp.Eq K) (_HashKInst : core.hash.Hash K)
    (_BuildHasherInst : core.hash.BuildHasher S Hasher) (BorrowInst : core.borrow.Borrow K Q)
    (_HashQInst : core.hash.Hash Q) (EqQInst : core.cmp.Eq Q)
    (m : std.collections.hash.map.HashMap K V S A) (q : Q) : Result (Option V) :=
  std.collections.hash.map.HashMap.lookup BorrowInst EqQInst m.entries q

@[rust_type "std::collections::hash::map::Iter" (body := .opaque)]
structure std.collections.hash.map.Iter (K V : Type) where
  items : List (K × V)

@[expose, rust_fun
  "std::collections::hash::map::{std::collections::hash::map::HashMap<@K, @V, @S, @A>}::iter"]
def std.collections.hash.map.HashMap.iter {K V S A : Type}
    (m : std.collections.hash.map.HashMap K V S A) : Result (std.collections.hash.map.Iter K V) :=
  ok { items := (std.collections.hash.hashOrder m.entries).val }

@[expose, rust_fun
  "std::collections::hash::map::{core::iter::traits::iterator::Iterator<std::collections::hash::map::Iter<'a, @K, @V>, (&'a @K, &'a @V)>}::next"]
def std.collections.hash.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV.next
    {K V : Type} (it : std.collections.hash.map.Iter K V) :
    Result ((Option (K × V)) × std.collections.hash.map.Iter K V) :=
  match it.items with
  | [] => ok (none, it)
  | x :: items => ok (some x, { items })

/-- Exact -/
@[rust_fun
  "std::collections::hash::map::{core::iter::traits::iterator::Iterator<std::collections::hash::map::Iter<'a, @K, @V>, (&'a @K, &'a @V)>}::size_hint"]
def std.collections.hash.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV.size_hint
    {K V : Type} (it : std.collections.hash.map.Iter K V) : Result (Usize × Option Usize) := do
  let n ← UScalar.tryMk .Usize it.items.length
  ok (n, some n)

@[expose, reducible, rust_trait_impl
  "core::iter::traits::iterator::Iterator<std::collections::hash::map::Iter<'a, @K, @V>, (&'a @K, &'a @V)>"]
def std.collections.hash.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV
    (K V : Type) :
    core.iter.traits.iterator.Iterator (std.collections.hash.map.Iter K V) (K × V) where
  next := std.collections.hash.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV.next
  size_hint :=
    std.collections.hash.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV.size_hint

@[rust_fun
  "std::collections::hash::map::{core::iter::traits::iterator::Iterator<std::collections::hash::map::Iter<'a, @K, @V>, (&'a @K, &'a @V)>}::count"]
def std.collections.hash.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV.count
    {K V : Type} (it : std.collections.hash.map.Iter K V) : Result Usize :=
  core.iter.traits.iterator.Iterator.count.default
    (std.collections.hash.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV K V) it

@[rust_fun
  "std::collections::hash::map::{core::iter::traits::iterator::Iterator<std::collections::hash::map::Iter<'a, @K, @V>, (&'a @K, &'a @V)>}::fold"]
def std.collections.hash.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV.fold
    {K V B F : Type} {Out : Type} [S : FoldShape B F Out]
    (FnMutInst : core.ops.function.FnMut F (B × (K × V)) B)
    (it : std.collections.hash.map.Iter K V) (init : B) (f : F) : Result Out :=
  core.iter.traits.iterator.Iterator.fold.default (S := S)
    (std.collections.hash.map.Iter.Insts.CoreIterTraitsIteratorIteratorPairSharedAKSharedAV K V)
    FnMutInst it init f

/-! ### `entry` -/

/-- The map and the key; std's `Occupied`/`Vacant` is whether the key is present -/
@[rust_type "std::collections::hash::map::Entry" (mutRegions := #[0]) (body := .opaque)]
structure std.collections.hash.map.Entry (K V A : Type) where
  entries : List (K × V)
  key : K
  /-- The position of the key's entry, if present -/
  pos : Option Nat

@[rust_type "std::collections::hash::map::OccupiedEntry" (mutRegions := #[0]) (body := .opaque)]
structure std.collections.hash.map.OccupiedEntry (K V A : Type) where
  entry : std.collections.hash.map.Entry K V A

@[rust_type "std::collections::hash::map::VacantEntry" (mutRegions := #[0]) (body := .opaque)]
structure std.collections.hash.map.VacantEntry (K V A : Type) where
  entry : std.collections.hash.map.Entry K V A

/-- The position of the entry whose key equals `k` -/
@[expose]
def std.collections.hash.map.HashMap.position {K V : Type} (EqInst : core.cmp.Eq K) :
    List (K × V) → K → Result (Option Nat)
  | [], _ => ok none
  | (k', _) :: es, k => do
    if ← EqInst.partialEqInst.eq k' k then ok (some 0)
    else
      match ← std.collections.hash.map.HashMap.position EqInst es k with
      | some i => ok (some (i + 1))
      | none => ok none

/-- The entry, and giving it back gives back the map -/
@[expose, rust_fun
  "std::collections::hash::map::{std::collections::hash::map::HashMap<@K, @V, @S, @A>}::entry"]
def std.collections.hash.map.HashMap.entry {K V S A Hasher : Type} (EqInst : core.cmp.Eq K)
    (_HashInst : core.hash.Hash K) (_BuildHasherInst : core.hash.BuildHasher S Hasher)
    (m : std.collections.hash.map.HashMap K V S A) (key : K) :
    Result ((std.collections.hash.map.Entry K V A) ×
      (std.collections.hash.map.Entry K V A → std.collections.hash.map.HashMap K V S A)) := do
  let pos ← std.collections.hash.map.HashMap.position EqInst m.entries key
  ok ({ entries := m.entries, key, pos }, fun e => { entries := e.entries })

/-- The value at the key, appending `(key, default)` if absent; writing through the returned
`&mut V` replaces that entry's value -/
@[expose, rust_fun
  "std::collections::hash::map::{std::collections::hash::map::Entry<'a, @K, @V, @A>}::or_insert"]
def std.collections.hash.map.Entry.or_insert {K V A : Type}
    (e : std.collections.hash.map.Entry K V A) (default : V) :
    Result (V × (V → std.collections.hash.map.Entry K V A)) :=
  let (entries, i) := match e.pos with
    | some i => (e.entries, i)
    | none => (e.entries ++ [(e.key, default)], e.entries.length)
  match entries[i]? with
  | some (k, v) => ok (v, fun v' => { e with entries := entries.set i (k, v'), pos := some i })
  | none => fail .panic -- unreachable: `i` is the key's position

/-! ## `HashSet` -/

@[rust_type "std::collections::hash::set::HashSet" (body := .opaque)]
structure std.collections.hash.set.HashSet (T S A : Type) where
  items : List T

@[rust_fun
  "std::collections::hash::set::{core::default::Default<std::collections::hash::set::HashSet<@T, @S, alloc::alloc::Global>>}::default"]
def std.collections.hash.set.HashSetTSGlobal.Insts.CoreDefaultDefault.default (T : Type)
    {S : Type} (_DefaultInst : core.default.Default S) :
    Result (std.collections.hash.set.HashSet T S Global) :=
  ok { items := [] }

/-- `true` and the item added if no equal item is present, else `false` and the set unchanged
(std keeps the old item) -/
@[rust_fun
  "std::collections::hash::set::{std::collections::hash::set::HashSet<@T, @S, @A>}::insert"]
def std.collections.hash.set.HashSet.insert {T S A Hasher : Type} (EqInst : core.cmp.Eq T)
    (_HashInst : core.hash.Hash T) (_BuildHasherInst : core.hash.BuildHasher S Hasher)
    (s : std.collections.hash.set.HashSet T S A) (x : T) :
    Result (Bool × std.collections.hash.set.HashSet T S A) := do
  if ← s.items.anyM (fun y => EqInst.partialEqInst.eq y x) then ok (false, s)
  else ok (true, { items := s.items ++ [x] })

/-- `HashSet::new()`, with std's hasher -/
@[expose, rust_fun
  "std::collections::hash::set::{std::collections::hash::set::HashSet<@T, std::hash::random::RandomState, alloc::alloc::Global>}::new"]
def std.collections.hash.set.HashSetTRandomStateGlobal.new (T : Type) :
    Result (std.collections.hash.set.HashSet T std.hash.random.RandomState Global) :=
  ok { items := [] }

@[expose, rust_fun
  "std::collections::hash::set::{std::collections::hash::set::HashSet<@T, @S, @A>}::is_empty"]
def std.collections.hash.set.HashSet.is_empty {T S A : Type}
    (s : std.collections.hash.set.HashSet T S A) : Result Bool :=
  ok s.items.isEmpty

/-- Whether an item, borrowed as `Q`, equals `q` -/
@[expose]
def std.collections.hash.set.HashSet.mem {T Q : Type} (BorrowInst : core.borrow.Borrow T Q)
    (EqQInst : core.cmp.Eq Q) (items : List T) (q : Q) : Result Bool :=
  items.anyM (fun y => do EqQInst.partialEqInst.eq (← BorrowInst.borrow y) q)

@[expose, rust_fun
  "std::collections::hash::set::{std::collections::hash::set::HashSet<@T, @S, @A>}::contains"]
def std.collections.hash.set.HashSet.contains {T S A Q Hasher : Type}
    (_EqInst : core.cmp.Eq T) (_HashInst : core.hash.Hash T)
    (_BuildHasherInst : core.hash.BuildHasher S Hasher) (BorrowInst : core.borrow.Borrow T Q)
    (_HashQInst : core.hash.Hash Q) (EqQInst : core.cmp.Eq Q)
    (s : std.collections.hash.set.HashSet T S A) (q : Q) : Result Bool :=
  std.collections.hash.set.HashSet.mem BorrowInst EqQInst s.items q

/-- Drop the first item equal to `q`, if any; `true` iff one was -/
@[expose]
def std.collections.hash.set.HashSet.removeList {T Q : Type} (BorrowInst : core.borrow.Borrow T Q)
    (EqQInst : core.cmp.Eq Q) : List T → Q → Result (Bool × List T)
  | [], _ => ok (false, [])
  | y :: ys, q => do
    if ← EqQInst.partialEqInst.eq (← BorrowInst.borrow y) q then ok (true, ys)
    else
      let (b, ys') ← std.collections.hash.set.HashSet.removeList BorrowInst EqQInst ys q
      ok (b, y :: ys')

@[expose, rust_fun
  "std::collections::hash::set::{std::collections::hash::set::HashSet<@T, @S, @A>}::remove"]
def std.collections.hash.set.HashSet.remove {T S A Q Hasher : Type}
    (_EqInst : core.cmp.Eq T) (_HashInst : core.hash.Hash T)
    (_BuildHasherInst : core.hash.BuildHasher S Hasher) (BorrowInst : core.borrow.Borrow T Q)
    (_HashQInst : core.hash.Hash Q) (EqQInst : core.cmp.Eq Q)
    (s : std.collections.hash.set.HashSet T S A) (q : Q) :
    Result (Bool × std.collections.hash.set.HashSet T S A) := do
  let (b, items) ← std.collections.hash.set.HashSet.removeList BorrowInst EqQInst s.items q
  ok (b, { items })

@[expose, rust_fun
  "std::collections::hash::set::{core::clone::Clone<std::collections::hash::set::HashSet<@T, @S, @A>>}::clone"]
def std.collections.hash.set.HashSet.Insts.CoreCloneClone.clone {T S A : Type}
    (CloneInst : core.clone.Clone T) (_CloneSInst : core.clone.Clone S)
    (_CloneAInst : core.clone.Clone A) (s : std.collections.hash.set.HashSet T S A) :
    Result (std.collections.hash.set.HashSet T S A) := do
  ok { items := ← s.items.mapM CloneInst.clone }

/-- Each item inserted in turn (an equal item already present wins) -/
@[expose]
def std.collections.hash.set.HashSet.insertAll {T : Type} (EqInst : core.cmp.Eq T)
    (items : List T) (xs : List T) : Result (List T) :=
  xs.foldlM
    (fun acc x => do
      if ← acc.anyM (fun y => EqInst.partialEqInst.eq y x) then ok acc else ok (acc ++ [x]))
    items

@[rust_fun
  "std::collections::hash::set::{core::iter::traits::collect::FromIterator<std::collections::hash::set::HashSet<@T, @S, alloc::alloc::Global>, @T>}::from_iter"]
def std.collections.hash.set.HashSetTSGlobal.Insts.CoreIterTraitsCollectFromIterator.from_iter
    {T S I Hasher IntoIter : Type} (EqInst : core.cmp.Eq T) (_HashInst : core.hash.Hash T)
    (_BuildHasherInst : core.hash.BuildHasher S Hasher) (_DefaultInst : core.default.Default S)
    (IntoIteratorInst : core.iter.traits.collect.IntoIterator I T IntoIter) (input : I) :
    Result (std.collections.hash.set.HashSet T S Global) := do
  let xs ← alloc.collections.btree.toList IntoIteratorInst.iteratorInst
    (← IntoIteratorInst.into_iter input)
  ok { items := ← std.collections.hash.set.HashSet.insertAll EqInst [] xs }

@[rust_fun
  "std::collections::hash::set::{core::iter::traits::collect::Extend<std::collections::hash::set::HashSet<@T, @S, @A>, @T>}::extend"]
def std.collections.hash.set.HashSet.Insts.CoreIterTraitsCollectExtend.extend
    {T S A I Hasher IntoIter : Type} (EqInst : core.cmp.Eq T) (_HashInst : core.hash.Hash T)
    (_BuildHasherInst : core.hash.BuildHasher S Hasher)
    (IntoIteratorInst : core.iter.traits.collect.IntoIterator I T IntoIter)
    (s : std.collections.hash.set.HashSet T S A) (input : I) :
    Result (std.collections.hash.set.HashSet T S A) := do
  let xs ← alloc.collections.btree.toList IntoIteratorInst.iteratorInst
    (← IntoIteratorInst.into_iter input)
  ok { items := ← std.collections.hash.set.HashSet.insertAll EqInst s.items xs }

/-- Iteration visits the items in std's order: `hashOrder`, as for `HashMap` -/
@[rust_type "std::collections::hash::set::Iter" (body := .opaque)]
structure std.collections.hash.set.Iter (K : Type) where
  items : List K

@[rust_type "std::collections::hash::set::IntoIter" (body := .opaque)]
structure std.collections.hash.set.IntoIter (K A : Type) where
  items : List K

@[expose, rust_fun
  "std::collections::hash::set::{std::collections::hash::set::HashSet<@T, @S, @A>}::iter"]
def std.collections.hash.set.HashSet.iter {T S A : Type}
    (s : std.collections.hash.set.HashSet T S A) : Result (std.collections.hash.set.Iter T) :=
  ok { items := (std.collections.hash.hashOrder s.items).val }

@[expose, rust_fun
  "std::collections::hash::set::{core::iter::traits::iterator::Iterator<std::collections::hash::set::Iter<'a, @K>, &'a @K>}::next"]
def std.collections.hash.set.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAK.next {K : Type}
    (it : std.collections.hash.set.Iter K) :
    Result (Option K × std.collections.hash.set.Iter K) :=
  match it.items with
  | [] => ok (none, it)
  | x :: xs => ok (some x, { items := xs })

@[expose, rust_fun
  "std::collections::hash::set::{core::iter::traits::collect::IntoIterator<std::collections::hash::set::HashSet<@T, @S, @A>, @T, std::collections::hash::set::IntoIter<@T, @A>>}::into_iter"]
def std.collections.hash.set.HashSet.Insts.CoreIterTraitsCollectIntoIteratorTIntoIter.into_iter
    {T S A : Type} (s : std.collections.hash.set.HashSet T S A) :
    Result (std.collections.hash.set.IntoIter T A) :=
  ok { items := (std.collections.hash.hashOrder s.items).val }

@[expose, rust_fun
  "std::collections::hash::set::{core::iter::traits::iterator::Iterator<std::collections::hash::set::IntoIter<@K, @A>, @K>}::next"]
def std.collections.hash.set.IntoIter.Insts.CoreIterTraitsIteratorIterator.next {K A : Type}
    (it : std.collections.hash.set.IntoIter K A) :
    Result (Option K × std.collections.hash.set.IntoIter K A) :=
  match it.items with
  | [] => ok (none, it)
  | x :: xs => ok (some x, { items := xs })

/-- `RandomState` carries nothing the models read -/
@[expose, rust_fun "std::hash::random::{core::clone::Clone<std::hash::random::RandomState>}::clone"]
def std.hash.random.RandomState.Insts.CoreCloneClone.clone (s : std.hash.random.RandomState) :
    Result std.hash.random.RandomState :=
  ok s

/-! ## `Option` as an iterator -/

/-- `Option::iter`: at most one item -/
@[rust_type "core::option::Iter" (body := .opaque)]
structure core.option.Iter (A : Type) where
  item : Option A

@[expose, rust_fun "core::option::{core::option::Option<@T>}::iter"]
def core.option.Option.iter {T : Type} (o : Option T) : Result (core.option.Iter T) :=
  ok { item := o }

@[expose, rust_fun
  "core::option::{core::iter::traits::iterator::Iterator<core::option::Iter<'a, @A>, &'a @A>}::next"]
def core.option.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAA.next {A : Type}
    (it : core.option.Iter A) : Result (Option A × core.option.Iter A) :=
  ok (it.item, { item := none })

@[expose, rust_fun "core::option::{core::clone::Clone<core::option::Option<@T>>}::clone"]
def core.option.Option.Insts.CoreCloneClone.clone {T : Type} (CloneInst : core.clone.Clone T) :
    Option T → Result (Option T)
  | none => ok none
  | some x => do ok (some (← CloneInst.clone x))

/-! ## `BTreeMap` -/

@[expose, rust_fun
  "alloc::collections::btree::map::{alloc::collections::btree::map::BTreeMap<@K, @V, @A>}::len"]
def alloc.collections.btree.map.BTreeMap.len {K V A : Type}
    (_AllocInst : core.alloc.AllocatorClone A) (m : alloc.collections.btree.map.BTreeMap K V A) :
    Result Usize :=
  UScalar.tryMk .Usize m.entries.length

/-! ## `BTreeSet` -/

@[rust_fun
  "alloc::collections::btree::set::{alloc::collections::btree::set::BTreeSet<@T, @A>}::is_empty"]
def alloc.collections.btree.set.BTreeSet.is_empty {T A : Type}
    (_AllocInst : core.alloc.AllocatorClone A) (s : alloc.collections.btree.set.BTreeSet T A) :
    Result Bool :=
  ok s.items.isEmpty

@[expose, rust_fun
  "alloc::collections::btree::set::{core::clone::Clone<alloc::collections::btree::set::BTreeSet<@T, @A>>}::clone"]
def alloc.collections.btree.set.BTreeSet.Insts.CoreCloneClone.clone {T A : Type}
    (CloneInst : core.clone.Clone T) (_AllocInst : core.alloc.AllocatorClone A)
    (s : alloc.collections.btree.set.BTreeSet T A) :
    Result (alloc.collections.btree.set.BTreeSet T A) := do
  ok { items := ← s.items.mapM CloneInst.clone }

/-- Equal lengths and pairwise equal items (`iter().eq(other.iter())`) -/
@[rust_fun
  "alloc::collections::btree::set::{core::cmp::PartialEq<alloc::collections::btree::set::BTreeSet<@T, @A>, alloc::collections::btree::set::BTreeSet<@T, @A>>}::eq"]
def alloc.collections.btree.set.BTreeSet.Insts.CoreCmpPartialEqBTreeSet.eq {T A : Type}
    (PartialEqInst : core.cmp.PartialEq T T) (_AllocInst : core.alloc.AllocatorClone A)
    (s t : alloc.collections.btree.set.BTreeSet T A) : Result Bool :=
  if s.items.length = t.items.length then
    List.allM (fun (x, y) => PartialEqInst.eq x y) (List.zip s.items t.items)
  else ok false

/-- Lexicographic, with the items compared by `partial_cmp` (`Iterator::partial_cmp`): the first
difference (or incomparable pair) decides, else the shorter is smaller -/
def List.lexPartialCmpM {T : Type} (cmp : T → T → Result (Option Ordering)) :
    List T → List T → Result (Option Ordering)
  | [], [] => ok (some .eq)
  | [], _ :: _ => ok (some .lt)
  | _ :: _, [] => ok (some .gt)
  | a :: as, b :: bs => do
    match ← cmp a b with
    | some .eq => List.lexPartialCmpM cmp as bs
    | o => ok o

@[rust_fun
  "alloc::collections::btree::set::{core::cmp::PartialOrd<alloc::collections::btree::set::BTreeSet<@T, @A>, alloc::collections::btree::set::BTreeSet<@T, @A>>}::partial_cmp"]
def alloc.collections.btree.set.BTreeSet.Insts.CoreCmpPartialOrdBTreeSet.partial_cmp {T A : Type}
    (PartialOrdInst : core.cmp.PartialOrd T T) (_AllocInst : core.alloc.AllocatorClone A)
    (s t : alloc.collections.btree.set.BTreeSet T A) : Result (Option Ordering) :=
  List.lexPartialCmpM PartialOrdInst.partial_cmp s.items t.items

@[expose, rust_fun
  "alloc::collections::btree::set::{core::cmp::Ord<alloc::collections::btree::set::BTreeSet<@T, @A>>}::cmp"]
def alloc.collections.btree.set.BTreeSet.Insts.CoreCmpOrd.cmp {T A : Type}
    (OrdInst : core.cmp.Ord T) (_AllocInst : core.alloc.AllocatorClone A)
    (s t : alloc.collections.btree.set.BTreeSet T A) : Result Ordering :=
  List.lexCmpM OrdInst.cmp s.items t.items

/-- Ascending -/
@[rust_type "alloc::collections::btree::set::Iter" (body := .opaque)]
structure alloc.collections.btree.set.Iter (T : Type) where
  items : List T

@[expose, rust_fun
  "alloc::collections::btree::set::{alloc::collections::btree::set::BTreeSet<@T, @A>}::iter"]
def alloc.collections.btree.set.BTreeSet.iter {T A : Type}
    (_AllocInst : core.alloc.AllocatorClone A) (s : alloc.collections.btree.set.BTreeSet T A) :
    Result (alloc.collections.btree.set.Iter T) :=
  ok { items := s.items }

@[rust_fun
  "alloc::collections::btree::set::{core::iter::traits::collect::IntoIterator<&'a alloc::collections::btree::set::BTreeSet<@T, @A>, &'a @T, alloc::collections::btree::set::Iter<'a, @T>>}::into_iter"]
def SharedABTreeSet.Insts.CoreIterTraitsCollectIntoIteratorSharedATIter.into_iter {T A : Type}
    (_AllocInst : core.alloc.AllocatorClone A) (s : alloc.collections.btree.set.BTreeSet T A) :
    Result (alloc.collections.btree.set.Iter T) :=
  ok { items := s.items }

@[expose, rust_fun
  "alloc::collections::btree::set::{core::iter::traits::iterator::Iterator<alloc::collections::btree::set::Iter<'a, @T>, &'a @T>}::next"]
def alloc.collections.btree.set.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAT.next {T : Type}
    (it : alloc.collections.btree.set.Iter T) :
    Result ((Option T) × alloc.collections.btree.set.Iter T) :=
  match it.items with
  | [] => ok (none, it)
  | x :: items => ok (some x, { items })

/-- Exact -/
@[rust_fun
  "alloc::collections::btree::set::{core::iter::traits::iterator::Iterator<alloc::collections::btree::set::Iter<'a, @T>, &'a @T>}::size_hint"]
def alloc.collections.btree.set.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAT.size_hint
    {T : Type} (it : alloc.collections.btree.set.Iter T) : Result (Usize × Option Usize) := do
  let n ← UScalar.tryMk .Usize it.items.length
  ok (n, some n)

/-- `self.next_back()`: the greatest item -/
@[rust_fun
  "alloc::collections::btree::set::{core::iter::traits::iterator::Iterator<alloc::collections::btree::set::Iter<'a, @T>, &'a @T>}::max"]
def alloc.collections.btree.set.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAT.max {T : Type}
    (_OrdInst : core.cmp.Ord T) (it : alloc.collections.btree.set.Iter T) : Result (Option T) :=
  ok it.items.getLast?

@[expose, reducible, rust_trait_impl
  "core::iter::traits::iterator::Iterator<alloc::collections::btree::set::Iter<'a, @T>, &'a @T>"]
def alloc.collections.btree.set.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAT (T : Type) :
    core.iter.traits.iterator.Iterator (alloc.collections.btree.set.Iter T) T where
  next := alloc.collections.btree.set.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAT.next
  size_hint := alloc.collections.btree.set.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAT.size_hint

@[reducible, rust_trait_impl
  "core::iter::traits::collect::IntoIterator<&'a alloc::collections::btree::set::BTreeSet<@T, @A>, &'a @T, alloc::collections::btree::set::Iter<'a, @T>>"]
def SharedABTreeSet.Insts.CoreIterTraitsCollectIntoIteratorSharedATIter {T A : Type}
    (AllocInst : core.alloc.AllocatorClone A) :
    core.iter.traits.collect.IntoIterator (alloc.collections.btree.set.BTreeSet T A) T
      (alloc.collections.btree.set.Iter T) where
  iteratorInst := alloc.collections.btree.set.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAT T
  into_iter := SharedABTreeSet.Insts.CoreIterTraitsCollectIntoIteratorSharedATIter.into_iter AllocInst

end Aeneas.Std
