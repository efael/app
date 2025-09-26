use std::{fs, path::PathBuf};

use async_trait::async_trait;
use matrix_sdk_rinf::{
    client::{Client, Session},
    error::ClientError,
};
use messages::prelude::{Context, Notifiable};
use rinf::{RustSignal, debug_print};

use crate::{
    actors::matrix::Matrix,
    signals::{MatrixInitRequest, MatrixInitResponse, MatrixSyncServiceRequest},
};

#[async_trait]
impl Notifiable<MatrixInitRequest> for Matrix {
    async fn notify(&mut self, msg: MatrixInitRequest, _: &Context<Self>) {
        if self.client.is_some() {
            debug_print!("MatrixInitRequest: client is already initialized");
            MatrixInitResponse::Err {
                message: "Client is already initialized".to_string(),
            }
            .send_signal_to_dart();
            return;
        }

        let application_support_directory = PathBuf::from(&msg.application_support_directory);

        self.application_support_directory = Some(application_support_directory.clone());

        if let Err(err) = self.init_client(msg.homeserver_url).await {
            debug_print!("MatrixInitRequest: failed to initialize client: {err:?}");
            MatrixInitResponse::Err {
                message: err.to_string(),
            }
            .send_signal_to_dart();
            return;
        }

        
        let client = self
            .client
            .as_ref()
            .expect("MatrixInitClient: client should exist already");

        let homeserver_login_details = client.homeserver_login_details().await;

        if let Some(session) = retreive_session_file(application_support_directory) {
            let session = session.unwrap();

            match restore_session(client, session).await {
                Ok(_) => {
                    MatrixInitResponse::Ok {
                        homeserver_login_details,
                        is_active: client.is_active(),
                        is_logged_in: true,
                    }
                    .send_signal_to_dart();

                    self.emit(MatrixSyncServiceRequest::Loop);
                    return;
                }
                Err(err) => {
                    debug_print!("[init] error: {err:?}");
                }
            }
        }

        let response = MatrixInitResponse::Ok {
            homeserver_login_details,
            is_active: client.is_active(),
            is_logged_in: false,
        };

        debug_print!("MatrixInitRequest: client was successfully initialized: {response:?}");
        response.send_signal_to_dart();
    }
}

async fn restore_session(client: &Client, session: Session) -> Result<(), ClientError> {
    debug_print!("[init] session trying to restore: {}", &session.user_id);
    debug_print!("  - access_token: {}", &session.access_token);
    debug_print!("  - refresh_token: {:?}", &session.refresh_token);
    debug_print!("  - user_id: {}", &session.user_id);
    debug_print!("  - device_id: {}", &session.device_id);
    debug_print!("  - homeserver_url: {}", &session.homeserver_url);
    debug_print!("  - oidc_data: {:?}", &session.oidc_data);
    debug_print!(
        "  - sliding_sync_version: {:?}",
        &session.sliding_sync_version
    );

    client.restore_session(session).await.unwrap();

    client
        .refresh_access_token()
        .await
        .map_err(|error| ClientError::Generic {
            msg: error.to_string(),
            details: None,
        })?;

    if client.is_server_accepts_session().await {
        debug_print!("MatrixInitRequest: session was restored successfully");
        return Ok(());
    }

    // session = client.session().unwrap();
    client.logout().await.unwrap();
    Err(ClientError::Generic {
        msg: String::from("cannot restore session"),
        details: None,
    })
}

fn retreive_session_file(mut dir: PathBuf) -> Option<Result<Session, ClientError>> {
    dir.push("./session.json");
    if !dir.exists() {
        return None;
    }

    match fs::read_to_string(&dir).map(|file| serde_json::from_str::<Session>(&file)) {
        Ok(Ok(session)) => {
            debug_print!("# Session found: {:?}", session.user_id);
            Some(Ok(session))
        }
        Ok(Err(err)) => Some(Err(ClientError::Generic {
            msg: "Failed to parse a file".to_string(),
            details: Some(err.to_string()),
        })),
        Err(err) => Some(Err(ClientError::Generic {
            msg: format!("Failed to save into {dir:?}"),
            details: Some(err.to_string()),
        })),
    }
}
