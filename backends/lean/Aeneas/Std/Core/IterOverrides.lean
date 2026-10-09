/- Std iterators' own methods (`count`, `fold`, `max`, `size_hint`), array and `&Vec`
iteration, slice `chunks`, `Range` clones and `collect` into a `Result` -/
module
public import Aeneas.Std.Core.IterAdapters
public import Aeneas.Std.VecIter
public import Aeneas.Std.RangeIter
public import Aeneas.Std.Array.Array
public section

set_option linter.dupNamespace false

namespace Aeneas.Std

open Result

/-! As in `IterAdapters`: overrides that core has only for speed are the provided methods,
which they must agree with; `size_hint` and `max` follow each iterator's own body. -/

/-! ## Arrays -/

/-- Core keeps the array and the live index range; the items left are enough here -/
@[rust_type "core::array::iter::IntoIter"]
structure core.array.iter.IntoIter (T : Type u) (N : Usize) where
  items : List T

@[rust_fun
  "core::array::iter::{core::iter::traits::collect::IntoIterator<[@T; @N], @T, core::array::iter::IntoIter<@T, @N>>}::into_iter"]
def Array.Insts.CoreIterTraitsCollectIntoIteratorTIntoIter.into_iter {T : Type} {N : Usize}
  (a : Array T N) : Result (core.array.iter.IntoIter T N) :=
  ok { items := a.val }

@[rust_fun
  "core::array::iter::{core::iter::traits::iterator::Iterator<core::array::iter::IntoIter<@T, @N>, @T>}::next"]
def core.array.iter.IntoIter.Insts.CoreIterTraitsIteratorIterator.next {T : Type} {N : Usize}
  (it : core.array.iter.IntoIter T N) : Result ((Option T) × (core.array.iter.IntoIter T N)) :=
  match it.items with
  | [] => ok (none, it)
  | x :: items => ok (some x, { items })

/-- Exact -/
@[rust_fun
  "core::array::iter::{core::iter::traits::iterator::Iterator<core::array::iter::IntoIter<@T, @N>, @T>}::size_hint"]
def core.array.iter.IntoIter.Insts.CoreIterTraitsIteratorIterator.size_hint {T : Type} {N : Usize}
  (it : core.array.iter.IntoIter T N) : Result (Usize × Option Usize) := do
  let n ← UScalar.tryMk .Usize it.items.length
  ok (n, some n)

@[reducible, rust_trait_impl
  "core::iter::traits::iterator::Iterator<core::array::iter::IntoIter<@T, @N>, @T>"]
def core.array.iter.IntoIter.Insts.CoreIterTraitsIteratorIterator (T : Type) (N : Usize) :
  core.iter.traits.iterator.Iterator (core.array.iter.IntoIter T N) T where
  next := core.array.iter.IntoIter.Insts.CoreIterTraitsIteratorIterator.next
  size_hint := core.array.iter.IntoIter.Insts.CoreIterTraitsIteratorIterator.size_hint

@[reducible, rust_trait_impl
  "core::iter::traits::collect::IntoIterator<[@T; @N], @T, core::array::iter::IntoIter<@T, @N>>"]
def Array.Insts.CoreIterTraitsCollectIntoIteratorTIntoIter (T : Type) (N : Usize) :
  core.iter.traits.collect.IntoIterator (Array T N) T (core.array.iter.IntoIter T N) where
  iteratorInst := core.array.iter.IntoIter.Insts.CoreIterTraitsIteratorIterator T N
  into_iter := Array.Insts.CoreIterTraitsCollectIntoIteratorTIntoIter.into_iter

@[rust_fun
  "core::array::iter::{core::iter::traits::iterator::Iterator<core::array::iter::IntoIter<@T, @N>, @T>}::count"]
def core.array.iter.IntoIter.Insts.CoreIterTraitsIteratorIterator.count {T : Type} {N : Usize}
  (it : core.array.iter.IntoIter T N) : Result Usize :=
  core.iter.traits.iterator.Iterator.count.default
    (core.array.iter.IntoIter.Insts.CoreIterTraitsIteratorIterator T N) it

@[rust_fun
  "core::array::iter::{core::iter::traits::iterator::Iterator<core::array::iter::IntoIter<@T, @N>, @T>}::fold"]
