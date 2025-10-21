use std::ops::Deref;

use async_trait::async_trait;
use matrix_sdk::{
    Client, Error, HttpError, LoopCtrl, RumaApiError, encryption::verification::Verification,
    sync::SyncResponse,
};
use messages::prelude::{Context, Notifiable};
use rinf::debug_print;
use ruma::{
    api::error::FromHttpResponseError,
    events::{
        AnySyncEphemeralRoomEvent, AnySyncTimelineEvent,
        key::verification::{
            request::ToDeviceKeyVerificationRequestEvent, start::ToDeviceKeyVerificationStartEvent,
        },
        room::message::{MessageType, OriginalSyncRoomMessageEvent},
    },
};

use crate::{
    actors::matrix::Matrix,
    extensions::easy_listener::EasyListener,
    matrix::{sas_verification, sync},
    signals::{MatrixSyncBackgroundRequest, MatrixSyncCompleted},
};

#[async_trait]
impl Notifiable<MatrixSyncBackgroundRequest> for Matrix {
    async fn notify(&mut self, _msg: MatrixSyncBackgroundRequest, _: &Context<Self>) {
        let client = match self.client.as_ref() {
            Some(client) => client,
            None => {
                debug_print!("[sync] client is not initialized");
                return;
            }
        };

        let notifier = self.get_address();

        // Default handler
        client.add_event_handler(|event: AnySyncTimelineEvent| async move {
            debug_print!("[event] AnySyncTimelineEvent: {event:?}");
        });

        client.add_event_handler(|event: AnySyncEphemeralRoomEvent| async move {
            debug_print!("[event] AnySyncEphemeralRoomEvent: {event:?}");
        });

        // Verification handler
        client.add_event_handler(|event: ToDeviceKeyVerificationRequestEvent, client: Client| async move {
            debug_print!("[event] ToDeviceKeyVerificationRequestEvent: received request: {event:?}");
            let request = match client
                .encryption()
                .get_verification_request(&event.sender, &event.content.transaction_id)
                .await
            {
                Some(req) => req,
                None => {
                    debug_print!("[event] ToDeviceKeyVerificationRequestEvent: could not create request");
                    return;
                }
            };

            debug_print!("[event] ToDeviceKeyVerificationRequestEvent: accepting request");
            request
                .accept()
                .await
                .expect("[event] ToDeviceKeyVerificationRequestEvent:  can't accept verification request");
        });

        client.add_event_handler(
            |event: ToDeviceKeyVerificationStartEvent, client: Client| async move {
                debug_print!(
                    "[event] ToDeviceKeyVerificationStartEvent: received request: {event:?}"
                );
                if let Some(Verification::SasV1(sas)) = client
                    .encryption()
                    .get_verification(&event.sender, event.content.transaction_id.as_str())
                    .await
                {
                    debug_print!("[event] ToDeviceKeyVerificationStartEvent: received SAS");
                    sas_verification::handler(
                        sas,
                        event.content.transaction_id.to_string(),
                        notifier,
                    );
                };
            },
        );

        client.add_event_handler(
            |event: OriginalSyncRoomMessageEvent, client: Client| async move {
                debug_print!("[event] OriginalSyncRoomMessageEvent: received request: {event:?}");
                if let MessageType::VerificationRequest(_) = &event.content.msgtype {
                    let request = match client
                        .encryption()
                        .get_verification_request(&event.sender, &event.event_id)
                        .await
                    {
                        Some(req) => req,
                        None => {
                            debug_print!(
                                "[event] OriginalSyncRoomMessageEvent: could not create request"
                            );
                            return;
                        }
                    };

                    debug_print!("[event] OriginalSyncRoomMessageEvent: accepting request");
                    request.accept().await.expect(
                        "[event] OriginalSyncRoomMessageEvent: can't accept verification request",
                    );
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
                        // this catches 401 unauthorized error
                        if let Error::Http(http_error) = &err
                            && let HttpError::Api(server) = http_error.deref()
                            && let FromHttpResponseError::Server(RumaApiError::ClientApi(
                                ruma_error,
                            )) = server.deref()
                            && ruma_error.status_code.eq(&401)
                        {
                            // do something
                        }

                        debug_print!("[sync] no result: {}", err);
                        return Ok(LoopCtrl::Continue);
                    }
                };

                // debug_print!("[sync] iteration completed - {}", &response.next_batch);
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
