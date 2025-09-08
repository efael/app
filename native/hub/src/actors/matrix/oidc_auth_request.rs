use async_trait::async_trait;
use matrix_sdk::authentication::oauth::OAuthAuthorizationData;
use matrix_sdk_rinf::client::OidcPrompt;
use messages::prelude::{Context, Notifiable};
use rinf::{RustSignal, debug_print};

use crate::{
    actors::matrix::Matrix,
    signals::{MatrixOidcAuthRequest, MatrixOidcAuthResponse},
};

#[async_trait]
impl Notifiable<MatrixOidcAuthRequest> for Matrix {
    async fn notify(&mut self, msg: MatrixOidcAuthRequest, _: &Context<Self>) {
        let client = match self.client.as_mut() {
            Some(client) => client,
            None => {
                debug_print!("MatrixOidcAuthRequest: client is not initialized");
                MatrixOidcAuthResponse::Err {
                    message: "Client is not initialized".to_string(),
                }
                .send_signal_to_dart();
                return;
            }
        };

        match client
            .url_for_oidc(&msg.oidc_configuration, Some(OidcPrompt::Consent), None)
            .await
        {
            Ok(OAuthAuthorizationData { url, state: _ }) => {
                debug_print!("MatrixOidcAuthRequest: url built: {url:?}");
                MatrixOidcAuthResponse::Ok {
                    url: url.to_string(),
                }
                .send_signal_to_dart();
            }
            Err(err) => {
                debug_print!("MatrixOidcAuthRequest: url build error: {err:?}");
                MatrixOidcAuthResponse::Err {
                    message: err.to_string(),
                }
                .send_signal_to_dart();
            }
        };
    }
}
