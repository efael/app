use async_trait::async_trait;
use messages::prelude::{Context, Notifiable};
use rinf::debug_print;
use ruma::events::key::verification::VerificationMethod;

use crate::{
    actors::matrix::Matrix,
    signals::{MatrixListChatsRequest, MatrixSessionVerificationRequest},
};

#[async_trait]
impl Notifiable<MatrixSessionVerificationRequest> for Matrix {
    async fn notify(&mut self, _msg: MatrixSessionVerificationRequest, _: &Context<Self>) {
        let client = match self.client.as_mut() {
            Some(client) => client,
            None => {
                debug_print!("MatrixSessionVerificationRequest: client is not initialized");
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

        let encrpyption = client.encryption();

        debug_print!("[verification] waiting for e2ee intialization");
        encrpyption.wait_for_e2ee_initialization_tasks().await;

        match encrpyption
            .get_user_identity(&session.user_session.meta.user_id)
            .await
        {
            Ok(Some(identity)) => {
                if identity.is_verified() {
                    debug_print!("[verification] identity verified ✅");
                    self.emit(MatrixListChatsRequest {
                        url: "".to_string(),
                    });
                    return;
                }

                match identity
                    .request_verification_with_methods(vec![VerificationMethod::SasV1])
                    .await
                {
                    Ok(request) => {
                        debug_print!("[verification] requested, flow {:?}", request.flow_id());
                    }
                    Err(err) => {
                        debug_print!("[verification] could not request verification: {}", err);
                    }
                };
            }
            Ok(None) => debug_print!("[verification] no user identity"),
            Err(err) => debug_print!("[verification] could not get user identity: {}", err),
        };
    }
}
