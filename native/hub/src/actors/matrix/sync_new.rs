use async_trait::async_trait;
use matrix_sdk::Client;
use matrix_sdk_ui::sync_service::SyncService;
use messages::prelude::{Context, Notifiable};
use ruma::events::{
    key::verification::{
        request::ToDeviceKeyVerificationRequestEvent, start::ToDeviceKeyVerificationStartEvent,
    },
    room::message::OriginalSyncRoomMessageEvent,
};

use crate::{
    actors::matrix::Matrix, extensions::easy_listener::EasyListener, matrix::sas_verification,
    signals::{MatrixListChatsRequest, MatrixSessionVerificationRequest, MatrixSyncBackgroundRequest},
};

#[async_trait]
impl Notifiable<MatrixSyncBackgroundRequest> for Matrix {
    #[tracing::instrument(skip(self))]
    async fn notify(&mut self, _msg: MatrixSyncBackgroundRequest, _: &Context<Self>) {
        let Some(client) = self.client.as_ref() else {
            tracing::error!("client is not initialized");
            return;
        };

        let sync_service = match SyncService::builder(client.clone())
            .with_offline_mode()
            .build()
            .await
        {
            Ok(ss) => ss,
            Err(err) => {
                tracing::error!(error = %err,"encountered error while initializing sync service");
                return;
            }
        };

        let address = self.get_address();

        client.add_event_handler(
            |event: ToDeviceKeyVerificationRequestEvent, client: Client| async move {
                sas_verification::to_device_key_verification_request_handler(event, client).await
            },
        );

        client.add_event_handler(
            |event: ToDeviceKeyVerificationStartEvent, client: Client| async move {
                sas_verification::to_device_key_verification_start_handler(
                    event,
                    client,
                    address.clone(),
                )
                .await
            },
        );

        client.add_event_handler(
            |event: OriginalSyncRoomMessageEvent, client: Client| async move {
                sas_verification::original_sync_message_room_handler(event, client).await
            },
        );

        sync_service.start().await;
        tracing::info!("started sync-service");

        self.emit(MatrixSessionVerificationRequest::Start);

        self.emit(MatrixListChatsRequest {
            url: "".to_string(),
        });

        self.owned_tasks.spawn(async move {
            let rls = sync_service.room_list_service();
            let rooms = rls.all_rooms().await;

            let mut loading_state = rooms.map(|r| r.loading_state());

            loop {
                if let Some(_state) = sync_service.state().next().await {
                    // tracing::trace!("[sync] new state {state:?}");
                }

                if let Ok(loading_state) = loading_state.as_mut()
                    && let Some(state) = loading_state.next().await
                {
                    tracing::info!("new room state {state:?}");
                }
            }
        });
    }
}
