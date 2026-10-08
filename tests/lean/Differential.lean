import ClosureOutputBorrows
import ClosureNestedBorrows
import AssocTypeDiamond

/-! # Differential checks: the extracted Lean computes what Rust computes

Each value here is the one the test's Rust unit test asserts (`#[cfg(test)] mod tests` in
`tests/src/<test>.rs`, run by `make cargo-test`). They pin down the borrow-handling prepasses
(closure results that borrow their inputs, erased lifetimes in closure results, diamond
associated types): a translation that typechecks but computes something else fails here. -/

open Aeneas Aeneas.Std

namespace Differential

-- tests/src/closure-output-borrows.rs
open closure_output_borrows in
#guard (identity 7#u32).reducesTo 7#u32
open closure_output_borrows in
#guard (pick (Slice.from [10#u32, 20#u32, 30#u32] (by scalar_tac)) 1#usize).reducesTo 20#u32
open closure_output_borrows in
#guard (first_pair (Slice.from [5#u32, 6#u32] (by scalar_tac))).reducesTo (5#u32, 5#u32)

-- Kernel-checked where the kernel can evaluate the code
open closure_output_borrows in
example : identity 7#u32 = .ok 7#u32 := by rfl
open closure_output_borrows in
example : pick (Slice.from [10#u32, 20#u32, 30#u32] (by scalar_tac)) 1#usize = .ok 20#u32 := by rfl

-- tests/src/closure-nested-borrows.rs
open closure_nested_borrows in
def unitPcs : Pcs Unit Std.U32 := {}
open closure_nested_borrows in
#guard (Evaluated.first (BuiltinCopy Std.U32) unitPcs
    { evals := alloc.vec.Vec.from [(3#u32, alloc.vec.Vec.from [9#u32, 8#u32] (by scalar_tac))] (by scalar_tac),
      commitment := 42#u32 }).reducesTo (3#u32, 9#u32, 42#u32)

-- tests/src/assoc-type-diamond.rs
open assoc_type_diamond in
def base : Base Unit Std.U32 := { coremarkerCopyInst := BuiltinCopy Std.U32 }
open assoc_type_diamond in
#guard (both Std.U32 { BaseInst := base } { BaseInst := base } 17#u32).reducesTo 17#u32

end Differential
