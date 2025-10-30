use async_trait::async_trait;
use matrix_sdk::authentication::oauth::OAuthAuthorizationData;
use messages::prelude::{Context, Notifiable};
use rinf::RustSignal;

use crate::{
    actors::matrix::Matrix,
    signals::dart::{MatrixOidcAuthRequest, MatrixOidcAuthResponse},
};

#[async_trait]
impl Notifiable<MatrixOidcAuthRequest> for Matrix {
    #[tracing::instrument(skip(self))]
    async fn notify(&mut self, msg: MatrixOidcAuthRequest, _: &Context<Self>) {
        let Some(client) = self.client.as_mut() else {
            tracing::error!("client is not initialized");
            MatrixOidcAuthResponse::Err {
                message: "Client is not initialized".to_string(),
            }
            .send_signal_to_dart();
            return;
        };

        match msg.oidc_configuration.url(client).await {
            Ok(OAuthAuthorizationData { url, state: _ }) => {
                MatrixOidcAuthResponse::Ok {
                    url: url.to_string(),
                }
                .send_signal_to_dart();
            }
            Err(err) => {
                tracing::error!(error = %err, "url build error");
                MatrixOidcAuthResponse::Err {
                    message: err.to_string(),
                }
                .send_signal_to_dart();
            }
        };
    }
}
