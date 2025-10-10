use async_trait::async_trait;
use matrix_sdk::{
    Client, Error, LoopCtrl, encryption::verification::Verification, sync::SyncResponse,
};
use messages::prelude::{Context, Notifiable};
use rinf::debug_print;
use ruma::events::{
    AnySyncEphemeralRoomEvent, AnySyncTimelineEvent,
    key::verification::{
        request::ToDeviceKeyVerificationRequestEvent, start::ToDeviceKeyVerificationStartEvent,
    },
    room::message::{MessageType, OriginalSyncRoomMessageEvent},
};

use crate::{
    actors::matrix::Matrix,
    extensions::easy_listener::EasyListener,
    matrix::sync,
    signals::{MatrixSyncBackgroundRequest, MatrixSyncCompleted},
};

#[async_trait]
impl Notifiable<MatrixSyncBackgroundRequest> for Matrix {
    async fn notify(&mut self, msg: MatrixSyncBackgroundRequest, _: &Context<Self>) {
        let client = match self.client.as_mut() {
            Some(client) => client,
            None => {
                debug_print!("[sync] client is not initialized");
                return;
            }
        };

        // Default handler
        client.add_event_handler(|event: AnySyncTimelineEvent| async move {
            debug_print!("[event] AnySyncTimelineEvent: {event:?}");
        });

        client.add_event_handler(|event: AnySyncEphemeralRoomEvent| async move {
            debug_print!("[event] AnySyncEphemeralRoomEvent: {event:?}");
        });

        // Verification handler
        client.add_event_handler(
            |ev: ToDeviceKeyVerificationRequestEvent, client: Client| async move {
                let request = match client
                    .encryption()
                    .get_verification_request(&ev.sender, &ev.content.transaction_id)
                    .await
                {
                    Some(req) => req,
                    None => {
                        debug_print!("could not create request");
                        return;
                    }
                };

                request
                    .accept()
                    .await
                    .expect("Can't accept verification request");
            },
        );

        client.add_event_handler(
            |ev: ToDeviceKeyVerificationStartEvent, client: Client| async move {
                if let Some(Verification::SasV1(sas)) = client
                    .encryption()
                    .get_verification(&ev.sender, ev.content.transaction_id.as_str())
                    .await
                {
                    // tokio::spawn(sas_verification_handler(sas, App::get_sender()));
                };
            },
        );

        client.add_event_handler(
            |ev: OriginalSyncRoomMessageEvent, client: Client| async move {
                if let MessageType::VerificationRequest(_) = &ev.content.msgtype {
                    let request = match client
                        .encryption()
                        .get_verification_request(&ev.sender, &ev.event_id)
                        .await
                    {
                        Some(req) => req,
                        None => {
                            debug_print!("could not create request");
                            return;
                        }
                    };

                    request
                        .accept()
                        .await
                        .expect("Can't accept verification request");
                }
            },
        );

        let settings = sync::build_sync_settings(None);
        let client = client.clone();
        let notifier = self.get_address();

        let after_each_sync = move |sync_result: Result<SyncResponse, Error>| {
            let mut notifier = notifier.clone();
            async move {
                let response = match sync_result {
                    Ok(resp) => resp,
                    Err(err) => {
                        debug_print!("[sync] no result: {}", err);
                        return Ok(LoopCtrl::Continue);
                    }
                };

                notifier
                    .notify(MatrixSyncCompleted {
                        next_batch: response.next_batch,
                    })
                    .await
                    .unwrap();

                Ok(LoopCtrl::Continue)
            }
        };

        debug_print!("[sync] starting");
        tokio::spawn(async move {
            client
                .sync_with_result_callback(settings, after_each_sync)
                .await
                .expect("[sync] failed");
        });
    }
}