def core.array.iter.IntoIter.Insts.CoreIterTraitsIteratorIterator.fold
  {T Acc Fold : Type} {N : Usize} (FoldInst : core.ops.function.FnMut Fold (Acc × T) Acc)
  (it : core.array.iter.IntoIter T N) (init : Acc) (fold : Fold) : Result Acc :=
  core.iter.traits.iterator.Iterator.fold.default
    (core.array.iter.IntoIter.Insts.CoreIterTraitsIteratorIterator T N) FoldInst it init fold

/-! ## `Vec` -/

@[rust_fun
  "alloc::vec::into_iter::{core::iter::traits::iterator::Iterator<alloc::vec::into_iter::IntoIter<@T, @A>, @T>}::count"
  (keepParams := [true, false])]
def alloc.vec.into_iter.IntoIter.Insts.CoreIterTraitsIteratorIterator.count {T : Type}
  (it : alloc.vec.into_iter.IntoIter T) : Result Usize :=
  core.iter.traits.iterator.Iterator.count.default (core.iter.traits.iterator.IteratorVecIntoIter T) it

@[rust_fun
  "alloc::vec::into_iter::{core::iter::traits::iterator::Iterator<alloc::vec::into_iter::IntoIter<@T, @A>, @T>}::fold"
  (keepParams := [true, false, true, true])]
def alloc.vec.into_iter.IntoIter.Insts.CoreIterTraitsIteratorIterator.fold {T B F : Type}
  (FnMutInst : core.ops.function.FnMut F (B × T) B)
  (it : alloc.vec.into_iter.IntoIter T) (init : B) (f : F) : Result B :=
  core.iter.traits.iterator.Iterator.fold.default
    (core.iter.traits.iterator.IteratorVecIntoIter T) FnMutInst it init f

/-- `for x in &v`: the slice iterator -/
@[rust_fun
  "alloc::vec::{core::iter::traits::collect::IntoIterator<&'a alloc::vec::Vec<@T>, &'a @T, core::slice::iter::Iter<'a, @T>>}::into_iter"
  (keepParams := [true, false])]
def SharedAVec.Insts.CoreIterTraitsCollectIntoIteratorSharedATIter.into_iter {T : Type}
  (v : alloc.vec.Vec T) : Result (core.slice.iter.Iter T) :=
  ok { slice := alloc.vec.Vec.deref v, i := 0 }

@[reducible, rust_trait_impl
  "core::iter::traits::collect::IntoIterator<&'a alloc::vec::Vec<@T>, &'a @T, core::slice::iter::Iter<'a, @T>>"
  (keepParams := [true, false])]
def SharedAVec.Insts.CoreIterTraitsCollectIntoIteratorSharedATIter (T : Type) :
  core.iter.traits.collect.IntoIterator (alloc.vec.Vec T) T (core.slice.iter.Iter T) where
  iteratorInst := core.iter.traits.iterator.IteratorSliceIter T
  into_iter := SharedAVec.Insts.CoreIterTraitsCollectIntoIteratorSharedATIter.into_iter

/-! ## `Enumerate`, `Zip`, `FlatMap` -/

@[rust_fun
  "core::iter::adapters::enumerate::{core::iter::traits::iterator::Iterator<core::iter::adapters::enumerate::Enumerate<@I>, (usize, @Clause0_Item)>}::count"]
def core.iter.adapters.enumerate.Enumerate.Insts.CoreIterTraitsIteratorIteratorPairUsizeClause0_Item.count
  {I Item : Type} (IteratorInst : core.iter.traits.iterator.Iterator I Item)
  (it : core.iter.adapters.enumerate.Enumerate I) : Result Usize :=
  core.iter.traits.iterator.Iterator.count.default
    (core.iter.traits.iterator.IteratorEnumerate IteratorInst) it

@[rust_fun
  "core::iter::adapters::enumerate::{core::iter::traits::iterator::Iterator<core::iter::adapters::enumerate::Enumerate<@I>, (usize, @Clause0_Item)>}::fold"]
def core.iter.adapters.enumerate.Enumerate.Insts.CoreIterTraitsIteratorIteratorPairUsizeClause0_Item.fold
  {I Acc Fold Item : Type} (IteratorInst : core.iter.traits.iterator.Iterator I Item)
  (FoldInst : core.ops.function.FnMut Fold (Acc × (Usize × Item)) Acc)
  (it : core.iter.adapters.enumerate.Enumerate I) (init : Acc) (fold : Fold) : Result Acc :=
  core.iter.traits.iterator.Iterator.fold.default
    (core.iter.traits.iterator.IteratorEnumerate IteratorInst) FoldInst it init fold

