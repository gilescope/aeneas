module
public import Aeneas.Std.Array.Array
public import Aeneas.Std.Slice
@[expose] public section

/-!
# `<[T]>::as_chunks`

`s.as_chunks::<N>()` is `s` cut into `⌊len/N⌋` arrays of `N` consecutive elements, and the
`len mod N` left over (`N = 0` panics).
-/

namespace Aeneas.Std

open Result

/-- Chunk `k` of `l`: its elements `k·n … k·n + n − 1`, for `(k + 1)·n ≤ |l|`. -/
def chunkAt {T : Type} (n : Usize) (l : List T) (k : ℕ) (hk : (k + 1) * n.val ≤ l.length) :
    Array T n :=
  Array.from ((l.drop (k * n.val)).take n.val) (by simp; rw [Nat.add_mul] at hk; omega)

@[rust_fun "core::slice::{[@T]}::as_chunks"]
def core.slice.Slice.as_chunks {T : Type} (N : Usize) (s : Slice T) :
    Result (Slice (Array T N) × Slice T) :=
  if h : 0 < N.val then
    let m := s.length / N.val
    let chunks := (List.finRange m).map fun k =>
      chunkAt N s.val k.val (by
        have hdm := Nat.div_mul_le_self s.length N.val
        have hk := k.isLt
        calc (k.val + 1) * N.val ≤ m * N.val := Nat.mul_le_mul_right _ (by omega)
          _ ≤ s.val.length := hdm)
    ok (Slice.from chunks (by
          have := s.property; simp [chunks, m]
          exact le_trans (Nat.div_le_self _ _) this),
        Slice.from (s.val.drop (m * N.val)) (by have := s.property; simp; omega))
  else fail .panic

/-- **`as_chunks`**: for `N > 0`, `⌊len/N⌋` chunks, chunk `k` being elements `k·N … k·N + N − 1`,
and the elements from `⌊len/N⌋·N` on left over. -/
theorem core.slice.Slice.as_chunks_spec {T : Type} (N : Usize) (s : Slice T) (hN : 0 < N.val) :
    ∃ chunks rest, core.slice.Slice.as_chunks N s = ok (chunks, rest) ∧
      chunks.val.length = s.length / N.val ∧
      (∀ k (hk : k < chunks.val.length),
        chunks.val[k].val = (s.val.drop (k * N.val)).take N.val) ∧
      rest.val = s.val.drop (s.length / N.val * N.val) := by
  simp only [core.slice.Slice.as_chunks, hN, ↓reduceDIte]
  refine ⟨_, _, rfl, ?_, ?_, ?_⟩
  · simp
  · intro k hk
    simp [chunkAt, Array.from_val]
  · simp

end Aeneas.Std
