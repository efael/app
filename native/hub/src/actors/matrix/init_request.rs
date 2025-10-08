use async_trait::async_trait;
use messages::prelude::{Context, Handler};
use rinf::{RustSignal, debug_print};
use std::path::PathBuf;

use crate::{
    actors::matrix::Matrix,
    signals::{MatrixInitRequest, MatrixInitResponse},
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

        // if let Some(session) = retreive_session_file(application_support_directory) {
        //     let session = session.unwrap();

        //     match restore_session(client, session).await {
        //         Ok(_) => {
        //             MatrixInitResponse::Ok {
        //                 is_active: client.is_active(),
        //                 is_logged_in: true,
        //             }
        //             .send_signal_to_dart();

        //             self.emit(MatrixSyncServiceRequest::Loop);
        //             return;
        //         }
        //         Err(err) => {
        //             debug_print!("[init] error: {err:?}");
        //         }
        //     }
        // }

        let response = MatrixInitResponse::Ok {
            is_active: client.is_active(),
            is_logged_in: false,
        };

        debug_print!("MatrixInitRequest: client was successfully initialized: {response:?}");
        response
    }
}

// async fn restore_session(client: &Client, session: Session) -> Result<(), ClientError> {
//     debug_print!("[init] session trying to restore: {}", &session.user_id);
//     debug_print!("  - access_token: {}", &session.access_token);
//     debug_print!("  - refresh_token: {:?}", &session.refresh_token);
//     debug_print!("  - user_id: {}", &session.user_id);
//     debug_print!("  - device_id: {}", &session.device_id);
//     debug_print!("  - homeserver_url: {}", &session.homeserver_url);
//     debug_print!("  - oidc_data: {:?}", &session.oidc_data);
//     debug_print!(
//         "  - sliding_sync_version: {:?}",
//         &session.sliding_sync_version
//     );

//     client.restore_session(session).await.unwrap();

//     client
//         .refresh_access_token()
//         .await
//         .map_err(|error| ClientError::Generic {
//             msg: error.to_string(),
//             details: None,
//         })?;

//     if client.is_server_accepts_session().await {
//         debug_print!("MatrixInitRequest: session was restored successfully");
//         return Ok(());
//     }

//     // session = client.session().unwrap();
//     client.logout().await.unwrap();
//     Err(ClientError::Generic {
//         msg: String::from("cannot restore session"),
//         details: None,
//     })
// }

// fn retreive_session_file(mut dir: PathBuf) -> Option<Result<Session, ClientError>> {
//     dir.push("./session.json");
//     if !dir.exists() {
//         return None;
//     }

//     match fs::read_to_string(&dir).map(|file| serde_json::from_str::<Session>(&file)) {
//         Ok(Ok(session)) => {
//             debug_print!("# Session found: {:?}", session.user_id);
//             Some(Ok(session))
//         }
//         Ok(Err(err)) => Some(Err(ClientError::Generic {
//             msg: "Failed to parse a file".to_string(),
//             details: Some(err.to_string()),
//         })),
//         Err(err) => Some(Err(ClientError::Generic {
//             msg: format!("Failed to save into {dir:?}"),
//             details: Some(err.to_string()),
//         })),
//     }
// }

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
