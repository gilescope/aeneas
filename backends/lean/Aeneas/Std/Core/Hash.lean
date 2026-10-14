module
public import Aeneas.Std.Core.Core
public import Aeneas.Std.Slice
public section

namespace Aeneas.Std

@[rust_trait "core::hash::Hasher"]
structure core.hash.Hasher (Self : Type) where
  finish : Self → Result U64
  write : Self → Slice U8 → Result Self

@[rust_trait "core::hash::Hash"]
structure core.hash.Hash (Self : Type) where
  hash : forall {H : Type}, core.hash.Hasher H → Self → H → Result H

@[rust_trait "core::hash::BuildHasher" (parentClauses := ["HasherInst"])]
structure core.hash.BuildHasher (Self : Type) (Self_Hasher : Type) where
  HasherInst : core.hash.Hasher Self_Hasher
  build_hasher : Self → Result Self_Hasher

end Aeneas.Std
