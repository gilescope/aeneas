//@ [!lean] skip
#![feature(register_tool)]
#![register_tool(verify)]
//! Regression test: a loop whose entry state holds a slice with a shared loan (an index read)
//! on one path and a mutable loan (an indexed write) on the other. Joining them was
//! "Unimplemented"; it now ends the shared loan and retries. From midnight-zk's MSM
//! `invert_all` (forward `split_at_mut` loop, then a backward loop).
pub trait Fld: Copy + for<'a> core::ops::MulAssign<&'a Self> {
    fn zero() -> Self;
    fn mul_into(out: &mut Self, a: &Self, b: &Self);
}

/// no let-else
pub fn no_letelse<T: Fld>(values: &mut [T], scratch: &mut [T], inv0: T) {
    scratch[0] = values[0];
    for j in 1..values.len() {
        let (done, rest) = scratch.split_at_mut(j);
        T::mul_into(&mut rest[0], &done[j - 1], &values[j]);
    }
    let mut inv = inv0;
    let mut inv_j = T::zero();
    for j in (1..values.len()).rev() {
        T::mul_into(&mut inv_j, &inv, &scratch[j - 1]);
        inv *= &values[j];
        values[j] = inv_j;
    }
    values[0] = inv;
}

fn prefix<T: Fld>(values: &[T], scratch: &mut [T]) {
    scratch[0] = values[0];
    for j in 1..values.len() {
        let (done, rest) = scratch.split_at_mut(j);
        T::mul_into(&mut rest[0], &done[j - 1], &values[j]);
    }
}

/// forward loop in a helper
pub fn helper<T: Fld>(values: &mut [T], scratch: &mut [T], inv0: T) {
    let Some(last) = values.len().checked_sub(1) else {
        return;
    };
    prefix(values, scratch);
    let _ = last;
    let mut inv = inv0;
    let mut inv_j = T::zero();
    for j in (1..values.len()).rev() {
        T::mul_into(&mut inv_j, &inv, &scratch[j - 1]);
        inv *= &values[j];
        values[j] = inv_j;
    }
    values[0] = inv;
}

/// `u64` with wrapping arithmetic, enough to run the loops
#[derive(Clone, Copy)]
pub struct W(pub u64);

impl core::ops::MulAssign<&W> for W {
    fn mul_assign(&mut self, b: &W) {
        self.0 = self.0.wrapping_mul(b.0);
    }
}

impl Fld for W {
    fn zero() -> Self {
        W(0)
    }
    fn mul_into(out: &mut Self, a: &Self, b: &Self) {
        out.0 = a.0.wrapping_mul(b.0);
    }
}

/// Prefix products on the way out, then the backward pass: with `inv0 = 1`, `values[j]`
/// becomes `v_0···v_{j-1}` times the product of the later values, as in Montgomery's trick
#[verify::test]
pub fn test_no_letelse() {
    let mut v = [W(2), W(3), W(5)];
    let mut s = [W(0); 3];
    no_letelse(&mut v, &mut s, W(1));
    // prefix: 2, 6, 30; backward from inv = 1: v2 = 1·6 = 6, inv = 5; v1 = 5·2 = 10, inv = 15;
    // v0 = 15
    assert!(s[0].0 == 2 && s[1].0 == 6 && s[2].0 == 30);
    assert!(v[0].0 == 15 && v[1].0 == 10 && v[2].0 == 6);
}
