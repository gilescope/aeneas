import ClosureOutputBorrows
import ClosureNestedBorrows
import AssocTypeDiamond
import LoopsNestedExits
import LoopsNestedExitsIter
import NestedSharedIter
import StaticStr

/-! # Differential checks: the extracted Lean computes what Rust computes

Each value here is the one the test's Rust unit test asserts (`#[cfg(test)] mod tests` in
`tests/src/<test>.rs`, run by `make cargo-test`). They pin down the borrow-handling prepasses
(closure results that borrow their inputs, erased lifetimes in closure results, diamond
associated types, exits lifted out of nested loops): a translation that typechecks but computes something else fails here. -/

open Aeneas Aeneas.Std

namespace Differential

-- To compare Rust `Result`s
deriving instance BEq for core.result.Result

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

-- tests/src/loops-nested-exits.rs
/-- A literal row -/
macro "row[" xs:term,* "]" : term =>
  `(alloc.vec.Vec.from [$xs,*] (by scalar_tac))
/-- A literal slice of rows -/
macro "rows[" rs:term,* "]" : term =>
  `(Slice.from [$rs,*] (by scalar_tac))

open loops_nested_exits in
#guard (sum_checked rows[row[1#u32, 2#u32], row[3#u32]]).reducesTo (.Ok 6#u32)
open loops_nested_exits in
#guard (sum_checked rows[row[1#u32, 2#u32], row[0#u32, 3#u32]]).reducesTo (.Err 7#u32)
open loops_nested_exits in
#guard (find3 5#u32).reducesTo 13#u32
open loops_nested_exits in
#guard (find3 2#u32).reducesTo 0#u32
open loops_nested_exits in
#guard (prefix_sums rows[row[1#u32, 0#u32, 5#u32], row[2#u32, 3#u32]]).reducesTo 1006#u32
open loops_nested_exits in
#guard (until_zero rows[row[1#u32, 2#u32], row[3#u32, 0#u32, 9#u32], row[4#u32]]).reducesTo 6#u32

-- tests/src/loops-nested-exits-iter.rs
/-- The `Vec`s in a result as lists, to compare them -/
def lists (r : core.result.Result (alloc.vec.Vec (alloc.vec.Vec Std.U32)) Std.U32) :
    core.result.Result (List (List Std.U32)) Std.U32 :=
  match r with
  | .Ok v => .Ok (v.val.map (·.val))
  | .Err e => .Err e
/-- The `Vec` in a result as a list, to compare it -/
def list (r : core.result.Result (alloc.vec.Vec Std.U32) Std.U32) :
    core.result.Result (List Std.U32) Std.U32 :=
  match r with
  | .Ok v => .Ok v.val
  | .Err e => .Err e
/-- A literal slice -/
macro "slice[" xs:term,* "]" : term =>
  `(Slice.from [$xs,*] (by scalar_tac))

open loops_nested_exits_iter in
#guard (sum_checked rows[row[1#u32, 2#u32], row[3#u32]]).reducesTo (.Ok 6#u32)
open loops_nested_exits_iter in
#guard (sum_checked rows[row[1#u32, 2#u32], row[0#u32, 3#u32]]).reducesTo (.Err 7#u32)
open loops_nested_exits_iter in
#guard (do let (r, _) ← evaluate slice[1#u32, 5#u32]
              { buf := row[10#u32, 20#u32, 30#u32, 40#u32], pos := 0#usize }
           pure (lists r)).reducesTo (.Ok [[11#u32, 22#u32], [35#u32, 46#u32]])
open loops_nested_exits_iter in
#guard (do let (r, _) ← evaluate slice[1#u32, 5#u32]
              { buf := row[10#u32, 20#u32, 30#u32], pos := 0#usize }
           pure (lists r)).reducesTo (.Err 1#u32)
open loops_nested_exits_iter in
#guard (do let (r, _) ← evaluate_checked slice[1#u32, 5#u32]
              { buf := row[10#u32, 20#u32, 30#u32, 40#u32], pos := 0#usize }
           pure (lists r)).reducesTo (.Ok [[11#u32, 22#u32], [35#u32, 46#u32]])
open loops_nested_exits_iter in
#guard (do let (r, _) ← evaluate_checked slice[1#u32, 5#u32]
              { buf := row[10#u32, 9#u32, 30#u32, 40#u32], pos := 0#usize }
           pure (lists r)).reducesTo (.Err 2#u32)
open loops_nested_exits_iter in
#guard (do let (r, _) ← evaluate_checked slice[1#u32, 5#u32]
              { buf := row[10#u32, 20#u32, 30#u32], pos := 0#usize }
           pure (lists r)).reducesTo (.Err 1#u32)
open loops_nested_exits_iter in
#guard (list <$> absorb slice[1#u32, 2#u32] rows[row[3#u32], row[4#u32, 5#u32]]).reducesTo
  (.Ok [1#u32, 1#u32, 3#u32, 2#u32, 4#u32, 5#u32])
open loops_nested_exits_iter in
#guard (list <$> absorb slice[1#u32, 0#u32] rows[row[3#u32]]).reducesTo (.Err 7#u32)
open loops_nested_exits_iter in
#guard (list <$> absorb slice[1#u32] rows[row[3#u32], row[]]).reducesTo (.Err 7#u32)
open loops_nested_exits_iter in
#guard (list <$> absorb slice[1#u32] rows[row[3#u32, 0#u32]]).reducesTo (.Err 7#u32)
-- tests/src/nested-shared-iter.rs
/-- A literal slice of slices -/
macro "slices[" rs:term,* "]" : term =>
  `(Slice.from [$rs,*] (by scalar_tac))

open nested_shared_iter in
#guard (total_len slices[slice[1#u32, 2#u32], slice[], slice[3#u32]]).reducesTo 3#u32
open nested_shared_iter in
#guard (total slices[slice[1#u32, 2#u32], slice[], slice[3#u32]]).reducesTo 6#u32
open nested_shared_iter in
#guard (absorb slices[slice[1#u32, 2#u32], slice[3#u32]]).reducesTo (.Ok 9#u32)
open nested_shared_iter in
#guard (absorb slices[slice[1#u32, 2#u32], slice[]]).reducesTo (.Err 7#u32)
open nested_shared_iter in
#guard (absorb slices[slice[1#u32, 0#u32]]).reducesTo (.Err 7#u32)

-- tests/src/static-str.rs
open static_str in
#guard «name».reducesTo (toStr "column")
open static_str in
#guard renamed.reducesTo (toStr "column")
open static_str in
#guard (check 3#usize true).reducesTo (.Ok 3#usize)
open static_str in
#guard (check 3#usize false).reducesTo (.Err (toStr "Cannot convert into Column<Advice>"))

end Differential
