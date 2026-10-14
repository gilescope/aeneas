//@ [!lean] skip
//@ [lean] subdir=ClosureMutCaptureCall
//@ [lean] aeneas-args=-split-files
//! A closure capturing a `&mut`, called through its `FnMut` instance - the PLONK verifier's
//! `|i| CS::read_commitment(transcript, ..)`. `call_mut` gives back the closure's own region
//! with an identity backward function, which the instance applies at once
//! (`ClosureMutCaptureCall/Properties.lean` checks both reads land).
//! Being `FnMut` too, the closure's `call_once` cannot give back its capture: it fails.

pub struct Counter {
    pub n: u32,
}

impl Counter {
    pub fn read(&mut self) -> u32 {
        self.n = self.n.wrapping_add(1);
        self.n
    }
}

pub fn reads(c: &mut Counter) -> Vec<u32> {
    (0..2u32).map(|i| c.read().wrapping_add(i)).collect()
}