/-- The smaller bounds (`zip.rs`) -/
@[rust_fun
  "core::iter::adapters::zip::{core::iter::traits::iterator::Iterator<core::iter::adapters::zip::Zip<@A, @B>, (@Clause0_Item, @Clause1_Item)>}::size_hint"]
def core.iter.adapters.zip.Zip.Insts.CoreIterTraitsIteratorIteratorPair.size_hint
  {A B ItemA ItemB : Type}
  (IA : core.iter.traits.iterator.Iterator A ItemA) (IB : core.iter.traits.iterator.Iterator B ItemB)
  (z : core.iter.adapters.zip.Zip A B) : Result (Usize × Option Usize) := do
  let (alo, ahi) ← IA.size_hint z.fst
  let (blo, bhi) ← IB.size_hint z.snd
  let min (x y : Usize) : Usize := if x.val ≤ y.val then x else y
  let hi := match ahi, bhi with
    | some x, some y => some (min x y)
    | some x, none => some x
    | none, some y => some y
    | none, none => none
  ok (min alo blo, hi)

@[reducible, rust_trait_impl
  "core::iter::traits::iterator::Iterator<core::iter::adapters::zip::Zip<@A, @B>, (@Clause0_Item, @Clause1_Item)>"]
def core.iter.adapters.zip.Zip.Insts.CoreIterTraitsIteratorIteratorPair
  {A B ItemA ItemB : Type}
  (IA : core.iter.traits.iterator.Iterator A ItemA) (IB : core.iter.traits.iterator.Iterator B ItemB) :
  core.iter.traits.iterator.Iterator (core.iter.adapters.zip.Zip A B) (ItemA × ItemB) where
  next := core.iter.adapters.zip.Zip.Insts.CoreIterTraitsIteratorIteratorPair.next IA IB
  size_hint := core.iter.adapters.zip.Zip.Insts.CoreIterTraitsIteratorIteratorPair.size_hint IA IB

@[rust_fun
  "core::iter::adapters::zip::{core::iter::traits::iterator::Iterator<core::iter::adapters::zip::Zip<@A, @B>, (@Clause0_Item, @Clause1_Item)>}::fold"]
def core.iter.adapters.zip.Zip.Insts.CoreIterTraitsIteratorIteratorPair.fold
  {A B Acc F ItemA ItemB : Type}
  (IA : core.iter.traits.iterator.Iterator A ItemA) (IB : core.iter.traits.iterator.Iterator B ItemB)
  (FInst : core.ops.function.FnMut F (Acc × (ItemA × ItemB)) Acc)
  (z : core.iter.adapters.zip.Zip A B) (init : Acc) (f : F) : Result Acc :=
  core.iter.traits.iterator.Iterator.fold.default
    (core.iter.adapters.zip.Zip.Insts.CoreIterTraitsIteratorIteratorPair IA IB) FInst z init f

@[rust_fun
  "core::iter::adapters::flatten::{core::iter::traits::iterator::Iterator<core::iter::adapters::flatten::FlatMap<@I, @U, @F, @Clause1_Item, @Clause1_IntoIter>, @Clause1_Item>}::count"]
def core.iter.adapters.flatten.FlatMap.Insts.CoreIterTraitsIteratorIterator.count
  {I U F Item0 Item IntoIter : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I Item0)
  (IntoIteratorInst : core.iter.traits.collect.IntoIterator U Item IntoIter)
  (FnMutInst : core.ops.function.FnMut F Item0 U)
  (it : core.iter.adapters.flatten.FlatMap I U F Item IntoIter) : Result Usize :=
  core.iter.traits.iterator.Iterator.count.default
    (core.iter.adapters.flatten.FlatMap.Insts.CoreIterTraitsIteratorIterator
      IteratorInst IntoIteratorInst FnMutInst) it

/-! ## Ranges -/

/-- `steps_between`'s exact count if `start < end`, panicking if it overflows `usize` (`range.rs`) -/
@[rust_fun
  "core::iter::range::{core::iter::traits::iterator::Iterator<core::ops::range::Range<@A>, @A>}::count"]
def core.ops.range.Range.Insts.CoreIterTraitsIteratorIterator.count {A : Type}
  (StepInst : core.iter.range.Step A) (r : core.ops.range.Range A) : Result Usize := do
  if ← StepInst.partialOrdInst.lt r.start r.end then
    let (_, hi) ← StepInst.steps_between r.start r.end
    match hi with
    | some n => ok n
    | none => fail .panic
  else ok 0#usize

