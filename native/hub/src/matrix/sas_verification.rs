use matrix_sdk::{
    crypto::{Emoji as SdkEmoji, SasState},
    encryption::verification::SasVerification,
    stream::StreamExt,
};
use messages::prelude::Address;
use rinf::{SignalPiece, debug_print};
use serde::{Deserialize, Serialize};

use crate::{
    actors::matrix::Matrix,
    signals::{MatrixListChatsRequest, MatrixSASConfirmRequest},
};

pub fn handler(verification: SasVerification, flow_id: String, mut notifier: Address<Matrix>) {
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
