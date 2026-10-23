//@ [!lean] skip
//@ aeneas-args=-join-early-exits
//! Joining after an `if` whose branches `break` or `return`. Without the join the code after
//! the `if` is translated once per branch, so a chain of `n` such `if`s is `2^n` copies of its
//! tail; `atoi_radix10::parse` has about seventy and exhausts memory. The join is sound here
//! because only the branches that fall through are joined; the exits keep their own code.

/// A chain of `if`s that may `return` early: three independent choices, so the tail (`res`)
/// would appear eight times without the join.
pub fn early_return_chain(s: &[u8], a: bool, b: bool, c: bool) -> u32 {
    let mut res = 0;
    if a {
        if s.is_empty() {
            return 100;
        }
        res += 1;
    }
    if b {
        if s.len() == 1 {
            return 200;
        }
        res += 2;
    }
    if c {
        if s.len() == 2 {
            return 300;
        }
        res += 4;
    }
    res
}

/// The same shape inside a one-shot `for`, breaking out of it: the Rust idiom for a block
/// one can leave early (as `atoi_radix10::parse` does).
pub fn break_chain(s: &[u8], a: bool, b: bool, c: bool) -> u32 {
    let mut res = 0;
    for _ in 0..1 {
        if a {
            res += 1;
            if s.is_empty() {
                break;
            }
        }
        if b {
            res += 2;
            if s.len() == 1 {
                break;
            }
        }
        if c {
            res += 4;
            if s.len() == 2 {
                break;
            }
        }
        res += 8;
    }
    res
}

/// The branches reborrow the slice before the join: the joined context must agree on `s`.
pub fn shrink(mut s: &[u8], a: bool, b: bool) -> usize {
    let mut res = 0;
    for _ in 0..1 {
        if a {
            s = &s[1..];
            if s.is_empty() {
                res = 1;
                break;
            }
            res += s.len();
        }
        if b {
            s = &s[2..];
            if s.is_empty() {
                res = 2;
                break;
            }
            res += s.len();
        }
        res += 10 * s.len();
    }
    res
}

/// A `?`-shaped exit: the `Err` arm returns, the `Ok` arm falls through, so there is nothing
/// to join and the output must be unchanged.
pub fn question_mark(x: Result<u32, u8>, y: Result<u32, u8>) -> Result<u32, u8> {
    let a = x?;
    let b = y?;
    Ok(a + b)
}
