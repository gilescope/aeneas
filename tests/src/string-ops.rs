//@ [!lean] skip
//! `String`'s `Clone`, `PartialEq`, `PartialOrd` and `Ord`, directly and through derives (the
//! PLONK verifier's `PolynomialLabel::Custom(String)`). `str` orders by its UTF-8 bytes; the
//! values below include non-ASCII and astral characters, so a model ordering by anything else
//! (UTF-16 units, say) disagrees with Rust somewhere.
use std::cmp::Ordering;

pub fn copy(s: &String) -> String {
    s.clone()
}

pub fn same(a: &String, b: &String) -> bool {
    a == b
}

pub fn order(a: &String, b: &String) -> Ordering {
    a.cmp(b)
}

pub fn partial_order(a: &String, b: &String) -> Option<Ordering> {
    a.partial_cmp(b)
}

#[derive(Clone, PartialEq, Eq, PartialOrd, Ord)]
pub enum Tag {
    Fixed(usize),
    Custom(String),
}

pub fn copy_tag(l: &Tag) -> Tag {
    l.clone()
}

pub fn same_tag(a: &Tag, b: &Tag) -> bool {
    a == b
}

pub fn order_tag(a: &Tag, b: &Tag) -> Ordering {
    a.cmp(b)
}

pub fn partial_order_tag(a: &Tag, b: &Tag) -> Option<Ordering> {
    a.partial_cmp(b)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn s(x: &str) -> String {
        x.to_string()
    }

    #[test]
    fn values() {
        assert!(copy(&s("é")) == s("é"));
        assert!(same(&s("ab"), &s("ab")));
        assert!(!same(&s("ab"), &s("abc")));
        assert_eq!(order(&s(""), &s("a")), Ordering::Less);
        assert_eq!(order(&s("ab"), &s("a")), Ordering::Greater);
        assert_eq!(order(&s("z"), &s("é")), Ordering::Less);
        // U+FF61 sorts before U+10000 in UTF-8 and code points, after it in UTF-16
        assert_eq!(order(&s("\u{FF61}"), &s("\u{10000}")), Ordering::Less);
        assert_eq!(order(&s("é"), &s("é")), Ordering::Equal);
        assert_eq!(partial_order(&s("b"), &s("a")), Some(Ordering::Greater));

        let custom = Tag::Custom(s("x"));
        assert!(copy_tag(&custom) == custom);
        assert!(!same_tag(&custom, &Tag::Custom(s("y"))));
        assert_eq!(order_tag(&Tag::Fixed(9), &custom), Ordering::Less);
        assert_eq!(order_tag(&Tag::Custom(s("é")), &custom), Ordering::Greater);
        let lt = partial_order_tag(&custom, &Tag::Custom(s("xa")));
        assert_eq!(lt, Some(Ordering::Less));
    }
}
