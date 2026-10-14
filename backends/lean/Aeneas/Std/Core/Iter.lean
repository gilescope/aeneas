module
public import Aeneas.Std.Core.Cmp
public import Aeneas.Std.Primitives
public import Aeneas.Std.Range
public import Aeneas.Std.Scalar.Core
public import Aeneas.Std.Scalar.Notations
public import Aeneas.Std.Scalar.CloneCopy
public import Aeneas.Std.Scalar.EqOrd
public import Aeneas.Std.Scalar.CheckedOps
public import Aeneas.Std.Core.Core
public import Aeneas.Std.Core.Ops
public section

@[expose] section

namespace Aeneas.Std

@[rust_trait "core::iter::range::Step"
  (parentClauses := ["cloneInst", "partialOrdInst"])]
structure core.iter.range.Step (Self : Type) where
  cloneInst : core.clone.Clone Self
  partialOrdInst : core.cmp.PartialOrd Self Self
  steps_between : Self → Self → Result (Usize × (Option Usize))
  forward_checked : Self → Usize → Result (Option Self)
  backward_checked : Self → Usize → Result (Option Self)

open Result

@[rust_trait "core::iter::adapters::zip::TrustedRandomAccessNoCoerce"
  (consts := ["MAY_HAVE_SIDE_EFFECT"])]
structure core.iter.adapters.zip.TrustedRandomAccessNoCoerce (Self : Type u)
  where
  MAY_HAVE_SIDE_EFFECT : Bool

@[rust_type "core::iter::adapters::step_by::StepBy" (body := .opaque)]
structure core.iter.adapters.step_by.StepBy (I : Type u) where
  iter : I
  /- This is not exactly the way the implementation is defined in the standard library, but this is a good model -/
  step_by : Usize

@[rust_type "core::iter::adapters::enumerate::Enumerate"]
structure core.iter.adapters.enumerate.Enumerate (I : Type u) where
  iter : I
  count : Usize

@[rust_type "core::iter::adapters::take::Take"]
structure core.iter.adapters.take.Take (I : Type u) where
  iter : I
  n : Usize

@[rust_type "core::iter::adapters::rev::Rev"]
structure core.iter.adapters.rev.Rev (T : Type u) where
  iter : T

@[rust_type "core::iter::adapters::take_while::TakeWhile"]
structure core.iter.adapters.take_while.TakeWhile (I : Type u) (P : Type u) where
  iter : I
  flag : Bool
  predicate : P

/-- `core::iter::adapters::zip::Zip` — the `a.zip(b)` adapter.

    The real Rust struct also carries `index`/`len` fields used for instance
    by the `TrustedRandomAccess` specialisation; for now we omit them. -/
@[rust_type "core::iter::adapters::zip::Zip"]
structure core.iter.adapters.zip.Zip (A : Type u) (B : Type u) where
  mk ::
  fst : A
  snd : B

def core.iter.traits.iterator.Iterator.step_by.default
  {Self : Type} (self: Self) (step_by : Std.Usize) :
  Result (core.iter.adapters.step_by.StepBy Self) :=
  if step_by.val = 0 then .fail .panic
  else .ok ⟨ self, step_by ⟩

