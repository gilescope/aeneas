/- Hand-written: the `Aeneas.Std.IterSpecs` lemmas on concrete inputs. -/
import Aeneas
open Aeneas Aeneas.Std Result

-- `-2..1` over `i32` yields `-2, -1, 0`
example : ∃ rs : List I32, rs.map (·.val) = [-2, -1, 0] ∧
    Yields (core.iter.traits.iterator.IteratorRange core.iter.range.StepI32) ⟨(-2)#i32, 1#i32⟩ rs := by
  obtain ⟨rs, h, hy⟩ := core.iter.range.IteratorRange.yields_I32 ⟨(-2)#i32, 1#i32⟩
  exact ⟨rs, by rw [h]; simp [intRange]; decide, hy⟩

-- `-1..=0` over `i64` yields `-1, 0`
example : ∃ rs : List I64, rs.map (·.val) = [-1, 0] ∧
    Yields (core.ops.range.RangeInclusive.Insts.CoreIterTraitsIteratorIterator
      core.iter.range.StepI64) ⟨(-1)#i64, 0#i64, false⟩ rs := by
  obtain ⟨rs, h, hy⟩ := core.ops.range.RangeInclusive.yields_I64 ⟨(-1)#i64, 0#i64, false⟩ rfl
  exact ⟨rs, by rw [h]; simp [intRange]; decide, hy⟩

-- an empty range yields nothing
example : Yields (core.iter.traits.iterator.IteratorRange core.iter.range.StepI32)
    ⟨3#i32, 3#i32⟩ [] := by
  obtain ⟨rs, h, hy⟩ := core.iter.range.IteratorRange.yields_I32 ⟨3#i32, 3#i32⟩
  have : rs = [] := by simpa [intRange] using h
  exact this ▸ hy

-- `foldlM` with a step that keeps the running sum
example (l : List ℕ) : l.foldlM (fun acc x => (ok (acc + x) : Result ℕ)) 0 ⦃ s => s = l.sum ⦄ := by
  have := List.foldlM_spec (fun acc x => (ok (acc + x) : Result ℕ))
    (fun i s => s = (l.take i).sum) l 0 (by simp) (by
      intro i hi s hs
      simp [hs, List.sum_take_succ _ _ hi])
  simpa using this

example : [1, 2, 3].overwrite [7, 8] = [7, 8, 3] := rfl
example : [1, 2].overwrite [7, 8, 9] = [7, 8] := rfl

