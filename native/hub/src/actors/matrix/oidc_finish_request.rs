use async_trait::async_trait;
use matrix_sdk::reqwest::Url;
use messages::prelude::{Context, Notifiable};
use rinf::{RustSignal, debug_print};

use crate::{
    actors::matrix::Matrix,
    matrix::session::Session,
    signals::{
        MatrixOidcAuthFinishRequest, MatrixOidcAuthFinishResponse, MatrixSyncOnceRequest,
    },
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

        debug_print!("# before login = session: {:?}", client.session());

        match client.oauth().finish_login(url.into()).await {
            Ok(_) => {
                debug_print!("MatrixOidcAuthFinishRequest: logged in");

                let oauth_session = client
                    .oauth()
                    .full_session()
                    .expect("after login, should have session");

                let session = Session::from_oauth(oauth_session, self.session_path());
                session
                    .save_to_disk()
                    .expect("failed to save session to disk");

                self.session = Some(session);

                self.emit(MatrixSyncOnceRequest { sync_token: None });
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
