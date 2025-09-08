use async_trait::async_trait;
use messages::prelude::{Context, Notifiable};
use rinf::debug_print;

use crate::{actors::matrix::Matrix, signals::MatrixProcessSyncResponseRequest};

#[async_trait]
impl Notifiable<MatrixProcessSyncResponseRequest> for Matrix {
    async fn notify(&mut self, msg: MatrixProcessSyncResponseRequest, _: &Context<Self>) {
        let client = match self.client.as_mut() {
            Some(client) => client,
            None => {
                debug_print!("MatrixProcessSyncResponseRequest: client is not initialized");
                return;
            }
        };

        // match msg {
        //     MatrixProcessSyncResponseRequest::Response(response) => {
        //         // let _ = client.process_sync(response).await;
        //     }
        // }
    }
}
