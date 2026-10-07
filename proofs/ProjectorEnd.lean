/-!
# Ending a borrow projector over a symbolic value: a model of the give-back rule

A model of what `end_aproj_borrows` and `give_back_symbolic_value`
(`src/interp/InterpBorrows.ml`) do when an abstraction `C` ends its projector of
borrows over a symbolic value `σ`, giving back a fresh value `n`.

* A symbolic value's type has region *slots*. Each abstraction owns a set of slots,
  and a projector in it projects onto exactly those slots.
* "Owned" is `projections_intersect` with `C`'s slots: here, the slot sets meet.
* `end_aproj_borrows`: every live borrows projector over `σ` that is owned by `C`
  ends; every other one ("outlive") gets a loans projector over `n`.
* `give_back_symbolic_value`: every owned loans projector over `σ` records `n` as
  consumed; every other one ("outlive") gets a borrows projector over `n`.

The invariant (`Invariants.ml`, "if there is an aproj_borrows ... there must also be
a corresponding aproj_loans") is `Inv`: every live borrows projector is matched by a
live loans projector over the same value on intersecting slots.

The fix (`nested_projections_intersect` and the matched-loans check): project only
into projectors whose slots are *nested* under the ended slots (`nest`), and on the
loans side only where `end_aproj_borrows` put a matching projector of loans.

Results:
* `old_breaks_inv`: the current rule breaks `Inv` when two sibling abstractions
  (e.g. the two regions of a `Zip<IterMut<'a>, IterMut<'b>>` moved into an opaque
  call) end one after the other.
* `fixed_preserves_inv`: the fixed rule preserves `Inv`, for every state, every
  ending abstraction and every nesting predicate.
* `fixed_no_outlive`: on the zip example (no slot nested under another) the fixed rule
  introduces no outlive projector at all, which the pure translation requires.
* `fixed_eq_old`: when every projector is nested (`&'a mut &'b mut T`) and the current
  rule keeps `Inv`, the two rules compute the same state.
* `consumed_eq`: the two rules record the same consumed values, which the pure
  translation reads back.

This models the two functions, not their OCaml text: the link is by inspection.
-/

namespace ProjectorEnd

abbrev Slots := List Nat

/-- Do two slot sets meet? -/
def meets (x y : Slots) : Bool := x.any (fun i => y.contains i)

theorem meets_iff (x y : Slots) : meets x y = true ↔ ∃ i, i ∈ x ∧ i ∈ y := by
  simp [meets, List.any_eq_true]

theorem meets_comm (x y : Slots) : meets x y = meets y x := by
  apply Bool.eq_iff_iff.mpr
  rw [meets_iff, meets_iff]
  exact ⟨fun ⟨i, hx, hy⟩ => ⟨i, hy, hx⟩, fun ⟨i, hy, hx⟩ => ⟨i, hx, hy⟩⟩

inductive Kind | loans | borrows
  deriving DecidableEq, Repr

/-- A live projector of kind `kind` over symbolic value `sv`, in abstraction `abs`. -/
structure Entry where
  kind : Kind
  sv : Nat
  abs : Nat
  deriving DecidableEq, Repr

structure St where
  /-- Owned slots of each abstraction. -/
  own : Nat → Slots
  live : List Entry
  /-- Consumed records `(σ, n, abs)`: abstraction `abs` got `n` back for `σ`. -/
  consumed : List (Nat × Nat × Nat)
  fresh : Nat

def Inv (s : St) : Prop :=
  ∀ e ∈ s.live, e.kind = .borrows →
    ∃ e' ∈ s.live, e'.kind = .loans ∧ e'.sv = e.sv ∧ meets (s.own e.abs) (s.own e'.abs) = true

