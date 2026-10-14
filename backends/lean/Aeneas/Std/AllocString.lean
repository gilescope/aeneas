/- `String`'s comparison and cloning -/
module
public import Aeneas.Std.Alloc
public import Aeneas.Std.Vec
public section

namespace Aeneas.Std

open Result

/-! Rust's `String` is Lean's `String` (see `Alloc`): both hold valid UTF-8, so equal strings are
equal byte sequences. `str` orders by its UTF-8 bytes; the models compare those bytes rather than
Lean's `Char`s so they match Rust by construction (the two orders agree on valid UTF-8, but that
would be a lemma to prove, not a definition to trust). -/

@[expose, rust_fun "alloc::string::{core::clone::Clone<alloc::string::String>}::clone"]
def alloc.string.String.Insts.CoreCloneClone.clone (s : String) : Result String := ok s

@[expose, rust_fun
  "alloc::string::{core::cmp::PartialEq<alloc::string::String, alloc::string::String>}::eq"]
def alloc.string.String.Insts.CoreCmpPartialEqString.eq (a b : String) : Result Bool :=
  ok (a == b)

@[expose, rust_fun "alloc::string::{core::cmp::Ord<alloc::string::String>}::cmp"]
def alloc.string.String.Insts.CoreCmpOrd.cmp (a b : String) : Result Ordering :=
  List.lexCmpM (fun x y : UInt8 => ok (compare x y)) a.toByteArray.toList b.toByteArray.toList

@[expose, rust_fun
  "alloc::string::{core::cmp::PartialOrd<alloc::string::String, alloc::string::String>}::partial_cmp"]
def alloc.string.String.Insts.CoreCmpPartialOrdString.partial_cmp (a b : String) :
    Result (Option Ordering) := do
  ok (some (← alloc.string.String.Insts.CoreCmpOrd.cmp a b))

end Aeneas.Std
