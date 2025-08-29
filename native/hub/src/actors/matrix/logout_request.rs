use async_trait::async_trait;
use messages::prelude::{Context, Notifiable};
use rinf::{RustSignal, debug_print};

use crate::{
    actors::matrix::Matrix,
    signals::{MatrixLogoutRequest, MatrixLogoutResponse, logout_error::LogoutError},
};

#[async_trait]
impl Notifiable<MatrixLogoutRequest> for Matrix {
    async fn notify(&mut self, _msg: MatrixLogoutRequest, _: &Context<Self>) {
        match self.logout().await {
            Ok(_) | Err(LogoutError::ClientNotInitialized) => {
                debug_print!("MatrixLogoutRequest: logged out");
                MatrixLogoutResponse {}.send_signal_to_dart();
            }
            Err(err) => {
                debug_print!("MatrixLogoutRequest: {err:?}");
                MatrixLogoutResponse {}.send_signal_to_dart();
            }
        };
    }
}
