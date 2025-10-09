use async_trait::async_trait;
use matrix_sdk::config::SyncSettings;
use messages::prelude::{Context, Notifiable};
use rinf::debug_print;
use ruma::api::client::filter::{FilterDefinition, LazyLoadOptions, RoomEventFilter, RoomFilter};

use crate::{
    actors::matrix::Matrix,
    signals::{MatrixSessionVerificationRequest, MatrixSyncServiceRequest},
};

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

        let session = match self.session.as_mut() {
            Some(session) => session,
            None => {
                debug_print!("MatrixSyncServiceRequest: session does not exist");
                return;
            }
        };

        let sync_token = match msg {
            MatrixSyncServiceRequest::Initial => None,
            MatrixSyncServiceRequest::Latest { sync_token } => Some(sync_token),
        };

        debug_print!("[sync] starting");
        let settings = build_sync_settings(sync_token);

        for attempt in 0..10 {
            match client.sync_once(settings.clone()).await {
                Ok(response) => {
                    debug_print!("[sync] next batch - {}", response.next_batch);

                    session.set_sync_token(response.next_batch);
                    session
                        .save_to_disk()
                        .expect("failed to save session to disk");

                    break;
                }
                Err(error) => {
                    debug_print!(
                        "[sync] An error occurred during initial sync, attempt {attempt}: {error}"
                    );
                }
            }
        }

        let sync_token = session
            .sync_token
            .as_ref()
            .expect("after sync should have sync_token")
            .clone();

        self.emit(MatrixSessionVerificationRequest::Start);

        let mut addr = self.self_addr.clone();
        let duration = tokio::time::Duration::from_millis(500);
        self.owned_tasks.spawn(async move {
            tokio::time::sleep(duration).await;
            let _ = addr
                .notify(MatrixSyncServiceRequest::Latest {
                    sync_token: sync_token,
                })
                .await;
        });
    }
}

fn build_sync_settings(sync_token: Option<String>) -> SyncSettings {
    let mut state_filter = RoomEventFilter::empty();
    state_filter.lazy_load_options = LazyLoadOptions::Enabled {
        include_redundant_members: false,
    };

    let mut room_filter = RoomFilter::empty();
    room_filter.state = state_filter;

    let mut filter = FilterDefinition::empty();
    filter.room = room_filter;

    let mut sync_settings = SyncSettings::default().filter(filter.into());

    if let Some(token) = sync_token {
        sync_settings = sync_settings.token(token);
    }

    sync_settings
}