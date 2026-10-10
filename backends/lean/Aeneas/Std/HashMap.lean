/- `HashMap` as the list of its entries, and std's default hasher -/
module
public import Aeneas.Std.BTree
public import Aeneas.Std.Core.Hash
public import Aeneas.Std.Array.ArraySlice
public import Aeneas.Std.Scalar.CoreConvertNum
public section

set_option linter.dupNamespace false

namespace Aeneas.Std

open Result

/-! A `HashMap` is the list of its entries, one per key, in insertion order. Only operations
that don't depend on std's (randomly seeded) iteration order are modelled: lookups compare
keys with `Eq`, which for a lawful `Hash` finds the entry std's probing finds. The hasher and
allocator parameters are kept for the types but unused. -/

@[rust_type "std::collections::hash::map::HashMap" (body := .opaque)]
structure std.collections.hash.map.HashMap (K : Type u) (V : Type v) (S : Type w)
    (A : Type x) where
  entries : List (K × V)

/-- The value of the entry whose key, borrowed as `Q`, equals `q` -/
def std.collections.hash.map.HashMap.lookup {K V Q : Type}
  (BorrowInst : core.borrow.Borrow K Q) (EqQInst : core.cmp.Eq Q) :
  List (K × V) → Q → Result (Option V)
  | [], _ => ok none
  | (k, v) :: es, q => do
    if ← EqQInst.partialEqInst.eq (← BorrowInst.borrow k) q then ok (some v)
    else std.collections.hash.map.HashMap.lookup BorrowInst EqQInst es q

/-- `map[&q]`: panics if absent -/
@[rust_fun
  "std::collections::hash::map::{core::ops::index::Index<std::collections::hash::map::HashMap<@K, @V, @S, @A>, &'0 @Q, @V>}::index"]
def std.collections.hash.map.HashMap.Insts.CoreOpsIndexIndexShared0QV.index
  {K Q V S A Hasher : Type} (_EqKInst : core.cmp.Eq K) (_HashKInst : core.hash.Hash K)
  (BorrowInst : core.borrow.Borrow K Q) (EqQInst : core.cmp.Eq Q)
  (_HashQInst : core.hash.Hash Q) (_BuildHasherInst : core.hash.BuildHasher S Hasher)
  (m : std.collections.hash.map.HashMap K V S A) (q : Q) : Result V := do
  match ← std.collections.hash.map.HashMap.lookup BorrowInst EqQInst m.entries q with
  | some v => ok v
  | none => fail .panic

/-- Insert: an equal key keeps its place (and its old key, as std does) and gets the new value;
a new key goes last -/
def std.collections.hash.map.HashMap.insertList {K V : Type} (EqInst : core.cmp.Eq K) :
  List (K × V) → K → V → Result (List (K × V))
  | [], k, v => ok [(k, v)]
  | (k', v') :: es, k, v => do
    if ← EqInst.partialEqInst.eq k' k then ok ((k', v) :: es)
    else ok ((k', v') :: (← std.collections.hash.map.HashMap.insertList EqInst es k v))

/-- Each pair inserted in turn, so the last value of a key wins -/
@[rust_fun
  "std::collections::hash::map::{core::iter::traits::collect::FromIterator<std::collections::hash::map::HashMap<@K, @V, @S, alloc::alloc::Global>, (@K, @V)>}::from_iter"]
def std.collections.hash.map.HashMapKVSGlobal.Insts.CoreIterTraitsCollectFromIteratorPair.from_iter
  {K V S I Hasher IntoIter : Type} (EqInst : core.cmp.Eq K) (_HashInst : core.hash.Hash K)
  (_BuildHasherInst : core.hash.BuildHasher S Hasher) (_DefaultInst : core.default.Default S)
  (IntoIteratorInst : core.iter.traits.collect.IntoIterator I (K × V) IntoIter) (input : I) :
  Result (std.collections.hash.map.HashMap K V S Global) := do
  let items ← alloc.collections.btree.toList IntoIteratorInst.iteratorInst
    (← IntoIteratorInst.into_iter input)
  let entries ← items.foldlM
    (fun es (k, v) => std.collections.hash.map.HashMap.insertList EqInst es k v) []
  ok { entries }

/-! ## std's default hasher -/

/-- `RandomState`: the random keys of the SipHash its hashers compute; never observed by the
models above -/
@[rust_type "std::hash::random::RandomState" (body := .opaque)]
structure std.hash.random.RandomState where

/-- `DefaultHasher`: the bytes written so far -/
@[rust_type "std::hash::random::DefaultHasher" (body := .opaque)]
structure std.hash.random.DefaultHasher where
  bytes : List U8

/-- The keyed SipHash of the bytes: an unknown function -/
opaque std.hash.random.DefaultHasher.sipHash : List U8 → U64

@[rust_fun "std::hash::random::{core::default::Default<std::hash::random::RandomState>}::default"]
def std.hash.random.RandomState.Insts.CoreDefaultDefault.default :
  Result std.hash.random.RandomState :=
  ok {}

@[rust_fun
  "std::hash::random::{core::hash::BuildHasher<std::hash::random::RandomState, std::hash::random::DefaultHasher>}::build_hasher"]
def std.hash.random.RandomState.Insts.CoreHashBuildHasherDefaultHasher.build_hasher
  (_ : std.hash.random.RandomState) : Result std.hash.random.DefaultHasher :=
  ok { bytes := [] }

@[rust_fun "std::hash::random::{core::hash::Hasher<std::hash::random::DefaultHasher>}::write"]
def std.hash.random.DefaultHasher.Insts.CoreHashHasher.write
  (h : std.hash.random.DefaultHasher) (s : Slice U8) : Result std.hash.random.DefaultHasher :=
  ok { bytes := h.bytes ++ s.val }

@[rust_fun "std::hash::random::{core::hash::Hasher<std::hash::random::DefaultHasher>}::finish"]
def std.hash.random.DefaultHasher.Insts.CoreHashHasher.finish
  (h : std.hash.random.DefaultHasher) : Result U64 :=
  ok (std.hash.random.DefaultHasher.sipHash h.bytes)

/-- `u32::hash`: `state.write_u32(*self)`, whose default writes the native-endian bytes (little
endian on the targets we model) -/
@[rust_fun "core::hash::impls::{core::hash::Hash<u32>}::hash"]
def U32.Insts.CoreHashHash.hash {H : Type} (HasherInst : core.hash.Hasher H) (x : U32)
  (h : H) : Result H :=
  HasherInst.write h (Array.to_slice (core.num.U32.to_le_bytes x))

end Aeneas.Std
