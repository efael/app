use async_trait::async_trait;
use messages::prelude::{Context, Handler};
use std::path::PathBuf;

use crate::{
    actors::matrix::Matrix,
    signals::dart::{MatrixInitRequest, MatrixInitResponse},
};

#[async_trait]
impl Handler<MatrixInitRequest> for Matrix {
    type Result = MatrixInitResponse;

    #[tracing::instrument(skip(self))]
    async fn handle(&mut self, msg: MatrixInitRequest, _context: &Context<Self>) -> Self::Result {
        if self.client.is_some() {
            tracing::error!("client is already initialized");
            return MatrixInitResponse::Err {
                message: "Client is already initialized".to_string(),
            };
        }

        let application_support_directory = PathBuf::from(&msg.application_support_directory);
        self.application_support_directory = Some(application_support_directory.clone());

        if let Err(err) = self.init_client(msg.homeserver_url).await {
            tracing::error!(error = %err, "failed to initialize client");
            return MatrixInitResponse::Err {
                message: err.to_string(),
            };
        }

        let client = self.client.as_ref().expect("client should exist already");

        MatrixInitResponse::Ok {
            is_active: client.is_active(),
            is_logged_in: client.oauth().user_session().is_some(),
        }
    }
}
