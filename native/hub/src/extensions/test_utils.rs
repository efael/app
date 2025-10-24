use crate::actors::{Actors, create_actors};

#[allow(dead_code)]
pub async fn init_test() -> Actors {
    println!("creating actors");

    create_actors().await
}
