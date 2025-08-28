//! This module contains actors.
//! To build a solid app, avoid communicating by sharing memory.
//! Focus on message passing instead.

mod matrix;

use messages::prelude::Context;
use tokio::spawn;

use crate::actors::matrix::Matrix;

// Uncomment below to target the web.
// use tokio_with_wasm::alias as tokio;

pub async fn create_actors() {
    let matrix_context = Context::new();
    let matrix_addr = matrix_context.address();

    let matrix_actor = Matrix::new(matrix_addr);
    spawn(matrix_context.run(matrix_actor));
}
