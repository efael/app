use async_trait::async_trait;
use messages::prelude::{Context, Handler};
use rinf::debug_print;
use std::path::PathBuf;

use crate::{
    actors::matrix::Matrix,
    signals::{MatrixInitRequest, MatrixInitResponse},
};

#[async_trait]
impl Handler<MatrixInitRequest> for Matrix {
    type Result = MatrixInitResponse;

    async fn handle(&mut self, msg: MatrixInitRequest, _context: &Context<Self>) -> Self::Result {
        if self.client.is_some() {
            debug_print!("[init] client is already initialized");
            return MatrixInitResponse::Err {
                message: "Client is already initialized".to_string(),
            };
        }

        let application_support_directory = PathBuf::from(&msg.application_support_directory);
        self.application_support_directory = Some(application_support_directory.clone());

        if let Err(err) = self.init_client(msg.homeserver_url).await {
            debug_print!("[init] failed to initialize client: {err:?}");
            return MatrixInitResponse::Err {
                message: err.to_string(),
            };
        }

        let client = self
            .client
            .as_ref()
            .expect("[init] client should exist already");

        MatrixInitResponse::Ok {
            is_active: client.is_active(),
            is_logged_in: client.oauth().user_session().is_some(),
        }
    }
}

#[cfg(test)]
mod tests {
    use crate::{
        extensions::test_utils,
        signals::{MatrixInitRequest, MatrixInitResponse},
    };

    #[tokio::test]
    async fn test() {
        let mut actors = test_utils::init_test().await;

        let mut cwd = std::env::current_dir().expect("Should be able to get current dir");
        cwd.push("./test_polygon");

        tokio::fs::create_dir_all(&cwd)
            .await
            .expect("Should create test folder");

        println!("Application support directory is: {cwd:?}");

        let res: MatrixInitResponse = actors
            .matrix
            .send(MatrixInitRequest {
                application_support_directory: cwd.to_str().unwrap().to_string(),
                homeserver_url: "https://efael.uz".to_string(),
            })
            .await
            .expect("could not send");

        println!("res: {res:?}");
        // assert!(false);
    }
}
