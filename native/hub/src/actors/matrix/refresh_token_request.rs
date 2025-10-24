use async_trait::async_trait;
use messages::prelude::{Context, Notifiable};

use crate::{actors::matrix::Matrix, signals::MatrixRefreshTokenRequest};

#[async_trait]
impl Notifiable<MatrixRefreshTokenRequest> for Matrix {
    #[tracing::instrument(skip(self))]
    async fn notify(&mut self, _msg: MatrixRefreshTokenRequest, _: &Context<Self>) {
        let Some(_client) = self.client.as_mut() else {
            tracing::error!("client is not initialized");
            return;
        };

        // match client.refresh_access_token().await {
        //     Ok(_) => {
        //         debug_print!("MatrixRefreshTokenRequest: token refreshed");
        //     }
        //     Err(err) => {
        //         debug_print!("MatrixRefreshTokenRequest: {err:?}");
        //         self.emit_logout_request();
        //         return;
        //     }
        // };

        // let client = client.clone();
        // let session = self.get_session().await;
        // let sync_token = session.and_then(
        //     |FullSession {
        //          user_session: _,
        //          sync_token,
        //      }| sync_token,
        // );
        //
        // let _ = self.save_session(sync_token.clone()).await;

        // self.emit_sync_request(MatrixSyncRequest::Init { client, sync_token });
    }
}
