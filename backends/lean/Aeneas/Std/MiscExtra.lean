/- `str`/`String` conversions, hashing and formatting; `bool::then_some`, `PhantomData`, `ilog2` -/
module
public import Aeneas.Std.AllocString
public import Aeneas.Std.String
public import Aeneas.Std.Core.Fmt
public import Aeneas.Std.Core.Hash
public import Aeneas.Std.CoreMisc
public import Aeneas.Std.Scalar.CoreConvertNum
public section

namespace Aeneas.Std

open Result

/-! ## `str` and `String` -/

/-- `String::from(&str)`. A `str` holds valid UTF-8, which `Str` (a byte slice) does not record:
the bytes Rust can produce always decode. -/
@[expose, rust_fun "alloc::string::{core::convert::From<alloc::string::String, &'0 str>}::from"]
def alloc.string.String.Insts.CoreConvertFromShared0Str.from (s : Str) : Result String :=
  match String.fromUTF8? ⟨(s.val.map (·.bv.toNat.toUInt8)).toArray⟩ with
  | some s => ok s
  | none => fail .undef

/-- `ToString` through `Display`: the text is not modelled (the `Display` models write nothing),
so it is an unknown function of the value -/
opaque alloc.string.ToString.text {T : Type} : core.fmt.Display T → T → String

@[expose, rust_fun "alloc::string::{alloc::string::ToString<@T>}::to_string"]
def alloc.string.ToString.Blanket.to_string {T : Type} (DisplayInst : core.fmt.Display T)
    (x : T) : Result String :=
  ok (alloc.string.ToString.text DisplayInst x)

/-- `str::hash` (`String`'s too): `state.write_str(s)`, whose default writes the bytes then
`0xff` -/
@[expose, rust_fun "alloc::string::{core::hash::Hash<alloc::string::String>}::hash"]
def alloc.string.String.Insts.CoreHashHash.hash {H : Type} (HasherInst : core.hash.Hasher H)
    (s : String) (h : H) : Result H := do
  let bytes := s.toByteArray.toList.map (fun b => (UScalar.ofNatCore b.toNat (by
    have := b.toNat_lt; simp [U8.size, UScalarTy.U8_numBits_eq] at *; omega) : U8))
  if hlen : bytes.length + 1 ≤ Usize.max then
    let h ← HasherInst.write h (Slice.from bytes (by omega))
    HasherInst.write h (Slice.from [255#u8] (by simp; scalar_tac))
  else fail .maximumSizeExceeded

/-! ## Formatting: the models write nothing, like the other `fmt` models -/

@[expose, rust_fun "core::fmt::{core::fmt::Debug<str>}::fmt"]
def Str.Insts.CoreFmtDebug.fmt (_ : Str) (fmt : core.fmt.Formatter) :
    Result ((core.result.Result Unit core.fmt.Error) × core.fmt.Formatter) :=
  ok (.Ok (), fmt)

@[expose, rust_fun "core::fmt::{core::fmt::Display<str>}::fmt"]
def Str.Insts.CoreFmtDisplay.fmt (_ : Str) (fmt : core.fmt.Formatter) :
    Result ((core.result.Result Unit core.fmt.Error) × core.fmt.Formatter) :=
  ok (.Ok (), fmt)

@[expose, rust_fun "alloc::string::{core::fmt::Debug<alloc::string::String>}::fmt"]
def alloc.string.String.Insts.CoreFmtDebug.fmt (_ : String) (fmt : core.fmt.Formatter) :
    Result ((core.result.Result Unit core.fmt.Error) × core.fmt.Formatter) :=
  ok (.Ok (), fmt)

@[expose, rust_fun "core::fmt::{core::fmt::Debug<core::marker::PhantomData<@T>>}::fmt"]
def core.marker.PhantomData.Insts.CoreFmtDebug.fmt {T : Type} (_ : core.marker.PhantomData T)
    (fmt : core.fmt.Formatter) :
    Result ((core.result.Result Unit core.fmt.Error) × core.fmt.Formatter) :=
  ok (.Ok (), fmt)

@[expose, rust_fun "core::num::error::{core::fmt::Debug<core::num::error::TryFromIntError>}::fmt"]
def core.num.error.TryFromIntError.Insts.CoreFmtDebug.fmt (_ : core.num.error.TryFromIntError)
    (fmt : core.fmt.Formatter) :
    Result ((core.result.Result Unit core.fmt.Error) × core.fmt.Formatter) :=
  ok (.Ok (), fmt)

/-- `<&T as Display>::fmt`: formats the referent -/
@[expose, rust_fun "core::fmt::{core::fmt::Display<&'0 @T>}::fmt"]
def Shared0T.Insts.CoreFmtDisplay.fmt {T : Type} (DisplayInst : core.fmt.Display T) (x : T)
    (fmt : core.fmt.Formatter) :
    Result ((core.result.Result Unit core.fmt.Error) × core.fmt.Formatter) :=
  DisplayInst.fmt x fmt

/-! ## Misc -/

@[expose, rust_fun "core::bool::{bool}::then_some"]
def core.bool.Bool.then_some {T : Type} (b : Bool) (x : T) : Result (Option T) :=
  ok (if b then some x else none)

@[expose, rust_fun "core::marker::{core::clone::Clone<core::marker::PhantomData<@T>>}::clone"]
def core.marker.PhantomData.Insts.CoreCloneClone.clone {T : Type}
    (p : core.marker.PhantomData T) : Result (core.marker.PhantomData T) :=
  ok p

/-- `usize::ilog2`: the floor of the base-2 logarithm; panics on `0` -/
@[expose, rust_fun "core::num::{usize}::ilog2"]
def core.num.Usize.ilog2 (x : Usize) : Result U32 :=
  if x.val = 0 then fail .panic
  else ok ⟨BitVec.ofNat 32 (Nat.log2 x.val)⟩

end Aeneas.Std
