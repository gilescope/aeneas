//@ [!lean] skip
#![feature(register_tool)]
#![register_tool(verify)]
//! `<[T]>::as_chunks` / `<[T; N]>` reading fixed-size limbs, as the GLV split once did.
pub fn limbs(bytes: &[u8; 32]) -> [u64; 4] {
    let (chunks, _) = bytes.as_chunks::<8>();
    [
        u64::from_le_bytes(chunks[0]),
        u64::from_le_bytes(chunks[1]),
        u64::from_le_bytes(chunks[2]),
        u64::from_le_bytes(chunks[3]),
    ]
}

pub fn tail_len(s: &[u32]) -> usize {
    let (chunks, rest) = s.as_chunks::<3>();
    chunks.len() * 3 + rest.len()
}

/// Two whole chunks of 3 and one element left over
#[verify::test]
pub fn test_chunks_rest() {
    let s: [u32; 7] = [1, 2, 3, 4, 5, 6, 7];
    let (chunks, rest) = s.as_slice().as_chunks::<3>();
    assert!(chunks.len() == 2 && rest.len() == 1);
    assert!(chunks[0][0] == 1 && chunks[0][2] == 3 && chunks[1][0] == 4 && chunks[1][2] == 6);
    assert!(rest[0] == 7);
    assert!(tail_len(&s) == 7);
}

/// Little-endian limbs through `as_chunks`
#[verify::test]
pub fn test_limbs() {
    let mut b = [0u8; 32];
    b[1] = 1;
    b[24] = 5;
    let l = limbs(&b);
    assert!(l[0] == 0x100 && l[1] == 0 && l[2] == 0 && l[3] == 5);
}
