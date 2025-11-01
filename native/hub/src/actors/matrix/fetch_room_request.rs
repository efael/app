use std::str::FromStr;

use async_trait::async_trait;
use messages::prelude::{Context, Handler};
use ruma::OwnedRoomId;

use crate::{
    actors::matrix::Matrix,
    matrix::vector_diff_timeline_item::VectorDiffTimelineItem,
    signals::dart::{MatrixFetchRoomRequest, MatrixFetchRoomResponse},
};

#[async_trait]
impl Handler<MatrixFetchRoomRequest> for Matrix {
    type Result = MatrixFetchRoomResponse;

    #[tracing::instrument(skip(self))]
    async fn handle(
        &mut self,
        msg: MatrixFetchRoomRequest,
        _context: &Context<Self>,
    ) -> Self::Result {
        if self.client.is_none() {
            tracing::error!("client is not initialized");
            return MatrixFetchRoomResponse::Err {
                message: "client is not initialized".to_string(),
            };
        };

        tracing::trace!("waiting for lock");
        let rooms = self.sync.room_list.rooms.lock().await;
        tracing::trace!("lock working");

        let room_id = match OwnedRoomId::from_str(&msg.room_id) {
            Ok(room_id) => room_id,
            Err(err) => {
                tracing::error!(error = %err, "failed to parse room id");
                return MatrixFetchRoomResponse::Err {
                    message: err.to_string(),
                };
            }
        };

        let Some(room) = rooms.get(&room_id) else {
            tracing::error!("failed to find room {room_id}");
            return MatrixFetchRoomResponse::Err {
                message: format!("failed to find room {room_id}"),
            };
        };

        let items = room.initial_items.iter().cloned().collect();
        let diff = VectorDiffTimelineItem::Reset { values: items };

        MatrixFetchRoomResponse::Ok {
            room_id: msg.room_id,
            diff,
        }
    }
}
