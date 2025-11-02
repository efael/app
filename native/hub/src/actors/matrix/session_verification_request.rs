use async_trait::async_trait;
use messages::prelude::{Context, Notifiable};
use ruma::events::key::verification::VerificationMethod;

use crate::{actors::matrix::Matrix, signals::dart::MatrixSessionVerificationRequest};

#[async_trait]
impl Notifiable<MatrixSessionVerificationRequest> for Matrix {
    #[tracing::instrument(skip(self))]
    async fn notify(&mut self, _msg: MatrixSessionVerificationRequest, _: &Context<Self>) {
        let Some(client) = self.client.as_mut() else {
            tracing::error!("client is not initialized");
            return;
        };

        let Some(session) = self.session.as_ref() else {
            tracing::error!("client does not have session");
            return;
        };

        let encrpyption = client.encryption();

        tracing::trace!("waiting for e2ee intialization");
        encrpyption.wait_for_e2ee_initialization_tasks().await;

        match encrpyption
            .get_user_identity(&session.user_session.meta.user_id)
            .await
        {
            Ok(Some(identity)) => {
                if identity.is_verified() {
                    tracing::trace!("identity verified ✅");
                    return;
                }

                match identity
                    .request_verification_with_methods(vec![VerificationMethod::SasV1])
                    .await
                {
                    Ok(request) => {
                        tracing::trace!("requested, flow {:?}", request.flow_id());
                    }
                    Err(err) => {
                        tracing::error!(error = %err, "could not request verification");
                    }
                };
            }
            Ok(None) => tracing::trace!("no user identity"),
            Err(err) => tracing::error!(error = %err, "could not get user identity"),
        };
    }
}
