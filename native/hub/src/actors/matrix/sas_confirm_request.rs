use async_trait::async_trait;
use matrix_sdk_rinf::session_verification::SessionVerificationData;
use messages::prelude::{Context, Notifiable};
use rinf::debug_print;

use crate::{
    actors::matrix::Matrix,
    signals::{MatrixListChatsRequest, MatrixSASConfirmRequest},
};

#[async_trait]
impl Notifiable<MatrixSASConfirmRequest> for Matrix {
    async fn notify(&mut self, request: MatrixSASConfirmRequest, _: &Context<Self>) {
        let client = match self.client.as_mut() {
            Some(client) => client,
            None => {
                debug_print!("MatrixSASConfirmRequest: client is not initialized");
                return;
            }
        };

        match &request.data {
            SessionVerificationData::Emojis { emojis, .. } => {
                debug_print!("[verification] Emojis:");
                for e in emojis {
                    debug_print!("{} ({})", e.symbol(), e.description());
                }
            }
            SessionVerificationData::Decimals { values } => {
                debug_print!("[verification] Decimals: {:?}", values);
            }
        }

        self.verification_controller
            .as_mut()
            .expect("verification controller does not exist")
            .accept_verification_request()
            .await
            .expect("failed to accept verification request");

        debug_print!("[verification] completed");
        self.emit(MatrixListChatsRequest {
            url: "".to_string(),
        });
    }
}
