/- Hand-written: a string literal in extracted code (`toStr "..."`) needs only Lean's standard
axioms; it used to add a `native_decide` one (`Lean.ofReduceBool`), which audits reject. -/
import Aeneas
open Aeneas Aeneas.Std

def strLiteral : Str := toStr "Fixed"

/-- info: 'strLiteral' depends on axioms: [propext, Quot.sound] -/
#guard_msgs in #print axioms strLiteral
