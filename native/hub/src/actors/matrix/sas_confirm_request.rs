use async_trait::async_trait;
use messages::prelude::{Context, Notifiable};

use crate::{actors::matrix::Matrix, signals::dart::MatrixSASConfirmRequest};

#[async_trait]
impl Notifiable<MatrixSASConfirmRequest> for Matrix {
    #[tracing::instrument(skip(self))]
    async fn notify(&mut self, request: MatrixSASConfirmRequest, _: &Context<Self>) {
        let Some(client) = self.client.as_mut() else {
            tracing::error!("client is not initialized");
            return;
        };

        let session = match self.session.as_ref() {
            Some(session) => session,
            None => {
                tracing::error!("client does have session");
                return;
            }
        };

        tracing::trace!("Emojis: {:?}", request.emojis);

        let verification_request = client
            .encryption()
            .get_verification(&session.user_session.meta.user_id, &request.flow_id)
            .await
            .expect("not found verification request");

        // Confirming without showing to user, temp implementation
        // Need to first send signal to dart to show emojis, receive
        // matched / not matched requests back
        verification_request
            .sas()
            .expect("not found SAS verification")
            .confirm()
            .await
            .expect("failed to confirm request");

        tracing::trace!("confirmed");
    }
}
