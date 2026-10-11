/- `Cloned`, `Successors`, `Rev::fold`, `Zip::next_back`, `Take::fold`, `unzip`, `reduce`,
`sort_by_key` -/
module
public import Aeneas.Std.Core.IterAdapters
public import Aeneas.Std.VecExtra
public section

set_option linter.dupNamespace false

namespace Aeneas.Std

open Result

/-! ## `Cloned` -/

@[rust_type "core::iter::adapters::cloned::Cloned"]
structure core.iter.adapters.cloned.Cloned (I : Type) where
  it : I

/-- `Iterator::cloned`: `Cloned::new(self)`. `Self: Iterator<Item = &T>` and the trait's own
`Self: Iterator` are two instances over the same iterator. -/
@[trait_default, rust_fun "core::iter::traits::iterator::Iterator::cloned"]
def core.iter.traits.iterator.Iterator.cloned.default {Self T Item : Type}
    (_IteratorSharedInst : core.iter.traits.iterator.Iterator Self T)
    (_CloneInst : core.clone.Clone T)
    (_IteratorInst : core.iter.traits.iterator.Iterator Self Item) (self : Self) :
    Result (core.iter.adapters.cloned.Cloned Self) :=
  ok ⟨self⟩

/-- The inner iterator's next item, cloned -/
@[rust_fun
  "core::iter::adapters::cloned::{core::iter::traits::iterator::Iterator<core::iter::adapters::cloned::Cloned<@I>, @T>}::next"]
def core.iter.adapters.cloned.Cloned.Insts.CoreIterTraitsIteratorIterator.next {I T : Type}
    (IteratorInst : core.iter.traits.iterator.Iterator I T) (CloneInst : core.clone.Clone T)
    (self : core.iter.adapters.cloned.Cloned I) :
    Result ((Option T) × core.iter.adapters.cloned.Cloned I) := do
  let (o, it) ← IteratorInst.next self.it
  match o with
  | none => ok (none, ⟨it⟩)
  | some x => ok (some (← CloneInst.clone x), ⟨it⟩)

@[rust_fun
  "core::iter::adapters::cloned::{core::iter::traits::iterator::Iterator<core::iter::adapters::cloned::Cloned<@I>, @T>}::size_hint"]
def core.iter.adapters.cloned.Cloned.Insts.CoreIterTraitsIteratorIterator.size_hint {I T : Type}
    (IteratorInst : core.iter.traits.iterator.Iterator I T) (_CloneInst : core.clone.Clone T)
    (self : core.iter.adapters.cloned.Cloned I) : Result (Usize × Option Usize) :=
  IteratorInst.size_hint self.it

@[reducible, rust_trait_impl
  "core::iter::traits::iterator::Iterator<core::iter::adapters::cloned::Cloned<@I>, @T>"]
def core.iter.adapters.cloned.Cloned.Insts.CoreIterTraitsIteratorIterator {I T : Type}
    (IteratorInst : core.iter.traits.iterator.Iterator I T) (CloneInst : core.clone.Clone T) :
    core.iter.traits.iterator.Iterator (core.iter.adapters.cloned.Cloned I) T where
  next := core.iter.adapters.cloned.Cloned.Insts.CoreIterTraitsIteratorIterator.next
    IteratorInst CloneInst
  size_hint := core.iter.adapters.cloned.Cloned.Insts.CoreIterTraitsIteratorIterator.size_hint
    IteratorInst CloneInst

@[rust_fun
  "core::iter::adapters::cloned::{core::iter::traits::iterator::Iterator<core::iter::adapters::cloned::Cloned<@I>, @T>}::fold"]
def core.iter.adapters.cloned.Cloned.Insts.CoreIterTraitsIteratorIterator.fold
    {I T Acc F : Type} {Out : Type} [S : FoldShape Acc F Out]
    (IteratorInst : core.iter.traits.iterator.Iterator I T) (CloneInst : core.clone.Clone T)
    (FnMutInst : core.ops.function.FnMut F (Acc × T) Acc)
    (self : core.iter.adapters.cloned.Cloned I) (init : Acc) (f : F) : Result Out :=
  core.iter.traits.iterator.Iterator.fold.default (S := S)
    (core.iter.adapters.cloned.Cloned.Insts.CoreIterTraitsIteratorIterator IteratorInst
      CloneInst) FnMutInst self init f

