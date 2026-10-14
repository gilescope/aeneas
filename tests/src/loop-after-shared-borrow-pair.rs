//@ [!lean] skip
#![feature(register_tool)]
#![register_tool(verify)]
//! Regression test: a loop after a call returning a pair of shared borrows, one half unused
//! (`as_chunks`, `split_at`). The call's abstraction keeps an ended shared loan for that half,
//! and matching it against the loop's fixed point fell through to "Unreachable": "Could not
//! match the contexts". From midnight-zk's GLV scalar split.

pub fn chunks_then_loop(bytes: [u8; 32], m: &[u64; 3]) -> u64 {
    let (limbs, _) = bytes.as_chunks::<8>();
    let kl: [u64; 4] = core::array::from_fn(|i| u64::from_le_bytes(limbs[i]));
    let mut acc = 0u64;
    for (j, mj) in m.iter().enumerate() {
        acc = acc.wrapping_add(kl[j].wrapping_mul(*mj));
    }
    acc
}

pub fn chunks_only_then_loop(bytes: [u8; 32], m: &[u64; 3]) -> u64 {
    let (limbs, _) = bytes.as_chunks::<8>();
    let k0 = u64::from_le_bytes(limbs[0]);
    let mut acc = k0;
    for (j, mj) in m.iter().enumerate() {
        acc = acc.wrapping_add((j as u64).wrapping_mul(*mj));
    }
    acc
}

pub fn from_fn_then_loop(bytes: [u8; 32], m: &[u64; 3]) -> u64 {
    let kl: [u64; 4] =
        core::array::from_fn(|i| u64::from_le_bytes(bytes[8 * i..8 * i + 8].try_into().unwrap()));
    let mut acc = 0u64;
    for (j, mj) in m.iter().enumerate() {
        acc = acc.wrapping_add(kl[j].wrapping_mul(*mj));
    }
    acc
}

pub fn split_then_loop(bytes: [u8; 32], m: &[u64; 3]) -> u64 {
    let (a, _) = bytes.split_at(8);
    let k0 = u64::from(a[0]);
    let mut acc = k0;
    for (j, mj) in m.iter().enumerate() {
        acc = acc.wrapping_add((j as u64).wrapping_mul(*mj));
    }
    acc
}

pub fn chunks_ref_then_loop(bytes: &[u8; 32], m: &[u64; 3]) -> u64 {
    let (limbs, _) = bytes.as_chunks::<8>();
    let k0 = u64::from_le_bytes(limbs[0]);
    let mut acc = k0;
    for (j, mj) in m.iter().enumerate() {
        acc = acc.wrapping_add((j as u64).wrapping_mul(*mj));
    }
    acc
}

pub fn chunks_no_loop(bytes: [u8; 32]) -> u64 {
    let (limbs, _) = bytes.as_chunks::<8>();
    u64::from_le_bytes(limbs[0])
}

#[verify::test]
pub fn test_loops() {
    let mut b = [0u8; 32];
    b[0] = 2;
    b[8] = 3;
    let m = [5u64, 7, 11];
    assert!(chunks_then_loop(b, &m) == 2 * 5 + 3 * 7);
    assert!(chunks_only_then_loop(b, &m) == 2 + 7 + 22);
    assert!(from_fn_then_loop(b, &m) == 2 * 5 + 3 * 7);
    assert!(split_then_loop(b, &m) == 2 + 7 + 22);
    assert!(chunks_ref_then_loop(&b, &m) == 2 + 7 + 22);
    assert!(chunks_no_loop(b) == 2);
}
