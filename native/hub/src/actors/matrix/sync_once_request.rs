use async_trait::async_trait;
use messages::prelude::{Context, Notifiable};
use rinf::debug_print;

use crate::{
    actors::matrix::Matrix,
    matrix::sync,
    signals::{MatrixSessionVerificationRequest, MatrixSyncCompleted, MatrixSyncOnceRequest},
};

#[async_trait]
impl Notifiable<MatrixSyncOnceRequest> for Matrix {
    async fn notify(&mut self, msg: MatrixSyncOnceRequest, _: &Context<Self>) {
        let client = match self.client.as_mut() {
            Some(client) => client,
            None => {
                debug_print!("MatrixSyncServiceRequest: client is not initialized");
                return;
            }
        };

        debug_print!("[sync-once] starting");
        let settings = sync::build_sync_settings(msg.sync_token);

        for attempt in 0..10 {
            match client.sync_once(settings.clone()).await {
                Ok(response) => {
                    debug_print!("[sync-once] next batch - {}", response.next_batch);

                    self.emit(MatrixSyncCompleted {
                        next_batch: response.next_batch,
                    });

                    break;
                }
                Err(error) => {
                    debug_print!(
                        "[sync-once] An error occurred during initial sync, attempt {attempt}: {error}"
                    );
                }
            }
        }

        self.emit(MatrixSessionVerificationRequest::Start);
    }
}
