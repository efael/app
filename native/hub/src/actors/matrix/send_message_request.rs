use std::str::FromStr;

use async_trait::async_trait;
use messages::prelude::{Context, Handler};
use ruma::{
    OwnedRoomId, UInt, events::{
        AnyMessageLikeEventContent,
        room::{
            ImageInfo,
            message::{ImageMessageEventContent, MessageType, RoomMessageEventContent},
        },
    }
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
        let Some(client) = self.client.as_mut() else {
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
            MatrixSendMessageContent::Message { body } => {
                return room
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
                    );
            }
            MatrixSendMessageContent::Image { size, bytes, mimetype, caption } => {
                let mut cursor = std::io::Cursor::new(bytes);
                let upload = client.upload_encrypted_file(&mut cursor);

                let progress = upload.subscribe_to_send_progress();

                let uploaded = match upload.await {
                    Ok(uploaded) => uploaded,
                    Err(err) => {
                        return MatrixSendMessageResponse::Err {
                            message: format!("failed to upload file - {err:?}"),
                        };
                    }
                };

                let mut info = ImageInfo::new();
                info.height = Some(UInt::new(1920).unwrap());
                info.width = Some(UInt::new(1080).unwrap());
                info.mimetype = Some(mimetype);
                info.size = Some(UInt::new(size).unwrap());

                let image_msg = ImageMessageEventContent::encrypted(
                    caption.unwrap_or("MY TEST IMAGE".to_string()),
                    uploaded,
                )
                .info(Some(Box::new(info)));

                return room
                    .timeline
                    .send(AnyMessageLikeEventContent::RoomMessage(
                        RoomMessageEventContent::new(MessageType::Image(image_msg)),
                    ))
                    .await
                    .map_or_else(
                        |err| {
                            tracing::error!(error = %err, "failed to send image");
                            MatrixSendMessageResponse::Err {
                                message: "failed to send image".to_string(),
                            }
                        },
                        |_| MatrixSendMessageResponse::Ok {},
                    );
            }
        }
    }
}
