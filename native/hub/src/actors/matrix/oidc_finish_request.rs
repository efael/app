use async_trait::async_trait;
use matrix_sdk::reqwest::Url;
use messages::prelude::{Context, Notifiable};
use rinf::{RustSignal, debug_print};

use crate::{
    actors::matrix::Matrix,
    signals::{MatrixOidcAuthFinishRequest, MatrixOidcAuthFinishResponse},
};

#[async_trait]
impl Notifiable<MatrixOidcAuthFinishRequest> for Matrix {
    async fn notify(&mut self, msg: MatrixOidcAuthFinishRequest, _: &Context<Self>) {
        let client = match self.client.as_mut() {
            Some(client) => client,
            None => {
                debug_print!("MatrixOidcAuthFinishRequest: client is not initialized");
                MatrixOidcAuthFinishResponse::Err {
                    message: "Client is not initialized".to_string(),
                }
                .send_signal_to_dart();
                return;
            }
        };

        let url = match Url::parse(msg.url.as_ref()) {
            Ok(url) => url,
            Err(err) => {
                debug_print!("MatrixOidcAuthFinishRequest: url parse error: {err:?}");
                MatrixOidcAuthFinishResponse::Err {
                    message: err.to_string(),
                }
                .send_signal_to_dart();
                return;
            }
        };

        match client.login_with_oidc_callback(url.into()).await {
            Ok(_) => {
                debug_print!("MatrixOidcAuthFinishRequest: logged in");
                MatrixOidcAuthFinishResponse::Ok {}.send_signal_to_dart();
            }
            Err(err) => {
                debug_print!("MatrixOidcAuthFinishRequest: failed to finish login: {err:?}");
                MatrixOidcAuthFinishResponse::Err {
                    message: err.to_string(),
                }
                .send_signal_to_dart();
            }
        };
    }
}
