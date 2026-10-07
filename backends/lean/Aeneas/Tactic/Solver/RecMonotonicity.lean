/- Monotonicity proofs for functions recursing through trait impls -/
module
public import Lean
public section

/-!
# `aeneas_monotonicity`

A function which calls itself from a closure (`call(|| f(false))`) is mutually recursive with
the closure's `FnOnce` impl (aeneas#1264). Aeneas extracts the functions of such a group as one
`partial_fixpoint` group, in which the impls are inlined as structure literals passed to the
callees (`call { call_once := f.closure.call_once } ()`).

Lean then cannot prove the group monotone on its own, because a recursive function is passed
*as a value* to `call`. `aeneas_monotonicity [call, ...]` proves it: it unfolds the given
callees (transparent, non-recursive functions, which only call the closures they receive),
reduces the inlined impl literals, peels the functions' arguments, runs `monotonicity`, and
closes what it leaves open with `mono_leaf`, which decomposes by syntax: constants, the
recursive calls (projections of the tuple of the group's functions, applied), and
function-valued terms. A callee which is opaque needs a `@[partial_fixpoint_monotone]` lemma
instead.
-/

namespace Aeneas

open Lean Meta Elab Tactic Lean.Order in
/-- Close a leaf goal `monotone fun x => e` left open by `monotonicity` in a group of
functions recursing through trait impls: `e` does not use `x`, is `x`, projects the tuple
of recursive functions, applies a function to arguments not using `x`, or is a function. -/
meta partial def monoLeaf : TacticM Unit := do
  -- The head of a recursive call: the tuple of recursive functions, projected.
  let rec isRecHead (e : Expr) : Bool :=
    match e.consumeMData with
    | .bvar 0 => true
    | .proj _ _ s => isRecHead s
    | e =>
      (e.isAppOfArity ``PProd.fst 3 || e.isAppOfArity ``PProd.snd 3) && isRecHead e.appArg!
  let g ← getMainGoal
  let some f := (← instantiateMVars (← g.getType)).getAppArgs.back?
    | throwError "mono_leaf: not a monotonicity goal"
  let .lam _ _ body _ := f.consumeMData | throwError "mono_leaf: not a lambda: {f}"
  let body := body.consumeMData
  let run (stx : TacticM Syntax) : TacticM Unit := do evalTactic (← stx)
  let isFunctionValued (f : Expr) : TacticM Bool := do
    let x ← mkFreshExprMVar (← inferType f).bindingDomain!
    return (← whnf (← inferType (mkApp f x))).isForall
  if !body.hasLooseBVars then run `(tactic| exact Lean.Order.monotone_const _)
  else if body == .bvar 0 then run `(tactic| exact Lean.Order.monotone_id)
  else if body.isLambda then
    run `(tactic| (apply Lean.Order.monotone_of_monotone_apply; intro _)); monoLeaf
  else if body.isAppOfArity ``PProd.fst 3 || (body.isProj && body.projIdx! == 0) then
    run `(tactic| apply Lean.Order.PProd.monotone_fst); monoLeaf
  else if body.isAppOfArity ``PProd.snd 3 || (body.isProj && body.projIdx! == 1) then
    run `(tactic| apply Lean.Order.PProd.monotone_snd); monoLeaf
  else if body.isApp && !body.appArg!.hasLooseBVars && isRecHead body.getAppFn then
    -- A recursive call: strip the arguments down to the tuple projection.
    run `(tactic| apply Lean.Order.monotone_apply); monoLeaf
  else if (← isFunctionValued f) then
    -- A function-valued body (e.g. a bind waiting for its continuation): peel it.
    run `(tactic| (apply Lean.Order.monotone_of_monotone_apply; intro _)); monoLeaf
  else
    -- Not a leaf: decompose it with `monotonicity`, then close what is left.
    let before ← getGoals
    run `(tactic| monotonicity)
    if (← getGoals) == before then
      throwError "mono_leaf: cannot decompose {f} ({body.ctorName})"
    let gs ← getGoals
    for g' in gs do
      setGoals [g']
      monoLeaf
    setGoals []

elab "mono_leaf" : tactic => monoLeaf

open Lean.Order in
syntax "aeneas_monotonicity" ("[" ident,* "]")? : tactic

open Lean.Order in
macro_rules
  | `(tactic| aeneas_monotonicity $[[$ids,*]]?) => do
    let unfold ← match ids with
      | some ids =>
        let ids := ids.getElems
        `(tactic| try unfold $ids*)
      | none => `(tactic| skip)
    `(tactic| (
      $unfold:tactic
      try dsimp only
      repeat (apply Lean.Order.monotone_of_monotone_apply; intro _)
      monotonicity <;> mono_leaf))

end Aeneas
