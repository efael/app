//! This module contains actors.
//! To build a solid app, avoid communicating by sharing memory.
//! Focus on message passing instead.

mod matrix;
mod matrix_sync;

use messages::prelude::Context;
use tokio::spawn;

use crate::actors::{matrix::Matrix, matrix_sync::MatrixSync};

// Uncomment below to target the web.
// use tokio_with_wasm::alias as tokio;

pub async fn create_actors() {
    let matrix_context = Context::new();
    let matrix_addr = matrix_context.address();

    let matrix_sync_context = Context::new();
    let matrix_sync_addr = matrix_sync_context.address();

    let matrix_actor = Matrix::new(matrix_addr.clone(), matrix_sync_addr.clone());
    spawn(matrix_context.run(matrix_actor));

    let matrix_sync_actor = MatrixSync::new(matrix_sync_addr, matrix_addr);
    spawn(matrix_sync_context.run(matrix_sync_actor));
}
