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
        if let Err(err) = self.logout().await {
            debug_print!("MatrixOidcAuthRequest: failed to logout: {err:?}");
            MatrixOidcAuthResponse::Err {
                message: err.to_string(),
            }
            .send_signal_to_dart();
            return;
        }

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

        let registration_data = match msg.oidc_configuration.registration_data() {
            Ok(registration_data) => registration_data,
            Err(err) => {
                debug_print!("MatrixOidcAuthRequest: registration_data error: {err:?}");
                MatrixOidcAuthResponse::Err {
                    message: err.to_string(),
                }
                .send_signal_to_dart();
                return;
            }
        };
        let redirect_uri = match msg.oidc_configuration.redirect_uri() {
            Ok(redirect_uri) => redirect_uri,
            Err(err) => {
                debug_print!("MatrixOidcAuthRequest: redirect_uri error: {err:?}");
                MatrixOidcAuthResponse::Err {
                    message: err.to_string(),
                }
                .send_signal_to_dart();
                return;
            }
        };

        // let device_id = device_id.map(OwnedDeviceId::from);
        let device_id = None;

        let url_builder = client
            .oauth()
            .login(redirect_uri, device_id, Some(registration_data));

        // if let Some(prompt) = prompt {
        //     url_builder = url_builder.prompt(vec![prompt.into()]);
        // }
        // if let Some(login_hint) = login_hint {
        //     url_builder = url_builder.login_hint(login_hint);
        // }

        match url_builder.build().await {
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
