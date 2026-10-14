//@ [!lean] skip
#![feature(register_tool)]
#![register_tool(verify)]
//! `core::array::from_fn` with a closure reading its environment, and one doing arithmetic.
pub fn limbs(bytes: &[u8; 32]) -> [u64; 4] {
    core::array::from_fn(|i| u64::from_le_bytes(bytes[8 * i..8 * i + 8].try_into().unwrap()))
}

pub fn squares() -> [u32; 5] {
    core::array::from_fn(|i| (i * i) as u32)
}

/// `from_fn` calls its closure on 0..N in order
#[verify::test]
pub fn test_squares() {
    let a = squares();
    assert!(a[0] == 0 && a[1] == 1 && a[2] == 4 && a[3] == 9 && a[4] == 16);
}

/// Each limb is its 8 little-endian bytes
#[verify::test]
pub fn test_limbs() {
    let mut b = [0u8; 32];
    b[0] = 1;
    b[8] = 2;
    b[17] = 3;
    b[31] = 0x80;
    let l = limbs(&b);
    assert!(l[0] == 1 && l[1] == 2 && l[2] == 0x300 && l[3] == 0x8000_0000_0000_0000);
}

/// A closure with state: `from_fn` threads it through the calls in order
#[verify::test]
pub fn test_stateful() {
    let mut n = 10u32;
    let a: [u32; 3] = core::array::from_fn(|i| {
        n += i as u32;
        n
    });
    assert!(a[0] == 10 && a[1] == 11 && a[2] == 13 && n == 13);
}
