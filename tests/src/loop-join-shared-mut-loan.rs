//@ [!lean] skip
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
