//@ [!lean] skip
//! String literals are `&'static str`: returning one (here in the error of a `TryFrom`, as the
//! PLONK verifier's `Column<Any>` conversions do) used to give back a borrow of a local, which
//! ends with the frame.

/// A bare literal
pub fn name() -> &'static str {
    "column"
}

#[derive(Clone, Copy)]
pub enum Any {
    Advice,
    Fixed,
}

#[derive(Clone, Copy)]
pub struct Column {
    index: usize,
    column_type: Any,
}

impl Column {
    pub fn column_type(&self) -> &Any {
        &self.column_type
    }
}

/// `TryFrom<Column<Any>> for Column<Advice>`'s shape
pub fn advice_index(any: Column) -> Result<usize, &'static str> {
    match any.column_type() {
        Any::Advice => Ok(any.index),
        _ => Err("Cannot convert into Column<Advice>"),
    }
}

fn first<'a>(a: &'a str, _b: &str) -> &'a str {
    a
}

/// A `'static` call result reborrowed into a callee
pub fn renamed() -> &'static str {
    first(name(), "other")
}

pub fn check(i: usize, b: bool) -> Result<usize, &'static str> {
    let c = Column { index: i, column_type: if b { Any::Advice } else { Any::Fixed } };
    advice_index(c)
}

/// `get_any_query_index`'s shape: `unwrap` instantiates the error's erased region with its own
pub fn advice_or_panic(i: usize) -> usize {
    check(i, true).unwrap()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn values() {
        assert_eq!(check(3, true), Ok(3));
        assert!(check(3, false).is_err());
        assert_eq!(renamed(), "column");
        assert_eq!(advice_or_panic(4), 4);
    }
}
