use async_trait::async_trait;
use matrix_sdk::reqwest::Url;
use messages::prelude::{Context, Notifiable};
use rinf::RustSignal;

use crate::{
    actors::matrix::Matrix,
    extensions::{easy_listener::EasyListener, emitter::Emitter},
    matrix::session::Session,
    signals::{
        dart::{MatrixOidcAuthFinishRequest, MatrixOidcAuthFinishResponse},
        internal::InternalSyncBackgroundRequest,
    },
};

#[async_trait]
impl Notifiable<MatrixOidcAuthFinishRequest> for Matrix {
    #[tracing::instrument(skip(self))]
    async fn notify(&mut self, msg: MatrixOidcAuthFinishRequest, _: &Context<Self>) {
        let Some(client) = self.client.as_mut() else {
            tracing::error!("client is not initialized");
            return;
        };

        let url = match Url::parse(msg.url.as_ref()) {
            Ok(url) => url,
            Err(err) => {
                tracing::error!(error = %err, "url parse error");
                MatrixOidcAuthFinishResponse::Err {
                    message: err.to_string(),
                }
                .send_signal_to_dart();
                return;
            }
        };

        tracing::trace!("before login = session: {:?}", client.session());

        match client.oauth().finish_login(url.into()).await {
            Ok(_) => {
                tracing::trace!(
                    "logged in as - {}",
                    client.session().unwrap().meta().user_id
                );

                let oauth_session = client
                    .oauth()
                    .full_session()
                    .expect("after login, should have session");

                let session = Session::from_oauth(oauth_session, self.session_path());
                session
                    .save_to_disk()
                    .expect("failed to save session to disk");

                self.session = Some(session);

                self.get_address()
                    .emit(InternalSyncBackgroundRequest::Start);

                MatrixOidcAuthFinishResponse::Ok {}.send_signal_to_dart();
            }
            Err(err) => {
                tracing::error!(error = %err, "failed to finish login");
                MatrixOidcAuthFinishResponse::Err {
                    message: err.to_string(),
                }
                .send_signal_to_dart();
            }
        };
    }
}
