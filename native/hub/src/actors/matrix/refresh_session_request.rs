use async_trait::async_trait;
use messages::prelude::{Context, Notifiable};
use rinf::debug_print;

use crate::{actors::matrix::Matrix, signals::MatrixRefreshSessionRequest};

#[async_trait]
impl Notifiable<MatrixRefreshSessionRequest> for Matrix {
    async fn notify(&mut self, _msg: MatrixRefreshSessionRequest, _: &Context<Self>) {
        let Some(client) = self.client.as_mut() else {
            debug_print!("MatrixRefreshSessionRequest: client is not initialized");
            return;
        };

        let path = self.session_path();

        // let fresh_session =
        // self.session
    }
}
