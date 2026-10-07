//@ [!borrow-check] skip
//! A value with two independent borrow regions (`Zip<IterMut<'a>, IterMut<'b>>`) moved into an
//! opaque call (`Iterator::for_each`): the call's two region abstractions end one after the
//! other, and ending the second used to project borrows nothing could match.

pub fn zip_for_each(left: &mut [u64], right: &mut [u64]) {
    left.iter_mut().zip(right.iter_mut()).for_each(|(a, b)| *a = a.wrapping_add(*b));
}

/// The FFT butterfly loop's shape.
pub fn butterflies(left: &mut [u64], right: &mut [u64], twiddles: &[u64], chunk: usize) {
    left.iter_mut().zip(right.iter_mut()).enumerate().for_each(|(i, (a, b))| {
        let t = b.wrapping_mul(twiddles[(i + 1) * chunk]);
        *b = a.wrapping_sub(t);
        *a = a.wrapping_add(t);
    });
}

/// The same loop as `zip_for_each`, which always worked.
pub fn zip_for(left: &mut [u64], right: &mut [u64]) {
    for (a, b) in left.iter_mut().zip(right.iter_mut()) {
        *a = a.wrapping_add(*b);
    }
}
