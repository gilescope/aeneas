//@ [!lean] skip
//! Enum constructors used as closures: each gets its own `Fn*` impls, named after the
//! constructor (they used to share one name, and the generated code clashed).
pub enum Label {
    Advice(usize),
    Fixed(usize),
}

pub fn first_labels(n: usize) -> (Option<Label>, Option<Label>) {
    (
        (0..n).map(Label::Advice).next(),
        (0..n).map(Label::Fixed).next(),
    )
}
