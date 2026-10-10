/- More of `Vec`'s API, and the `Hash` impls of integers, references and `Vec`s -/
module
public import Aeneas.Std.BTree
public import Aeneas.Std.Core.Hash
public import Aeneas.Std.Array.ArraySlice
public import Aeneas.Std.Scalar.CoreConvertNum
public section

namespace Aeneas.Std

open Result

/-- `MaybeUninit<T>`: possibly a `T`. Charon meets it inside `vec![..]`'s expansion; no model reads
it. -/
@[rust_type "core::mem::maybe_uninit::MaybeUninit" (body := .opaque)]
structure core.mem.maybe_uninit.MaybeUninit (T : Type) where
  value : Option T

/-! ## `Vec` -/

/-- `reserve` only changes the capacity, which we don't model -/
@[expose, rust_fun "alloc::vec::{alloc::vec::Vec<@T>}::reserve" (keepParams := [true, false])]
def alloc.vec.Vec.reserve {T : Type} (v : alloc.vec.Vec T) (_ : Usize) :
    Result (alloc.vec.Vec T) :=
  ok v

/-- Keep the first `n` elements (all of them if there are fewer) -/
@[expose, rust_fun "alloc::vec::{alloc::vec::Vec<@T>}::truncate" (keepParams := [true, false])]
def alloc.vec.Vec.truncate {T : Type} (v : alloc.vec.Vec T) (n : Usize) :
    Result (alloc.vec.Vec T) :=
  ok (Vec.from (v.val.take n.val) (by have := v.property; grind))

@[expose, rust_fun "alloc::vec::{alloc::vec::Vec<@T>}::as_slice" (keepParams := [true, false])]
def alloc.vec.Vec.as_slice {T : Type} (v : alloc.vec.Vec T) : Result (Slice T) :=
  ok v.slice

@[expose, rust_fun "alloc::vec::{alloc::vec::Vec<@T>}::is_empty" (keepParams := [true, false])]
def alloc.vec.Vec.is_empty {T : Type} (v : alloc.vec.Vec T) : Result Bool :=
  ok (v.length = 0)

/-- `self.append(other)`: moves `other`'s elements to the end of `self`, leaving `other`
empty (both are given back); panics past `usize::MAX` elements -/
@[expose, rust_fun "alloc::vec::{alloc::vec::Vec<@T>}::append" (keepParams := [true, false])]
def alloc.vec.Vec.append {T : Type} (v w : alloc.vec.Vec T) :
    Result (alloc.vec.Vec T × alloc.vec.Vec T) :=
  if h : v.length + w.length ≤ Usize.max then
    ok (Vec.from (v.val ++ w.val) (by simpa using h), Vec.new T)
  else fail .panic

@[expose, rust_fun "alloc::vec::{core::default::Default<alloc::vec::Vec<@T>>}::default"]
def alloc.vec.Vec.Insts.CoreDefaultDefault.default (T : Type) : Result (alloc.vec.Vec T) :=
  ok (Vec.new T)

/-- `Extend<T>`: pushes the items in turn (so it panics past `usize::MAX` elements) -/
@[expose, rust_fun
  "alloc::vec::{core::iter::traits::collect::Extend<alloc::vec::Vec<@T>, @T>}::extend"
  (keepParams := [true, false, true, true])]
def alloc.vec.Vec.Insts.CoreIterTraitsCollectExtend.extend {T I IntoIter : Type}
    (IntoIteratorInst : core.iter.traits.collect.IntoIterator I T IntoIter)
    (v : alloc.vec.Vec T) (items : I) : Result (alloc.vec.Vec T) := do
  let items ← alloc.collections.btree.toList IntoIteratorInst.iteratorInst
    (← IntoIteratorInst.into_iter items)
  items.foldlM Vec.push v

/-- `vec.iter().map(Vec::len)`: the function item `Vec::len` called through `FnMut`. A function
item is extracted as the function itself, and holds no state. The allocator parameter is
kept: the fn item's impls pass it. -/
@[expose, rust_fun
  "alloc::vec::{alloc::vec::Vec<@T>}::{core::ops::function::FnMut<@, (&'0 alloc::vec::Vec<@T>), usize>}::call_mut"]
