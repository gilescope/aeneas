//@ [!lean] skip
//! String literals with non-ASCII characters and escapes (midnight-proofs' `"π"` label).
pub fn pi() -> &'static str {
    "π"
}

pub fn escapes() -> &'static str {
    "tab\there \"quoted\" back\\slash\nnul\0 bell\u{7} é"
}
