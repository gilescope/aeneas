//@ [!lean] skip
//! `core::array::from_fn` with a closure reading its environment, and one doing arithmetic.
pub fn limbs(bytes: &[u8; 32]) -> [u64; 4] {
    core::array::from_fn(|i| u64::from_le_bytes(bytes[8 * i..8 * i + 8].try_into().unwrap()))
}

pub fn squares() -> [u32; 5] {
    core::array::from_fn(|i| (i * i) as u32)
}