/-- `self.next_back()`: the last item -/
@[rust_fun
  "core::iter::range::{core::iter::traits::iterator::Iterator<core::ops::range::Range<@A>, @A>}::max"]
def core.ops.range.Range.Insts.CoreIterTraitsIteratorIterator.max {A : Type}
  (StepInst : core.iter.range.Step A) (_OrdInst : core.cmp.Ord A) (r : core.ops.range.Range A) :
  Result (Option A) := do
  let (o, _) ← core.ops.range.Range.Insts.CoreIterTraitsDoubleEndedIterator.next_back StepInst r
  ok o

/-- `exhausted` or `start > end` -/
def core.ops.range.RangeInclusive.isEmpty {A : Type} (StepInst : core.iter.range.Step A)
  (r : core.ops.range.RangeInclusive A) : Result Bool := do
  if r.exhausted then ok true else ok !(← StepInst.partialOrdInst.le r.start r.end)

/-- One more than `steps_between`, panicking if that overflows `usize` (`range.rs`) -/
@[rust_fun
  "core::iter::range::{core::iter::traits::iterator::Iterator<core::ops::range::RangeInclusive<@A>, @A>}::count"]
def core.ops.range.RangeInclusive.Insts.CoreIterTraitsIteratorIterator.count {A : Type}
  (StepInst : core.iter.range.Step A) (r : core.ops.range.RangeInclusive A) : Result Usize := do
  if ← core.ops.range.RangeInclusive.isEmpty StepInst r then ok 0#usize
  else
    let (_, hi) ← StepInst.steps_between r.start r.end
    match hi with
    | some n => n + 1#usize
    | none => fail .panic

/-- `self.next_back()`: `end` unless empty -/
@[rust_fun
  "core::iter::range::{core::iter::traits::iterator::Iterator<core::ops::range::RangeInclusive<@A>, @A>}::max"]
def core.ops.range.RangeInclusive.Insts.CoreIterTraitsIteratorIterator.max {A : Type}
  (StepInst : core.iter.range.Step A) (_OrdInst : core.cmp.Ord A)
  (r : core.ops.range.RangeInclusive A) : Result (Option A) := do
  if ← core.ops.range.RangeInclusive.isEmpty StepInst r then ok none
  else ok (some (← StepInst.cloneInst.clone r.end))

@[rust_fun
  "core::iter::range::{core::iter::traits::iterator::Iterator<core::ops::range::RangeInclusive<@A>, @A>}::fold"]
def core.ops.range.RangeInclusive.Insts.CoreIterTraitsIteratorIterator.fold {A Acc F : Type}
  (StepInst : core.iter.range.Step A) (FInst : core.ops.function.FnMut F (Acc × A) Acc)
  (r : core.ops.range.RangeInclusive A) (init : Acc) (f : F) : Result Acc :=
  core.iter.traits.iterator.Iterator.fold.default
    (core.ops.range.RangeInclusive.Insts.CoreIterTraitsIteratorIterator StepInst) FInst r init f

/-- Derived -/
@[rust_fun "core::ops::range::{core::clone::Clone<core::ops::range::Range<@Idx>>}::clone"]
def core.ops.range.Range.Insts.CoreCloneClone.clone {Idx : Type} (CloneInst : core.clone.Clone Idx)
  (r : core.ops.range.Range Idx) : Result (core.ops.range.Range Idx) := do
  ok { start := ← CloneInst.clone r.start, «end» := ← CloneInst.clone r.end }

/-- Derived -/
@[rust_fun "core::ops::range::{core::clone::Clone<core::ops::range::RangeInclusive<@Idx>>}::clone"]
def core.ops.range.RangeInclusive.Insts.CoreCloneClone.clone {Idx : Type}
  (CloneInst : core.clone.Clone Idx) (r : core.ops.range.RangeInclusive Idx) :
  Result (core.ops.range.RangeInclusive Idx) := do
  ok { start := ← CloneInst.clone r.start, «end» := ← CloneInst.clone r.end, exhausted := r.exhausted }

/-! ## Slice `chunks` -/

/-- The slice left and the chunk size -/
@[rust_type "core::slice::iter::Chunks"]
structure core.slice.iter.Chunks (T : Type) where
  v : Slice T
  chunk_size : Usize

