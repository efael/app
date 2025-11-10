use matrix_sdk::Client;
use matrix_sdk_ui::sync_service::SyncService;
use messages::prelude::Address;
use ruma::events::{
    key::verification::{
        request::ToDeviceKeyVerificationRequestEvent, start::ToDeviceKeyVerificationStartEvent,
    },
    room::message::OriginalSyncRoomMessageEvent,
};
use tokio::task::AbortHandle;

use crate::{
    actors::matrix::Matrix,
    extensions::emitter::Emitter,
    matrix::{room_list::RoomList, sas_verification},
    signals::dart::MatrixSessionVerificationRequest,
};

#[derive(Debug, Default)]
pub struct Sync {
    pub should_sync: bool,
    pub room_list: RoomList,
    pub sync_listener: Option<AbortHandle>,
}

impl Sync {
    #[tracing::instrument(skip(self))]
    pub async fn start(&mut self, mut address: Address<Matrix>, client: Client) {
        tracing::trace!("sync start started");
        if !self.should_sync {
            tracing::error!("called start sync without setting should_sync flag");
            return;
        }

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

        client.add_event_handler(
            |event: ToDeviceKeyVerificationRequestEvent, client: Client| async move {
                sas_verification::to_device_key_verification_request_handler(event, client).await
            },
        );

        let t_address = address.clone();
        client.add_event_handler(
            |event: ToDeviceKeyVerificationStartEvent, client: Client| async move {
                sas_verification::to_device_key_verification_start_handler(
                    event,
                    client,
                    t_address.clone(),
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

        address.emit(MatrixSessionVerificationRequest::Start);

        let room_list_service = sync_service.room_list_service();

        let rooms_list = room_list_service
            .all_rooms()
            .await
            .expect("failed to fetch room-list");

        self.room_list.listen_to_updates(rooms_list);

        let listener = tokio::spawn(async move {
            loop {
                if let Some(_state) = sync_service.state().next().await {
                    // tracing::trace!("[sync] new state {state:?}");
                }

                // if let Ok(loading_state) = loading_state.as_mut()
                //     && let Some(state) = loading_state.next().await
                // {
                //     tracing::info!("new room state {state:?}");
                // }
            }
        });

        self.sync_listener = Some(listener.abort_handle());
        tracing::trace!("sync start finished");
    }

    pub async fn stop(&mut self) {
        tracing::trace!("sync stop started");
        if let Some(listener) = self.sync_listener.take() {
            listener.abort();
        }

        self.room_list.cleanup().await;
        tracing::trace!("sync stop finished");
    }
}
