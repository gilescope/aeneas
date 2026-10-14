module
public import Aeneas.Std.Scalar
public import Aeneas.Std.Slice
public import Aeneas.Std.StringDef
public section

namespace Aeneas.Std

instance : DecidableEq Str := inferInstanceAs (DecidableEq (Slice U8))

/-- `bs.toList` has the same length as `bs`. -/
theorem ByteArray.length_toList (bs : ByteArray) :
    bs.toList.length = bs.size := by
  have loop_length :
      ∀ (i : Nat) (r : List UInt8), i ≤ bs.size →
        (ByteArray.toList.loop bs i r).length = (bs.size - i) + r.length := by
    intro i r hi
    fun_induction ByteArray.toList.loop bs i r with
    | case1 i r h ih =>
      have hi' : i + 1 ≤ bs.size := by scalar_tac
      rw [ih hi']
      simp; scalar_tac
    | case2 i r h =>
      simp; scalar_tac
  unfold ByteArray.toList
  rw [loop_length 0 [] (Nat.zero_le _)]
  simp

/-- A string literal as a `Str`. No bound proof at each literal: `decide` cannot prove one
(`U32.max` is an `irreducible_def`, opaque to the kernel), and `decide +native` added a
`native_decide` axiom per literal, which axiom audits reject. Rust literals are under `u32::MAX`
bytes, so the `take` keeps them whole. It is a `take`, not an `if`: the `if`'s compiled helper
(`toStr._redArg`) was unknown to `#eval` in importing modules. -/
def toStr (s : String) : Str :=
  .from ((s.toByteArray.toList.map
      (fun x => ⟨ x.toNat, by cases x; simp only [UInt8.toNat_ofBitVec, UScalarTy.U8_numBits_eq, Nat.reducePow]; omega  ⟩)).take U32.max)
    ((List.length_take_le _ _).trans (by scalar_tac))

example : Str := toStr "hello"

end Aeneas.Std
