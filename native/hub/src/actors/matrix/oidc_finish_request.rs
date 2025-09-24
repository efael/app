use async_trait::async_trait;
use matrix_sdk::reqwest::Url;
use matrix_sdk_rinf::client::Session;
use messages::prelude::{Context, Notifiable};
use rinf::{RustSignal, debug_print};
use std::{fs, path::PathBuf};

use crate::{
    actors::matrix::Matrix,
    signals::{MatrixOidcAuthFinishRequest, MatrixOidcAuthFinishResponse, MatrixSyncServiceRequest},
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

        debug_print!("# before login = session: {:?}", client.session().map(|a| a.user_id));
        debug_print!("# before login = device id: {:?}", client.device_id());

        match client.login_with_oidc_callback(url.into()).await {
            Ok(_) => {
                debug_print!("MatrixOidcAuthFinishRequest: logged in");

                debug_print!("# after session: {:?}", client.session().map(|a| a.user_id));
                debug_print!("# after device id: {:?}", client.device_id());

                // save session into json
                save_session(
                    client.session().unwrap(),
                    self.application_support_directory.clone().unwrap().clone(),
                );

                MatrixOidcAuthFinishResponse::Ok {}.send_signal_to_dart();

                self.emit(MatrixSyncServiceRequest::Start).await;
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

fn save_session(session: Session, mut dir: PathBuf) {
    dir.push(format!("./session.json"));
    debug_print!("# save session file: {:?}", dir);

    serde_json::
        to_string::<Session>(&session)
        .map(|session| fs::write(dir, session))
        .unwrap()
        .unwrap();
}