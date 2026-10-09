/- Small `core`/`alloc` functions: `Option`'s and tuples' comparisons, integer helpers,
`Vec::swap_remove`, `split_first`, `PhantomData`. Overflow, division by zero and out-of-bounds
indices fail, as they panic in debug Rust. -/
module
public import Aeneas.Std.Core
public import Aeneas.Std.Vec
public section

namespace Aeneas.Std

open Result

/-! ## Comparisons -/

@[expose, rust_fun "core::borrow::{core::borrow::Borrow<@T, @T>}::borrow"]
def core.borrow.Borrow.Blanket.borrow {T : Type} (x : T) : Result T := ok x

/-- `Ord for &A`: compares the referents -/
@[expose, rust_fun "core::cmp::impls::{core::cmp::Ord<&'0 @A>}::cmp"]
def core.cmp.impls.OrdShared.cmp {A : Type} (OrdInst : core.cmp.Ord A) (a b : A) :
    Result Ordering :=
  OrdInst.cmp a b

/-! `Option`'s comparisons are derived: `None < Some _`, and `Some`s compare their contents. -/

@[expose, rust_fun
  "core::option::{core::cmp::PartialEq<core::option::Option<@T>, core::option::Option<@T>>}::eq"]
def core.option.Option.Insts.CoreCmpPartialEqOption.eq {T : Type}
    (PartialEqInst : core.cmp.PartialEq T T) : Option T → Option T → Result Bool
  | some a, some b => PartialEqInst.eq a b
  | none, none => ok true
  | _, _ => ok false

@[expose, rust_fun
  "core::option::{core::cmp::PartialOrd<core::option::Option<@T>, core::option::Option<@T>>}::partial_cmp"]
def core.option.Option.Insts.CoreCmpPartialOrdOption.partial_cmp {T : Type}
    (PartialOrdInst : core.cmp.PartialOrd T T) : Option T → Option T → Result (Option Ordering)
  | some a, some b => PartialOrdInst.partial_cmp a b
  | none, none => ok (some .eq)
  | none, some _ => ok (some .lt)
  | some _, none => ok (some .gt)

@[expose, rust_fun "core::option::{core::cmp::Ord<core::option::Option<@T>>}::cmp"]
def core.option.Option.Insts.CoreCmpOrd.cmp {T : Type} (OrdInst : core.cmp.Ord T) :
    Option T → Option T → Result Ordering
  | some a, some b => OrdInst.cmp a b
  | none, none => ok .eq
  | none, some _ => ok .lt
  | some _, none => ok .gt

/-- `(U, T) == (U, T)`: fields left to right, stopping at the first difference -/
@[expose, rust_fun "core::tuple::{core::cmp::PartialEq<(@U, @T), (@U, @T)>}::eq"]
def Pair.Insts.CoreCmpPartialEqPair.eq {U T : Type} (PartialEqInst0 : core.cmp.PartialEq U U)
    (PartialEqInst1 : core.cmp.PartialEq T T) (a b : U × T) : Result Bool := do
  if ← PartialEqInst0.eq a.1 b.1 then PartialEqInst1.eq a.2 b.2 else ok false

/-! ## `Option` -/

@[expose, rust_fun "core::option::{core::option::Option<&'0 @T>}::copied"]
def core.option.OptionShared0T.copied {T : Type} (_CopyInst : core.marker.Copy T) (o : Option T) :
    Result (Option T) :=
  ok o

@[expose, rust_fun "core::option::{core::option::Option<@T>}::unwrap_or_default"]
def core.option.Option.unwrap_or_default {T : Type} (DefaultInst : core.default.Default T) :
    Option T → Result T
  | some x => ok x
  | none => DefaultInst.default

/-! ## Integers -/

@[expose, rust_fun "core::num::{i32}::abs"]
def core.num.I32.abs (x : I32) : Result I32 := IScalar.tryMk .I32 x.val.natAbs

@[expose, rust_fun "core::num::{i64}::unsigned_abs"]
def core.num.I64.unsigned_abs (x : I64) : Result U64 := UScalar.tryMk .U64 x.val.natAbs

/-- The smallest power of two `≥ x` (so `1` for `0`) -/
@[expose, rust_fun "core::num::{usize}::next_power_of_two"]
def core.num.Usize.next_power_of_two (x : Usize) : Result Usize :=
  UScalar.tryMk .Usize x.val.nextPowerOfTwo

/-! ## Slices and vectors -/

@[expose, rust_fun "core::slice::raw::from_ref"]
def core.slice.raw.from_ref {T : Type} (x : T) : Result (Slice T) :=
  ok (Slice.from [x] (by simp; scalar_tac))

@[expose, rust_fun "core::slice::{[@T]}::split_first"]
def core.slice.Slice.split_first {T : Type} (s : Slice T) : Result (Option (T × Slice T)) :=
  match h : s.val with
  | [] => ok none
  | x :: t => ok (some (x, Slice.from t (by have := Slice.property s; rw [h] at this; simp at this; omega)))

/-- Removes element `i`, moving the last element into its place -/
@[expose, rust_fun "alloc::vec::{alloc::vec::Vec<@T>}::swap_remove" (keepParams := [true, false])]
def alloc.vec.Vec.swap_remove {T : Type} (v : alloc.vec.Vec T) (i : Usize) :
    Result (T × alloc.vec.Vec T) :=
  if h : i.val < v.length then
    let last := v.val.getLast (by intro e; simp_all [Vec.length])
    let l := (v.val.set i.val last).dropLast
    ok (v.val[i.val]'(by simp_all [Vec.length]),
      .from l (by have := Vec.property v; simp [l]; omega))
  else fail .panic

/-! ## `PhantomData` -/

@[expose, reducible, rust_type "core::marker::PhantomData"]
def core.marker.PhantomData (_ : Type) := Unit

@[expose, rust_fun "core::marker::{core::default::Default<core::marker::PhantomData<@T>>}::default"]
def core.marker.PhantomData.Insts.CoreDefaultDefault.default (T : Type) :
    Result (core.marker.PhantomData T) :=
  ok ()

end Aeneas.Std