/-- Panics on `0` -/
@[rust_fun "core::slice::{[@T]}::chunks"]
def core.slice.Slice.chunks {T : Type} (s : Slice T) (chunk_size : Usize) :
  Result (core.slice.iter.Chunks T) :=
  if chunk_size.val = 0 then fail .panic else ok { v := s, chunk_size }

/-- The next `chunk_size` items, or fewer at the end -/
@[rust_fun
  "core::slice::iter::{core::iter::traits::iterator::Iterator<core::slice::iter::Chunks<'a, @T>, &'a [@T]>}::next"]
def core.slice.iter.Chunks.Insts.CoreIterTraitsIteratorIteratorSharedASlice.next {T : Type}
  (it : core.slice.iter.Chunks T) : Result ((Option (Slice T)) × (core.slice.iter.Chunks T)) :=
  if it.v.val = [] then ok (none, it)
  else
    let n := min it.v.val.length it.chunk_size.val
    let fst : Slice T := Slice.from (it.v.val.take n) (by have := it.v.property; simp <;> omega)
    let snd : Slice T := Slice.from (it.v.val.drop n) (by have := it.v.property; simp <;> omega)
    ok (some fst, { it with v := snd })

/-- Exact: `len.div_ceil(chunk_size)` -/
@[rust_fun
  "core::slice::iter::{core::iter::traits::iterator::Iterator<core::slice::iter::Chunks<'a, @T>, &'a [@T]>}::size_hint"]
def core.slice.iter.Chunks.Insts.CoreIterTraitsIteratorIteratorSharedASlice.size_hint {T : Type}
  (it : core.slice.iter.Chunks T) : Result (Usize × Option Usize) := do
  let n ← UScalar.tryMk .Usize ((it.v.val.length + it.chunk_size.val - 1) / it.chunk_size.val)
  ok (n, some n)

@[reducible, rust_trait_impl
  "core::iter::traits::iterator::Iterator<core::slice::iter::Chunks<'a, @T>, &'a [@T]>"]
def core.slice.iter.Chunks.Insts.CoreIterTraitsIteratorIteratorSharedASlice (T : Type) :
  core.iter.traits.iterator.Iterator (core.slice.iter.Chunks T) (Slice T) where
  next := core.slice.iter.Chunks.Insts.CoreIterTraitsIteratorIteratorSharedASlice.next
  size_hint := core.slice.iter.Chunks.Insts.CoreIterTraitsIteratorIteratorSharedASlice.size_hint

@[rust_fun
  "core::slice::iter::{core::iter::traits::iterator::Iterator<core::slice::iter::Chunks<'a, @T>, &'a [@T]>}::count"]
def core.slice.iter.Chunks.Insts.CoreIterTraitsIteratorIteratorSharedASlice.count {T : Type}
  (it : core.slice.iter.Chunks T) : Result Usize :=
  core.iter.traits.iterator.Iterator.count.default
    (core.slice.iter.Chunks.Insts.CoreIterTraitsIteratorIteratorSharedASlice T) it

/-! ## `IterMut`: the closure-free methods. `fold` and `any` take a closure of `&mut T`, whose
writes their Aeneas signature cannot return, so they have no model. -/

/-- Exact: the elements left -/
@[rust_fun
  "core::slice::iter::{core::iter::traits::iterator::Iterator<core::slice::iter::IterMut<'a, @T>, &'a mut @T>}::size_hint"]
def core.slice.iter.IterMut.Insts.CoreIterTraitsIteratorIteratorMutAT.size_hint {T : Type}
  (it : core.slice.iter.IterMut T) : Result (Usize × Option Usize) := do
  let n ← UScalar.tryMk .Usize (it.slice.val.length - it.i)
  ok (n, some n)

/-- The elements left; the slice is given back unchanged -/
@[rust_fun
  "core::slice::iter::{core::iter::traits::iterator::Iterator<core::slice::iter::IterMut<'a, @T>, &'a mut @T>}::count"]
def core.slice.iter.IterMut.Insts.CoreIterTraitsIteratorIteratorMutAT.count {T : Type}
  (it : core.slice.iter.IterMut T) : Result (Usize × core.slice.iter.IterMut T) := do
  let n ← UScalar.tryMk .Usize (it.slice.val.length - it.i)
  ok (n, it)

/-! ## `collect` into a `Result` -/

/-- Core's `GenericShunt`: the `Ok` items, stopping (and remembering the error) at the first
`Err` -/
structure core.iter.adapters.GenericShunt (I E : Type) where
  iter : I
  residual : Option E

