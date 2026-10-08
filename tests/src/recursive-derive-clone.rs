//@ [!lean] skip
//! A derived `Clone` on a type which contains itself through a `Vec`, as the PLONK verifier's
//! `PolynomialLabel::Collection(Vec<PolynomialLabel>)`: `clone` passes its own impl to
//! `Vec::clone`, so the method and the impl are mutually recursive. Charon ignores a method's
//! references to its own impl (`reorder_decls`): the recursion was hidden, the impl defined
//! after its use, or (when every caller calls the method directly) never translated.
//! (A derived `Debug` recurses through a `dyn Debug` given to the opaque formatter: no
//! monotonicity proof is possible there, and it is not supported.)

#[derive(Clone, PartialEq, Eq, Ord)]
pub enum Label {
    Fixed(usize),
    Custom(u32),
    Collection(Vec<Label>),
    NoLabel,
}

impl PartialOrd for Label {
    fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
        Some(self.cmp(other))
    }
}

/// Calls the method directly, the only reference to the impl being `clone`'s own
pub fn copy(l: &Label) -> Label {
    l.clone()
}

/// Compares through `Vec`'s `eq`, given `eq`'s own impl
pub fn same(a: &Label, b: &Label) -> bool {
    a == b
}

/// Orders through `Vec`'s `cmp`, given `cmp`'s own impl
pub fn order(a: &Label, b: &Label) -> std::cmp::Ordering {
    a.cmp(b)
}

pub fn sample() -> Label {
    Label::Collection(vec![Label::Fixed(1), Label::Collection(vec![Label::NoLabel])])
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn values() {
        assert!(copy(&sample()) == sample());
        assert!(sample() != Label::Collection(vec![Label::Fixed(1)]));
        let shorter = Label::Collection(vec![Label::Fixed(1)]);
        assert_eq!(order(&sample(), &shorter), std::cmp::Ordering::Greater);
        assert_eq!(order(&shorter, &sample()), std::cmp::Ordering::Less);
        assert_eq!(order(&sample(), &sample()), std::cmp::Ordering::Equal);
    }
}
