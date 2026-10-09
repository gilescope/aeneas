import ClosureOutputBorrows
import ClosureNestedBorrows
import AssocTypeDiamond
import LoopsNestedExits
import LoopsNestedExitsIter
import NestedSharedIter
import StaticStr
import RecursiveDeriveClone
import StringOps
import StdSmallOps
import RefOps
import IterAdaptersStd

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
-- Kernel-checked: `unwrap`'s `Debug` instance is noncomputable
open static_str in
example : advice_or_panic 4#usize = .ok 4#usize := by
  simp [advice_or_panic, check, advice_index, Column.impl.column_type, core.result.Result.unwrap]

-- tests/src/recursive-derive-clone.rs
open recursive_derive_clone in
#guard (do let s ← sample; let c ← copy s; same c s).reducesTo true
open recursive_derive_clone in
#guard (do let s ← sample; same s (.Collection (alloc.vec.Vec.new Label))).reducesTo false
open recursive_derive_clone in
/-- `Collection [Fixed 1]`: a prefix of `sample` -/
def shorter : Result Label := do
  let v ← (alloc.vec.Vec.new Label).push (.Fixed 1#usize)
  .ok (.Collection v)
open recursive_derive_clone in
#guard (do let s ← sample; let t ← shorter; order s t).reducesTo .gt
open recursive_derive_clone in
#guard (do let s ← sample; let t ← shorter; order t s).reducesTo .lt
open recursive_derive_clone in
#guard (do let s ← sample; order s s).reducesTo .eq

-- tests/src/string-ops.rs
open string_ops in
#guard (copy "é").reducesTo "é"
open string_ops in
#guard (same "ab" "ab").reducesTo true
open string_ops in
#guard (same "ab" "abc").reducesTo false
open string_ops in
#guard (order "" "a").reducesTo .lt
open string_ops in
#guard (order "ab" "a").reducesTo .gt
open string_ops in
#guard (order "z" "é").reducesTo .lt
open string_ops in
#guard (order "\uFF61" "𐀀").reducesTo .lt
open string_ops in
#guard (order "é" "é").reducesTo .eq
open string_ops in
#guard (partial_order "b" "a").reducesTo (some .gt)
open string_ops in
#guard (do let c ← copy_tag (.Custom "x"); same_tag c (.Custom "x")).reducesTo true
open string_ops in
#guard (same_tag (.Custom "x") (.Custom "y")).reducesTo false
open string_ops in
#guard (order_tag (.Fixed 9#usize) (.Custom "x")).reducesTo .lt
open string_ops in
#guard (order_tag (.Custom "é") (.Custom "x")).reducesTo .gt
open string_ops in
#guard (partial_order_tag (.Custom "x") (.Custom "xa")).reducesTo (some .lt)

-- tests/src/std-small-ops.rs
/-- `r` panics, with error `e` -/
def failsWith {R : Type} (r : Result R) (e : Error) : Bool :=
  match r.match with
  | .vis (.fail e') _ => e' == e
  | _ => false

section
open std_small_ops
#guard (option_order none (some 0#u32)).reducesTo .lt
#guard (option_order (some 2#u32) (some 1#u32)).reducesTo .gt
#guard (option_order none none).reducesTo .eq
#guard (option_partial_order (some 1#u32) (some 2#u32)).reducesTo (some .lt)
#guard (option_same (some 3#u32) (some 3#u32)).reducesTo true
#guard (option_same (some 3#u32) none).reducesTo false
#guard (or_default none).reducesTo 0#u32
#guard (or_default (some 5#u32)).reducesTo 5#u32
#guard (pair_same (1#u32, 2#u64) (1#u32, 2#u64)).reducesTo true
#guard (pair_same (1#u32, 2#u64) (1#u32, 3#u64)).reducesTo false
#guard (ref_order 1#u32 2#u32).reducesTo .lt
#guard (abs (-7)#i32).reducesTo 7#i32
#guard failsWith (abs (-2147483648)#i32) .integerOverflow
#guard (unsigned_abs (-9223372036854775808)#i64).reducesTo 9223372036854775808#u64
#guard (div_ceil 7#usize 2#usize).reducesTo 4#usize
#guard (div_ceil 8#usize 2#usize).reducesTo 4#usize
#guard (div_ceil 0#usize 3#usize).reducesTo 0#usize
#guard failsWith (div_ceil 1#usize 0#usize) .divisionByZero
#guard (next_power_of_two 0#usize).reducesTo 1#usize
#guard (next_power_of_two 5#usize).reducesTo 8#usize
#guard (next_power_of_two 8#usize).reducesTo 8#usize
#guard failsWith (next_power_of_two core.num.Usize.MAX) .integerOverflow
#guard (do let (x, v) ← swap_remove row[10#u32, 20#u32, 30#u32, 40#u32] 1#usize; .ok (x, v.val))
  |>.reducesTo (20#u32, [10#u32, 40#u32, 30#u32])
#guard (do let (x, v) ← swap_remove row[10#u32, 40#u32, 30#u32] 2#usize; .ok (x, v.val))
  |>.reducesTo (30#u32, [10#u32, 40#u32])
#guard failsWith (swap_remove row[1#u32] 1#usize) .panic
#guard (copied (some 4#u32)).reducesTo (some 4#u32)
#guard (copied none).reducesTo none
#guard (split_first (Slice.from [4#u32, 5#u32, 6#u32] (by scalar_tac))).reducesTo (some (4#u32, 2#usize))
#guard (split_first (Slice.from [] (by scalar_tac))).reducesTo none
#guard (from_ref 9#u32).reducesTo 1#usize
#guard (borrowed 11#u32).reducesTo 11#u32
end

-- tests/src/ref-ops.rs
section
open ref_ops
#guard (add_refs 200#u8 55#u8).reducesTo 255#u8
#guard failsWith (add_refs 200#u8 56#u8) .integerOverflow
#guard (sub_val_ref (-5)#i64 7#i64).reducesTo (-12)#i64
#guard failsWith (sub_val_ref core.num.I64.MIN 1#i64) .integerOverflow
#guard (mul_ref_val 6#u32 7#u32).reducesTo 42#u32
#guard (div_ref_val (-7)#i32 2#i32).reducesTo (-3)#i32
#guard failsWith (div_ref_val 1#i32 0#i32) .divisionByZero
#guard failsWith (div_ref_val core.num.I32.MIN (-1)#i32) .integerOverflow
#guard (rem_val_ref 17#usize 5#usize).reducesTo 2#usize
#guard failsWith (rem_val_ref 1#usize 0#usize) .divisionByZero
#guard (xor_refs 12#u64 10#u64).reducesTo 6#u64
#guard (and_ref_val 12#u16 10#u16).reducesTo 8#u16
#guard (or_val_ref (-128)#i8 1#i8).reducesTo (-127)#i8
end

-- tests/src/iter-adapters-std.rs
/-- A literal `u32` slice -/
macro "u32s[" xs:term,* "]" : term => `((Slice.from [$xs,*] (by scalar_tac) : Slice Std.U32))
/-- A literal `usize` slice -/
macro "usizes[" xs:term,* "]" : term => `((Slice.from [$xs,*] (by scalar_tac) : Slice Std.Usize))

section
open iter_adapters_std
#guard (sum_doubled u32s[1#u32, 2#u32, 3#u32]).reducesTo 12#u32
#guard (count_even u32s[1#u32, 2#u32, 4#u32, 5#u32]).reducesTo 2#usize
#guard (any_big u32s[1#u32, 11#u32]).reducesTo true
#guard (any_big u32s[1#u32, 2#u32]).reducesTo false
#guard (halves u32s[2#u32, 3#u32, 8#u32]).reducesTo 5#u32
#guard (chained u32s[1#u32, 2#u32] u32s[3#u32]).reducesTo 3#usize
#guard (chained_sum u32s[1#u32, 2#u32] u32s[3#u32]).reducesTo 6#u32
#guard (flat u32s[1#u32, 3#u32]).reducesTo 1234#u32
#guard (once_then_empty 7#u32).reducesTo 1#usize
#guard (largest usizes[3#usize, 9#usize, 2#usize]).reducesTo (some 9#usize)
#guard (largest usizes[]).reducesTo none
#guard (largest_by usizes[3#usize, 9#usize, 9#usize, 2#usize]).reducesTo (some 9#usize)
#guard (total usizes[1#usize, 2#usize, 3#usize]).reducesTo 6#usize
#guard (hint u32s[1#u32, 2#u32, 3#u32]).reducesTo (3#usize, some 3#usize)
#guard (filter_hint u32s[1#u32, 2#u32, 3#u32]).reducesTo (0#usize, some 3#usize)
#guard (chain_hint u32s[1#u32, 2#u32] u32s[3#u32]).reducesTo (3#usize, some 3#usize)
end

end Differential
