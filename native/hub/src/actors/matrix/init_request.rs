use async_trait::async_trait;
use matrix_sdk::AuthSession;
use messages::prelude::{Context, Handler};
use rinf::debug_print;
use std::path::PathBuf;

use crate::{
    actors::matrix::Matrix,
    matrix::session::Session,
    signals::{MatrixInitRequest, MatrixInitResponse, MatrixSyncOnceRequest},
};

#[async_trait]
impl Handler<MatrixInitRequest> for Matrix {
    type Result = MatrixInitResponse;

    async fn handle(&mut self, msg: MatrixInitRequest, context: &Context<Self>) -> Self::Result {
        if self.client.is_some() {
            debug_print!("MatrixInitRequest: client is already initialized");
            return MatrixInitResponse::Err {
                message: "Client is already initialized".to_string(),
            };
        }

        let application_support_directory = PathBuf::from(&msg.application_support_directory);
        self.application_support_directory = Some(application_support_directory.clone());

        if let Err(err) = self.init_client(msg.homeserver_url).await {
            debug_print!("MatrixInitRequest: failed to initialize client: {err:?}");
            return MatrixInitResponse::Err {
                message: err.to_string(),
            };
        }

        let client = self
            .client
            .as_ref()
            .expect("MatrixInitClient: client should exist already");

        let session_path = self.session_path();
        let exists_session_file = session_path.exists();
        if !exists_session_file {
            return MatrixInitResponse::Ok {
                is_active: client.is_active(),
                is_logged_in: false,
            };
        }

        let session = match tokio::fs::read_to_string(&session_path)
            .await
            .map(|file| serde_json::from_str::<Session>(&file))
        {
            Ok(Ok(session)) => {
                debug_print!("[init] session found: {:?}", session.user_session.meta.user_id);
                session
            }
            Ok(Err(err)) => {
                debug_print!("[init] failed to parse file: {err:?}");
                return MatrixInitResponse::Ok {
                    is_active: client.is_active(),
                    is_logged_in: false,
                };
            }
            Err(err) => {
                debug_print!("[init] failed to read session file: {err:?}");
                return MatrixInitResponse::Ok {
                    is_active: client.is_active(),
                    is_logged_in: false,
                };
            }
        };

        client
            .restore_session(AuthSession::from(&session))
            .await
            .expect("[init] failed to restore session");
        debug_print!("[init] client was successfully initialized");

        let response = MatrixInitResponse::Ok {
            is_active: client.is_active(),
            is_logged_in: true,
        };

        self.emit(MatrixSyncOnceRequest {
            sync_token: Some(session.sync_token.expect("previous session should have sync_token")),
        });

        response
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
        assert!(false);
    }
}
