/- `Iterator`'s provided methods, and the adapters and sources they build -/
module
public import Aeneas.Std.Core.Iter
public import Aeneas.Std.SliceIter
public import Aeneas.Std.Scalar.SaturatingOps
public section

set_option linter.dupNamespace false

namespace Aeneas.Std

open Result

/-! Each model follows its body in core (`iter/traits/iterator.rs`, `iter/adapters/*.rs`).
Where core overrides a provided method only for speed (`count`, `fold`, `any` on slices,
`Filter::count`, `Chain::fold`, ...) the model is the provided method, which computes the same
result: the overrides are required to agree with it. `size_hint` is the exception: there each
iterator's own is modelled, as it differs from the default. Integer overflow fails, as with
debug assertions (`count` and `sum` use `#[rustc_inherit_overflow_checks]`). -/

/-! ## Provided methods, from `next` -/

/-- `fold`: `f` over every item, front to back -/
@[trait_default, rust_fun "core::iter::traits::iterator::Iterator::fold"]
def core.iter.traits.iterator.Iterator.fold.default
  {Self B F Item : Type} [S : FoldShape B F]
  (IteratorInst : core.iter.traits.iterator.Iterator Self Item)
  (FnMutInst : core.ops.function.FnMut F (B × Item) B)
  (self : Self) (init : B) (f : F) : Result S.Out := do
  let (acc, f) ← loop (fun ((it, acc, f) : Self × B × F) => do
    let (o, it) ← IteratorInst.next it
    match o with
    | none => ok (.done (acc, f))
    | some x =>
      let (acc, f) ← FnMutInst.call_mut f (acc, x)
      ok (.cont (it, acc, f))) (self, init, f)
  ok (S.ofFold acc f)

