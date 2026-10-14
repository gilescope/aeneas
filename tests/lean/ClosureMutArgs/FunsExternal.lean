-- [closure_mut_args]: the opaque `each`, modelled by hand
module
public import Aeneas
public import ClosureMutArgs.Types
@[expose] public section
open Aeneas Aeneas.Std Result

namespace closure_mut_args

/-- `f` on each element in turn; `f` gives the element back after its output. -/
def eachList {F O : Type} (call : F → Std.U32 → Result ((O × Std.U32) × F)) :
    List Std.U32 → F → Result (List Std.U32)
  | [], _ => ok []
  | x :: xs, f => do
    let ((_, x'), f') ← call f x
    let rest ← eachList call xs f'
    ok (x' :: rest)

/-- `each(s, f)`, for a closure whose instance gives its `&mut u32` back (`Output × u32`). -/
def each {F O : Type} (inst : core.ops.function.FnMut F Std.U32 (O × Std.U32))
    (s : Slice Std.U32) (f : F) : Result (Slice Std.U32) := do
  let l ← eachList inst.call_mut s.val f
  (if h : l.length ≤ Std.Usize.max then ok (Slice.from l h) else fail .undef)

end closure_mut_args
