use async_trait::async_trait;
use messages::prelude::{Context, Notifiable};
use rinf::debug_print;

use crate::{actors::matrix::Matrix, signals::{MatrixListChatsRequest, MatrixSessionVerificationRequest, MatrixSyncServiceRequest}};

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

        let first_time = self.sync_service.is_none();
        if first_time {
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

        if first_time {
            self.emit(MatrixSessionVerificationRequest::Start);
        }

        let mut addr = self.self_addr.clone();
        let duration = tokio::time::Duration::from_millis(200);
        self.owned_tasks.spawn(async move {
            tokio::time::sleep(duration).await;
            let _ = addr.notify(MatrixSyncServiceRequest::Loop).await;
        });
    }
}

