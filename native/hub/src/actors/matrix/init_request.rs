use std::path::PathBuf;

use async_trait::async_trait;
use messages::prelude::{Context, Notifiable};
use rinf::{RustSignal, debug_print};

use crate::{
    actors::matrix::Matrix,
    signals::{MatrixInitRequest, MatrixInitResponse},
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

        self.application_support_directory = Some(application_support_directory);

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

        let response = MatrixInitResponse::Ok {
            homeserver_login_details,
            is_active: client.is_active(),
            is_logged_in: client.is_authorized(),
        };

        debug_print!("MatrixInitRequest: client was successfully initialized: {response:?}");
        response.send_signal_to_dart();
    }
}
