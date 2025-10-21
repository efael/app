use async_trait::async_trait;
use messages::prelude::{Context, Notifiable};
use rinf::{RustSignal, debug_print};

use crate::{
    actors::matrix::Matrix,
    signals::{MatrixLogoutRequest, MatrixLogoutResponse},
};

#[async_trait]
impl Notifiable<MatrixLogoutRequest> for Matrix {
    async fn notify(&mut self, _msg: MatrixLogoutRequest, _: &Context<Self>) {
        let client = match self.client.as_mut() {
            Some(client) => client,
            None => {
                debug_print!("MatrixLogoutRequest: client is not initialized");
                MatrixLogoutResponse::Err {
                    message: "Client is not initialized".to_string(),
                }
                .send_signal_to_dart();
                return;
            }
        };

        let homeserver_url = client.homeserver();

        if let Err(err) = self.clean_storage().await {
            debug_print!("MatrixLogoutRequest: failed to clean storage{err:?}");
            MatrixLogoutResponse::Err {
                message: "Failed to clean storage".to_string(),
            }
            .send_signal_to_dart();
            return;
        };

        if let Err(err) = self.init_client(homeserver_url.to_string()).await {
            debug_print!("MatrixLogoutRequest: failed to initialize client {err:?}");
            MatrixLogoutResponse::Err {
                message: "Failed to initialize client".to_string(),
            }
            .send_signal_to_dart();
            return;
        };

        MatrixLogoutResponse::Ok {}.send_signal_to_dart();
    }
}
