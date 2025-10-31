use async_trait::async_trait;
use messages::prelude::{Context, Notifiable};
use rinf::RustSignal;

use crate::{
    actors::matrix::Matrix,
    signals::dart::{MatrixLogoutRequest, MatrixLogoutResponse},
};

#[async_trait]
impl Notifiable<MatrixLogoutRequest> for Matrix {
    #[tracing::instrument(skip(self))]
    async fn notify(&mut self, _msg: MatrixLogoutRequest, _: &Context<Self>) {
        let Some(client) = self.client.as_mut() else {
            tracing::error!("client is not initialized");
            MatrixLogoutResponse::Err {
                message: "Client is not initialized".to_string(),
            }
            .send_signal_to_dart();
            return;
        };

        self.sync.stop().await;
        self.sync.should_sync = false;

        let homeserver_url = client.homeserver();

        if (self.clean_storage().await).is_err() {
            tracing::error!("failed to clean storage");
            MatrixLogoutResponse::Err {
                message: "Failed to clean storage".to_string(),
            }
            .send_signal_to_dart();
            return;
        };

        if let Err(err) = self.init_client(homeserver_url.to_string()).await {
            tracing::error!(error = %err, "failed to initialize client");
            MatrixLogoutResponse::Err {
                message: "Failed to initialize client".to_string(),
            }
            .send_signal_to_dart();
            return;
        };

        MatrixLogoutResponse::Ok {}.send_signal_to_dart();
    }
}