/-! ## `Successors` -/

@[rust_type "core::iter::sources::successors::Successors"]
structure core.iter.sources.successors.Successors (T F : Type) where
  next : Option T
  succ : F

@[rust_fun "core::iter::sources::successors::successors"]
def core.iter.sources.successors.successors {T F : Type}
    (_FnMutInst : core.ops.function.FnMut F T (Option T)) (first : Option T) (succ : F) :
    Result (core.iter.sources.successors.Successors T F) :=
  ok ⟨first, succ⟩

/-- The pending item, the next one computed from it -/
@[rust_fun
  "core::iter::sources::successors::{core::iter::traits::iterator::Iterator<core::iter::sources::successors::Successors<@T, @F>, @T>}::next"]
def core.iter.sources.successors.Successors.Insts.CoreIterTraitsIteratorIterator.next
    {T F : Type} (FnMutInst : core.ops.function.FnMut F T (Option T))
    (self : core.iter.sources.successors.Successors T F) :
    Result ((Option T) × core.iter.sources.successors.Successors T F) := do
  match self.next with
  | none => ok (none, self)
  | some x =>
    let (n, succ) ← FnMutInst.call_mut self.succ x
    ok (some x, ⟨n, succ⟩)

/-- `(1, None)` while an item is pending, else `(0, Some(0))` -/
@[rust_fun
  "core::iter::sources::successors::{core::iter::traits::iterator::Iterator<core::iter::sources::successors::Successors<@T, @F>, @T>}::size_hint"]
