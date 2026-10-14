//@ [!lean] skip
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