-- the scalar specs
example : core.num.I64.unsigned_abs ((-5)#i64) ⦃ y => y.val = 5 ⦄ := by
  have := core.num.I64.unsigned_abs_spec ((-5)#i64); simpa using this
example : core.num.I32.abs ((-7)#i32) ⦃ y => y.val = 7 ⦄ := by
  have := core.num.I32.abs_spec ((-7)#i32) (by scalar_tac); simpa using this

-- `iter()` then `collect()` gives the slice back
example (s : Slice U32) :
    core.iter.traits.iterator.Iterator.collect.default
      (core.iter.traits.iterator.IteratorSliceIter U32)
      (core.iter.traits.collect.FromIteratorVec U32) ⟨s, 0⟩ ⦃ v => v.val = s.val ⦄ :=
  core.iter.traits.iterator.Iterator.collect_vec_spec _ _ _
    (by simpa using core.slice.iter.IteratorSliceIter.yields _ ⟨s, 0⟩ rfl) s.property

-- a stateful `map`: each output is the item plus the running count
example : List.mapState (fun (n : ℕ) (x : ℕ) => (x + n, n + 1)) 0 [10, 20, 30] = [10, 21, 32] :=
  rfl

-- `map` with a counting closure over `iter()` yields the outputs `mapState` lists
example (s : Slice ℕ) (FI : core.ops.function.FnMut ℕ ℕ ℕ)
    (hFI : ∀ n x, FI.call_mut n x = ok (x + n, n + 1)) :
    Yields (core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator
      (core.iter.traits.iterator.IteratorSliceIter ℕ) FI)
      ({ iter := { slice := s, i := 0 }, f := 0 } : core.iter.adapters.map.Map (core.slice.iter.Iter ℕ) ℕ)
      (List.mapState (fun n x => (x + n, n + 1)) 0 s.val) :=
  core.iter.adapters.map.Map.yields _ FI _ (fun _ _ => True) (fun x _ n _ => ⟨hFI n x, trivial⟩)
    s.val (⟨s, 0⟩ : core.slice.iter.Iter ℕ) 0
    (by simpa using core.slice.iter.IteratorSliceIter.yields _ (⟨s, 0⟩ : core.slice.iter.Iter ℕ) rfl)
    trivial

-- `BTreeMap` lookup by a `usize` key finds the first entry with that key
example (es : List (Usize × ℕ)) (q : Usize) :
    alloc.collections.btree.map.BTreeMap.lookup (core.borrow.Borrow.Blanket Usize)
      core.cmp.OrdUsize es q = ok ((es.find? fun e => decide (e.1 = q)).map (·.2)) := by
  rw [alloc.collections.btree.map.BTreeMap.lookup_eq core.cmp.OrdUsize q (fun k =>
    ⟨compare q.val k.val, rfl, by
      rw [compare_eq_iff_eq]; exact ⟨fun h => (UScalar.eq_of_val_eq h).symm,
        fun h => by rw [h]⟩⟩) es]
  congr; funext e; congr 1

-- `map` with a closure known by a spec: outputs at least the item, a counter as state
example (s : Slice ℕ) (FI : core.ops.function.FnMut ℕ ℕ ℕ)
    (hFI : ∀ n x, FI.call_mut n x ⦃ y n' => x ≤ y ∧ n' = n + 1 ⦄) :
    ∃ ys : List ℕ, ys.length = s.val.length ∧ (∀ j (_hj : j < ys.length), s.val.getD j 0 ≤ ys[j]) ∧
      Yields (core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator
        (core.iter.traits.iterator.IteratorSliceIter ℕ) FI)
        ({ iter := { slice := s, i := 0 }, f := 0 } :
          core.iter.adapters.map.Map (core.slice.iter.Iter ℕ) ℕ) ys :=
  core.iter.adapters.map.Map.yields_spec _ FI s.val (fun j y => s.val.getD j 0 ≤ y) (fun j n => n = j)
    (⟨s, 0⟩ : core.slice.iter.Iter ℕ) 0
    (by simpa using core.slice.iter.IteratorSliceIter.yields _ (⟨s, 0⟩ : core.slice.iter.Iter ℕ) rfl)
    rfl (fun j _ n hn => WP.spec_mono (hFI n _) fun ⟨_, _⟩ h => by simp_all [List.getD_eq_getElem?_getD])

-- `iter().any(p)` with a stateless predicate is `List.any`
example (s : Slice ℕ) (FI : core.ops.function.FnMut Unit ℕ Bool)
    (hFI : ∀ x, FI.call_mut () x = ok (decide (x = 3), ())) :
    core.iter.traits.iterator.Iterator.any.default (core.iter.traits.iterator.IteratorSliceIter ℕ)
      FI (⟨s, 0⟩ : core.slice.iter.Iter ℕ) () ⦃ b _ => b = s.val.any (fun x => decide (x = 3)) ⦄ :=
  core.iter.traits.iterator.Iterator.any_spec _ FI _ () hFI s.val (⟨s, 0⟩ : core.slice.iter.Iter ℕ)
    (by simpa using core.slice.iter.IteratorSliceIter.yields _ (⟨s, 0⟩ : core.slice.iter.Iter ℕ) rfl)

-- `a.chain(b)` over two slices yields both, in order
example (s t : Slice ℕ) :
    Yields (core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator
      (core.iter.traits.iterator.IteratorSliceIter ℕ) (core.iter.traits.iterator.IteratorSliceIter ℕ))
      ⟨some (⟨s, 0⟩ : core.slice.iter.Iter ℕ), some (⟨t, 0⟩ : core.slice.iter.Iter ℕ)⟩ (s.val ++ t.val) :=
  core.iter.adapters.chain.Chain.yields _ _ t.val _
    (by simpa using core.slice.iter.IteratorSliceIter.yields _ (⟨t, 0⟩ : core.slice.iter.Iter ℕ) rfl)
    s.val _
    (by simpa using core.slice.iter.IteratorSliceIter.yields _ (⟨s, 0⟩ : core.slice.iter.Iter ℕ) rfl)

-- `flat_map` of a slice of slices, each iterated, yields their concatenation
example (ss : Slice (Slice ℕ)) (FI : core.ops.function.FnMut Unit (Slice ℕ) (core.slice.iter.Iter ℕ))
    (hFI : ∀ s, FI.call_mut () s = ok (⟨s, 0⟩, ())) :
    ∃ yss : List (List ℕ), yss.length = ss.val.length ∧
      (∀ i (hi : i < ss.val.length) (hi' : i < yss.length), yss[i] = ss.val[i].val) ∧
      Yields (core.iter.adapters.flatten.FlatMap.Insts.CoreIterTraitsIteratorIterator
        (core.iter.traits.iterator.IteratorSliceIter (Slice ℕ))
        (core.iter.traits.collect.IntoIterator.Blanket (core.iter.traits.iterator.IteratorSliceIter ℕ))
        FI) ⟨some (⟨ss, 0⟩ : core.slice.iter.Iter (Slice ℕ)), (), none, none⟩ yss.flatten :=
  core.iter.adapters.flatten.FlatMap.yields _ _ FI () (fun s ys => ys = s.val) ss.val _
    (by simpa using
          core.slice.iter.IteratorSliceIter.yields _ (⟨ss, 0⟩ : core.slice.iter.Iter (Slice ℕ)) rfl)
    fun s _ => ⟨⟨s, 0⟩, ⟨s, 0⟩, s.val, hFI s, rfl,
      (by simpa using core.slice.iter.IteratorSliceIter.yields _ (⟨s, 0⟩ : core.slice.iter.Iter ℕ) rfl),
      rfl⟩

-- `vec![1, 2].into_iter()` yields `1, 2`
example : alloc.vec.IntoIteratorVec.into_iter (alloc.vec.Vec.from [1#u32, 2#u32] (by scalar_tac)) ⦃ it =>
    Yields (core.iter.traits.iterator.IteratorVecIntoIter U32) it [1#u32, 2#u32] ⦄ :=
  alloc.vec.IntoIteratorVec.into_iter_yields _

/-- A closure's state, holding a `&mut`: `collect` gives it back. -/
structure Counter where
  n : ℕ

instance : GivesBack Counter := ⟨⟩

-- `iter().map(f).collect::<Vec<_>>()` with a counting closure: the caller learns the final count
example (s : Slice ℕ) (FI : core.ops.function.FnMut Counter ℕ ℕ)
    (hFI : ∀ c x, FI.call_mut c x ⦃ y c' => y = x + c.n ∧ c'.n = c.n + 1 ⦄) :
    core.iter.traits.iterator.Iterator.collect.default
      (core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator
        (core.iter.traits.iterator.IteratorSliceIter ℕ) FI)
      (core.iter.traits.collect.FromIteratorVec ℕ)
      ({ iter := ⟨s, 0⟩, f := ⟨0⟩ } : core.iter.adapters.map.Map (core.slice.iter.Iter ℕ) Counter)
    ⦃ v back => v.val.length = s.val.length ∧ back.f.n = s.val.length ⦄ := by
  refine WP.spec_mono (core.iter.traits.iterator.Iterator.collect_vec_map_back_spec _ FI s.val
    (fun j y => y = s.val.getD j 0 + j) (fun j c => c.n = j) (⟨s, 0⟩ : core.slice.iter.Iter ℕ) ⟨0⟩
    (by simpa using core.slice.iter.IteratorSliceIter.yields _ (⟨s, 0⟩ : core.slice.iter.Iter ℕ) rfl)
    s.property rfl
    (fun j _ c hc => WP.spec_mono (hFI c _) fun ⟨_, _⟩ h => by
      simp_all [List.getD_eq_getElem?_getD])) ?_
  rintro ⟨v, back⟩ ⟨ys, hv, hl, -, hb⟩
  exact ⟨hv ▸ hl, hb⟩

-- an accepted bind ran its first step to a value
example (h : Std.bind (ok (2 : ℕ)) (fun x => (ok (x + 1) : Result ℕ)) = ok 3) :
    ∃ x, (ok 2 : Result ℕ) = ok x ∧ (ok (x + 1) : Result ℕ) = ok 3 :=
  bind_eq_ok_inv h

-- a spec's post holds of the value a run returns
example (m : Result ℕ) (x : ℕ) (hs : m ⦃ v => v % 2 = 0 ⦄) (h : m = ok x) : x % 2 = 0 :=
  spec_of_eq_ok (P := fun v => v % 2 = 0) hs h

-- `iter().fold(0, |acc, x| { calls += 1; acc + x })`: the sum, the closure counting every call
example (s : Slice ℕ) (FI : core.ops.function.FnMut ℕ (ℕ × ℕ) ℕ)
    (hFI : ∀ n acc x, FI.call_mut n (acc, x) = ok (acc + x, n + 1)) :
    core.iter.traits.iterator.Iterator.fold.default (S := inferInstance)
      (core.iter.traits.iterator.IteratorSliceIter ℕ) FI (⟨s, 0⟩ : core.slice.iter.Iter ℕ) 0 0
    ⦃ r => r = s.val.sum ⦄ := by
  refine WP.spec_mono (core.iter.traits.iterator.Iterator.fold.default_inv_spec _ FI s.val
    (fun done acc n => acc = done.sum ∧ n = done.length)
    (fun done x _ acc n _ ⟨ha, hn⟩ => by rw [hFI]; simp [WP.spec_ok, ha, hn]) _ 0 0
    (by simpa using core.slice.iter.IteratorSliceIter.yields _ (⟨s, 0⟩ : core.slice.iter.Iter ℕ) rfl)
    ⟨rfl, rfl⟩) ?_
  rintro r ⟨acc, n, ⟨ha, -⟩, hr⟩
  rw [hr]; exact ha

-- `iter().map(|x| (None, x))`: a stateless closure yields its outputs
example (s : Slice ℕ) (FI : core.ops.function.FnMut Unit ℕ (Option ℕ × ℕ))
    (hFI : ∀ x, FI.call_mut () x = ok ((none, x), ())) :
    Yields (core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator
      (core.iter.traits.iterator.IteratorSliceIter ℕ) FI)
      ({ iter := ⟨s, 0⟩, f := () } : core.iter.adapters.map.Map (core.slice.iter.Iter ℕ) Unit)
      (s.val.map (none, ·)) :=
  core.iter.adapters.map.Map.yields_of_pure _ FI () (fun x => (none, x)) hFI s.val _
    (by simpa using core.slice.iter.IteratorSliceIter.yields _ (⟨s, 0⟩ : core.slice.iter.Iter ℕ) rfl)

/-! ## `YieldsAtLeast` -/

-- a finite `Yields` is a `YieldsAtLeast` of the same list
example (s : Slice ℕ) :
    YieldsAtLeast (core.iter.traits.iterator.IteratorSliceIter ℕ) (⟨s, 0⟩ : core.slice.iter.Iter ℕ)
      s.val :=
  YieldsAtLeast.of_yields _ _ _
    (by simpa using core.slice.iter.IteratorSliceIter.yields _ (⟨s, 0⟩ : core.slice.iter.Iter ℕ) rfl)

-- `(0..).take(3)` over an unbounded counter yields `0, 1, 2`
def counter : core.iter.traits.iterator.Iterator ℕ ℕ where
  next n := ok (some n, n + 1)
  size_hint _ := ok (0#usize, none)

example : Yields (core.iter.traits.iterator.IteratorTake counter) ⟨0, 3#usize⟩ [0, 1, 2] :=
  core.iter.adapters.take.Take.yields_atLeast counter [0, 1, 2] 0 3#usize rfl
    (by simp [YieldsAtLeast, counter, WP.spec_ok])

/-! ## Unsigned ranges, Ok-conditional `collect`, `OkYields` -/

-- `2..5` over `usize` yields `2, 3, 4`
example : ∃ rs : List Usize, rs.map (·.val) = [2, 3, 4] ∧
    Yields (core.iter.traits.iterator.IteratorRange core.iter.range.StepUsize) ⟨2#usize, 5#usize⟩ rs := by
  obtain ⟨rs, h, hy⟩ := core.iter.range.IteratorRange.yields_Usize ⟨2#usize, 5#usize⟩
  exact ⟨rs, by rw [h]; decide, hy⟩

-- an accepted `iter().map(f).collect()` relates input and output item by item
example (s : Slice ℕ) (FI : core.ops.function.FnMut Unit ℕ ℕ)
    (hst : ∀ x y f', FI.call_mut () x = ok (y, f') → f' = ()) (v : alloc.vec.Vec ℕ)
    (h : core.iter.traits.iterator.Iterator.collect.default (S := instCollectShape)
      (core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator
        (core.iter.traits.iterator.IteratorSliceIter ℕ) FI)
      (core.iter.traits.collect.FromIteratorVec ℕ) ⟨⟨s, 0⟩, ()⟩ = ok v) :
    List.Forall₂ (fun x y => FI.call_mut () x = ok (y, ())) s.val v.val :=
  core.iter.traits.iterator.Iterator.collect_vec_map_ok _ FI () hst s.val _
    (by simpa using core.slice.iter.IteratorSliceIter.yields _ (⟨s, 0⟩ : core.slice.iter.Iter ℕ) rfl) v h

-- the same through `iterToList`, from a non-empty accumulator
example (s : Slice ℕ) (FI : core.ops.function.FnMut Unit ℕ ℕ)
    (hst : ∀ x y f', FI.call_mut () x = ok (y, f') → f' = ()) (l : List ℕ)
    (h : alloc.vec.FromIteratorVec.iterToList
      (core.iter.adapters.map.Map.Insts.CoreIterTraitsIteratorIterator
        (core.iter.traits.iterator.IteratorSliceIter ℕ) FI) ⟨⟨s, 0⟩, ()⟩ [7] = ok l) :
    ∃ ys, l = 7 :: ys ∧ List.Forall₂ (fun x y => FI.call_mut () x = ok (y, ())) s.val ys := by
  simpa using alloc.vec.FromIteratorVec.iterToList_map_ok _ FI () hst s.val _ [7] l
    (by simpa using core.slice.iter.IteratorSliceIter.yields _ (⟨s, 0⟩ : core.slice.iter.Iter ℕ) rfl) h

-- `Yields` is `OkYields`; `a.chain(b)` Ok-yields both; an accepted `collect` is the list
example (s t : Slice ℕ) (v : alloc.vec.Vec ℕ)
    (h : core.iter.traits.iterator.Iterator.collect.default (S := instCollectShape)
      (core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator
        (core.iter.traits.iterator.IteratorSliceIter ℕ) (core.iter.traits.iterator.IteratorSliceIter ℕ))
      (core.iter.traits.collect.FromIteratorVec ℕ) ⟨some ⟨s, 0⟩, some ⟨t, 0⟩⟩ = ok v) :
    v.val = s.val ++ t.val := by
  have ys := fun u : Slice ℕ => OkYields.of_yields _ _ _
    (by simpa using core.slice.iter.IteratorSliceIter.yields _ (⟨u, 0⟩ : core.slice.iter.Iter ℕ) rfl)
  exact core.iter.traits.iterator.Iterator.collect_vec_okYields _ _ _
    (core.iter.adapters.chain.Chain.okYields _ _ _ _ (ys t) _ _ (ys s)) v h

-- the second half of a chain alone
example (t : Slice ℕ) :
    OkYields (core.iter.adapters.chain.Chain.Insts.CoreIterTraitsIteratorIterator
      (core.iter.traits.iterator.IteratorSliceIter ℕ) (core.iter.traits.iterator.IteratorSliceIter ℕ))
      ⟨none, some ⟨t, 0⟩⟩ t.val :=
  core.iter.adapters.chain.Chain.okYields_b _ _ _ _ (OkYields.of_yields _ _ _
    (by simpa using core.slice.iter.IteratorSliceIter.yields _ (⟨t, 0⟩ : core.slice.iter.Iter ℕ) rfl))

-- `OkYields` through `iterToList`
example (s : Slice ℕ) (l : List ℕ)
    (h : alloc.vec.FromIteratorVec.iterToList (core.iter.traits.iterator.IteratorSliceIter ℕ)
      ⟨s, 0⟩ [] = ok l) : l = s.val := by
  simpa using alloc.vec.FromIteratorVec.iterToList_okYields _ s.val _ [] l (OkYields.of_yields _ _ _
    (by simpa using core.slice.iter.IteratorSliceIter.yields _ (⟨s, 0⟩ : core.slice.iter.Iter ℕ) rfl)) h

/-! ## Accepted scalar and `Vec` ops -/

example (x y z : U32) (h : x + y = ok z) : z.val = x.val + y.val := UScalar.add_ok h

example (x y z : Usize) (h : x - y = ok z) : y.val ≤ x.val ∧ z.val = x.val - y.val :=
  UScalar.sub_ok h

example (r : U8) (h : UScalar.tryMk .U8 7 = ok r) : r.val = 7 := UScalar.tryMk_ok h

example (r : I16) (h : IScalar.tryMk .I16 (-7) = ok r) : r.val = -7 := IScalar.tryMk_ok h

example (v r : alloc.vec.Vec ℕ) (h : v.push 3 = ok r) : r.val = v.val ++ [3] := alloc.vec.Vec.push_ok h

example (v : alloc.vec.Vec ℕ) (i : Usize) (x : ℕ)
    (h : alloc.vec.Vec.index (core.slice.index.SliceIndexUsizeSlice ℕ) v i = ok x) :
    ∃ hi : i.val < v.val.length, x = v.val[i.val] := alloc.vec.Vec.index_ok h

example (v : alloc.vec.Vec ℕ) (i : Usize) (x : ℕ) (back : ℕ → alloc.vec.Vec ℕ)
    (h : alloc.vec.Vec.index_mut (core.slice.index.SliceIndexUsizeSlice ℕ) v i = ok (x, back)) :
    ∃ hi : i.val < v.val.length, x = v.val[i.val] ∧ back = v.set i := alloc.vec.Vec.index_mut_ok h

/-! ## `spec_bind_assoc`, list sums and folds -/

-- a spec of the first two steps, then the third
example : ((ok 1 : Result ℕ) >>= fun x => (ok (x + 1) : Result ℕ) >>= fun y => ok (y * 2))
    ⦃ z => z = 4 ⦄ :=
  spec_bind_assoc (P := fun y => y = 2) (by simp [WP.spec_ok]) (fun y hy => by simp [WP.spec_ok, hy])

example (l1 l2 : List ℕ) (h : List.Forall₂ (fun a b => a = b + 1) l1 l2) :
    ((l1.zipIdx 3).map fun p => p.1 * p.2).sum = ((l2.zipIdx 3).map fun p => (p.1 + 1) * p.2).sum :=
  h.sum_map_zipIdx (fun a k => a * k) (fun b k => (b + 1) * k) (fun _ _ _ h => by rw [h]) 3

example (l1 l2 : List ℕ) (h : List.Forall₂ (· ≤ ·) l1 l2) (b : ℕ) (hb : b ∈ l2) :
    ∃ a ∈ l1, a ≤ b :=
  h.exists_of_mem_right hb

example (l : List ℕ) (hl : l.Nodup) (p : ℕ × ℕ) (hp : p ∈ l.zip l.tail) : p.1 ≠ p.2 :=
  List.Nodup.ne_of_mem_zip_tail hl p hp

example : [1, 2, 3].anyM (fun _ => (ok false : Result Bool)) = ok false :=
  List.anyM_ok_false _ _ (fun _ _ => rfl)

-- Horner from the back is a power-weighted sum
example (x : ℚ) (t : ℕ → ℚ) (l : List ℕ) : l.reverse.foldl (fun k a => k * x + t a) 0 =
    ((List.range l.length).map fun j => x ^ j * (l[j]?.elim 0 t)).sum :=
  List.foldl_reverse_horner x t l

example (l1 l2 : List ℕ) (h : l1.length = l2.length) :
    l1.reverse.zip l2.reverse = (l1.zip l2).reverse := List.zip_reverse l1 l2 h

-- an inner product against `xⁱ⁺ᵏ` is a `zipIdx` sum
example (l ys : List ℚ) (x : ℚ) (hl : l.length ≤ ys.length)
    (hy : ∀ i (h : i < ys.length), ys[i] = x ^ (i + 2)) :
    (List.zipWith (fun c s => id s • id c) l ys).sum = ((l.zipIdx 2).map fun (c, m) => x ^ m • id c).sum :=
  List.sum_zipWith_smul_pow id id x l ys 2 hl hy

-- a `ListN`'s list is no larger than it
example (l : Aeneas.Data.ListN.ListN ℕ 3) : sizeOf l.toList ≤ sizeOf l :=
  Aeneas.Data.ListN.ListN.sizeOf_toList_le l
