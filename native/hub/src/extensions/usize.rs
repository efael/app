pub struct Usize(usize);

impl From<usize> for Usize {
    fn from(value: usize) -> Self {
        Self(value)
    }
}

impl From<Usize> for u64 {
    fn from(value: Usize) -> Self {
        value.0.try_into().expect("should convert to u64")
    }
}
