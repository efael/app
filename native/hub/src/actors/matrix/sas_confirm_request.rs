use async_trait::async_trait;
use messages::prelude::{Context, Notifiable};
use rinf::debug_print;

use crate::{actors::matrix::Matrix, signals::MatrixSASConfirmRequest};

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

        let session = match self.session.as_ref() {
            Some(session) => session,
            None => {
                debug_print!("MatrixSessionVerificationRequest: client does have session");
                return;
            }
        };

        debug_print!("[sas-confirm] Emojis: {:?}", request.emojis);

        let verification_request = client
            .encryption()
            .get_verification(&session.user_session.meta.user_id, &request.flow_id)
            .await
            .expect("[sas-confirm] not found verification request");

        // Confirming without showing to user, temp implementation
        // Need to first send signal to dart to show emojis, receive
        // matched / not matched requests back
        verification_request
            .sas()
            .expect("[sas-confirm] not found SAS verification")
            .confirm()
            .await
            .expect("[sas-confirm] failed to confirm request");

        debug_print!("[sas-confirm] confirmed");
    }
}