/-- `count`: the number of items, panicking past `usize::MAX` -/
@[trait_default, rust_fun "core::iter::traits::iterator::Iterator::count"]
def core.iter.traits.iterator.Iterator.count.default
  {Self Item : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator Self Item)
  (self : Self) : Result Usize :=
  loop (fun ((it, n) : Self × Usize) => do
    let (o, it) ← IteratorInst.next it
    match o with
    | none => ok (.done n)
    | some _ => ok (.cont (it, ← n + 1#usize))) (self, 0#usize)

/-- `any`: whether some item satisfies `f`, stopping at the first; takes `&mut self` -/
@[trait_default, rust_fun "core::iter::traits::iterator::Iterator::any"]
def core.iter.traits.iterator.Iterator.any.default
  {Self F Item : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator Self Item)
  (FnMutInst : core.ops.function.FnMut F Item Bool)
  (self : Self) (f : F) : Result (Bool × Self) :=
  loop (fun ((it, f) : Self × F) => do
    let (o, it) ← IteratorInst.next it
    match o with
    | none => ok (.done (false, it))
    | some x =>
      let (b, f) ← FnMutInst.call_mut f x
      if b then ok (.done (true, it)) else ok (.cont (it, f))) (self, f)

/-- `max_by`: the greatest item by `compare`; of equal ones, the last (`cmp::max_by` keeps the
second unless the first is `Greater`) -/
@[trait_default, rust_fun "core::iter::traits::iterator::Iterator::max_by"]
def core.iter.traits.iterator.Iterator.max_by.default
  {Self F Item : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator Self Item)
  (FnMutInst : core.ops.function.FnMut F (Item × Item) Ordering)
  (self : Self) (compare : F) : Result (Option Item) := do
  let (o, it) ← IteratorInst.next self
  match o with
  | none => ok none
  | some first =>
    loop (fun ((it, best, compare) : Self × Item × F) => do
      let (o, it) ← IteratorInst.next it
      match o with
      | none => ok (.done (some best))
      | some x =>
        let (c, compare) ← FnMutInst.call_mut compare (best, x)
        ok (.cont (it, (if c = .gt then best else x), compare))) (it, first, compare)

/-- `Ord::cmp`, as a `FnMut` on pairs -/
def core.cmp.Ord.cmpFnMut {T : Type} (OrdInst : core.cmp.Ord T) :
    core.ops.function.FnMut Unit (T × T) Ordering where
  FnOnceInst := { call_once := fun _ (a, b) => OrdInst.cmp a b }
  call_mut := fun u (a, b) => do ok (← OrdInst.cmp a b, u)

/-- `max`: `max_by(Ord::cmp)` -/
@[trait_default, rust_fun "core::iter::traits::iterator::Iterator::max"]
def core.iter.traits.iterator.Iterator.max.default
  {Self Item : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator Self Item)
  (OrdInst : core.cmp.Ord Item) (self : Self) : Result (Option Item) :=
  core.iter.traits.iterator.Iterator.max_by.default IteratorInst
    (core.cmp.Ord.cmpFnMut OrdInst) self ()

/-- `sum`: `Sum::sum(self)` -/
@[trait_default, rust_fun "core::iter::traits::iterator::Iterator::sum"]
def core.iter.traits.iterator.Iterator.sum.default
  {Self S Item : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator Self Item)
  (SumInst : core.iter.traits.accum.Sum S Item) (self : Self) : Result S :=
  SumInst.sum IteratorInst self

/-- `Sum<usize> for usize`: `fold(0, +)`, panicking on overflow -/
@[rust_fun "core::iter::traits::accum::{core::iter::traits::accum::Sum<usize, usize>}::sum"]
def Usize.Insts.CoreIterTraitsAccumSumUsize.sum {I : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I Usize) (it : I) : Result Usize :=
  loop (fun ((it, s) : I × Usize) => do
    let (o, it) ← IteratorInst.next it
    match o with
    | none => ok (.done s)
    | some x => ok (.cont (it, ← s + x))) (it, 0#usize)

@[reducible, rust_trait_impl "core::iter::traits::accum::Sum<usize, usize>"]
def Usize.Insts.CoreIterTraitsAccumSumUsize : core.iter.traits.accum.Sum Usize Usize := {
  sum := Usize.Insts.CoreIterTraitsAccumSumUsize.sum
}

/-- `Ord::cmp` on `usize`, passed as a function (`max_by(Ord::cmp)`) -/
@[rust_fun
  "core::cmp::impls::{core::cmp::Ord<usize>}::{core::ops::function::FnOnce<@, (&'0 usize, &'1 usize), core::cmp::Ordering>}::call_once"]
def core.cmp.impls.OrdUsize.cmp.Insts.CoreOpsFunctionFnOnce.call_once
  (f : Usize → Usize → Ordering) (args : Usize × Usize) : Result Ordering :=
  ok (f args.1 args.2)

@[rust_fun
  "core::cmp::impls::{core::cmp::Ord<usize>}::{core::ops::function::FnMut<@, (&'0 usize, &'1 usize), core::cmp::Ordering>}::call_mut"]
def core.cmp.impls.OrdUsize.cmp.Insts.CoreOpsFunctionFnMut.call_mut
  (f : Usize → Usize → Ordering) (args : Usize × Usize) :
  Result (Ordering × (Usize → Usize → Ordering)) :=
  ok (f args.1 args.2, f)

/-! ## `Map` -/

/-- `f` of the inner item -/
@[rust_fun
  "core::iter::adapters::map::{core::iter::traits::iterator::Iterator<core::iter::adapters::map::Map<@I, @F>, @B>}::next"]
def core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator.next
  {B I F Item : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I Item)
  (FnMutInst : core.ops.function.FnMut F Item B)
  (self : core.iter.adapters.map.Map I F) :
  Result ((Option B) × (core.iter.adapters.map.Map I F)) := do
  let (o, iter) ← IteratorInst.next self.iter
  match o with
  | none => ok (none, { self with iter })
  | some x =>
    let (y, f) ← FnMutInst.call_mut self.f x
    ok (some y, { iter, f })

/-- The inner iterator's -/
@[rust_fun
  "core::iter::adapters::map::{core::iter::traits::iterator::Iterator<core::iter::adapters::map::Map<@I, @F>, @B>}::size_hint"]
def core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator.size_hint
  {B I F Item : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I Item)
  (_FnMutInst : core.ops.function.FnMut F Item B)
  (self : core.iter.adapters.map.Map I F) : Result (Usize × Option Usize) :=
  IteratorInst.size_hint self.iter

@[reducible, rust_trait_impl
  "core::iter::traits::iterator::Iterator<core::iter::adapters::map::Map<@I, @F>, @B>"]
def core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator
  {B I F Item : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I Item)
  (FnMutInst : core.ops.function.FnMut F Item B) :
  core.iter.traits.iterator.Iterator (core.iter.adapters.map.Map I F) B where
  next := core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator.next IteratorInst FnMutInst
  size_hint :=
    core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator.size_hint IteratorInst FnMutInst

/-- `Map::fold`: the inner `fold` with `g(acc, f(x))`, i.e. `fold` over `Map::next` -/
@[rust_fun
  "core::iter::adapters::map::{core::iter::traits::iterator::Iterator<core::iter::adapters::map::Map<@I, @F>, @B>}::fold"]
def core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator.fold
  {B I F Acc G Item : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I Item)
  (FnMutInst : core.ops.function.FnMut F Item B)
  (GInst : core.ops.function.FnMut G (Acc × B) Acc)
  (self : core.iter.adapters.map.Map I F) (init : Acc) (g : G) : Result Acc :=
  core.iter.traits.iterator.Iterator.fold.default
    (core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator IteratorInst FnMutInst)
    GInst self init g

@[trait_default, rust_fun "core::iter::traits::iterator::Iterator::map"]
def core.iter.traits.iterator.Iterator.map.default
  {Self B F Item : Type} [S : MapShape Self F]
  (_IteratorInst : core.iter.traits.iterator.Iterator Self Item)
  (_FnMutInst : core.ops.function.FnMut F Item B)
  (self : Self) (f : F) : Result S.Out :=
  ok (S.ofMap { iter := self, f })

/-! ## `Filter` -/

@[rust_type "core::iter::adapters::filter::Filter"]
structure core.iter.adapters.filter.Filter (I : Type u) (P : Type v) where
  iter : I
  predicate : P

/-- The next inner item satisfying the predicate -/
@[rust_fun
  "core::iter::adapters::filter::{core::iter::traits::iterator::Iterator<core::iter::adapters::filter::Filter<@I, @P>, @Clause0_Item>}::next"]
def core.iter.adapters.filter.Filter.Insts.CoreIterTraitsIteratorIterator.next
  {I P Item : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I Item)
  (FnMutInst : core.ops.function.FnMut P Item Bool)
  (self : core.iter.adapters.filter.Filter I P) :
  Result ((Option Item) × (core.iter.adapters.filter.Filter I P)) :=
  loop (fun (self : core.iter.adapters.filter.Filter I P) => do
    let (o, iter) ← IteratorInst.next self.iter
    match o with
    | none => ok (.done (none, { self with iter }))
    | some x =>
      let (b, predicate) ← FnMutInst.call_mut self.predicate x
      if b then ok (.done (some x, { iter, predicate }))
      else ok (.cont { iter, predicate })) self

/-- `(0, upper)`: the predicate may reject everything -/
@[rust_fun
  "core::iter::adapters::filter::{core::iter::traits::iterator::Iterator<core::iter::adapters::filter::Filter<@I, @P>, @Clause0_Item>}::size_hint"]
def core.iter.adapters.filter.Filter.Insts.CoreIterTraitsIteratorIterator.size_hint
  {I P Item : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I Item)
  (_FnMutInst : core.ops.function.FnMut P Item Bool)
  (self : core.iter.adapters.filter.Filter I P) : Result (Usize × Option Usize) := do
  let (_, hi) ← IteratorInst.size_hint self.iter
  ok (0#usize, hi)

@[reducible, rust_trait_impl
  "core::iter::traits::iterator::Iterator<core::iter::adapters::filter::Filter<@I, @P>, @Clause0_Item>"]
def core.iter.adapters.filter.Filter.Insts.CoreIterTraitsIteratorIterator
  {I P Item : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I Item)
  (FnMutInst : core.ops.function.FnMut P Item Bool) :
  core.iter.traits.iterator.Iterator (core.iter.adapters.filter.Filter I P) Item where
  next := core.iter.adapters.filter.Filter.Insts.CoreIterTraitsIteratorIterator.next IteratorInst FnMutInst
  size_hint :=
    core.iter.adapters.filter.Filter.Insts.CoreIterTraitsIteratorIterator.size_hint IteratorInst FnMutInst

@[rust_fun
  "core::iter::adapters::filter::{core::iter::traits::iterator::Iterator<core::iter::adapters::filter::Filter<@I, @P>, @Clause0_Item>}::count"]
def core.iter.adapters.filter.Filter.Insts.CoreIterTraitsIteratorIterator.count
  {I P Item : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I Item)
  (FnMutInst : core.ops.function.FnMut P Item Bool)
  (self : core.iter.adapters.filter.Filter I P) : Result Usize :=
  core.iter.traits.iterator.Iterator.count.default
    (core.iter.adapters.filter.Filter.Insts.CoreIterTraitsIteratorIterator IteratorInst FnMutInst)
    self

@[rust_fun
  "core::iter::adapters::filter::{core::iter::traits::iterator::Iterator<core::iter::adapters::filter::Filter<@I, @P>, @Clause0_Item>}::fold"]
def core.iter.adapters.filter.Filter.Insts.CoreIterTraitsIteratorIterator.fold
  {I P Acc Fold Item : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I Item)
  (FnMutInst : core.ops.function.FnMut P Item Bool)
  (FoldInst : core.ops.function.FnMut Fold (Acc × Item) Acc)
  (self : core.iter.adapters.filter.Filter I P) (init : Acc) (fold : Fold) : Result Acc :=
  core.iter.traits.iterator.Iterator.fold.default
    (core.iter.adapters.filter.Filter.Insts.CoreIterTraitsIteratorIterator IteratorInst FnMutInst)
    FoldInst self init fold

@[trait_default, rust_fun "core::iter::traits::iterator::Iterator::filter"]
def core.iter.traits.iterator.Iterator.filter.default
  {Self P Item : Type}
  (_IteratorInst : core.iter.traits.iterator.Iterator Self Item)
  (_FnMutInst : core.ops.function.FnMut P Item Bool)
  (self : Self) (predicate : P) : Result (core.iter.adapters.filter.Filter Self P) :=
  ok { iter := self, predicate }

/-! ## `FilterMap` -/

@[rust_type "core::iter::adapters::filter_map::FilterMap"]
structure core.iter.adapters.filter_map.FilterMap (I : Type u) (F : Type v) where
  iter : I
  f : F

/-- The next `Some` of `f` over the inner items -/
@[rust_fun
  "core::iter::adapters::filter_map::{core::iter::traits::iterator::Iterator<core::iter::adapters::filter_map::FilterMap<@I, @F>, @B>}::next"]
def core.iter.adapters.filter_map.FilterMap.Insts.CoreIterTraitsIteratorIterator.next
  {B I F Item : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I Item)
  (FnMutInst : core.ops.function.FnMut F Item (Option B))
  (self : core.iter.adapters.filter_map.FilterMap I F) :
  Result ((Option B) × (core.iter.adapters.filter_map.FilterMap I F)) :=
  loop (fun (self : core.iter.adapters.filter_map.FilterMap I F) => do
    let (o, iter) ← IteratorInst.next self.iter
    match o with
    | none => ok (.done (none, { self with iter }))
    | some x =>
      let (y, f) ← FnMutInst.call_mut self.f x
      match y with
      | some y => ok (.done (some y, { iter, f }))
      | none => ok (.cont { iter, f })) self

/-- `(0, upper)`: `f` may reject everything -/
@[rust_fun
  "core::iter::adapters::filter_map::{core::iter::traits::iterator::Iterator<core::iter::adapters::filter_map::FilterMap<@I, @F>, @B>}::size_hint"]
def core.iter.adapters.filter_map.FilterMap.Insts.CoreIterTraitsIteratorIterator.size_hint
  {B I F Item : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I Item)
  (_FnMutInst : core.ops.function.FnMut F Item (Option B))
  (self : core.iter.adapters.filter_map.FilterMap I F) : Result (Usize × Option Usize) := do
  let (_, hi) ← IteratorInst.size_hint self.iter
  ok (0#usize, hi)

@[reducible, rust_trait_impl
  "core::iter::traits::iterator::Iterator<core::iter::adapters::filter_map::FilterMap<@I, @F>, @B>"]
def core.iter.adapters.filter_map.FilterMap.Insts.CoreIterTraitsIteratorIterator
  {B I F Item : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I Item)
  (FnMutInst : core.ops.function.FnMut F Item (Option B)) :
  core.iter.traits.iterator.Iterator (core.iter.adapters.filter_map.FilterMap I F) B where
  next :=
    core.iter.adapters.filter_map.FilterMap.Insts.CoreIterTraitsIteratorIterator.next IteratorInst FnMutInst
  size_hint :=
    core.iter.adapters.filter_map.FilterMap.Insts.CoreIterTraitsIteratorIterator.size_hint IteratorInst FnMutInst

@[rust_fun
  "core::iter::adapters::filter_map::{core::iter::traits::iterator::Iterator<core::iter::adapters::filter_map::FilterMap<@I, @F>, @B>}::fold"]
def core.iter.adapters.filter_map.FilterMap.Insts.CoreIterTraitsIteratorIterator.fold
  {B I F Acc Fold Item : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I Item)
  (FnMutInst : core.ops.function.FnMut F Item (Option B))
  (FoldInst : core.ops.function.FnMut Fold (Acc × B) Acc)
  (self : core.iter.adapters.filter_map.FilterMap I F) (init : Acc) (fold : Fold) : Result Acc :=
  core.iter.traits.iterator.Iterator.fold.default
    (core.iter.adapters.filter_map.FilterMap.Insts.CoreIterTraitsIteratorIterator IteratorInst FnMutInst)
    FoldInst self init fold

@[trait_default, rust_fun "core::iter::traits::iterator::Iterator::filter_map"]
def core.iter.traits.iterator.Iterator.filter_map.default
  {Self B F Item : Type}
  (_IteratorInst : core.iter.traits.iterator.Iterator Self Item)
  (_FnMutInst : core.ops.function.FnMut F Item (Option B))
  (self : Self) (f : F) : Result (core.iter.adapters.filter_map.FilterMap Self F) :=
  ok { iter := self, f }

/-! ## `Chain` -/

/-- Core's: each half is dropped (`None`) once exhausted, `a` first -/
@[rust_type "core::iter::adapters::chain::Chain"]
structure core.iter.adapters.chain.Chain (A : Type u) (B : Type v) where
  a : Option A
  b : Option B

/-- `a`'s next item, then (once `a` is exhausted and dropped) `b`'s -/
@[rust_fun
  "core::iter::adapters::chain::{core::iter::traits::iterator::Iterator<core::iter::adapters::chain::Chain<@A, @B>, @Clause0_Item>}::next"]
def core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator.next
  {A B Item : Type}
  (IA : core.iter.traits.iterator.Iterator A Item)
  (IB : core.iter.traits.iterator.Iterator B Item)
  (self : core.iter.adapters.chain.Chain A B) :
  Result ((Option Item) × (core.iter.adapters.chain.Chain A B)) := do
  let nextB (self : core.iter.adapters.chain.Chain A B) :
      Result ((Option Item) × (core.iter.adapters.chain.Chain A B)) :=
    match self.b with
    | none => ok (none, self)
    | some b => do
      let (o, b) ← IB.next b
      ok (o, { self with b := some b })
  match self.a with
  | none => nextB self
  | some a =>
    let (o, a) ← IA.next a
    match o with
    | some x => ok (some x, { self with a := some a })
    | none => nextB { self with a := none }

/-- Both halves' bounds, added (lower saturating, upper checked) -/
@[rust_fun
  "core::iter::adapters::chain::{core::iter::traits::iterator::Iterator<core::iter::adapters::chain::Chain<@A, @B>, @Clause0_Item>}::size_hint"]
def core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator.size_hint
  {A B Item : Type}
  (IA : core.iter.traits.iterator.Iterator A Item)
  (IB : core.iter.traits.iterator.Iterator B Item)
  (self : core.iter.adapters.chain.Chain A B) : Result (Usize × Option Usize) := do
  match self.a, self.b with
  | some a, some b =>
    let (alo, ahi) ← IA.size_hint a
    let (blo, bhi) ← IB.size_hint b
    let lo := core.num.Usize.saturating_add alo blo
    let hi : Option Usize := match ahi, bhi with
      | some x, some y => Usize.checked_add x y
      | _, _ => none
    ok (lo, hi)
  | some a, none => IA.size_hint a
  | none, some b => IB.size_hint b
  | none, none => ok (0#usize, some 0#usize)

@[reducible, rust_trait_impl
  "core::iter::traits::iterator::Iterator<core::iter::adapters::chain::Chain<@A, @B>, @Clause0_Item>"]
def core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator
  {A B Item : Type}
  (IA : core.iter.traits.iterator.Iterator A Item)
  (IB : core.iter.traits.iterator.Iterator B Item) :
  core.iter.traits.iterator.Iterator (core.iter.adapters.chain.Chain A B) Item where
  next := core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator.next IA IB
  size_hint := core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator.size_hint IA IB

@[rust_fun
  "core::iter::adapters::chain::{core::iter::traits::iterator::Iterator<core::iter::adapters::chain::Chain<@A, @B>, @Clause0_Item>}::count"]
def core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator.count
  {A B Item : Type}
  (IA : core.iter.traits.iterator.Iterator A Item)
  (IB : core.iter.traits.iterator.Iterator B Item)
  (self : core.iter.adapters.chain.Chain A B) : Result Usize :=
  core.iter.traits.iterator.Iterator.count.default
    (core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator IA IB) self

@[rust_fun
  "core::iter::adapters::chain::{core::iter::traits::iterator::Iterator<core::iter::adapters::chain::Chain<@A, @B>, @Clause0_Item>}::fold"]
def core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator.fold
  {A B Acc F Item : Type}
  (IA : core.iter.traits.iterator.Iterator A Item)
  (IB : core.iter.traits.iterator.Iterator B Item)
  (FInst : core.ops.function.FnMut F (Acc × Item) Acc)
  (self : core.iter.adapters.chain.Chain A B) (init : Acc) (f : F) : Result Acc :=
  core.iter.traits.iterator.Iterator.fold.default
    (core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator IA IB) FInst self init f

/-- `Chain::new(self, other.into_iter())` -/
@[trait_default, rust_fun "core::iter::traits::iterator::Iterator::chain"]
def core.iter.traits.iterator.Iterator.chain.default
  {Self U Item IntoIter : Type}
  (_IteratorInst : core.iter.traits.iterator.Iterator Self Item)
  (IntoIteratorInst : core.iter.traits.collect.IntoIterator U Item IntoIter)
  (self : Self) (other : U) : Result (core.iter.adapters.chain.Chain Self IntoIter) := do
  ok { a := some self, b := some (← IntoIteratorInst.into_iter other) }

/-! ## `FlatMap` -/

/-- Core's `FlattenCompat` over `Map<I, F>`: the items of the iterator in front, then of `f` of
the next inner item (the back iterator is only filled by `next_back`, not modelled) -/
@[rust_type "core::iter::adapters::flatten::FlatMap" (body := .opaque)]
structure core.iter.adapters.flatten.FlatMap (I : Type u) (U : Type v) (F : Type w)
    (Item : Type x) (IntoIter : Type y) where
  iter : Option I
  f : F
  frontiter : Option IntoIter
  backiter : Option IntoIter

/-- `FlattenCompat::next`: drain `frontiter`; when it ends, refill it from the inner iterator
(fused: `iter` is dropped once exhausted), finally drain `backiter` -/
@[rust_fun
  "core::iter::adapters::flatten::{core::iter::traits::iterator::Iterator<core::iter::adapters::flatten::FlatMap<@I, @U, @F, @Clause1_Item, @Clause1_IntoIter>, @Clause1_Item>}::next"]
def core.iter.adapters.flatten.FlatMap.Insts.CoreIterTraitsIteratorIterator.next
  {I U F Item0 Item IntoIter : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I Item0)
  (IntoIteratorInst : core.iter.traits.collect.IntoIterator U Item IntoIter)
  (FnMutInst : core.ops.function.FnMut F Item0 U)
  (self : core.iter.adapters.flatten.FlatMap I U F Item IntoIter) :
  Result ((Option Item) × (core.iter.adapters.flatten.FlatMap I U F Item IntoIter)) :=
  loop (fun (self : core.iter.adapters.flatten.FlatMap I U F Item IntoIter) => do
    match self.frontiter with
    | some front =>
      -- `and_then_or_clear(&mut self.frontiter, Iterator::next)`
      let (o, front) ← IntoIteratorInst.iteratorInst.next front
      match o with
      | some x => ok (.done (some x, { self with frontiter := some front }))
      | none => ok (.cont { self with frontiter := none })
    | none =>
      match self.iter with
      | some it =>
        let (o, it) ← IteratorInst.next it
        match o with
        | some x =>
          let (u, f) ← FnMutInst.call_mut self.f x
          let front ← IntoIteratorInst.into_iter u
          ok (.cont { self with iter := some it, f, frontiter := some front })
        | none => ok (.cont { self with iter := none })
      | none =>
        match self.backiter with
        | none => ok (.done (none, self))
        | some back =>
          let (o, back) ← IntoIteratorInst.iteratorInst.next back
          ok (.done (o, { self with backiter := if o.isSome then some back else none }))) self

/-- `FlattenCompat::size_hint` without the `ConstSizeIntoIterator` case (no inner type here has
a constant size): the front and back iterators' bounds; an upper bound only once the inner
iterator is known to be empty -/
@[rust_fun
  "core::iter::adapters::flatten::{core::iter::traits::iterator::Iterator<core::iter::adapters::flatten::FlatMap<@I, @U, @F, @Clause1_Item, @Clause1_IntoIter>, @Clause1_Item>}::size_hint"]
def core.iter.adapters.flatten.FlatMap.Insts.CoreIterTraitsIteratorIterator.size_hint
  {I U F Item0 Item IntoIter : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I Item0)
  (IntoIteratorInst : core.iter.traits.collect.IntoIterator U Item IntoIter)
  (_FnMutInst : core.ops.function.FnMut F Item0 U)
  (self : core.iter.adapters.flatten.FlatMap I U F Item IntoIter) :
  Result (Usize × Option Usize) := do
  let hint (o : Option IntoIter) : Result (Usize × Option Usize) :=
    match o with
    | none => ok (0#usize, some 0#usize)
    | some it => IntoIteratorInst.iteratorInst.size_hint it
  let (flo, fhi) ← hint self.frontiter
  let (blo, bhi) ← hint self.backiter
  let lo := core.num.Usize.saturating_add flo blo
  let inner ← match self.iter with
    | none => ok (0#usize, some 0#usize)
    | some it => IteratorInst.size_hint it
  match inner, fhi, bhi with
  | (z, some z'), some a, some b =>
    if z.val = 0 ∧ z'.val = 0 then
      ok (lo, Usize.checked_add a b)
    else ok (lo, none)
  | _, _, _ => ok (lo, none)

@[reducible, rust_trait_impl
  "core::iter::traits::iterator::Iterator<core::iter::adapters::flatten::FlatMap<@I, @U, @F, @Clause1_Item, @Clause1_IntoIter>, @Clause1_Item>"]
def core.iter.adapters.flatten.FlatMap.Insts.CoreIterTraitsIteratorIterator
  {I U F Item0 Item IntoIter : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I Item0)
  (IntoIteratorInst : core.iter.traits.collect.IntoIterator U Item IntoIter)
  (FnMutInst : core.ops.function.FnMut F Item0 U) :
  core.iter.traits.iterator.Iterator (core.iter.adapters.flatten.FlatMap I U F Item IntoIter) Item where
  next := core.iter.adapters.flatten.FlatMap.Insts.CoreIterTraitsIteratorIterator.next
    IteratorInst IntoIteratorInst FnMutInst
  size_hint := core.iter.adapters.flatten.FlatMap.Insts.CoreIterTraitsIteratorIterator.size_hint
    IteratorInst IntoIteratorInst FnMutInst

@[rust_fun
  "core::iter::adapters::flatten::{core::iter::traits::iterator::Iterator<core::iter::adapters::flatten::FlatMap<@I, @U, @F, @Clause1_Item, @Clause1_IntoIter>, @Clause1_Item>}::fold"]
def core.iter.adapters.flatten.FlatMap.Insts.CoreIterTraitsIteratorIterator.fold
  {I U F Acc Fold Item0 Item IntoIter : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I Item0)
  (IntoIteratorInst : core.iter.traits.collect.IntoIterator U Item IntoIter)
  (FnMutInst : core.ops.function.FnMut F Item0 U)
  (FoldInst : core.ops.function.FnMut Fold (Acc × Item) Acc)
  (self : core.iter.adapters.flatten.FlatMap I U F Item IntoIter) (init : Acc) (fold : Fold) :
  Result Acc :=
  core.iter.traits.iterator.Iterator.fold.default
    (core.iter.adapters.flatten.FlatMap.Insts.CoreIterTraitsIteratorIterator
      IteratorInst IntoIteratorInst FnMutInst)
    FoldInst self init fold

@[trait_default, rust_fun "core::iter::traits::iterator::Iterator::flat_map"]
def core.iter.traits.iterator.Iterator.flat_map.default
  {Self U F Item0 Item IntoIter : Type}
  (_IteratorInst : core.iter.traits.iterator.Iterator Self Item0)
  (_IntoIteratorInst : core.iter.traits.collect.IntoIterator U Item IntoIter)
  (_FnMutInst : core.ops.function.FnMut F Item0 U)
  (self : Self) (f : F) : Result (core.iter.adapters.flatten.FlatMap Self U F Item IntoIter) :=
  ok { iter := some self, f, frontiter := none, backiter := none }

/-! ## `once` and `empty` -/

@[rust_type "core::iter::sources::once::Once" (body := .opaque)]
structure core.iter.sources.once.Once (T : Type u) where
  inner : Option T

@[rust_fun "core::iter::sources::once::once"]
def core.iter.sources.once.once {T : Type} (value : T) : Result (core.iter.sources.once.Once T) :=
  ok { inner := some value }

@[rust_fun
  "core::iter::sources::once::{core::iter::traits::iterator::Iterator<core::iter::sources::once::Once<@T>, @T>}::next"]
def core.iter.sources.once.Once.Insts.CoreIterTraitsIteratorIterator.next {T : Type}
  (self : core.iter.sources.once.Once T) : Result ((Option T) × (core.iter.sources.once.Once T)) :=
  ok (self.inner, { inner := none })

@[rust_fun
  "core::iter::sources::once::{core::iter::traits::iterator::Iterator<core::iter::sources::once::Once<@T>, @T>}::size_hint"]
def core.iter.sources.once.Once.Insts.CoreIterTraitsIteratorIterator.size_hint {T : Type}
  (self : core.iter.sources.once.Once T) : Result (Usize × Option Usize) :=
  let n := if self.inner.isSome then 1#usize else 0#usize
  ok (n, some n)

@[reducible, rust_trait_impl
  "core::iter::traits::iterator::Iterator<core::iter::sources::once::Once<@T>, @T>"]
def core.iter.sources.once.Once.Insts.CoreIterTraitsIteratorIterator (T : Type) :
  core.iter.traits.iterator.Iterator (core.iter.sources.once.Once T) T where
  next := core.iter.sources.once.Once.Insts.CoreIterTraitsIteratorIterator.next
  size_hint := core.iter.sources.once.Once.Insts.CoreIterTraitsIteratorIterator.size_hint

@[rust_type "core::iter::sources::empty::Empty" (body := .opaque)]
structure core.iter.sources.empty.Empty (T : Type u) where

@[rust_fun "core::iter::sources::empty::empty"]
def core.iter.sources.empty.empty (T : Type) : Result (core.iter.sources.empty.Empty T) :=
  ok {}

@[rust_fun
  "core::iter::sources::empty::{core::iter::traits::iterator::Iterator<core::iter::sources::empty::Empty<@T>, @T>}::next"]
def core.iter.sources.empty.Empty.Insts.CoreIterTraitsIteratorIterator.next {T : Type}
  (self : core.iter.sources.empty.Empty T) : Result ((Option T) × (core.iter.sources.empty.Empty T)) :=
  ok (none, self)

@[rust_fun
  "core::iter::sources::empty::{core::iter::traits::iterator::Iterator<core::iter::sources::empty::Empty<@T>, @T>}::size_hint"]
def core.iter.sources.empty.Empty.Insts.CoreIterTraitsIteratorIterator.size_hint {T : Type}
  (_ : core.iter.sources.empty.Empty T) : Result (Usize × Option Usize) :=
  ok (0#usize, some 0#usize)

@[reducible, rust_trait_impl
  "core::iter::traits::iterator::Iterator<core::iter::sources::empty::Empty<@T>, @T>"]
def core.iter.sources.empty.Empty.Insts.CoreIterTraitsIteratorIterator (T : Type) :
  core.iter.traits.iterator.Iterator (core.iter.sources.empty.Empty T) T where
  next := core.iter.sources.empty.Empty.Insts.CoreIterTraitsIteratorIterator.next
  size_hint := core.iter.sources.empty.Empty.Insts.CoreIterTraitsIteratorIterator.size_hint

/-- `position`: the index of the first item the predicate accepts (the count overflowing
fails, as with `#[rustc_inherit_overflow_checks]`) -/
@[trait_default, rust_fun "core::iter::traits::iterator::Iterator::position"]
def core.iter.traits.iterator.Iterator.position.default
  {Self P Item : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator Self Item)
  (FnMutInst : core.ops.function.FnMut P Item Bool)
  (self : Self) (p : P) : Result ((Option Usize) × Self) :=
  loop (fun ((it, p, i) : Self × P × Nat) => do
    let (o, it) ← IteratorInst.next it
    match o with
    | none => ok (.done (none, it))
    | some x =>
      let (b, p) ← FnMutInst.call_mut p x
      if b then
        let i ← UScalar.tryMk .Usize i
        ok (.done (some i, it))
      else ok (.cont (it, p, i + 1))) (self, p, 0)

/-! ## Slice iterators: core's overrides, which agree with the provided methods -/

@[rust_fun
  "core::slice::iter::{core::iter::traits::iterator::Iterator<core::slice::iter::Iter<'a, @T>, &'a @T>}::fold"]
def core.slice.iter.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAT.fold
  {T B F : Type} [S : FoldShape B F] (FnMutInst : core.ops.function.FnMut F (B × T) B)
  (it : core.slice.iter.Iter T) (init : B) (f : F) : Result S.Out :=
  core.iter.traits.iterator.Iterator.fold.default (S := S)
    (core.iter.traits.iterator.IteratorSliceIter T) FnMutInst it init f

@[rust_fun
  "core::slice::iter::{core::iter::traits::iterator::Iterator<core::slice::iter::Iter<'a, @T>, &'a @T>}::position"]
def core.slice.iter.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAT.position {T P : Type}
  (FnMutInst : core.ops.function.FnMut P T Bool) (it : core.slice.iter.Iter T) (p : P) :
  Result ((Option Usize) × core.slice.iter.Iter T) :=
  core.iter.traits.iterator.Iterator.position.default
    (core.iter.traits.iterator.IteratorSliceIter T) FnMutInst it p

@[rust_fun
  "core::slice::iter::{core::iter::traits::iterator::Iterator<core::slice::iter::Iter<'a, @T>, &'a @T>}::count"]
def core.slice.iter.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAT.count {T : Type}
  (it : core.slice.iter.Iter T) : Result Usize :=
  core.iter.traits.iterator.Iterator.count.default (core.iter.traits.iterator.IteratorSliceIter T) it

@[rust_fun
  "core::slice::iter::{core::iter::traits::iterator::Iterator<core::slice::iter::Iter<'a, @T>, &'a @T>}::any"]
def core.slice.iter.Iter.Insts.CoreIterTraitsIteratorIteratorSharedAT.any
  {T F : Type} (FnMutInst : core.ops.function.FnMut F T Bool)
  (it : core.slice.iter.Iter T) (f : F) : Result (Bool × core.slice.iter.Iter T) :=
  core.iter.traits.iterator.Iterator.any.default
    (core.iter.traits.iterator.IteratorSliceIter T) FnMutInst it f

end Aeneas.Std
