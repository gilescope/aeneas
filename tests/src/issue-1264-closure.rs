//@ [!lean] skip
//! A function mutually recursive with a closure's `FnOnce` impl (aeneas#1264): the function,
//! the impl and its `call_once` form one mixed declaration group.

fn call(f: impl FnOnce()) {
    f()
}

pub fn f(b: bool) {
    if b {
        call(|| f(false));
    }
}
