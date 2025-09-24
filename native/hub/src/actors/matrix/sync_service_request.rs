use async_trait::async_trait;
use matrix_sdk_rinf::sync_service::SyncServiceState;
use messages::prelude::{Context, Notifiable};
use rinf::debug_print;

use crate::{actors::matrix::Matrix, signals::{MatrixListChatsRequest, MatrixSyncServiceRequest}};

#[async_trait]
impl Notifiable<MatrixSyncServiceRequest> for Matrix {
    async fn notify(&mut self, msg: MatrixSyncServiceRequest, _: &Context<Self>) {
        let client = match self.client.as_mut() {
            Some(client) => client,
            None => {
                debug_print!("MatrixSyncServiceRequest: client is not initialized");
                return;
            }
        };

        let sync_service = match &self.sync_service {
            None => {
                let service = client
                    .sync_service()
                    .finish()
                    .await
                    .unwrap();

                self.sync_service = Some(service.clone());
                service
            },
            Some(service) => {
                service.clone()
            }
        };

        sync_service
            .start()
            .await;

        debug_print!("sync service started, emitting list-chat req");

        // after staring sync-service
        // self.emit(MatrixListChatsRequest { url: "".to_string() }).await;

        // if let Some(_) = sync_service.next_state().await {
        //     debug_print!("next state switched, anyways starting sync again");
        //     self.emit(MatrixSyncServiceRequest::Start).await;
        // }

        debug_print!("waiting for next-state");
        let duration = tokio::time::Duration::from_secs(15);
        tokio::time::sleep(duration).await;

        match sync_service.next_state() {
            // not implemented
            SyncServiceState::Error => {
                debug_print!("[MatrixSyncServiceRequest] not implemented handling Error sync-service state");
            },

            // not implemented
            SyncServiceState::Offline => {
                debug_print!("[MatrixSyncServiceRequest] not implemented handling Offline sync-service state");
            },

            // call itself again
            SyncServiceState::Idle | 
            SyncServiceState::Terminated |
            SyncServiceState::Running => {
                self.emit(MatrixSyncServiceRequest::Start).await;
            },
        }
    }
}