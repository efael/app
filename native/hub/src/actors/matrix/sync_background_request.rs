use async_trait::async_trait;
use matrix_sdk::{Error as SdkError, sync::SyncResponse, LoopCtrl};
use messages::prelude::{Context, Notifiable};
use rinf::debug_print;

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

        let session = match self.session.as_mut() {
            Some(session) => session,
            None => {
                debug_print!("[sync] session does not exist");
                return;
            }
        };

        let settings = sync::build_sync_settings(None);
        let client = client.clone();
        let notifier = self.get_address();

        let after_each_sync = move |sync_result: Result<SyncResponse, SdkError>| {
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

        // // Default handler
        // client.add_event_handler(|event: AnySyncTimelineEvent, room: Room| async move {
        //     App::get_sender()
        //         .send(Matui(MatuiEvent::Timeline(
        //             event.into_full_event(room.room_id().into()),
        //         )))
        //         .expect("could not send timeline event");
        // });

        // client.add_event_handler(|event: AnySyncEphemeralRoomEvent, room: Room| async move {
        //     if room.state() != RoomState::Joined {
        //         return;
        //     }

        //     match event {
        //         AnySyncEphemeralRoomEvent::Typing(SyncEphemeralRoomEvent { content: c }) => {
        //             App::get_sender()
        //                 .send(Matui(MatuiEvent::Typing(room, c.user_ids)))
        //                 .expect("could not send typing event");
        //         }
        //         AnySyncEphemeralRoomEvent::Receipt(SyncEphemeralRoomEvent { content: c }) => {
        //             App::get_sender()
        //                 .send(Matui(MatuiEvent::Receipt(room, c)))
        //                 .expect("could not send typing event");
        //         }
        //         _ => {}
        //     };
        // });

        // // Verification handler
        // client.add_event_handler(|ev: ToDeviceKeyVerificationRequestEvent, client: Client| async move {
        //     let request = match client
        //         .encryption()
        //         .get_verification_request(&ev.sender, &ev.content.transaction_id)
        //         .await
        //     {
        //         Some(req) => req,
        //         None => {
        //             error!("could not create request");
        //             return;
        //         }
        //     };

        //     request
        //         .accept()
        //         .await
        //         .expect("Can't accept verification request");
        // });

        // client.add_event_handler(|ev: ToDeviceKeyVerificationStartEvent, client: Client| async move {
        //     if let Some(Verification::SasV1(sas)) = client
        //         .encryption()
        //         .get_verification(&ev.sender, ev.content.transaction_id.as_str())
        //         .await
        //     {
        //         tokio::spawn(sas_verification_handler(sas, App::get_sender()));
        //     };
        // });

        // client.add_event_handler(|ev: OriginalSyncRoomMessageEvent, client: Client| async move {
        //     if let MessageType::VerificationRequest(_) = &ev.content.msgtype {
        //         let request = match client
        //             .encryption()
        //             .get_verification_request(&ev.sender, &ev.event_id)
        //             .await
        //         {
        //             Some(req) => req,
        //             None => {
        //                 error!("could not create request");
        //                 return;
        //             }
        //         };

        //         request
        //             .accept()
        //             .await
        //             .expect("Can't accept verification request");
        //     }
        // });

        // client.add_event_handler(|ev: OriginalSyncKeyVerificationStartEvent, client: Client| async move {
        //     if let Some(Verification::SasV1(sas)) = client
        //         .encryption()
        //         .get_verification(&ev.sender, ev.content.relates_to.event_id.as_str())
        //         .await
        //     {
        //         tokio::spawn(sas_verification_handler(sas, App::get_sender()));
        //     }
        // });
    }
}
