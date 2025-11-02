use std::str::FromStr;

use async_trait::async_trait;
use messages::prelude::{Context, Handler};
use ruma::{
    OwnedRoomId,
    events::{AnyMessageLikeEventContent, room::message::RoomMessageEventContent},
};

use crate::{
    actors::matrix::Matrix,
    signals::dart::{
        MatrixSendMessageContent, MatrixSendMessageRequest, MatrixSendMessageResponse,
    },
};

#[async_trait]
impl Handler<MatrixSendMessageRequest> for Matrix {
    type Result = MatrixSendMessageResponse;

    #[tracing::instrument(skip(self))]
    async fn handle(
        &mut self,
        msg: MatrixSendMessageRequest,
        _context: &Context<Self>,
    ) -> Self::Result {
        let Some(_client) = self.client.as_mut() else {
            tracing::error!("client is not initialized");
            return MatrixSendMessageResponse::Err {
                message: "Client is not initialized".to_string(),
            };
        };

        let room_id = match OwnedRoomId::from_str(&msg.room_id) {
            Ok(room_id) => room_id,
            Err(err) => {
                tracing::error!(error = %err, "failed to parse room id");
                return MatrixSendMessageResponse::Err {
                    message: "failed to parse room id".to_string(),
                };
            }
        };

        let mut rooms = self.sync.room_list.rooms.lock().await;

        let Some(room) = rooms.get_mut(&room_id) else {
            tracing::error!("failed to find room by room id");
            return MatrixSendMessageResponse::Err {
                message: "failed to find room by room id".to_string(),
            };
        };

        match msg.content {
            MatrixSendMessageContent::Message { body } => room
                .timeline
                .send(AnyMessageLikeEventContent::RoomMessage(
                    RoomMessageEventContent::text_plain(body),
                ))
                .await
                .map_or_else(
                    |err| {
                        tracing::error!(error = %err, "failed to send message");
                        MatrixSendMessageResponse::Err {
                            message: "failed to send message".to_string(),
                        }
                    },
                    |_| MatrixSendMessageResponse::Ok {},
                ),
        }
    }
}
