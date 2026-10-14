//@ [!lean] skip
//@ [lean] known-failure
// A higher-ranked trait bound whose implied bounds relate a locally-bound
// (higher-ranked) lifetime to a free lifetime through a *mutable* borrow: in
// `&'a mut &'b u8`, `'b: 'a`. Aeneas erases regions and cannot model such a
// constraint, so it is rejected (the shared case is accepted: see
// higher_ranked_implied_bounds_borrow).

trait RefTrait<X> {
    fn get(&self) -> X;
}

fn borrow_outlive<'b, P>(_p: &'b P)
where
    P: for<'a> RefTrait<&'a mut &'b u8>,
{
}