def core.iter.sources.successors.Successors.Insts.CoreIterTraitsIteratorIterator.size_hint
    {T F : Type} (_FnMutInst : core.ops.function.FnMut F T (Option T))
    (self : core.iter.sources.successors.Successors T F) : Result (Usize × Option Usize) :=
  match self.next with
  | some _ => ok (1#usize, none)
  | none => ok (0#usize, some 0#usize)

@[reducible, rust_trait_impl
  "core::iter::traits::iterator::Iterator<core::iter::sources::successors::Successors<@T, @F>, @T>"]
def core.iter.sources.successors.Successors.Insts.CoreIterTraitsIteratorIterator {T F : Type}
    (FnMutInst : core.ops.function.FnMut F T (Option T)) :
    core.iter.traits.iterator.Iterator (core.iter.sources.successors.Successors T F) T where
  next := core.iter.sources.successors.Successors.Insts.CoreIterTraitsIteratorIterator.next
    FnMutInst
  size_hint :=
    core.iter.sources.successors.Successors.Insts.CoreIterTraitsIteratorIterator.size_hint
      FnMutInst

/-! ## `Rev::fold`, `Zip::next_back` -/

/-- `DoubleEndedIterator::rfold`: `f` over every item, back to front -/
def core.iter.traits.double_ended.DoubleEndedIterator.rfold {I B F Item : Type}
    (DEInst : core.iter.traits.double_ended.DoubleEndedIterator I Item)
    (FnMutInst : core.ops.function.FnMut F (B × Item) B) (it : I) (init : B) (f : F) :
    Result (B × F) :=
  loop (fun ((it, acc, f) : I × B × F) => do
    let (o, it) ← DEInst.next_back it
    match o with
    | none => ok (.done (acc, f))
    | some x =>
      let (acc, f) ← FnMutInst.call_mut f (acc, x)
      ok (.cont (it, acc, f))) (it, init, f)

/-- `Rev::fold`: the inner iterator's `rfold` -/
@[rust_fun
  "core::iter::adapters::rev::{core::iter::traits::iterator::Iterator<core::iter::adapters::rev::Rev<@I>, @Clause0_Clause0_Item>}::fold"]
def core.iter.adapters.rev.Rev.Insts.CoreIterTraitsIteratorIterator.fold
    {I Acc F Item : Type} {Out : Type} [S : FoldShape Acc F Out]
    (DEInst : core.iter.traits.double_ended.DoubleEndedIterator I Item)
    (FnMutInst : core.ops.function.FnMut F (Acc × Item) Acc)
    (self : core.iter.adapters.rev.Rev I) (init : Acc) (f : F) : Result Out := do
  let (acc, f) ← core.iter.traits.double_ended.DoubleEndedIterator.rfold DEInst FnMutInst
    self.iter init f
  ok (S.ofFold acc f)

/-- `ExactSizeIterator::len`: the exact `size_hint`, asserted -/
def core.iter.traits.exact_size.ExactSizeIterator.len {I Item : Type}
    (Inst : core.iter.traits.exact_size.ExactSizeIterator I Item) (it : I) : Result Usize := do
  let (lo, hi) ← Inst.iteratorInst.size_hint it
  if hi = some lo then ok lo else fail .panic

/-- `n` calls of `next_back`, the items dropped -/
def core.iter.traits.double_ended.DoubleEndedIterator.dropBack {I Item : Type}
    (DEInst : core.iter.traits.double_ended.DoubleEndedIterator I Item) : Nat → I → Result I
  | 0, it => ok it
  | n + 1, it => do
    let (_, it) ← DEInst.next_back it
    core.iter.traits.double_ended.DoubleEndedIterator.dropBack DEInst n it

/-- `Zip::next_back` on exact-size iterators (core's general `ZipImpl`): trim the longer side
to the shorter's length from the back, then take both last items -/
@[rust_fun
  "core::iter::adapters::zip::{core::iter::traits::double_ended::DoubleEndedIterator<core::iter::adapters::zip::Zip<@A, @B>, (@Clause0_Clause0_Item, @Clause2_Clause0_Item)>}::next_back"]
def core.iter.adapters.zip.Zip.Insts.CoreIterTraitsDouble_endedDoubleEndedIteratorPair.next_back
    {A B ItemA ItemA' ItemB ItemB' : Type}
    (DEA : core.iter.traits.double_ended.DoubleEndedIterator A ItemA)
    (ESA : core.iter.traits.exact_size.ExactSizeIterator A ItemA')
    (DEB : core.iter.traits.double_ended.DoubleEndedIterator B ItemB)
    (ESB : core.iter.traits.exact_size.ExactSizeIterator B ItemB')
    (self : core.iter.adapters.zip.Zip A B) :
    Result ((Option (ItemA × ItemB)) × core.iter.adapters.zip.Zip A B) := do
  let la ← core.iter.traits.exact_size.ExactSizeIterator.len ESA self.fst
  let lb ← core.iter.traits.exact_size.ExactSizeIterator.len ESB self.snd
  let a ← core.iter.traits.double_ended.DoubleEndedIterator.dropBack DEA (la.val - lb.val)
    self.fst
  let b ← core.iter.traits.double_ended.DoubleEndedIterator.dropBack DEB (lb.val - la.val)
    self.snd
  let (oa, a) ← DEA.next_back a
  let (ob, b) ← DEB.next_back b
  match oa, ob with
  | some x, some y => ok (some (x, y), ⟨a, b⟩)
  | none, none => ok (none, ⟨a, b⟩)
  | _, _ => fail .panic -- `unreachable!()`: the lengths were made equal

/-! ## `Take::fold`, `Take::count`: the provided methods (core overrides them for speed) -/

@[rust_fun
  "core::iter::adapters::take::{core::iter::traits::iterator::Iterator<core::iter::adapters::take::Take<@I>, @Clause0_Item>}::fold"]
def core.iter.adapters.take.Take.Insts.CoreIterTraitsIteratorIterator.fold
    {I B F Item : Type} {Out : Type} [S : FoldShape B F Out]
    (IteratorInst : core.iter.traits.iterator.Iterator I Item)
    (FnMutInst : core.ops.function.FnMut F (B × Item) B)
    (self : core.iter.adapters.take.Take I) (init : B) (f : F) : Result Out :=
  core.iter.traits.iterator.Iterator.fold.default (S := S)
    (core.iter.traits.iterator.IteratorTake IteratorInst) FnMutInst self init f

@[rust_fun
  "core::iter::adapters::take::{core::iter::traits::iterator::Iterator<core::iter::adapters::take::Take<@I>, @Clause0_Item>}::count"]
def core.iter.adapters.take.Take.Insts.CoreIterTraitsIteratorIterator.count {I Item : Type}
    (IteratorInst : core.iter.traits.iterator.Iterator I Item)
    (self : core.iter.adapters.take.Take I) : Result Usize :=
  core.iter.traits.iterator.Iterator.count.default
    (core.iter.traits.iterator.IteratorTake IteratorInst) self

/-! ## `unzip`, `reduce` -/

/-- `unzip`: each pair's halves `extend_one`d (`extend` with one item) onto defaults -/
@[trait_default, rust_fun "core::iter::traits::iterator::Iterator::unzip"]
def core.iter.traits.iterator.Iterator.unzip.default {Self A B FromA FromB Item : Type}
    (IteratorPairInst : core.iter.traits.iterator.Iterator Self (A × B))
    (DefaultAInst : core.default.Default FromA) (ExtendAInst : core.iter.traits.collect.Extend FromA A)
    (DefaultBInst : core.default.Default FromB) (ExtendBInst : core.iter.traits.collect.Extend FromB B)
    (_IteratorInst : core.iter.traits.iterator.Iterator Self Item) (self : Self) :
    Result (FromA × FromB) := do
  let items ← alloc.collections.btree.toList IteratorPairInst self
  items.foldlM (fun ((fa, fb) : FromA × FromB) ((a, b) : A × B) => do
    let fa ← ExtendAInst.extend (core.iter.traits.collect.IntoIteratorVec A) fa
      (alloc.vec.Vec.from [a] (by simp; scalar_tac))
    let fb ← ExtendBInst.extend (core.iter.traits.collect.IntoIteratorVec B) fb
      (alloc.vec.Vec.from [b] (by simp; scalar_tac))
    ok (fa, fb)) (← DefaultAInst.default, ← DefaultBInst.default)

/-- `reduce`: the first item folded with the rest -/
@[trait_default, rust_fun "core::iter::traits::iterator::Iterator::reduce"]
def core.iter.traits.iterator.Iterator.reduce.default {Self F Item : Type}
    (IteratorInst : core.iter.traits.iterator.Iterator Self Item)
    (FnMutInst : core.ops.function.FnMut F (Item × Item) Item) (self : Self) (f : F) :
    Result (Option Item) := do
  let (o, it) ← IteratorInst.next self
  match o with
  | none => ok none
  | some first =>
    let (acc, _) ← loop (fun ((it, acc, f) : Self × Item × F) => do
      let (o, it) ← IteratorInst.next it
      match o with
      | none => ok (.done (acc, f))
      | some x =>
        let (acc, f) ← FnMutInst.call_mut f (acc, x)
        ok (.cont (it, acc, f))) (it, first, f)
    ok (some acc)

/-! ## `sort_by_key` -/

/-- Insert `x` after the elements whose key is not greater (so equal keys keep their order) -/
def List.insertByKeyM {T K : Type} (cmp : K → K → Result Ordering) (x : T × K) :
    List (T × K) → Result (List (T × K))
  | [] => ok [x]
  | y :: ys => do
    if (← cmp x.2 y.2) = .lt then ok (x :: y :: ys)
    else ok (y :: (← List.insertByKeyM cmp x ys))

/-- A stable sort by the keys `f` computes, called once per element in order (core's merge sort
calls it an unspecified number of times: the same result for a key function without state).
The closure's state is not given back: `sort_by_key` takes `F` by value. -/
@[rust_fun "alloc::slice::{[@T]}::sort_by_key"]
def alloc.slice.Slice.sort_by_key {T K F : Type} (FnMutInst : core.ops.function.FnMut F T K)
    (OrdInst : core.cmp.Ord K) (s : Slice T) (f : F) : Result (Slice T) := do
  let (keyed, _) ← s.val.foldlM (fun ((acc, f) : List (T × K) × F) x => do
    let (k, f) ← FnMutInst.call_mut f x
    ok (acc ++ [(x, k)], f)) ([], f)
  let sorted ← keyed.foldlM (fun acc x => List.insertByKeyM OrdInst.cmp x acc) []
  let l := sorted.map Prod.fst
  if h : l.length ≤ Usize.max then ok (Slice.from l h) else fail .panic

end Aeneas.Std
