//@ [!lean] skip
//@ [lean] aeneas-args=-filter-trait-methods
//! A conditional `mem::swap` of two locals, then a loop writing a nested `Vec` while following
//! links in another: midnight-proofs' permutation `Assembly::copy` (`keygen.rs:79-93`).

pub struct Assembly {
    pub columns: Vec<u64>,
    pub mapping: Vec<Vec<(usize, usize)>>,
    pub aux: Vec<Vec<(usize, usize)>>,
    pub sizes: Vec<Vec<usize>>,
}

impl Assembly {
    pub fn merge(&mut self, left_column: u64, left_row: usize, right_column: u64,
        right_row: usize) -> Result<(), ()> {
        let left_column = self.columns.iter().position(|c| c == &left_column).ok_or(())?;
        let right_column = self.columns.iter().position(|c| c == &right_column).ok_or(())?;
        let mut left_cycle = self.aux[left_column][left_row];
        let mut right_cycle = self.aux[right_column][right_row];
        if self.sizes[left_cycle.0][left_cycle.1] < self.sizes[right_cycle.0][right_cycle.1] {
            std::mem::swap(&mut left_cycle, &mut right_cycle);
        }
        let mut i = right_cycle;
        loop {
            self.aux[i.0][i.1] = left_cycle;
            i = self.mapping[i.0][i.1];
            if i == right_cycle {
                break;
            }
        }
        Ok(())
    }
}
