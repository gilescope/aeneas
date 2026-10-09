//@ [!lean] skip
//! Integer operators with reference operands (`&a + b`, `a % &b`, `&a ^ &b`, ...), which core
//! forwards to the by-value operators. Overflow and division by zero panic.

pub fn add_refs(a: &u8, b: &u8) -> u8 {
    a + b
}

pub fn sub_val_ref(a: i64, b: &i64) -> i64 {
    a - b
}

pub fn mul_ref_val(a: &u32, b: u32) -> u32 {
    a * b
}

pub fn div_ref_val(a: &i32, b: i32) -> i32 {
    a / b
}

pub fn rem_val_ref(a: usize, b: &usize) -> usize {
    a % b
}

pub fn xor_refs(a: &u64, b: &u64) -> u64 {
    a ^ b
}

pub fn and_ref_val(a: &u16, b: u16) -> u16 {
    a & b
}

pub fn or_val_ref(a: i8, b: &i8) -> i8 {
    a | b
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::panic::catch_unwind;

    #[test]
    fn values() {
        assert_eq!(add_refs(&200, &55), 255);
        assert!(catch_unwind(|| add_refs(&200, &56)).is_err());
        assert_eq!(sub_val_ref(-5, &7), -12);
        assert!(catch_unwind(|| sub_val_ref(i64::MIN, &1)).is_err());
        assert_eq!(mul_ref_val(&6, 7), 42);
        assert_eq!(div_ref_val(&-7, 2), -3);
        assert!(catch_unwind(|| div_ref_val(&1, 0)).is_err());
        assert!(catch_unwind(|| div_ref_val(&i32::MIN, -1)).is_err());
        assert_eq!(rem_val_ref(17, &5), 2);
        assert!(catch_unwind(|| rem_val_ref(1, &0)).is_err());
        assert_eq!(xor_refs(&0b1100, &0b1010), 0b0110);
        assert_eq!(and_ref_val(&0b1100, 0b1010), 0b1000);
        assert_eq!(or_val_ref(-128, &1), -127);
    }
}
