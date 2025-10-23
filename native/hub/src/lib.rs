//! This `hub` crate is the
//! entry point of the Rust logic.

mod actors;
mod extensions;
mod matrix;
mod signals;

use actors::create_actors;
use rinf::{dart_shutdown, write_interface};
use tokio::spawn;
use tracing_subscriber::FmtSubscriber;

use crate::extensions::rinf_writer::RinfWriter;

// Uncomment below to target the web.
// use tokio_with_wasm::alias as tokio;

write_interface!();

// You can go with any async library, not just `tokio`.
#[tokio::main(flavor = "current_thread")]
#[tracing::instrument]
async fn main() {
    let subscriber = FmtSubscriber::builder()
        // https://docs.rs/tracing-subscriber/latest/tracing_subscriber/filter/struct.EnvFilter.html
        .with_env_filter("error,hub=trace")
        .with_writer(RinfWriter)
        .compact()
        .finish();

    tracing::subscriber::set_global_default(subscriber).expect("setting default subscriber failed");

    std::panic::set_hook(Box::new(tracing_panic::panic_hook));

    // Spawn concurrent tasks.
    // Always use non-blocking async functions like `tokio::fs::File::open`.
    // If you must use blocking code, use `tokio::task::spawn_blocking`
    // or the equivalent provided by your async library.
    spawn(create_actors());

    // Keep the main function running until Dart shutdown.
    dart_shutdown().await;
}
