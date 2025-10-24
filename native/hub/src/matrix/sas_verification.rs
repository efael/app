use matrix_sdk::{
    Client,
    crypto::{Emoji as SdkEmoji, SasState},
    encryption::verification::{SasVerification, Verification},
    stream::StreamExt,
};
use messages::prelude::Address;
use rinf::{SignalPiece, debug_print};
use ruma::events::{
    key::verification::{
        request::ToDeviceKeyVerificationRequestEvent, start::ToDeviceKeyVerificationStartEvent,
    },
    room::message::{MessageType, OriginalSyncRoomMessageEvent},
};
use serde::{Deserialize, Serialize};

use crate::{
    actors::matrix::Matrix,
    signals::{MatrixListChatsRequest, MatrixSASConfirmRequest},
};

pub fn sas_handler(verification: SasVerification, flow_id: String, mut notifier: Address<Matrix>) {
    tokio::spawn(async move {
        verification
            .accept()
            .await
            .expect("[sas-verification] cannot accept verification");

        let mut stream = verification.changes();

        while let Some(state) = stream.next().await {
            match state {
                SasState::KeysExchanged {
                    emojis,
                    decimals: _,
                } => {
                    debug_print!("[sas-verification] keys exchanged");

                    let emoji_slice = emojis
                        .expect("[sas-verification] only emoji verification is supported")
                        .emojis
                        .into_iter()
                        .map(|sdk_emoji| Emoji::from(sdk_emoji))
                        .collect::<Vec<Emoji>>();

                    notifier
                        .notify(MatrixSASConfirmRequest {
                            flow_id: flow_id.clone(),
                            emojis: emoji_slice,
                        })
                        .await
                        .unwrap();
                }
                SasState::Done { .. } => {
                    debug_print!("[sas-verification] done");

                    notifier
                        .notify(MatrixListChatsRequest {
                            url: "".to_string(),
                        })
                        .await
                        .unwrap();
                }
                SasState::Started { .. } => debug_print!("[sas-verification] started"),
                SasState::Accepted { .. } => debug_print!("[sas-verification] accepted"),
                SasState::Confirmed => debug_print!("[sas-verification] confirmed"),
                SasState::Cancelled(_) => debug_print!("[sas-verification] cancelled"),
                SasState::Created { .. } => debug_print!("[sas-verification] created"),
            }
        }
    });
}

pub async fn to_device_key_verification_request_handler(
    event: ToDeviceKeyVerificationRequestEvent,
    client: Client,
) {
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
}

pub async fn to_device_key_verification_start_handler(
    event: ToDeviceKeyVerificationStartEvent,
    client: Client,
    notifier: Address<Matrix>,
) {
    debug_print!("[event] ToDeviceKeyVerificationStartEvent: received request: {event:?}");
    if let Some(Verification::SasV1(sas)) = client
        .encryption()
        .get_verification(&event.sender, event.content.transaction_id.as_str())
        .await
    {
        debug_print!("[event] ToDeviceKeyVerificationStartEvent: received SAS");
        sas_handler(sas, event.content.transaction_id.to_string(), notifier);
    };
}

pub async fn original_sync_message_room_handler(
    event: OriginalSyncRoomMessageEvent,
    client: Client,
) {
    debug_print!("[event] OriginalSyncRoomMessageEvent: received request: {event:?}");
    if let MessageType::VerificationRequest(_) = &event.content.msgtype {
        let request = match client
            .encryption()
            .get_verification_request(&event.sender, &event.event_id)
            .await
        {
            Some(req) => req,
            None => {
                debug_print!("[event] OriginalSyncRoomMessageEvent: could not create request");
                return;
            }
        };

        debug_print!("[event] OriginalSyncRoomMessageEvent: accepting request");
        request
            .accept()
            .await
            .expect("[event] OriginalSyncRoomMessageEvent: can't accept verification request");
    }
}

/// An emoji that is used for interactive verification using a short auth
/// string.
///
/// This will contain a single emoji and description from the list of emojis
/// from the [spec].
///
/// [spec]: https://spec.matrix.org/unstable/client-server-api/#sas-method-emoji
#[derive(Debug, Serialize, Deserialize, SignalPiece)]
pub struct Emoji {
    pub symbol: String,
    pub description: String,
}

impl From<SdkEmoji> for Emoji {
    fn from(value: SdkEmoji) -> Self {
        Self {
            symbol: value.symbol.to_string(),
            description: value.description.to_string(),
        }
    }
}