def core.iter.adapters.GenericShunt.next {I T E : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I (core.result.Result T E))
  (s : core.iter.adapters.GenericShunt I E) :
  Result ((Option T) × core.iter.adapters.GenericShunt I E) := do
  -- Like core, this does not stop at a recorded error: it pulls the next input item.
  let (o, iter) ← IteratorInst.next s.iter
  match o with
  | none => ok (none, { s with iter })
  | some (.Ok x) => ok (some x, { s with iter })
  | some (.Err e) => ok (none, { iter, residual := some e })

/-- `(0, upper)` until an error, then `(0, Some(0))` -/
def core.iter.adapters.GenericShunt.size_hint {I T E : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I (core.result.Result T E))
  (s : core.iter.adapters.GenericShunt I E) : Result (Usize × Option Usize) := do
  if s.residual.isSome then ok (0#usize, some 0#usize)
  else
    let (_, hi) ← IteratorInst.size_hint s.iter
    ok (0#usize, hi)

@[reducible]
def core.iter.adapters.GenericShunt.iteratorInst {I T E : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I (core.result.Result T E)) :
  core.iter.traits.iterator.Iterator (core.iter.adapters.GenericShunt I E) T where
  next := core.iter.adapters.GenericShunt.next IteratorInst
  size_hint := core.iter.adapters.GenericShunt.size_hint IteratorInst

/-- The first error of the shunt's input, if any -/
def core.iter.adapters.GenericShunt.firstErr {I T E : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I (core.result.Result T E)) (iter : I) :
  Result (Option E) :=
  loop (fun (iter : I) => do
    let (o, iter) ← IteratorInst.next iter
    match o with
    | none => ok (.done none)
    | some (.Ok _) => ok (.cont iter)
    | some (.Err e) => ok (.done (some e))) iter

/-- `iter::try_process(iter, |i| i.collect())`: `V::from_iter` of the `Ok` items up to the first
`Err`, which, if there is one, is the result.

In core the shunt holds `&mut residual`, which `from_iter` cannot return here, so the error is
found by running the (pure) input again. That is the error core reports whenever `V::from_iter`
reads to the end, as every std collection does. -/
@[rust_fun
  "core::result::{core::iter::traits::collect::FromIterator<core::result::Result<@V, @E>, core::result::Result<@T, @E>>}::from_iter"]
def core.result.Result.Insts.CoreIterTraitsCollectFromIteratorResult.from_iter
  {T E V I IntoIter : Type}
  (FromIteratorInst : core.iter.traits.collect.FromIterator V T)
  (IntoIteratorInst : core.iter.traits.collect.IntoIterator I (core.result.Result T E) IntoIter)
  (input : I) : Std.Result (core.result.Result V E) := do
  let iter ← IntoIteratorInst.into_iter input
  let shunt : core.iter.adapters.GenericShunt IntoIter E := { iter, residual := none }
  let v ← FromIteratorInst.from_iter
    (core.iter.traits.collect.IntoIterator.Blanket
      (core.iter.adapters.GenericShunt.iteratorInst IntoIteratorInst.iteratorInst)) shunt
  match ← core.iter.adapters.GenericShunt.firstErr IntoIteratorInst.iteratorInst iter with
  | some e => ok (.Err e)
  | none => ok (.Ok v)

@[reducible, rust_trait_impl
  "core::iter::traits::collect::FromIterator<core::result::Result<@V, @E>, core::result::Result<@T, @E>>"]
def core.result.Result.Insts.CoreIterTraitsCollectFromIteratorResult {T : Type} (E : Type) {V : Type}
  (FromIteratorInst : core.iter.traits.collect.FromIterator V T) :
  core.iter.traits.collect.FromIterator (core.result.Result V E) (core.result.Result T E) where
  from_iter := fun {I IntoIter} IntoIteratorInst =>
    core.result.Result.Insts.CoreIterTraitsCollectFromIteratorResult.from_iter
      FromIteratorInst IntoIteratorInst

/-- `Option`'s derived `Eq`: a compile-time check, no runtime effect -/
@[rust_fun "core::option::{core::cmp::Eq<core::option::Option<@T>>}::assert_fields_are_eq"]
def core.option.Option.Insts.CoreCmpEq.assert_fields_are_eq {T : Type}
  (_EqInst : core.cmp.Eq T) (_ : Option T) : Result Unit :=
  ok ()

end Aeneas.Std