def alloc.vec.Vec.len.Insts.CoreOpsFunctionFnMut.call_mut {T : Type} (_A : Type)
    (f : alloc.vec.Vec T → Usize) (v : alloc.vec.Vec T) :
    Result (Usize × (alloc.vec.Vec T → Usize)) :=
  ok (f v, f)

@[expose, rust_fun
  "alloc::vec::{alloc::vec::Vec<@T>}::{core::ops::function::FnOnce<@, (&'0 alloc::vec::Vec<@T>), usize>}::call_once"]
def alloc.vec.Vec.len.Insts.CoreOpsFunctionFnOnce.call_once {T : Type} (_A : Type)
    (f : alloc.vec.Vec T → Usize) (v : alloc.vec.Vec T) : Result Usize :=
  ok (f v)

/-! ## `Hash` impls

`Hasher::write_usize`/`write_isize`, which these use, write the native-endian bytes: little
endian and 64 bits on the targets we model. -/

/-- `usize::hash`: `state.write_usize(*self)` -/
@[expose, rust_fun "core::hash::impls::{core::hash::Hash<usize>}::hash"]
def Usize.Insts.CoreHashHash.hash {H : Type} (HasherInst : core.hash.Hasher H) (x : Usize)
    (h : H) : Result H :=
  HasherInst.write h (Array.to_slice (core.num.U64.to_le_bytes (UScalar.cast .U64 x)))

/-- `isize::hash`: `state.write_isize(*self)` -/
@[expose, rust_fun "core::hash::impls::{core::hash::Hash<isize>}::hash"]
def Isize.Insts.CoreHashHash.hash {H : Type} (HasherInst : core.hash.Hasher H) (x : Isize)
    (h : H) : Result H :=
  HasherInst.write h (Array.to_slice (core.num.I64.to_le_bytes (IScalar.cast .I64 x)))

/-- `<&T>::hash`: hashes the referent -/
@[expose, rust_fun "core::hash::impls::{core::hash::Hash<&'0 @T>}::hash"]
def Shared0T.Insts.CoreHashHash.hash {T H : Type} (HashInst : core.hash.Hash T)
    (HasherInst : core.hash.Hasher H) (x : T) (h : H) : Result H :=
  HashInst.hash HasherInst x h

/-- `Vec::hash`: the length (`write_length_prefix`, i.e. `write_usize`), then each element -/
@[expose, rust_fun "alloc::vec::{core::hash::Hash<alloc::vec::Vec<@T>>}::hash"
  (keepParams := [true, false, true])]
def alloc.vec.Vec.Insts.CoreHashHash.hash {T H : Type} (HashInst : core.hash.Hash T)
    (HasherInst : core.hash.Hasher H) (v : alloc.vec.Vec T) (h : H) : Result H := do
  let h ← Usize.Insts.CoreHashHash.hash HasherInst v.len h
  v.val.foldlM (fun h x => HashInst.hash HasherInst x h) h

section
open Lean.Order

/-- A type hashing itself through a `Vec` (`Collection(Vec<Self>)`) passes its own recursive
`hash` to `Vec`'s -/
@[partial_fixpoint_monotone]
theorem alloc.vec.Vec.Insts.CoreHashHash.hash_monotone {γ : Type _} [Lean.Order.PartialOrder γ]
    {T H : Type} (inst : γ → core.hash.Hash T) (HasherInst : core.hash.Hasher H)
    (v : alloc.vec.Vec T) (h : H)
    (hmono : monotone (fun x => (inst x).hash (H := H))) :
    monotone (fun x => alloc.vec.Vec.Insts.CoreHashHash.hash (inst x) HasherInst v h) := by
  simp only [alloc.vec.Vec.Insts.CoreHashHash.hash]
  apply monotone_bind
  · apply Lean.Order.monotone_const
  · apply monotone_of_monotone_apply
    intro h
    apply List.monotone_foldlM
    apply monotone_of_monotone_apply
    intro h
    apply monotone_of_monotone_apply
    intro y
    apply monotone_apply
    apply monotone_apply
    apply monotone_apply
    exact hmono

end

end Aeneas.Std
