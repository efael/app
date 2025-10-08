use async_trait::async_trait;
use matrix_sdk::authentication::oauth::OAuthAuthorizationData;
use messages::prelude::{Context, Notifiable};
use rinf::{RustSignal, debug_print};

use crate::{
    actors::matrix::Matrix,
    signals::{MatrixOidcAuthRequest, MatrixOidcAuthResponse},
};

#[async_trait]
impl Notifiable<MatrixOidcAuthRequest> for Matrix {
    async fn notify(&mut self, msg: MatrixOidcAuthRequest, _: &Context<Self>) {
        let mut client = match self.client.as_mut() {
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

        match msg.oidc_configuration.url(&mut client).await {
            Ok(OAuthAuthorizationData { url, state: _ }) => {
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
