//@ [!lean] skip
// A higher-ranked trait bound whose implied bounds relate a locally-bound
// (higher-ranked) lifetime to a free lifetime through a *shared* borrow: in
// `&'a &'b u8` the lifetime `'a` of the outer borrow must be shorter than `'b`,
// i.e. `'b: 'a`. A shared borrow gives nothing back, so the constraint relates
// nothing Aeneas tracks and is accepted (`Iterator::find`'s predicate,
// `for<'a> FnMut(&'a &'b T)`, has this shape). Through a mutable borrow it is
// still rejected: see higher_ranked_implied_bounds_mut_borrow.

trait RefTrait<X> {
    fn get(&self) -> X;
}

fn borrow_outlive<'b, P>(_p: &'b P)
where
    P: for<'a> RefTrait<&'a &'b u8>,
{
}
