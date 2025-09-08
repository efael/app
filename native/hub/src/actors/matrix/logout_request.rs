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
        match client.logout().await {
            Ok(_) => {
                debug_print!("MatrixLogoutRequest: logged out");
                MatrixLogoutResponse::Ok {}.send_signal_to_dart();
            }
            Err(err) => {
                debug_print!("MatrixLogoutRequest: {err:?}");
                MatrixLogoutResponse::Err {
                    message: err.to_string(),
                }
                .send_signal_to_dart();
            }
        };
    }
}
