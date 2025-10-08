//! This module contains actors.
//! To build a solid app, avoid communicating by sharing memory.
//! Focus on message passing instead.

mod matrix;

use messages::prelude::{Address, Context};
use tokio::spawn;

use crate::actors::matrix::Matrix;

// Uncomment below to target the web.
// use tokio_with_wasm::alias as tokio;

#[allow(dead_code)]
pub struct Actors {
    pub matrix: Address<Matrix>,
}

pub async fn create_actors() -> Actors {
    let matrix_context = Context::new();
    let matrix_addr = matrix_context.address();

    let matrix_actor = Matrix::new(matrix_addr.clone());
    spawn(matrix_context.run(matrix_actor));

    Actors {
        matrix: matrix_addr,
    }
}
