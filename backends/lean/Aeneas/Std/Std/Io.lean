module
public import Aeneas.Std.Core.Fmt
public section

namespace Aeneas.Std

@[expose, rust_fun "std::io::stdio::_print"]
def std.io.stdio._print (_ : core.fmt.Arguments) : Result Unit := .ok ()

/-- `#[must_use]`'s marker function: the identity -/
@[expose, rust_fun "core::hint::must_use"]
def core.hint.must_use {T : Type} (x : T) : Result T := .ok x

/-- `format!`: the text is not modelled (`Arguments` carries none), so it is an unknown string -/
opaque alloc.fmt.formatted : String

@[expose, rust_fun "alloc::fmt::format"]
def alloc.fmt.format (_ : core.fmt.Arguments) : Result String := .ok alloc.fmt.formatted

/-- `io::Error`: errors are only built and propagated, never inspected, so an error is an
unknown value of the function that built it -/
@[rust_type "core::io::error::Error" (body := .opaque)]
structure core.io.error.Error where
  id : Nat

opaque core.io.error.Error.ofNew {K E : Type} : K → E → Nat
opaque core.io.error.Error.ofOther {E : Type} : E → Nat

/-- `io::Error::new(kind, error)`; its bound `E: Into<Box<dyn Error + Send + Sync>>` is dropped
(Aeneas has no `dyn` types) -/
@[expose, rust_fun "alloc::io::error::{core::io::error::Error}::new"]
def alloc.io.error.Error.new {K E : Type} (kind : K) (error : E) : Result core.io.error.Error :=
  .ok ⟨core.io.error.Error.ofNew kind error⟩

/-- `io::Error::other(error)`, likewise -/
@[expose, rust_fun "alloc::io::error::{core::io::error::Error}::other"]
def alloc.io.error.Error.other {E : Type} (error : E) : Result core.io.error.Error :=
  .ok ⟨core.io.error.Error.ofOther error⟩

end Aeneas.Std