/-- `Inv` as a Boolean, for concrete states. -/
def invB (s : St) : Bool :=
  s.live.all fun e => decide (e.kind ≠ .borrows) ||
    s.live.any fun e' => decide (e'.kind = .loans) && decide (e'.sv = e.sv) &&
      meets (s.own e.abs) (s.own e'.abs)

theorem inv_invB {s : St} (h : Inv s) : invB s = true := by
  simp only [invB, List.all_eq_true, Bool.or_eq_true, decide_eq_true_eq, List.any_eq_true,
    Bool.and_eq_true]
  intro e he
  by_cases hk : e.kind = .borrows
  · obtain ⟨e', he', h1, h2, h3⟩ := h e he hk
    exact Or.inr ⟨e', he', ⟨h1, h2⟩, h3⟩
  · exact Or.inl hk

/-- `C` ends its borrows projector over `σ`; `fixed` selects the corrected rule.

`nest e` says whether projector `e`'s slots meet the slots *nested* under `C`'s ended
slots (`nested_projections_intersect`): only there can the given back value carry new
inner borrows. The current rule projects into every non-owned projector; the fixed
rule only into nested ones, and on the loans side only where a matching projector of
loans over `n` exists. -/
def endBorrows (fixed : Bool) (nest : Entry → Bool) (s : St) (C σ : Nat) : St :=
  let n := s.fresh
  let oc := s.own C
  -- `end_aproj_borrows`
  let owned (e : Entry) : Bool := meets (s.own e.abs) oc
  let isB (e : Entry) : Bool := decide (e.kind = .borrows) && decide (e.sv = σ)
  let isL (e : Entry) : Bool := decide (e.kind = .loans) && decide (e.sv = σ)
  let others := s.live.filter fun d => isB d && !owned d && (!fixed || nest d)
  let liveA := s.live.filter fun e => !(isB e && owned e)
  let newLoans := others.map fun d => (⟨.loans, n, d.abs⟩ : Entry)
  -- `give_back_symbolic_value`
  let consumedNew := (s.live.filter fun b => isL b && owned b).map fun b => (σ, n, b.abs)
  let keep (b : Entry) : Bool :=
    !fixed || (nest b && others.any fun d => meets (s.own d.abs) (s.own b.abs))
  let newBorrows :=
    (s.live.filter fun b => isL b && !owned b && keep b).map fun b => (⟨.borrows, n, b.abs⟩ : Entry)
  { s with live := liveA ++ newLoans ++ newBorrows, consumed := s.consumed ++ consumedNew,
           fresh := n + 1 }

/-! ## The current rule breaks the invariant -/

/-- Caller abstractions `4 {'4}`, `5 {'5}` loan out `s6 : Zip<'4,'5>`; the callee's
sibling abstractions `6 {'6}`, `7 {'7}` borrow it (slots 0 and 1). -/
def zip : St where
  own a := if a = 4 ∨ a = 6 then [0] else if a = 5 ∨ a = 7 then [1] else []
  live := [⟨.loans, 6, 4⟩, ⟨.loans, 6, 5⟩, ⟨.borrows, 6, 6⟩, ⟨.borrows, 6, 7⟩]
  consumed := []
  fresh := 8

theorem zip_inv : Inv zip := by
  intro e he hk
  simp only [zip, List.mem_cons, List.not_mem_nil, or_false] at he
  rcases he with rfl | rfl | rfl | rfl
  · cases hk
  · cases hk
  · exact ⟨⟨.loans, 6, 4⟩, by simp [zip], rfl, rfl, by decide⟩
  · exact ⟨⟨.loans, 6, 5⟩, by simp [zip], rfl, rfl, by decide⟩

/-- `Zip<IterMut<'a>, IterMut<'b>>`: no slot is nested under another. -/
def flat : Entry → Bool := fun _ => false

/-- `abs@6` ends (giving back `s8`), then `abs@7` (giving back `s9`, the trace's `s@11`). -/
def runOld := endBorrows false flat (endBorrows false flat zip 6 6) 7 6
def runFixed := endBorrows true flat (endBorrows true flat zip 6 6) 7 6

/-- With the fix, only the original projectors remain: no outlive projection at all. -/
theorem fixed_no_outlive : runFixed.live.all (fun e => decide (e.sv = 6)) = true := by decide

theorem old_breaks_inv : ¬ Inv runOld := fun h => by
  have := inv_invB h
  revert this; decide

theorem fixed_ok : invB runFixed = true := by decide

/-- Both rules give `abs@4` and `abs@5` their slot back exactly once. -/
theorem zip_consumed : runOld.consumed = [(6, 8, 4), (6, 9, 5)] ∧
    runFixed.consumed = [(6, 8, 4), (6, 9, 5)] := by decide

/-! ## The fixed rule preserves the invariant -/

theorem fixed_preserves_inv (nest : Entry → Bool) (s : St) (C σ : Nat) (h : Inv s) :
    Inv (endBorrows true nest s C σ) := by
  intro e he hk
  simp only [endBorrows, List.mem_append, List.mem_map, List.mem_filter] at he
  rcases he with (⟨he, -⟩ | ⟨d, -, rfl⟩) | ⟨b, ⟨-, hkeep⟩, rfl⟩
  · -- An old borrows projector: its loans projector is still live (loans never end here).
    obtain ⟨e', he', h1, h2, h3⟩ := h e he hk
    refine ⟨e', ?_, h1, h2, h3⟩
    simp only [endBorrows, List.mem_append, List.mem_filter]
    left; left
    refine ⟨he', ?_⟩
    simp [h1]
  · cases hk
  · -- A new borrows projector over `n`: `end_aproj_borrows` put its loans projector in `d`.
    simp only [Bool.not_true, Bool.false_or, Bool.and_eq_true, List.any_eq_true,
      List.mem_filter] at hkeep
    obtain ⟨-, -, d, ⟨hd, hdb⟩, hm⟩ := hkeep
    refine ⟨⟨.loans, s.fresh, d.abs⟩, ?_, rfl, rfl, ?_⟩
    · simp only [endBorrows, List.mem_append, List.mem_map, List.mem_filter]
      left; right
      exact ⟨d, ⟨hd, by simpa using hdb⟩, rfl⟩
    · show meets (s.own b.abs) (s.own d.abs) = true
      rw [meets_comm]; exact hm

/-! ## Where the current rule works, the fixed rule changes nothing -/

/-- For nested borrows (`&'a mut &'b mut T`: every non-owned projector is nested) the fix
changes nothing wherever the current rule keeps the invariant. -/
theorem fixed_eq_old (nest : Entry → Bool) (s : St) (C σ : Nat)
    (hnest : ∀ e ∈ s.live, nest e = true) (hfresh : ∀ e ∈ s.live, e.sv < s.fresh)
    (h : Inv (endBorrows false nest s C σ)) :
    endBorrows true nest s C σ = endBorrows false nest s C σ := by
  -- Every projector is nested, so the extra `nest` conditions are all true.
  have hO : ∀ d ∈ s.live,
      (decide (d.kind = .borrows) && decide (d.sv = σ) && !meets (s.own d.abs) (s.own C) &&
        (!true || nest d)) =
      (decide (d.kind = .borrows) && decide (d.sv = σ) && !meets (s.own d.abs) (s.own C) &&
        (!false || nest d)) := by
    intro d hd; simp [hnest d hd]
  simp only [endBorrows, St.mk.injEq, and_true, true_and]
  rw [List.filter_congr hO]
  congr 2
  apply List.filter_congr
  intro b hb
  simp only [Bool.not_true, Bool.false_or, Bool.not_false, Bool.true_or, Bool.and_true,
    hnest b hb, Bool.true_and]
  -- In the old run `b` received a borrows projector over `n`; `Inv` matches it.
  by_cases hc : (decide (b.kind = .loans) && decide (b.sv = σ) && !meets (s.own b.abs) (s.own C)) = true
  · rw [hc, Bool.true_and]
    have hmem : (⟨.borrows, s.fresh, b.abs⟩ : Entry) ∈ (endBorrows false nest s C σ).live := by
      simp only [endBorrows, List.mem_append, List.mem_map, List.mem_filter]
      right
      exact ⟨b, ⟨hb, by simpa using hc⟩, rfl⟩
    obtain ⟨e', he', h1, h2, h3⟩ := h _ hmem rfl
    simp only [endBorrows, List.mem_append, List.mem_map, List.mem_filter] at he'
    rcases he' with (⟨he', -⟩ | ⟨d, hd, rfl⟩) | ⟨b', -, rfl⟩
    · exact absurd (hfresh e' he') (by simp at h2; omega)
    · simp only [List.any_eq_true]
      have h3' : meets (s.own b.abs) (s.own d.abs) = true := h3
      refine ⟨d, ?_, by rw [meets_comm]; exact h3'⟩
      simpa using hd
    · cases h1
  · simp only [Bool.not_eq_true] at hc
    rw [hc, Bool.false_and]

/-- The fix only touches the "outlive" branch: consumed records are the same. -/
theorem consumed_eq (nest : Entry → Bool) (s : St) (C σ : Nat) :
    (endBorrows true nest s C σ).consumed = (endBorrows false nest s C σ).consumed := rfl

end ProjectorEnd

#print axioms ProjectorEnd.fixed_preserves_inv
#print axioms ProjectorEnd.fixed_eq_old
#print axioms ProjectorEnd.old_breaks_inv
#print axioms ProjectorEnd.fixed_no_outlive