def core.iter.traits.iterator.Iterator.enumerate.default
  {Self : Type} (self: Self) :
  Result (core.iter.adapters.enumerate.Enumerate Self) :=
  .ok { iter := self, count := 0#usize }

def core.iter.traits.iterator.Iterator.take.default
  {Self : Type} (self: Self) (n : Std.Usize) :
  Result (core.iter.adapters.take.Take Self) :=
  .ok ⟨ self, n ⟩


/-! ## Mutable regions, and what is given back through them

A `&mut` iterator (`iter_mut()`, and every adapter over one) holds a mutable region per
borrowed slice; Aeneas gives each back through a backward function of its own, so a call's
output shape depends on how many regions `Self` holds: a constructor returns
`(w, back_1, .., back_n)` with `back_i : W → Self`, `next` returns `(o, it, nb_1, .., nb_n)`
with `nb_i : I → Option Item → I` (each writes its region's part of the item), and a consumer
returns the final iterator once per region. `MutRegions` is that count at the type level, and
the `Backs`/`FinalsWith`/`Prods` shapes below are what the models return. The backward functions
themselves ride on the `Iterator` instance (`nextMut`), so adapters compose without knowing
what they wrap, and a plain iterator (no region) keeps today's shapes. -/

/-- `T` holds a `&mut` (in one region): generic functions it is moved into give it back.
Aeneas emits an instance for each closure capturing one. -/
class GivesBack (T : Type u) : Prop where

/-- How many mutable regions `T` holds: `IterMut` one, `Zip<IterMut, IterMut>` two, an
adapter as many as the iterator it wraps; none unless an instance says otherwise. -/
class MutRegions (T : Type) where
  n : Nat

instance (priority := low) plainMutRegions {T : Type} : MutRegions T := ⟨0⟩

@[simp] theorem plainMutRegions_n {T : Type} : (plainMutRegions (T := T)).n = 0 := rfl

/-- `W` followed by the types in `l`, right-nested as Lean tuples are: `Tup W [A, B]` is
`W × (A × B)`, which `let (w, a, b) ← …` destructures. -/
@[reducible] def Tup : Type → List Type → Type
  | W, [] => W
  | W, A :: l => W × Tup A l

/-- A value per type in `l` -/
inductive HList : List Type → Type 1
  | nil : HList []
  | cons {A : Type} {l : List Type} : A → HList l → HList (A :: l)

def Tup.ofHList {W : Type} : {l : List Type} → W → HList l → Tup W l
  | [], w, _ => w
  | _ :: _, w, .cons a rest => (w, Tup.ofHList a rest)

def HList.replicate {F : Type} : (n : Nat) → F → HList (List.replicate n F)
  | 0, _ => .nil
  | n + 1, f => .cons f (HList.replicate n f)

/-- The `i`th element of `l` for each `i < n`, `dflt` past its end -/
def HList.ofList {F : Type} (l : List F) (dflt : F) : (n : Nat) → HList (List.replicate n F)
  | 0 => .nil
  | n + 1 => .cons (l.headD dflt) (HList.ofList l.tail dflt n)

def HList.append : {l1 l2 : List Type} → HList l1 → HList l2 → HList (l1 ++ l2)
  | [], _, .nil, bs => bs
  | _ :: _, _, .cons a rest, bs => .cons a (HList.append rest bs)

/-- `W` and `n` backward functions `F`: `W`, `W × F`, `W × (F × F)`, ... -/
abbrev Backs (n : Nat) (W F : Type) : Type := Tup W (List.replicate n F)

/-- `w` with `n` copies of `f` -/
def Backs.replicate (n : Nat) {W F : Type} (w : W) (f : F) : Backs n W F :=
  Tup.ofHList w (HList.replicate n f)

/-- `w` with the first `n` of `fs`, `dflt` where `fs` is short -/
def Backs.ofList (n : Nat) {W F : Type} (w : W) (fs : List F) (dflt : F) : Backs n W F :=
  Tup.ofHList w (HList.ofList fs dflt n)

/-- The types in `l` as a right-nested tuple, `Unit` for none: what a consumer with no result
of its own gives back (the final iterator per region, then a capturing closure) -/
@[reducible] def Prods : List Type → Type
  | [] => Unit
  | [A] => A
  | A :: l => A × Prods l

def HList.toProds : {l : List Type} → HList l → Prods l
  | [], .nil => ()
  | [_], .cons a .nil => a
  | _ :: _ :: _, .cons a rest => (a, HList.toProds rest)

/-- A consumer's result `R`, then the final iterator once per region -/
abbrev FinalsWith (n : Nat) (R I : Type) : Type := Tup R (List.replicate n I)

def FinalsWith.mk (n : Nat) {R I : Type} (r : R) (it : I) : FinalsWith n R I :=
  Tup.ofHList r (HList.replicate n it)

/-- The `&mut` parts of `I`'s items, which a closure handed an item gives back (Aeneas drops
the rest: `Enumerate`'s index, a zipped shared item), put back into the item. `Unit` where
the items hold no `&mut`. -/
class ItemMut (I Item : Type) where
  M : Type
  put : Item → M → Item

instance (priority := low) plainItemMut {I Item : Type} : ItemMut I Item := ⟨Unit, fun x _ => x⟩

/-- The `&mut` parts of a zipped pair of items, by each side's region count: a side without
`&mut` is dropped -/
@[reducible] def ZipMut : Nat → Nat → Type → Type → Type
  | 0, _, _, B => B
  | _ + 1, 0, A, _ => A
  | _ + 1, _ + 1, A, B => A × B

def ZipMut.split {A B : Type} : (na nb : Nat) → ZipMut na nb A B → Option A × Option B
  | 0, _, b => (none, some b)
  | _ + 1, 0, a => (some a, none)
  | _ + 1, _ + 1, (a, b) => (some a, some b)

/-- What a closure gives back in its output: its result `R`, then the `&mut` parts it was
handed, if any (`Unit` when none) -/
class ItemBack (Out R : Type) where
  M : Type
  split : Out → R × Option M

instance (priority := low) plainItemBack {R : Type} : ItemBack R R := ⟨Unit, fun r => (r, none)⟩

instance {R M : Type} : ItemBack (R × M) R := ⟨M, fun (r, m) => (r, some m)⟩

@[rust_trait "core::iter::traits::iterator::Iterator"]
structure core.iter.traits.iterator.Iterator (Self : Type) (Self_Item : Type)
  where
  next : Self → Result ((Option Self_Item) × Self)
  /-- No default: Rust's `(0, None)` is wrong for most std iterators, so each model states
  its own (adapters such as `Map` forward to it). -/
  size_hint : Self → Result (Usize × Option Usize)
  /-- `next` giving `&mut` items back: a backward function per mutable region of `Self`
  (`MutRegions`), each writing its region's part of the item it is given. Not a Rust method,
  so Aeneas never names it: generated impls keep the default (nothing to give back), the
  library's `IterMut` and adapters override it. -/
  nextMut : Self → Result ((Option Self_Item) × Self × List (Self → Option Self_Item → Self)) :=
    fun self => do
      let (o, self) ← next self
      ok (o, self, [])
  -- Provided methods are not fields (`rev` would be circular; `zip` cannot be typed): calls go
  -- to their `trait_default` models, whose output shape depends on `Self`'s regions.

/-- `Iterator::size_hint`'s provided body: no bounds. -/
@[trait_default, rust_fun "core::iter::traits::iterator::Iterator::size_hint"]
def core.iter.traits.iterator.Iterator.size_hint.trait_default
  {Self Item : Type}
  (_IteratorInst : core.iter.traits.iterator.Iterator Self Item)
  (_self : Self) : Result (Usize × Option Usize) :=
  ok (0#usize, none)

/-- `next` as Aeneas calls it on a `Self` with `n` regions: through `next` without one, else
through `nextMut`, its backward functions laid out as a tuple (`Backs`) -/
def core.iter.traits.iterator.Iterator.nextShapedN {Self Item : Type}
    (Inst : core.iter.traits.iterator.Iterator Self Item) :
    (n : Nat) → Self → Result ((Option Item) × Backs n Self (Self → Option Item → Self))
  | 0, self => Inst.next self
  | n + 1, self => do
    let (o, self, bs) ← Inst.nextMut self
    ok (o, Backs.ofList (n + 1) self bs (fun self _ => self))

/-- Without a region, the shaped `next` is `next` -/
@[simp] theorem core.iter.traits.iterator.Iterator.nextShapedN_zero {Self Item : Type}
    (Inst : core.iter.traits.iterator.Iterator Self Item) (self : Self) :
    Inst.nextShapedN 0 self = Inst.next self := rfl

/-- `next` as Aeneas calls it, by `Self`'s regions -/
abbrev core.iter.traits.iterator.Iterator.nextShaped {Self Item : Type} [M : MutRegions Self]
    (Inst : core.iter.traits.iterator.Iterator Self Item) (self : Self) :=
  Inst.nextShapedN M.n self

@[trait_default, rust_fun "core::iter::traits::iterator::Iterator::step_by"]
def core.iter.traits.iterator.Iterator.step_by.trait_default
  {Self Item : Type} [M : MutRegions Self]
  (_IteratorInst : core.iter.traits.iterator.Iterator Self Item)
  (self: Self) (step_by : Std.Usize) :
  Result (Backs M.n (core.iter.adapters.step_by.StepBy Self)
    (core.iter.adapters.step_by.StepBy Self → Self)) := do
  let sb ← core.iter.traits.iterator.Iterator.step_by.default self step_by
  ok (Backs.replicate M.n sb (·.iter))

@[trait_default, rust_fun "core::iter::traits::iterator::Iterator::enumerate"]
def core.iter.traits.iterator.Iterator.enumerate.trait_default
  {Self Item : Type} [M : MutRegions Self]
  (_IteratorInst : core.iter.traits.iterator.Iterator Self Item)
  (self: Self) :
  Result (Backs M.n (core.iter.adapters.enumerate.Enumerate Self)
    (core.iter.adapters.enumerate.Enumerate Self → Self)) := do
  let e ← core.iter.traits.iterator.Iterator.enumerate.default self
  ok (Backs.replicate M.n e (·.iter))

@[trait_default, rust_fun "core::iter::traits::iterator::Iterator::take"]
def core.iter.traits.iterator.Iterator.take.trait_default
  {Self Item : Type} [M : MutRegions Self]
  (_IteratorInst : core.iter.traits.iterator.Iterator Self Item)
  (self: Self) (n : Std.Usize) :
  Result (Backs M.n (core.iter.adapters.take.Take Self)
    (core.iter.adapters.take.Take Self → Self)) := do
  let t ← core.iter.traits.iterator.Iterator.take.default self n
  ok (Backs.replicate M.n t (·.iter))

/-- Skip up to `n` elements from an iterator -/
def core.iter.adapters.step_by.skipN
    {I : Type} {Item : Type}
    (iterInst : core.iter.traits.iterator.Iterator I Item)
    (iter : I) : (n : Nat) → Result I
  | 0 => .ok iter
  | n + 1 => do
    let (opt, iter) ← iterInst.next iter
    match opt with
    | none => .ok iter
    | some _ => core.iter.adapters.step_by.skipN iterInst iter n

def core.iter.adapters.step_by.IteratorStepBy.nextPlain
  {I : Type} {Item : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I Item) :
  core.iter.adapters.step_by.StepBy I →
  Result ((Option Item) × (core.iter.adapters.step_by.StepBy I)) :=
  fun self => do
    let (opt, iter) ← IteratorInst.next self.iter
    match opt with
    | none => .ok (none, { self with iter })
    | some item => do
      let iter ← core.iter.adapters.step_by.skipN IteratorInst iter (self.step_by.val - 1)
      .ok (some item, { iter, step_by := self.step_by })

/-- `skipN` through `nextMut`: the skipped items' backward functions are dropped (nothing
holds those items) -/
def core.iter.adapters.step_by.skipNMut
    {I : Type} {Item : Type}
    (iterInst : core.iter.traits.iterator.Iterator I Item)
    (iter : I) : (n : Nat) → Result I
  | 0 => .ok iter
  | n + 1 => do
    let (opt, iter, _) ← iterInst.nextMut iter
    match opt with
    | none => .ok iter
    | some _ => core.iter.adapters.step_by.skipNMut iterInst iter n

/-- The skipped items are dropped unwritten (nothing holds them) -/
def core.iter.adapters.step_by.IteratorStepBy.nextMut
  {I : Type} {Item : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I Item)
  (self : core.iter.adapters.step_by.StepBy I) :
  Result ((Option Item) × (core.iter.adapters.step_by.StepBy I) ×
    List (core.iter.adapters.step_by.StepBy I → Option Item →
      core.iter.adapters.step_by.StepBy I)) := do
  let (opt, iter, bs) ← IteratorInst.nextMut self.iter
  let bs := bs.map fun b sb o => { sb with iter := b sb.iter o }
  match opt with
  | none => .ok (none, { self with iter }, bs)
  | some item => do
    let iter ← core.iter.adapters.step_by.skipNMut IteratorInst iter (self.step_by.val - 1)
    .ok (some item, { iter, step_by := self.step_by }, bs)

/-- `1 + (n - 1) / step` items (none if `n = 0`): `StepBy`'s count when it takes its first
item next, which this model always does (it skips eagerly after each item). -/
def core.iter.adapters.step_by.firstSize (step n : Usize) : Usize :=
  if n.val = 0 then 0#usize
  else UScalar.ofNatCore (1 + (n.val - 1) / step.val)
    (by have := Nat.div_le_self (n.val - 1) step.val; have := n.hBounds; scalar_tac)

/-- Core's `spec_size_hint` (`step_by.rs`), with `first_take` always set -/
@[rust_fun
  "core::iter::adapters::step_by::{core::iter::traits::iterator::Iterator<core::iter::adapters::step_by::StepBy<@I>, @Clause0_Item>}::size_hint"]
def core.iter.adapters.step_by.IteratorStepBy.size_hint
  {I : Type} {Item : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I Item)
  (self : core.iter.adapters.step_by.StepBy I) : Result (Usize × Option Usize) := do
  let (lo, hi) ← IteratorInst.size_hint self.iter
  let f := core.iter.adapters.step_by.firstSize self.step_by
  ok (f lo, hi.map f)

@[reducible, rust_trait_impl
  "core::iter::traits::iterator::Iterator<core::iter::adapters::step_by::StepBy<@I>, @Clause0_Item>"]
impl_def core.iter.traits.iterator.IteratorStepBy {I : Type} {Item : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I Item) :
  core.iter.traits.iterator.Iterator (core.iter.adapters.step_by.StepBy I) Item := {
  next := core.iter.adapters.step_by.IteratorStepBy.nextPlain IteratorInst
  size_hint := core.iter.adapters.step_by.IteratorStepBy.size_hint IteratorInst
  nextMut := core.iter.adapters.step_by.IteratorStepBy.nextMut IteratorInst
}

instance {I : Type} [M : MutRegions I] : MutRegions (core.iter.adapters.step_by.StepBy I) := ⟨M.n⟩
instance {I : Type} [GivesBack I] : GivesBack (core.iter.adapters.step_by.StepBy I) := ⟨⟩
instance {I Item : Type} [IM : ItemMut I Item] : ItemMut (core.iter.adapters.step_by.StepBy I) Item :=
  ⟨IM.M, IM.put⟩

@[rust_fun
  "core::iter::adapters::step_by::{core::iter::traits::iterator::Iterator<core::iter::adapters::step_by::StepBy<@I>, @Clause0_Item>}::next"]
def core.iter.adapters.step_by.IteratorStepBy.next
  {I : Type} {Item : Type} [M : MutRegions I]
  (IteratorInst : core.iter.traits.iterator.Iterator I Item)
  (self : core.iter.adapters.step_by.StepBy I) :
  Result ((Option Item) × Backs M.n (core.iter.adapters.step_by.StepBy I)
    (core.iter.adapters.step_by.StepBy I → Option Item → core.iter.adapters.step_by.StepBy I)) :=
  (core.iter.traits.iterator.IteratorStepBy IteratorInst).nextShapedN M.n self

@[rust_trait "core::iter::traits::accum::Sum"]
structure core.iter.traits.accum.Sum (Self : Type) (A : Type) where
  sum : forall {I : Type} (_ : core.iter.traits.iterator.Iterator I A), I → Result Self

@[rust_trait "core::iter::traits::accum::Product"]
structure core.iter.traits.accum.Product (Self : Type) (A : Type) where
  product : forall {I : Type} (_ : core.iter.traits.iterator.Iterator I A), I → Result Self

@[rust_trait "core::iter::traits::collect::IntoIterator"
  (parentClauses := ["iteratorInst"])]
structure core.iter.traits.collect.IntoIterator (Self : Type) (Item :
  Type) (IntoIter : Type) where
  iteratorInst : core.iter.traits.iterator.Iterator IntoIter Item
  into_iter : Self → Result IntoIter

@[rust_trait "core::iter::traits::collect::FromIterator"]
structure core.iter.traits.collect.FromIterator (Self : Type) (A : Type) where
  from_iter : forall {T : Type} {IntoIter : Type}
    (_ : core.iter.traits.collect.IntoIterator T A IntoIter),
    T → Result Self

@[rust_fun
  "core::iter::traits::collect::{core::iter::traits::collect::IntoIterator<@I, @Item, @I>}::into_iter",
  simp]
def core.iter.traits.collect.IntoIterator.Blanket.into_iter
  {I : Type} {Item : Type} (_ : core.iter.traits.iterator.Iterator I Item) :
  I → Result I :=
    λ x => ok x

@[reducible, rust_trait_impl
  "core::iter::traits::collect::IntoIterator<@I, @Item, @I>"]
def core.iter.traits.collect.IntoIterator.Blanket {I : Type} {Item : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I Item) :
    core.iter.traits.collect.IntoIterator I Item I := {
  iteratorInst := IteratorInst
  into_iter := core.iter.traits.collect.IntoIterator.Blanket.into_iter IteratorInst
}

/-! ## Values given back by generic functions

A value holding a `&mut` (e.g. a closure capturing one) which is moved into a generic function
is given back from the function's output: Aeneas's call site expects `map(it, f)` to return
`(Map it f, back)` and `collect(m)` to return `(v, m)`, the final `Map` from which `back` gives
the closure back. Aeneas emits `GivesBack T` for each such type `T` (with one `&mut` region),
and the models below pick the shape of their output from it. -/

/-- A closure capturing a `&mut` (Aeneas emits its `GivesBack`) holds one region; the
adapters' own instances come first, so a wrapped `IterMut` keeps its count -/
instance (priority := 500) {T : Type} [GivesBack T] : MutRegions T := ⟨1⟩

/-- How an `IntoIterator` value is recovered from its iterator, for give back: a `&mut` moved
into `chain` or `zip` (`Some(&mut x)`, `iter_mut()`) comes back from the final state. -/
class IntoIterBack (IntoIter U : Type) where
  back : IntoIter → U

/-- An iterator is its own `IntoIterator` (`IntoIterator::Blanket`). -/
instance (priority := low) {I : Type} : IntoIterBack I I := ⟨id⟩

/-- `FromIterator::from_iter`, which also gives back the iterator in its final state: how far
the collection read it, which a closure the iterator holds must be given back from. -/
class FromIterBack (B : Type) (A : Type) where
  fromIterBack : {I : Type} → core.iter.traits.iterator.Iterator I A → I → Result (B × I)

/-- The output of `collect`: `B`, and the iterator in its final state when it gives back. -/
class CollectShape (Self B Item : Type) where
  Out : Type
  collect : core.iter.traits.iterator.Iterator Self Item →
    core.iter.traits.collect.FromIterator B Item → Self → Result Out

instance (priority := low) {Self B Item : Type} : CollectShape Self B Item :=
  ⟨B, fun it fromIter self =>
    fromIter.from_iter (core.iter.traits.collect.IntoIterator.Blanket it) self⟩

instance {Self B Item : Type} [GivesBack Self] [FromIterBack B Item] :
    CollectShape Self B Item :=
  ⟨B × Self, fun it _ self => FromIterBack.fromIterBack it self⟩

@[rust_fun "core::iter::traits::iterator::Iterator::collect"]
def core.iter.traits.iterator.Iterator.collect.default
  {Self : Type} {B : Type} {Item : Type} [S : CollectShape Self B Item] (IteratorInst :
  core.iter.traits.iterator.Iterator Self Item)
  (collectFromIteratorInst : core.iter.traits.collect.FromIterator B Item) :
  Self → Result S.Out :=
  S.collect IteratorInst collectFromIteratorInst

@[rust_trait "core::iter::traits::collect::Extend"]
structure core.iter.traits.collect.Extend (Self : Type) (A : Type) where
  extend : forall {T : Type} {IntoIter : Type}
    (_ : core.iter.traits.collect.IntoIterator T A IntoIter), Self → T → Result Self

@[rust_trait "core::iter::traits::double_ended::DoubleEndedIterator"
  (parentClauses := ["iteratorInst"])]
structure core.iter.traits.double_ended.DoubleEndedIterator (Self : Type) (Item : Type) where
  iteratorInst : core.iter.traits.iterator.Iterator Self Item
  next_back : Self → Result ((Option Item) × Self)
  /-- `next_back` giving `&mut` items back, as `Iterator.nextMut` -/
  nextBackMut : Self → Result ((Option Item) × Self × List (Self → Option Item → Self)) :=
    fun self => do
      let (o, self) ← next_back self
      ok (o, self, [])

@[rust_trait "core::iter::traits::exact_size::ExactSizeIterator"
  (parentClauses := ["iteratorInst"])]
structure core.iter.traits.exact_size.ExactSizeIterator (Self : Type) (Item : Type) where
  iteratorInst : core.iter.traits.iterator.Iterator Self Item

-- ============================================================================
-- Generic Step operations for UScalar types
-- ============================================================================

/-- Generic `steps_between` for all unsigned scalar types.
    Conservatively checks that `diff ≤ Usize.max` (always true for small types,
    needed for U64/U128). -/
def core.iter.range.UScalarStep.steps_between {ty : UScalarTy}
    (start end_ : UScalar ty) : Result (Usize × (Option Usize)) :=
  if h: start.val > end_.val then ok ⟨ 0#usize, none ⟩
  else
    let diff := end_.val - start.val
    if h : diff ≤ Usize.max then
      let steps := Usize.ofNatCore diff (by scalar_tac)
      ok ⟨ steps, some steps ⟩
    else
      let usizeMax := Usize.ofNatCore Usize.max (by scalar_tac)
      ok ⟨ usizeMax, none ⟩

/-- Generic `steps_between` for all signed scalar types. -/
def core.iter.range.IScalarStep.steps_between {ty : IScalarTy}
    (start end_ : IScalar ty) : Result (Usize × (Option Usize)) :=
  if h: start.val > end_.val then ok ⟨ 0#usize, none ⟩
  else
    let diff := end_.val - start.val
    if h : diff ≤ Usize.max then
      let steps := Usize.ofNatCore diff.toNat (by grind)
      ok ⟨ steps, some steps ⟩
    else
      let usizeMax := Usize.ofNatCore Usize.max (by scalar_tac)
      ok ⟨ usizeMax, none ⟩

/-- Generic `forward_checked` for all unsigned scalar types. -/
def core.iter.range.UScalarStep.forward_checked {ty : UScalarTy}
    (start : UScalar ty) (n : Usize) : Result (Option (UScalar ty)) :=
  if h : start.val + n.val ≤ UScalar.max ty then
    ok (some (UScalar.ofNatCore (start.val + n.val)
      (by cases ty <;> grind)))
  else ok none

/-- Generic `forward_checked` for all signed scalar types. -/
def core.iter.range.IScalarStep.forward_checked {ty : IScalarTy}
    (start : IScalar ty) (n : Usize) : Result (Option (IScalar ty)) :=
  if h : start.val + n.val ≤ IScalar.max ty then
    ok (some (IScalar.ofIntCore (start.val + n.val)
      (by cases ty <;> grind)))
  else ok none

/-- Generic `backward_checked` for all unsigned scalar types. -/
def core.iter.range.UScalarStep.backward_checked {ty : UScalarTy}
    (start : UScalar ty) (n : Usize) : Result (Option (UScalar ty)) :=
  if h : n.val ≤ start.val then
    ok (some (UScalar.ofNatCore (start.val - n.val)
      (by have := start.hBounds; omega)))
  else ok none

/-- Generic `backward_checked` for all unsigned scalar types. -/
def core.iter.range.IScalarStep.backward_checked {ty : IScalarTy}
    (start : IScalar ty) (n : Usize) : Result (Option (IScalar ty)) :=
  if h : n.val ≤ start.val then
    ok (some (IScalar.ofIntCore (start.val - n.val)
      (by have := start.hBounds; omega)))
  else ok none

/-! ### `forward_overflowing` / `backward_overflowing` for scalars

The standard library defines one implementation per scalar type, with two different
cases. For the types narrower than (or equal to) `usize`:
```rust
fn forward_overflowing(start: Self, n: usize) -> (Self, bool) {
    match Self::try_from(n) {
        Ok(n) => start.overflowing_add(n),
        // if n is out of range, `start + n` must overflow
        Err(_) => (start.wrapping_add(n as Self), true),
    }
}
```
and for the wider ones:  `start.overflowing_add(n as Self)` (the cast is
exact there). The signed impls are the same modulo
`overflowing_add_unsigned` / `wrapping_add_unsigned`.

All of those agree with the uniform model below:

* the value is always `start.wrapping_add(n)`
* the flag is exactly "the mathematical result does not fit in `Self`"

This does *not* model `Step for NonZero<_>`, which saturates instead of
wrapping and is a separate impl. -/

/-- Generic `forward_overflowing` for all unsigned scalar types. -/
def core.iter.range.UScalarStep.forward_overflowing {ty : UScalarTy}
    (start : UScalar ty) (n : Usize) : Result (UScalar ty × Bool) :=
  ok (⟨ start.bv + BitVec.ofNat ty.numBits n.val ⟩,
      decide (UScalar.max ty < start.val + n.val))

/-- Generic `backward_overflowing` for all unsigned scalar types. -/
def core.iter.range.UScalarStep.backward_overflowing {ty : UScalarTy}
    (start : UScalar ty) (n : Usize) : Result (UScalar ty × Bool) :=
  ok (⟨ start.bv - BitVec.ofNat ty.numBits n.val ⟩,
      decide (start.val < n.val))

/-- Generic `forward_overflowing` for all signed scalar types. -/
def core.iter.range.IScalarStep.forward_overflowing {ty : IScalarTy}
    (start : IScalar ty) (n : Usize) : Result (IScalar ty × Bool) :=
  ok (⟨ start.bv + BitVec.ofNat ty.numBits n.val ⟩,
      decide (IScalar.max ty < start.val + (n.val : Int)))

/-- Generic `backward_overflowing` for all signed scalar types. -/
def core.iter.range.IScalarStep.backward_overflowing {ty : IScalarTy}
    (start : IScalar ty) (n : Usize) : Result (IScalar ty × Bool) :=
  ok (⟨ start.bv - BitVec.ofNat ty.numBits n.val ⟩,
      decide (start.val - (n.val : Int) < IScalar.min ty))

-- ============================================================================
-- Specialized Step instances
-- ============================================================================

/-- Generic Step instance for all unsigned scalar types. The per-type instances
    below are abbreviations of this, differing only in Clone/PartialOrd. -/
def core.iter.range.UScalarStep (ty : UScalarTy)
    (cloneInst : core.clone.Clone (UScalar ty))
    (partialOrdInst : core.cmp.PartialOrd (UScalar ty) (UScalar ty)) :
    core.iter.range.Step (UScalar ty) := {
  cloneInst
  partialOrdInst
  steps_between := UScalarStep.steps_between
  forward_checked := UScalarStep.forward_checked
  backward_checked := UScalarStep.backward_checked
}

/-- Generic Step instance for all unsigned scalar types. The per-type instances
    below are abbreviations of this, differing only in Clone/PartialOrd. -/
def core.iter.range.IScalarStep (ty : IScalarTy)
    (cloneInst : core.clone.Clone (IScalar ty))
    (partialOrdInst : core.cmp.PartialOrd (IScalar ty) (IScalar ty)) :
    core.iter.range.Step (IScalar ty) := {
  cloneInst
  partialOrdInst
  steps_between := IScalarStep.steps_between
  forward_checked := IScalarStep.forward_checked
  backward_checked := IScalarStep.backward_checked
}

-- Per-type abbreviations with @[rust_fun] tags for the Aeneas compiler.

@[rust_fun "core::iter::range::{core::iter::range::Step<usize>}::steps_between"]
abbrev core.iter.range.StepUsize.steps_between := @UScalarStep.steps_between .Usize
@[rust_fun "core::iter::range::{core::iter::range::Step<usize>}::forward_checked"]
abbrev core.iter.range.StepUsize.forward_checked := @UScalarStep.forward_checked .Usize
@[rust_fun "core::iter::range::{core::iter::range::Step<usize>}::backward_checked"]
abbrev core.iter.range.StepUsize.backward_checked := @UScalarStep.backward_checked .Usize
@[rust_fun "core::iter::range::{core::iter::range::Step<usize>}::forward_overflowing"]
abbrev core.iter.range.StepUsize.forward_overflowing := @UScalarStep.forward_overflowing .Usize
@[rust_fun "core::iter::range::{core::iter::range::Step<usize>}::backward_overflowing"]
abbrev core.iter.range.StepUsize.backward_overflowing := @UScalarStep.backward_overflowing .Usize
@[rust_trait_impl "core::iter::range::Step<usize>"]
abbrev core.iter.range.StepUsize := UScalarStep .Usize core.clone.CloneUsize core.cmp.PartialOrdUsize

@[rust_fun "core::iter::range::{core::iter::range::Step<u8>}::steps_between"]
abbrev core.iter.range.StepU8.steps_between := @UScalarStep.steps_between .U8
@[rust_fun "core::iter::range::{core::iter::range::Step<u8>}::forward_checked"]
abbrev core.iter.range.StepU8.forward_checked := @UScalarStep.forward_checked .U8
@[rust_fun "core::iter::range::{core::iter::range::Step<u8>}::backward_checked"]
abbrev core.iter.range.StepU8.backward_checked := @UScalarStep.backward_checked .U8
@[rust_fun "core::iter::range::{core::iter::range::Step<u8>}::forward_overflowing"]
abbrev core.iter.range.StepU8.forward_overflowing := @UScalarStep.forward_overflowing .U8
@[rust_fun "core::iter::range::{core::iter::range::Step<u8>}::backward_overflowing"]
abbrev core.iter.range.StepU8.backward_overflowing := @UScalarStep.backward_overflowing .U8
@[rust_trait_impl "core::iter::range::Step<u8>"]
abbrev core.iter.range.StepU8 := UScalarStep .U8 core.clone.CloneU8 core.cmp.PartialOrdU8

@[rust_fun "core::iter::range::{core::iter::range::Step<u16>}::steps_between"]
abbrev core.iter.range.StepU16.steps_between := @UScalarStep.steps_between .U16
@[rust_fun "core::iter::range::{core::iter::range::Step<u16>}::forward_checked"]
abbrev core.iter.range.StepU16.forward_checked := @UScalarStep.forward_checked .U16
@[rust_fun "core::iter::range::{core::iter::range::Step<u16>}::backward_checked"]
abbrev core.iter.range.StepU16.backward_checked := @UScalarStep.backward_checked .U16
@[rust_fun "core::iter::range::{core::iter::range::Step<u16>}::forward_overflowing"]
abbrev core.iter.range.StepU16.forward_overflowing := @UScalarStep.forward_overflowing .U16
@[rust_fun "core::iter::range::{core::iter::range::Step<u16>}::backward_overflowing"]
abbrev core.iter.range.StepU16.backward_overflowing := @UScalarStep.backward_overflowing .U16
@[rust_trait_impl "core::iter::range::Step<u16>"]
abbrev core.iter.range.StepU16 := UScalarStep .U16 core.clone.CloneU16 core.cmp.PartialOrdU16

@[rust_fun "core::iter::range::{core::iter::range::Step<u32>}::steps_between"]
abbrev core.iter.range.StepU32.steps_between := @UScalarStep.steps_between .U32
@[rust_fun "core::iter::range::{core::iter::range::Step<u32>}::forward_checked"]
abbrev core.iter.range.StepU32.forward_checked := @UScalarStep.forward_checked .U32
@[rust_fun "core::iter::range::{core::iter::range::Step<u32>}::backward_checked"]
abbrev core.iter.range.StepU32.backward_checked := @UScalarStep.backward_checked .U32
@[rust_fun "core::iter::range::{core::iter::range::Step<u32>}::forward_overflowing"]
abbrev core.iter.range.StepU32.forward_overflowing := @UScalarStep.forward_overflowing .U32
@[rust_fun "core::iter::range::{core::iter::range::Step<u32>}::backward_overflowing"]
abbrev core.iter.range.StepU32.backward_overflowing := @UScalarStep.backward_overflowing .U32
@[rust_trait_impl "core::iter::range::Step<u32>"]
abbrev core.iter.range.StepU32 := UScalarStep .U32 core.clone.CloneU32 core.cmp.PartialOrdU32

@[rust_fun "core::iter::range::{core::iter::range::Step<u64>}::steps_between"]
abbrev core.iter.range.StepU64.steps_between := @UScalarStep.steps_between .U64
@[rust_fun "core::iter::range::{core::iter::range::Step<u64>}::forward_checked"]
abbrev core.iter.range.StepU64.forward_checked := @UScalarStep.forward_checked .U64
@[rust_fun "core::iter::range::{core::iter::range::Step<u64>}::backward_checked"]
abbrev core.iter.range.StepU64.backward_checked := @UScalarStep.backward_checked .U64
@[rust_fun "core::iter::range::{core::iter::range::Step<u64>}::forward_overflowing"]
abbrev core.iter.range.StepU64.forward_overflowing := @UScalarStep.forward_overflowing .U64
@[rust_fun "core::iter::range::{core::iter::range::Step<u64>}::backward_overflowing"]
abbrev core.iter.range.StepU64.backward_overflowing := @UScalarStep.backward_overflowing .U64
@[rust_trait_impl "core::iter::range::Step<u64>"]
abbrev core.iter.range.StepU64 := UScalarStep .U64 core.clone.CloneU64 core.cmp.PartialOrdU64

@[rust_fun "core::iter::range::{core::iter::range::Step<u128>}::steps_between"]
abbrev core.iter.range.StepU128.steps_between := @UScalarStep.steps_between .U128
@[rust_fun "core::iter::range::{core::iter::range::Step<u128>}::forward_checked"]
abbrev core.iter.range.StepU128.forward_checked := @UScalarStep.forward_checked .U128
@[rust_fun "core::iter::range::{core::iter::range::Step<u128>}::backward_checked"]
abbrev core.iter.range.StepU128.backward_checked := @UScalarStep.backward_checked .U128
@[rust_fun "core::iter::range::{core::iter::range::Step<u128>}::forward_overflowing"]
abbrev core.iter.range.StepU128.forward_overflowing := @UScalarStep.forward_overflowing .U128
@[rust_fun "core::iter::range::{core::iter::range::Step<u128>}::backward_overflowing"]
abbrev core.iter.range.StepU128.backward_overflowing := @UScalarStep.backward_overflowing .U128
@[rust_trait_impl "core::iter::range::Step<u128>"]
abbrev core.iter.range.StepU128 := UScalarStep .U128 core.clone.CloneU128 core.cmp.PartialOrdU128

@[rust_fun "core::iter::range::{core::iter::range::Step<isize>}::steps_between"]
abbrev core.iter.range.StepIsize.steps_between := @IScalarStep.steps_between .Isize
@[rust_fun "core::iter::range::{core::iter::range::Step<isize>}::forward_checked"]
abbrev core.iter.range.StepIsize.forward_checked := @IScalarStep.forward_checked .Isize
@[rust_fun "core::iter::range::{core::iter::range::Step<isize>}::backward_checked"]
abbrev core.iter.range.StepIsize.backward_checked := @IScalarStep.backward_checked .Isize
@[rust_fun "core::iter::range::{core::iter::range::Step<isize>}::forward_overflowing"]
abbrev core.iter.range.StepIsize.forward_overflowing := @IScalarStep.forward_overflowing .Isize
@[rust_fun "core::iter::range::{core::iter::range::Step<isize>}::backward_overflowing"]
abbrev core.iter.range.StepIsize.backward_overflowing := @IScalarStep.backward_overflowing .Isize
@[rust_trait_impl "core::iter::range::Step<isize>"]
abbrev core.iter.range.StepIsize := IScalarStep .Isize core.clone.CloneIsize core.cmp.PartialOrdIsize

@[rust_fun "core::iter::range::{core::iter::range::Step<i8>}::steps_between"]
abbrev core.iter.range.StepI8.steps_between := @IScalarStep.steps_between .I8
@[rust_fun "core::iter::range::{core::iter::range::Step<i8>}::forward_checked"]
abbrev core.iter.range.StepI8.forward_checked := @IScalarStep.forward_checked .I8
@[rust_fun "core::iter::range::{core::iter::range::Step<i8>}::backward_checked"]
abbrev core.iter.range.StepI8.backward_checked := @IScalarStep.backward_checked .I8
@[rust_fun "core::iter::range::{core::iter::range::Step<i8>}::forward_overflowing"]
abbrev core.iter.range.StepI8.forward_overflowing := @IScalarStep.forward_overflowing .I8
@[rust_fun "core::iter::range::{core::iter::range::Step<i8>}::backward_overflowing"]
abbrev core.iter.range.StepI8.backward_overflowing := @IScalarStep.backward_overflowing .I8
@[rust_trait_impl "core::iter::range::Step<i8>"]
abbrev core.iter.range.StepI8 := IScalarStep .I8 core.clone.CloneI8 core.cmp.PartialOrdI8

@[rust_fun "core::iter::range::{core::iter::range::Step<i16>}::steps_between"]
abbrev core.iter.range.StepI16.steps_between := @IScalarStep.steps_between .I16
@[rust_fun "core::iter::range::{core::iter::range::Step<i16>}::forward_checked"]
abbrev core.iter.range.StepI16.forward_checked := @IScalarStep.forward_checked .I16
@[rust_fun "core::iter::range::{core::iter::range::Step<i16>}::backward_checked"]
abbrev core.iter.range.StepI16.backward_checked := @IScalarStep.backward_checked .I16
@[rust_fun "core::iter::range::{core::iter::range::Step<i16>}::forward_overflowing"]
abbrev core.iter.range.StepI16.forward_overflowing := @IScalarStep.forward_overflowing .I16
@[rust_fun "core::iter::range::{core::iter::range::Step<i16>}::backward_overflowing"]
abbrev core.iter.range.StepI16.backward_overflowing := @IScalarStep.backward_overflowing .I16
@[rust_trait_impl "core::iter::range::Step<i16>"]
abbrev core.iter.range.StepI16 := IScalarStep .I16 core.clone.CloneI16 core.cmp.PartialOrdI16

@[rust_fun "core::iter::range::{core::iter::range::Step<i32>}::steps_between"]
abbrev core.iter.range.StepI32.steps_between := @IScalarStep.steps_between .I32
@[rust_fun "core::iter::range::{core::iter::range::Step<i32>}::forward_checked"]
abbrev core.iter.range.StepI32.forward_checked := @IScalarStep.forward_checked .I32
@[rust_fun "core::iter::range::{core::iter::range::Step<i32>}::backward_checked"]
abbrev core.iter.range.StepI32.backward_checked := @IScalarStep.backward_checked .I32
@[rust_fun "core::iter::range::{core::iter::range::Step<i32>}::forward_overflowing"]
abbrev core.iter.range.StepI32.forward_overflowing := @IScalarStep.forward_overflowing .I32
@[rust_fun "core::iter::range::{core::iter::range::Step<i32>}::backward_overflowing"]
abbrev core.iter.range.StepI32.backward_overflowing := @IScalarStep.backward_overflowing .I32
@[rust_trait_impl "core::iter::range::Step<i32>"]
abbrev core.iter.range.StepI32 := IScalarStep .I32 core.clone.CloneI32 core.cmp.PartialOrdI32

@[rust_fun "core::iter::range::{core::iter::range::Step<i64>}::steps_between"]
abbrev core.iter.range.StepI64.steps_between := @IScalarStep.steps_between .I64
@[rust_fun "core::iter::range::{core::iter::range::Step<i64>}::forward_checked"]
abbrev core.iter.range.StepI64.forward_checked := @IScalarStep.forward_checked .I64
@[rust_fun "core::iter::range::{core::iter::range::Step<i64>}::backward_checked"]
abbrev core.iter.range.StepI64.backward_checked := @IScalarStep.backward_checked .I64
@[rust_fun "core::iter::range::{core::iter::range::Step<i64>}::forward_overflowing"]
abbrev core.iter.range.StepI64.forward_overflowing := @IScalarStep.forward_overflowing .I64
@[rust_fun "core::iter::range::{core::iter::range::Step<i64>}::backward_overflowing"]
abbrev core.iter.range.StepI64.backward_overflowing := @IScalarStep.backward_overflowing .I64
@[rust_trait_impl "core::iter::range::Step<i64>"]
abbrev core.iter.range.StepI64 := IScalarStep .I64 core.clone.CloneI64 core.cmp.PartialOrdI64

@[rust_fun "core::iter::range::{core::iter::range::Step<i128>}::steps_between"]
abbrev core.iter.range.StepI128.steps_between := @IScalarStep.steps_between .I128
@[rust_fun "core::iter::range::{core::iter::range::Step<i128>}::forward_checked"]
abbrev core.iter.range.StepI128.forward_checked := @IScalarStep.forward_checked .I128
@[rust_fun "core::iter::range::{core::iter::range::Step<i128>}::backward_checked"]
abbrev core.iter.range.StepI128.backward_checked := @IScalarStep.backward_checked .I128
@[rust_fun "core::iter::range::{core::iter::range::Step<i128>}::forward_overflowing"]
abbrev core.iter.range.StepI128.forward_overflowing := @IScalarStep.forward_overflowing .I128
@[rust_fun "core::iter::range::{core::iter::range::Step<i128>}::backward_overflowing"]
abbrev core.iter.range.StepI128.backward_overflowing := @IScalarStep.backward_overflowing .I128
@[rust_trait_impl "core::iter::range::Step<i128>"]
abbrev core.iter.range.StepI128 := IScalarStep .I128 core.clone.CloneI128 core.cmp.PartialOrdI128

-- ============================================================================
-- Enumerate.next — generic over any inner iterator
-- ============================================================================
--  Model for `Iterator::next` on `Enumerate<I>`

def core.iter.adapters.enumerate.IteratorEnumerate.nextPlain
    {I : Type} {Item : Type}
    (IteratorInst : core.iter.traits.iterator.Iterator I Item)
    (self : core.iter.adapters.enumerate.Enumerate I) :
    Result ((Option (Usize × Item)) × (core.iter.adapters.enumerate.Enumerate I)) := do
  let (opt, iter') ← IteratorInst.next self.iter
  match opt with
  | none => ok (none, { iter := iter', count := self.count })
  | some a => do
      let count' ← self.count + 1#usize
      ok (some (self.count, a), { iter := iter', count := count' })

/-- The inner backward functions, given the item without its index -/
def core.iter.adapters.enumerate.IteratorEnumerate.nextMut
    {I : Type} {Item : Type}
    (IteratorInst : core.iter.traits.iterator.Iterator I Item)
    (self : core.iter.adapters.enumerate.Enumerate I) :
    Result ((Option (Usize × Item)) × (core.iter.adapters.enumerate.Enumerate I) ×
      List (core.iter.adapters.enumerate.Enumerate I → Option (Usize × Item) →
        core.iter.adapters.enumerate.Enumerate I)) := do
  let (opt, iter', bs) ← IteratorInst.nextMut self.iter
  let bs := bs.map fun b e o => { e with iter := b e.iter (o.map (·.2)) }
  match opt with
  | none => ok (none, { iter := iter', count := self.count }, bs)
  | some a => do
      let count' ← self.count + 1#usize
      ok (some (self.count, a), { iter := iter', count := count' }, bs)

/-- The inner iterator's -/
@[rust_fun
  "core::iter::adapters::enumerate::{core::iter::traits::iterator::Iterator<core::iter::adapters::enumerate::Enumerate<@I>, (usize, @Clause0_Item)>}::size_hint"]
def core.iter.adapters.enumerate.IteratorEnumerate.size_hint
  {I : Type} {Item : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I Item)
  (self : core.iter.adapters.enumerate.Enumerate I) : Result (Usize × Option Usize) :=
  IteratorInst.size_hint self.iter

@[reducible, rust_trait_impl
  "core::iter::traits::iterator::Iterator<core::iter::adapters::enumerate::Enumerate<@I>, (usize, @Clause0_Item)>"]
impl_def core.iter.traits.iterator.IteratorEnumerate {I : Type} {Item : Type}
    (IteratorInst : core.iter.traits.iterator.Iterator I Item) :
    core.iter.traits.iterator.Iterator (core.iter.adapters.enumerate.Enumerate I) (Usize × Item) := {
  next := core.iter.adapters.enumerate.IteratorEnumerate.nextPlain IteratorInst
  size_hint := core.iter.adapters.enumerate.IteratorEnumerate.size_hint IteratorInst
  nextMut := core.iter.adapters.enumerate.IteratorEnumerate.nextMut IteratorInst
}

instance {I : Type} [M : MutRegions I] : MutRegions (core.iter.adapters.enumerate.Enumerate I) := ⟨M.n⟩
instance {I : Type} [GivesBack I] : GivesBack (core.iter.adapters.enumerate.Enumerate I) := ⟨⟩
instance {I Item : Type} [IM : ItemMut I Item] :
    ItemMut (core.iter.adapters.enumerate.Enumerate I) (Usize × Item) :=
  ⟨IM.M, fun (i, x) m => (i, IM.put x m)⟩

@[rust_fun
  "core::iter::adapters::enumerate::{core::iter::traits::iterator::Iterator<core::iter::adapters::enumerate::Enumerate<@I>, (usize, @Clause0_Item)>}::next"]
def core.iter.adapters.enumerate.IteratorEnumerate.next
    {I : Type} {Item : Type} [M : MutRegions I]
    (IteratorInst : core.iter.traits.iterator.Iterator I Item)
    (self : core.iter.adapters.enumerate.Enumerate I) :
    Result ((Option (Usize × Item)) × Backs M.n (core.iter.adapters.enumerate.Enumerate I)
      (core.iter.adapters.enumerate.Enumerate I → Option (Usize × Item) →
        core.iter.adapters.enumerate.Enumerate I)) :=
  (core.iter.traits.iterator.IteratorEnumerate IteratorInst).nextShapedN M.n self

-- ============================================================================
-- Take.next — generic over any inner iterator
-- ============================================================================
-- Model for `Iterator::next` on `Take<I>`

def core.iter.adapters.take.IteratorTake.nextPlain
    {I : Type} {Item : Type}
    (IteratorInst : core.iter.traits.iterator.Iterator I Item)
    (self : core.iter.adapters.take.Take I) :
    Result ((Option Item) × (core.iter.adapters.take.Take I)) :=
  if self.n.val = 0 then
    ok (none, self)
  else do
    let n' ← self.n - 1#usize
    let (opt, iter') ← IteratorInst.next self.iter
    ok (opt, { iter := iter', n := n' })

def core.iter.adapters.take.IteratorTake.nextMut
    {I : Type} {Item : Type}
    (IteratorInst : core.iter.traits.iterator.Iterator I Item)
    (self : core.iter.adapters.take.Take I) :
    Result ((Option Item) × (core.iter.adapters.take.Take I) ×
      List (core.iter.adapters.take.Take I → Option Item → core.iter.adapters.take.Take I)) :=
  if self.n.val = 0 then
    ok (none, self, [])
  else do
    let n' ← self.n - 1#usize
    let (opt, iter', bs) ← IteratorInst.nextMut self.iter
    ok (opt, { iter := iter', n := n' }, bs.map fun b t o => { t with iter := b t.iter o })

/-- The inner iterator's, capped at `n` (`take.rs`) -/
@[rust_fun
  "core::iter::adapters::take::{core::iter::traits::iterator::Iterator<core::iter::adapters::take::Take<@I>, @Clause0_Item>}::size_hint"]
def core.iter.adapters.take.IteratorTake.size_hint
  {I : Type} {Item : Type}
  (IteratorInst : core.iter.traits.iterator.Iterator I Item)
  (self : core.iter.adapters.take.Take I) : Result (Usize × Option Usize) := do
  if self.n.val = 0 then ok (0#usize, some 0#usize)
  else
    let (lo, hi) ← IteratorInst.size_hint self.iter
    let lo := if lo.val ≤ self.n.val then lo else self.n
    let hi := match hi with
      | some x => if x.val < self.n.val then some x else some self.n
      | none => some self.n
    ok (lo, hi)

@[reducible, rust_trait_impl
  "core::iter::traits::iterator::Iterator<core::iter::adapters::take::Take<@I>, @Clause0_Item>"]
impl_def core.iter.traits.iterator.IteratorTake {I : Type} {Item : Type}
    (IteratorInst : core.iter.traits.iterator.Iterator I Item) :
    core.iter.traits.iterator.Iterator (core.iter.adapters.take.Take I) Item := {
  next := core.iter.adapters.take.IteratorTake.nextPlain IteratorInst
  size_hint := core.iter.adapters.take.IteratorTake.size_hint IteratorInst
  nextMut := core.iter.adapters.take.IteratorTake.nextMut IteratorInst
}

instance {I : Type} [M : MutRegions I] : MutRegions (core.iter.adapters.take.Take I) := ⟨M.n⟩
instance {I : Type} [GivesBack I] : GivesBack (core.iter.adapters.take.Take I) := ⟨⟩
instance {I Item : Type} [IM : ItemMut I Item] : ItemMut (core.iter.adapters.take.Take I) Item :=
  ⟨IM.M, IM.put⟩

@[rust_fun
  "core::iter::adapters::take::{core::iter::traits::iterator::Iterator<core::iter::adapters::take::Take<@I>, @Clause0_Item>}::next"]
def core.iter.adapters.take.IteratorTake.next
    {I : Type} {Item : Type} [M : MutRegions I]
    (IteratorInst : core.iter.traits.iterator.Iterator I Item)
    (self : core.iter.adapters.take.Take I) :
    Result ((Option Item) × Backs M.n (core.iter.adapters.take.Take I)
      (core.iter.adapters.take.Take I → Option Item → core.iter.adapters.take.Take I)) :=
  (core.iter.traits.iterator.IteratorTake IteratorInst).nextShapedN M.n self

@[rust_fun
  "core::iter::range::{core::iter::traits::iterator::Iterator<core::ops::range::Range<@A>, @A>}::next"]
def core.iter.range.IteratorRange.next
   {A : Type} (StepInst : core.iter.range.Step A) :
  core.ops.range.Range A → Result ((Option A) × (core.ops.range.Range A)) :=
  λ range => do
    let cmp ← StepInst.partialOrdInst.lt range.start range.end;
    if cmp then
      let range' ← StepInst.cloneInst.clone range.start;
      let n ← StepInst.forward_checked range' 1#usize;
      match n with
      | none => fail .panic -- Step invariants not upheld
      | some n => ok ⟨ some range', {range with start := n} ⟩
    else ok ⟨ none, range ⟩

/-- `Step::steps_between(start, end)` if `start < end`, else none (`range.rs`) -/
@[rust_fun
  "core::iter::range::{core::iter::traits::iterator::Iterator<core::ops::range::Range<@A>, @A>}::size_hint"]
def core.iter.range.IteratorRange.size_hint {A : Type} (StepInst : core.iter.range.Step A)
  (range : core.ops.range.Range A) : Result (Usize × Option Usize) := do
  if ← StepInst.partialOrdInst.lt range.start range.end then
    StepInst.steps_between range.start range.end
  else ok (0#usize, some 0#usize)

@[reducible, rust_trait_impl
  "core::iter::traits::iterator::Iterator<core::ops::range::Range<@A>, @A>"]
impl_def core.iter.traits.iterator.IteratorRange {A : Type}
  (StepInst : core.iter.range.Step A) : core.iter.traits.iterator.Iterator
  (core.ops.range.Range A) A := {
  next := core.iter.range.IteratorRange.next StepInst
  size_hint := core.iter.range.IteratorRange.size_hint StepInst
}

/-- `Zip<A, B>::next` (default `ZipImpl::next`, `zip.rs:164-168`):
    ```rust
    let x = self.a.next()?;   // advance A
    let y = self.b.next()?;   // advance B (only if A produced)
    Some((x, y))
    ```
    `?` short-circuits: if A yields `none`, B is *not* advanced. -/
def core.iter.adapters.zip.Zip.nextPlain
  {A B Item_A Item_B : Type}
  (IA : core.iter.traits.iterator.Iterator A Item_A)
  (IB : core.iter.traits.iterator.Iterator B Item_B)
  (z : core.iter.adapters.zip.Zip A B) :
  Result ((Option (Item_A × Item_B)) × core.iter.adapters.zip.Zip A B) := do
  let (oa, a') ← IA.next z.fst
  match oa with
  | none => ok (none, ⟨a', z.snd⟩)
  | some a => do
      let (ob, b') ← IB.next z.snd
      match ob with
      | none => ok (none, ⟨a', b'⟩)
      | some b => ok (some (a, b), ⟨a', b'⟩)

/-- `Zip::next` giving back: `A`'s backward functions (each on the item's first component)
then `B`'s (on its second); `B`'s are absent when `A` is exhausted, as `B` is not advanced -/
def core.iter.adapters.zip.Zip.nextMut
  {A B Item_A Item_B : Type}
  (IA : core.iter.traits.iterator.Iterator A Item_A)
  (IB : core.iter.traits.iterator.Iterator B Item_B)
  (z : core.iter.adapters.zip.Zip A B) :
  Result ((Option (Item_A × Item_B)) × core.iter.adapters.zip.Zip A B ×
    List (core.iter.adapters.zip.Zip A B → Option (Item_A × Item_B) →
      core.iter.adapters.zip.Zip A B)) := do
  let (oa, a', ba) ← IA.nextMut z.fst
  let liftA : (A → Option Item_A → A) → core.iter.adapters.zip.Zip A B →
      Option (Item_A × Item_B) → core.iter.adapters.zip.Zip A B :=
    fun b z o => ⟨b z.fst (o.map (·.1)), z.snd⟩
  let liftB : (B → Option Item_B → B) → core.iter.adapters.zip.Zip A B →
      Option (Item_A × Item_B) → core.iter.adapters.zip.Zip A B :=
    fun b z o => ⟨z.fst, b z.snd (o.map (·.2))⟩
  match oa with
  | none => ok (none, ⟨a', z.snd⟩, ba.map liftA)
  | some a => do
      let (ob, b', bb) ← IB.nextMut z.snd
      match ob with
      | none => ok (none, ⟨a', b'⟩, ba.map liftA ++ bb.map liftB)
      | some b => ok (some (a, b), ⟨a', b'⟩, ba.map liftA ++ bb.map liftB)

instance {A B : Type} [MA : MutRegions A] [MB : MutRegions B] :
    MutRegions (core.iter.adapters.zip.Zip A B) := ⟨MA.n + MB.n⟩
instance {A B : Type} [GivesBack A] : GivesBack (core.iter.adapters.zip.Zip A B) := ⟨⟩
instance {A B : Type} [GivesBack B] : GivesBack (core.iter.adapters.zip.Zip A B) := ⟨⟩
instance {A B Item_A Item_B : Type} [NA : MutRegions A] [NB : MutRegions B]
    [MA : ItemMut A Item_A] [MB : ItemMut B Item_B] :
    ItemMut (core.iter.adapters.zip.Zip A B) (Item_A × Item_B) :=
  ⟨ZipMut NA.n NB.n MA.M MB.M, fun (a, b) c =>
    let (ma, mb) := ZipMut.split NA.n NB.n c
    ((ma.map (MA.put a)).getD a, (mb.map (MB.put b)).getD b)⟩

@[rust_fun "core::ops::range::{core::ops::range::RangeInclusive<@Idx>}::new"]
def core.ops.range.RangeInclusive.new {Idx : Type}
    (start «end» : Idx) : Result (core.ops.range.RangeInclusive Idx) :=
  ok ⟨start, «end», false⟩

@[rust_fun "core::ops::range::{core::ops::range::RangeInclusive<@Idx>}::is_empty"]
def core.ops.range.RangeInclusive.is_empty {Idx : Type} (inst : core.cmp.PartialOrd Idx Idx)
  (self : core.ops.range.RangeInclusive Idx) : Result Bool := do
  if self.exhausted then ok true
  else
    let startLeEnd ← inst.le self.start self.«end»
    pure (not startLeEnd)

/-- `RangeInclusive<A>::next` (`range.rs:1396`):
    ```rust
    default fn spec_next(&mut self) -> Option<A> {
        if self.is_empty() {
            return None;
        }
        let is_iterating = self.start < self.end;
        Some(if is_iterating {
            let n =
                Step::forward_checked(self.start.clone(), 1).expect("`Step` invariants not upheld");
            mem::replace(&mut self.start, n)
        } else {
            self.exhausted = true;
            self.start.clone()
        })
    }
    ``` -/
@[rust_fun
  "core::iter::range::{core::iter::traits::iterator::Iterator<core::ops::range::RangeInclusive<@A>, @A>}::next"]
def core.ops.range.RangeInclusive.Insts.CoreIterTraitsIteratorIterator.next
  {A : Type} (StepInst : core.iter.range.Step A)
  (self : core.ops.range.RangeInclusive A) :
  Result ((Option A) × core.ops.range.RangeInclusive A) := do
  if ← self.is_empty StepInst.partialOrdInst then .ok (none, self)
  else
    let is_iterating ← StepInst.partialOrdInst.lt self.start self.«end»
    if is_iterating then
      let n ← StepInst.forward_checked self.start 1#usize
      match n with
      | none => .fail .panic
      | some n => ok (some self.start, ⟨n, self.«end», self.exhausted⟩)
    else
      let n ← StepInst.cloneInst.clone self.start
      ok (some n, ⟨self.start, self.«end», true⟩)

-- ============================================================================
-- Iterator-adapter methods: `rev` / `zip` / `next_back` / `Rev::next` / defaults
-- ============================================================================

/-- `Iterator::zip` default body: `Zip::new(self, other.into_iter())`. -/
def core.iter.traits.iterator.Iterator.zip.default
  {Self U IntoIter : Type}
  (into_iter : U → Result IntoIter) :
  Self → U → Result (core.iter.adapters.zip.Zip Self IntoIter) :=
  fun self other => do
    let b ← into_iter other
    ok ⟨self, b⟩

/-- The output of `zip(self, other)`: the `Zip`, then `self` given back once per region it
holds, then `other` (e.g. `iter_mut()`, its own `IntoIterator`) once per region of its
iterator. -/
class ZipShape (Self U IntoIter : Type) where
  Out : Type
  ofZip : core.iter.adapters.zip.Zip Self IntoIter → Out

/-- Without a way back from `IntoIter` to `U`, `other` has nothing to give back -/
instance (priority := low) {Self U IntoIter : Type} [MS : MutRegions Self] :
    ZipShape Self U IntoIter :=
  ⟨Backs MS.n (core.iter.adapters.zip.Zip Self IntoIter)
    (core.iter.adapters.zip.Zip Self IntoIter → Self),
   fun z => Backs.replicate MS.n z (·.fst)⟩

instance {Self U IntoIter : Type} [MS : MutRegions Self] [MU : MutRegions IntoIter]
    [IntoIterBack IntoIter U] : ZipShape Self U IntoIter :=
  ⟨Tup (core.iter.adapters.zip.Zip Self IntoIter)
    (List.replicate MS.n (core.iter.adapters.zip.Zip Self IntoIter → Self) ++
      List.replicate MU.n (core.iter.adapters.zip.Zip Self IntoIter → U)),
   fun z => Tup.ofHList z (HList.append (HList.replicate MS.n (·.fst))
    (HList.replicate MU.n (fun z => IntoIterBack.back z.snd)))⟩

@[trait_default, rust_fun "core::iter::traits::iterator::Iterator::zip"]
def core.iter.traits.iterator.Iterator.zip.trait_default
  {Self U Item0 Item1 IntoIter : Type} [S : ZipShape Self U IntoIter]
  (_IteratorInst : core.iter.traits.iterator.Iterator Self Item0)
  (IntoIterInst : core.iter.traits.collect.IntoIterator U Item1 IntoIter) :
  Self → U → Result S.Out := fun self other => do
  let z ← core.iter.traits.iterator.Iterator.zip.default IntoIterInst.into_iter self other
  ok (S.ofZip z)

/-- `Iterator::rev` default body: `Rev { iter: self }`. -/
def core.iter.traits.iterator.Iterator.rev.default
  {Self : Type} :
  Self → Result (core.iter.adapters.rev.Rev Self) :=
  fun self => ok ⟨self⟩

@[trait_default, rust_fun "core::iter::traits::iterator::Iterator::rev"]
def core.iter.traits.iterator.Iterator.rev.trait_default
  {Self Item0 Item1 : Type} [M : MutRegions Self]
  (_IteratorInst : core.iter.traits.iterator.Iterator Self Item0)
  (_DEInst : core.iter.traits.double_ended.DoubleEndedIterator Self Item1)
  (self : Self) :
  Result (Backs M.n (core.iter.adapters.rev.Rev Self) (core.iter.adapters.rev.Rev Self → Self)) := do
  let r ← core.iter.traits.iterator.Iterator.rev.default self
  ok (Backs.replicate M.n r (·.iter))

/-- `Iterator::take_while` default body: `TakeWhile { iter: self, flag: false, predicate }`. -/
def core.iter.traits.iterator.Iterator.take_while.default
  {Self P : Type} :
  Self → P → Result (core.iter.adapters.take_while.TakeWhile Self P) :=
  fun self predicate => ok ⟨self, false, predicate⟩

@[trait_default, rust_fun "core::iter::traits::iterator::Iterator::take_while"]
def core.iter.traits.iterator.Iterator.take_while.trait_default
  {Self P Item : Type}
  (_IteratorInst : core.iter.traits.iterator.Iterator Self Item)
  (_PredInst : core.ops.function.FnMut P Item Bool) :
  Self → P → Result (core.iter.adapters.take_while.TakeWhile Self P) :=
  core.iter.traits.iterator.Iterator.take_while.default

/-! ## `@[step]` specs for the default-method constructors -/

@[step]
theorem core.iter.traits.iterator.Iterator.step_by.default.spec
    {Self : Type} (self : Self) (step : Std.Usize) (hstep : 0 < step.val) :
    core.iter.traits.iterator.Iterator.step_by.default self step
    ⦃ sb => sb.iter = self ∧ sb.step_by = step ⦄ := by
  unfold core.iter.traits.iterator.Iterator.step_by.default
  simp [show ¬ step.val = 0 from by omega, WP.spec_ok]

@[step]
theorem core.iter.traits.iterator.Iterator.step_by.trait_default.spec
    {Self Item : Type} (inst : core.iter.traits.iterator.Iterator Self Item)
    (self : Self) (step : Std.Usize) (hstep : 0 < step.val) :
    core.iter.traits.iterator.Iterator.step_by.trait_default inst self step
    ⦃ sb => sb.iter = self ∧ sb.step_by = step ⦄ := by
  unfold core.iter.traits.iterator.Iterator.step_by.trait_default
  apply WP.spec_bind (core.iter.traits.iterator.Iterator.step_by.default.spec self step hstep)
  intro x h
  simp only [WP.spec_ok]
  exact h

@[step]
theorem core.iter.traits.iterator.Iterator.enumerate.default.spec
    {Self : Type} (self : Self) :
    core.iter.traits.iterator.Iterator.enumerate.default self
    ⦃ e => e.iter = self ∧ e.count = 0#usize ⦄ := by
  unfold core.iter.traits.iterator.Iterator.enumerate.default
  simp [WP.spec_ok]

@[step]
theorem core.iter.traits.iterator.Iterator.enumerate.trait_default.spec
    {Self Item : Type} (inst : core.iter.traits.iterator.Iterator Self Item)
    (self : Self) :
    core.iter.traits.iterator.Iterator.enumerate.trait_default inst self
    ⦃ e => e.iter = self ∧ e.count = 0#usize ⦄ := by
  unfold core.iter.traits.iterator.Iterator.enumerate.trait_default
  apply WP.spec_bind (core.iter.traits.iterator.Iterator.enumerate.default.spec self)
  intro x h
  simp only [WP.spec_ok]
  exact h

@[step]
theorem core.iter.traits.iterator.Iterator.take.default.spec
    {Self : Type} (self : Self) (n : Std.Usize) :
    core.iter.traits.iterator.Iterator.take.default self n
    ⦃ t => t.iter = self ∧ t.n = n ⦄ := by
  unfold core.iter.traits.iterator.Iterator.take.default
  simp [WP.spec_ok]

@[step]
theorem core.iter.traits.iterator.Iterator.take.trait_default.spec
    {Self Item : Type} (inst : core.iter.traits.iterator.Iterator Self Item)
    (self : Self) (n : Std.Usize) :
    core.iter.traits.iterator.Iterator.take.trait_default inst self n
    ⦃ t => t.iter = self ∧ t.n = n ⦄ := by
  unfold core.iter.traits.iterator.Iterator.take.trait_default
  apply WP.spec_bind (core.iter.traits.iterator.Iterator.take.default.spec self n)
  intro x h
  simp only [WP.spec_ok]
  exact h

@[step]
theorem core.iter.traits.iterator.Iterator.rev.default.spec
    {Self : Type} (self : Self) :
    core.iter.traits.iterator.Iterator.rev.default self
    ⦃ r => r.iter = self ⦄ := by
  unfold core.iter.traits.iterator.Iterator.rev.default
  simp [WP.spec_ok]

@[step]
theorem core.iter.traits.iterator.Iterator.take_while.default.spec
    {Self P : Type} (self : Self) (predicate : P) :
    core.iter.traits.iterator.Iterator.take_while.default self predicate
    ⦃ t => t.iter = self ∧ t.flag = false ∧ t.predicate = predicate ⦄ := by
  unfold core.iter.traits.iterator.Iterator.take_while.default
  simp [WP.spec_ok]

@[step]
theorem core.iter.traits.iterator.Iterator.take_while.trait_default.spec
    {Self P Item : Type}
    (inst : core.iter.traits.iterator.Iterator Self Item)
    (predInst : core.ops.function.FnMut P Item Bool)
    (self : Self) (predicate : P) :
    core.iter.traits.iterator.Iterator.take_while.trait_default inst predInst self predicate
    ⦃ t => t.iter = self ∧ t.flag = false ∧ t.predicate = predicate ⦄ := by
  unfold core.iter.traits.iterator.Iterator.take_while.trait_default
  exact core.iter.traits.iterator.Iterator.take_while.default.spec self predicate

@[step]
theorem core.iter.traits.iterator.Iterator.rev.trait_default.spec
    {Self Item0 Item1 : Type}
    (inst : core.iter.traits.iterator.Iterator Self Item0)
    (de : core.iter.traits.double_ended.DoubleEndedIterator Self Item1)
    (self : Self) :
    core.iter.traits.iterator.Iterator.rev.trait_default inst de self
    ⦃ r => r.iter = self ⦄ := by
  unfold core.iter.traits.iterator.Iterator.rev.trait_default
  apply WP.spec_bind (core.iter.traits.iterator.Iterator.rev.default.spec self)
  intro x h
  simp only [WP.spec_ok]
  exact h

@[step]
theorem core.iter.traits.iterator.Iterator.zip.default.spec
    {Self U IntoIter : Type}
    (into_iter : U → Result IntoIter)
    (self : Self) (other : U)
    (h_into : ∃ other', into_iter other = ok other') :
    core.iter.traits.iterator.Iterator.zip.default into_iter self other
    ⦃ z => ∃ other', into_iter other = ok other' ∧ z.fst = self ∧ z.snd = other' ⦄ := by
  unfold core.iter.traits.iterator.Iterator.zip.default
  obtain ⟨ other', h_into ⟩ := h_into
  simp [h_into, WP.spec_ok]

@[step]
theorem core.iter.traits.iterator.Iterator.zip.trait_default.spec
    {Self U Item0 Item1 IntoIter : Type}
    (inst : core.iter.traits.iterator.Iterator Self Item0)
    (IntoIterInst : core.iter.traits.collect.IntoIterator U Item1 IntoIter)
    (self : Self) (other : U)
    (h_into : ∃ other', IntoIterInst.into_iter other = ok other') :
    core.iter.traits.iterator.Iterator.zip.trait_default inst IntoIterInst self other
    ⦃ z => ∃ other', IntoIterInst.into_iter other = ok other' ∧ z.fst = self ∧ z.snd = other' ⦄ := by
  unfold core.iter.traits.iterator.Iterator.zip.trait_default
    core.iter.traits.iterator.Iterator.zip.default
  obtain ⟨ other', h_into ⟩ := h_into
  simp [h_into, WP.spec_ok, ZipShape.ofZip]
  exact ⟨rfl, rfl⟩

/-- `Iterator::next` on `TakeWhile<I, P>`: yields until the predicate first fails,
    then latches `flag` and yields nothing further. -/
@[rust_fun
  "core::iter::adapters::take_while::{core::iter::traits::iterator::Iterator<core::iter::adapters::take_while::TakeWhile<@I, @P>, @Clause0_Item>}::next"]
def core.iter.adapters.take_while.TakeWhile.Insts.CoreIterTraitsIteratorIterator.next
  {I P Item : Type}
  (IterInst : core.iter.traits.iterator.Iterator I Item)
  (PredInst : core.ops.function.FnMut P Item Bool) :
  core.iter.adapters.take_while.TakeWhile I P →
    Result ((Option Item) × core.iter.adapters.take_while.TakeWhile I P) :=
  fun self =>
    if self.flag then ok (none, self)
    else do
      let (o, it) ← IterInst.next self.iter
      match o with
      | none => ok (none, ⟨it, self.flag, self.predicate⟩)
      | some x => do
        let (b, p) ← PredInst.call_mut self.predicate x
        if b then ok (some x, ⟨it, false, p⟩)
        else ok (none, ⟨it, true, p⟩)

/-- `Iterator::next` on `Rev<I>`: delegates to the inner `next_back`. -/
def core.iter.adapters.rev.Rev.Insts.CoreIterTraitsIteratorIterator.nextPlain
  {I Item : Type}
  (DEInst : core.iter.traits.double_ended.DoubleEndedIterator I Item) :
  core.iter.adapters.rev.Rev I →
    Result ((Option Item) × core.iter.adapters.rev.Rev I) :=
  fun self => do
    let (o, it) ← DEInst.next_back self.iter
    ok (o, ⟨it⟩)

def core.iter.adapters.rev.Rev.Insts.CoreIterTraitsIteratorIterator.nextMut
  {I Item : Type}
  (DEInst : core.iter.traits.double_ended.DoubleEndedIterator I Item)
  (self : core.iter.adapters.rev.Rev I) :
  Result ((Option Item) × core.iter.adapters.rev.Rev I ×
    List (core.iter.adapters.rev.Rev I → Option Item → core.iter.adapters.rev.Rev I)) := do
  let (o, it, bs) ← DEInst.nextBackMut self.iter
  ok (o, ⟨it⟩, bs.map fun b r o => ⟨b r.iter o⟩)

/-- The inner `size_hint` -/
def core.iter.adapters.rev.Rev.Insts.CoreIterTraitsIteratorIterator.size_hint
  {I Item : Type}
  (DEInst : core.iter.traits.double_ended.DoubleEndedIterator I Item)
  (self : core.iter.adapters.rev.Rev I) : Result (Usize × Option Usize) :=
  DEInst.iteratorInst.size_hint self.iter

@[reducible, rust_trait_impl
  "core::iter::traits::iterator::Iterator<core::iter::adapters::rev::Rev<@I>, @Clause0_Clause0_Item>"]
impl_def core.iter.adapters.rev.Rev.Insts.CoreIterTraitsIteratorIterator {I Item : Type}
  (DEInst : core.iter.traits.double_ended.DoubleEndedIterator I Item) :
  core.iter.traits.iterator.Iterator (core.iter.adapters.rev.Rev I) Item := {
  next := core.iter.adapters.rev.Rev.Insts.CoreIterTraitsIteratorIterator.nextPlain DEInst
  size_hint := core.iter.adapters.rev.Rev.Insts.CoreIterTraitsIteratorIterator.size_hint DEInst
  nextMut := core.iter.adapters.rev.Rev.Insts.CoreIterTraitsIteratorIterator.nextMut DEInst
}

instance {I : Type} [M : MutRegions I] : MutRegions (core.iter.adapters.rev.Rev I) := ⟨M.n⟩
instance {I : Type} [GivesBack I] : GivesBack (core.iter.adapters.rev.Rev I) := ⟨⟩
instance {I Item : Type} [IM : ItemMut I Item] : ItemMut (core.iter.adapters.rev.Rev I) Item :=
  ⟨IM.M, IM.put⟩

@[rust_fun
  "core::iter::adapters::rev::{core::iter::traits::iterator::Iterator<core::iter::adapters::rev::Rev<@I>, @Clause0_Clause0_Item>}::next"]
def core.iter.adapters.rev.Rev.Insts.CoreIterTraitsIteratorIterator.next
  {I Item : Type} [M : MutRegions I]
  (DEInst : core.iter.traits.double_ended.DoubleEndedIterator I Item)
  (self : core.iter.adapters.rev.Rev I) :
  Result ((Option Item) × Backs M.n (core.iter.adapters.rev.Rev I)
    (core.iter.adapters.rev.Rev I → Option Item → core.iter.adapters.rev.Rev I)) :=
  (core.iter.adapters.rev.Rev.Insts.CoreIterTraitsIteratorIterator DEInst).nextShapedN M.n self

/-- `Range<A>::next_back` (`DoubleEndedIterator`): if `start < end`, decrement
    `end` by one and yield the new `end`; otherwise `none`. -/
@[rust_fun
  "core::iter::range::{core::iter::traits::double_ended::DoubleEndedIterator<core::ops::range::Range<@A>, @A>}::next_back"]
def core.ops.range.Range.Insts.CoreIterTraitsDoubleEndedIterator.next_back
  {A : Type} (StepInst : core.iter.range.Step A) :
  core.ops.range.Range A → Result ((Option A) × core.ops.range.Range A) :=
  fun r => do
    let lt ← StepInst.partialOrdInst.lt r.start r.«end»
    if lt then do
      let b ← StepInst.backward_checked r.«end» 1#usize
      match b with
      | none => .fail .panic
      | some e' => ok (some e', { r with «end» := e' })
    else ok (none, r)

/-- `RangeInclusive<A>::next_back` (`DoubleEndedIterator`): symmetric to `next`,
    consuming from the high end (`end`).

```rust
fn spec_next_back(&mut self) -> Option<A> {
  if self.is_empty() {
      return None;
  }
  let is_iterating = self.start < self.end;
  Some(if is_iterating {
      let n =
          Step::backward_checked(self.end.clone(), 1).expect("`Step` invariants not upheld");
      mem::replace(&mut self.end, n)
  } else {
      self.exhausted = true;
      self.end.clone()
  })
}
```
-/
@[rust_fun
  "core::iter::range::{core::iter::traits::double_ended::DoubleEndedIterator<core::ops::range::RangeInclusive<@A>, @A>}::next_back"]
def core.ops.range.RangeInclusive.Insts.CoreIterTraitsDoubleEndedIterator.next_back
  {A : Type} (StepInst : core.iter.range.Step A)
  (self : core.ops.range.RangeInclusive A) :
  Result ((Option A) × core.ops.range.RangeInclusive A) := do
  if ← self.is_empty StepInst.partialOrdInst then .ok (none, self)
  else
    let is_iterating ← StepInst.partialOrdInst.lt self.start self.«end»
    if is_iterating then
      let n ← StepInst.backward_checked self.«end» 1#usize
      match n with
      | none => .fail .panic
      | some e' => ok (some self.«end», ⟨self.start, e', self.exhausted⟩)
    else
      let n ← StepInst.cloneInst.clone self.end
      ok (some n, ⟨self.start, self.«end», true⟩)

@[rust_type "core::iter::adapters::map::Map"]
structure core.iter.adapters.map.Map (I : Type u) (F : Type v) where
  iter : I
  f : F

instance {I F : Type} [GivesBack F] : GivesBack (core.iter.adapters.map.Map I F) := ⟨⟩

/-- The output of `map(it, f)`: the `Map`, and the closure's give back from its final state. -/
class MapShape (Self F : Type) where
  Out : Type
  ofMap : core.iter.adapters.map.Map Self F → Out

instance (priority := low) {Self F : Type} : MapShape Self F := ⟨_, id⟩

instance {Self F : Type} [GivesBack F] : MapShape Self F :=
  ⟨core.iter.adapters.map.Map Self F × (core.iter.adapters.map.Map Self F → F),
    fun m => (m, (·.f))⟩

/-- The output of `fold(it, init, f)`: the result, and the closure in its final state. `Tail`
is that closure alone, for consumers over `&mut` items, which give it back after the final
iterators. -/
class FoldShape (B F : Type) (Out : outParam Type) where
  ofFold : B → F → Out
  Tail : List Type
  tail : F → HList Tail

instance (priority := low) {B F : Type} : FoldShape B F B := ⟨fun b _ => b, [], fun _ => .nil⟩

instance {B F : Type} [GivesBack F] : FoldShape B F (B × F) := ⟨Prod.mk, [F], fun f => .cons f .nil⟩
