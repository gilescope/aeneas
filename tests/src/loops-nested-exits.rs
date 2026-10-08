//@ [!lean] skip
//! Exits out of nested loops: a `?` two loops deep (the PLONK verifier's transcript parsing), a
//! `return` three deep, and labelled `break`/`continue` to an outer loop. The
//! `lift_nested_loop_exits` prepass lifts them with flags, one loop level at a time.
//! Index loops only: with `for` loops over iterators, the borrows their `next` leaves alive
//! cannot yet be joined across a lifted exit.

fn check(x: u32) -> Result<u32, u32> {
    if x == 0 {
        Err(7)
    } else {
        Ok(x)
    }
}

/// `?` in an inner loop (index loops: with `for` loops over iterators, the borrows of the
/// iterators' `next` cannot be joined across the lifted exit yet).
pub fn sum_checked(xss: &[Vec<u32>]) -> Result<u32, u32> {
    let mut s = 0u32;
    let mut i = 0;
    while i < xss.len() {
        let mut j = 0;
        while j < xss[i].len() {
            s = s.wrapping_add(check(xss[i][j])?);
            j += 1;
        }
        i += 1;
    }
    Ok(s)
}

/// `return` three loops deep.
pub fn find3(n: u32) -> u32 {
    let mut i = 0;
    while i < n {
        let mut j = 0;
        while j < n {
            let mut k = 0;
            while k < n {
                if i + j + k == 4 && i < j && j < k {
                    return 100 * i + 10 * j + k;
                }
                k += 1;
            }
            j += 1;
        }
        i += 1;
    }
    0
}

/// `continue 'outer`: skip the rest of a row at its first zero.
pub fn prefix_sums(xss: &[Vec<u32>]) -> u32 {
    let mut s = 0u32;
    let mut i = 0;
    'outer: while i < xss.len() {
        let row = &xss[i];
        i += 1;
        let mut j = 0;
        while j < row.len() {
            if row[j] == 0 {
                continue 'outer;
            }
            s = s.wrapping_add(row[j]);
            j += 1;
        }
        s = s.wrapping_add(1000);
    }
    s
}

/// `break 'outer`: stop everything at the first zero.
pub fn until_zero(xss: &[Vec<u32>]) -> u32 {
    let mut s = 0u32;
    let mut i = 0;
    'outer: while i < xss.len() {
        let mut j = 0;
        while j < xss[i].len() {
            if xss[i][j] == 0 {
                break 'outer;
            }
            s = s.wrapping_add(xss[i][j]);
            j += 1;
        }
        i += 1;
    }
    s
}

// Concrete results, checked against the extracted Lean in tests/lean/Differential.lean.
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn values() {
        assert_eq!(sum_checked(&[vec![1, 2], vec![3]]), Ok(6));
        assert_eq!(sum_checked(&[vec![1, 2], vec![0, 3]]), Err(7));
        assert_eq!(find3(5), 13);
        assert_eq!(find3(2), 0);
        assert_eq!(prefix_sums(&[vec![1, 0, 5], vec![2, 3]]), 1006);
        assert_eq!(until_zero(&[vec![1, 2], vec![3, 0, 9], vec![4]]), 6);
    }
}
