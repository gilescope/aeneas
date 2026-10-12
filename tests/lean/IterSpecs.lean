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
