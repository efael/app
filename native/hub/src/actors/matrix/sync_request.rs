use std::{sync::Arc, time::Duration};

use async_trait::async_trait;
use matrix_sdk::{config::SyncSettings, ruma::api::client::filter::FilterDefinition};
use messages::prelude::{Context, Notifiable};
use rinf::debug_print;
use tokio::sync::Mutex;

use crate::{actors::matrix::Matrix, signals::MatrixSyncRequest};

#[async_trait]
impl Notifiable<MatrixSyncRequest> for Matrix {
    async fn notify(&mut self, msg: MatrixSyncRequest, _: &Context<Self>) {
        let client = match self.client.as_ref() {
            Some(client) => client,
            None => {
                return;
            }
        };

        if client.auth_api().is_none() {
            return;
        }

        // Enable room members lazy-loading, it will speed up the initial sync a lot
        // with accounts in lots of rooms.
        // See <https://spec.matrix.org/v1.6/client-server-api/#lazy-loading-room-members>.
        let filter = FilterDefinition::with_lazy_loading();

        let mut sync_settings = SyncSettings::default()
            .filter(filter.into())
            .timeout(Duration::from_secs(1));
        let sync_token = Arc::new(Mutex::new(msg.sync_token));

        // We restore the sync where we left.
        // This is not necessary when not using `sync_once`. The other sync methods get
        // the sync token from the store.
        if let Some(sync_token) = sync_token.lock().await.as_ref() {
            sync_settings = sync_settings.token(sync_token);
        }

        // debug_print!("MatrixSyncRequest: sync started");

        // Let's ignore messages before the program was launched.
        // This is a loop in case the initial sync is longer than our timeout. The
        // server should cache the response and it will ultimately take less time to
        // receive.
        match client.sync_once(sync_settings.clone()).await {
            Ok(response) => {
                // debug_print!("MatrixSyncRequest: sync finished");
                sync_token.lock().await.replace(response.next_batch);
            }
            Err(error) => {
                debug_print!("MatrixSyncRequest: an error occurred during sync: {error}");
            }
        }

        let sync_token = sync_token.lock().await.as_ref().map(|t| t.clone());
        if sync_token.is_some() {
            let _ = self.save_session(sync_token.clone()).await;
        }

        tokio::time::sleep(Duration::from_millis(100)).await;

        self.emit_sync_request(sync_token);
    }
}
