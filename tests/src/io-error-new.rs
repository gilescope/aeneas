//@ [!lean] skip
//! Building an `io::Error` from a kind and a message - the KZG verifier's `read_commitment`
//! rejecting a malformed proof. `Error::new`'s bound `E: Into<Box<dyn Error + Send + Sync>>`
//! names a `dyn` type.
use std::io;

pub fn check(n: usize, expected: usize) -> io::Result<()> {
    if n != expected {
        return Err(io::Error::new(
            io::ErrorKind::InvalidData,
            format!("got {}, expected {}", n, expected),
        ));
    }
    Ok(())
}

pub fn other(n: usize) -> io::Result<usize> {
    if n == 0 {
        return Err(io::Error::other("zero"));
    }
    Ok(n)
}
