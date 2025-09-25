use async_trait::async_trait;
use messages::prelude::{Context, Notifiable};
use rinf::debug_print;

use crate::{actors::matrix::Matrix, signals::MatrixSyncServiceRequest};

#[async_trait]
impl Notifiable<MatrixSyncServiceRequest> for Matrix {
    async fn notify(&mut self, _msg: MatrixSyncServiceRequest, _: &Context<Self>) {
        let client = match self.client.as_mut() {
            Some(client) => client,
            None => {
                debug_print!("MatrixSyncServiceRequest: client is not initialized");
                return;
            }
        };

        if self.sync_service.is_none() {
            let service = client
                .sync_service()
                .with_offline_mode()
                .finish()
                .await
                .unwrap();
            self.sync_service = Some(service);
        }

        let sync_service = self.sync_service.as_mut().expect("should exist a value");

        sync_service.start().await;

        // after staring sync-service
        // self.emit(MatrixListChatsRequest { url: "".to_string() }).await;

        let state = sync_service.next_state();
        debug_print!("state: {state:?}");

        let mut addr = self.self_addr.clone();
        let duration = tokio::time::Duration::from_millis(200);
        self.owned_tasks.spawn(async move {
            tokio::time::sleep(duration).await;
            let _ = addr.notify(MatrixSyncServiceRequest::Loop).await;
        });
    }
}

