//@ [!lean] skip
//@ charon-args=--opaque sibling_region_abstractions::It --opaque sibling_region_abstractions::Two --opaque sibling_region_abstractions::it --opaque sibling_region_abstractions::two --opaque sibling_region_abstractions::consume
//! A symbolic value whose type has two independent borrow regions, `Two<It<'a>, It<'b>>` (the
//! shape of `Zip<IterMut<'a, T>, IterMut<'b, T>>`), moved into an opaque call: the call has one
//! region abstraction per region, ended one after the other (aeneas#1192).

pub struct It<'a> {
    x: &'a mut u64,
}

pub struct Two<A, B> {
    a: A,
    b: B,
}

pub fn it<'a>(x: &'a mut u64) -> It<'a> {
    It { x }
}

pub fn two<'a, 'b>(a: It<'a>, b: It<'b>) -> Two<It<'a>, It<'b>> {
    Two { a, b }
}

pub fn consume<'a, 'b>(t: Two<It<'a>, It<'b>>) {
    *t.a.x += *t.b.x;
}

pub fn siblings(x: &mut u64, y: &mut u64) {
    consume(two(it(x), it(y)));
}
