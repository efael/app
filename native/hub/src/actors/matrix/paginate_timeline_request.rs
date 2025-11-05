use std::str::FromStr;

use async_trait::async_trait;
use messages::prelude::{Context, Handler};
use ruma::OwnedRoomId;

use crate::{
    actors::matrix::Matrix,
    matrix::timeline_pagination::TimelinePagination,
    signals::dart::{MatrixTimelinePaginateResponse, MatrixTimelinePaginateRequest},
};

#[async_trait]
impl Handler<MatrixTimelinePaginateRequest> for Matrix {
    type Result = MatrixTimelinePaginateResponse;

    #[tracing::instrument(skip(self))]
    async fn handle(
        &mut self,
        msg: MatrixTimelinePaginateRequest,
        _context: &Context<Self>,
    ) -> Self::Result {
        if self.client.is_none() {
            tracing::error!("client is not initialized");
            return MatrixTimelinePaginateResponse::Err {
                message: "client is not initialized".to_string(),
            };
        };

        let rooms = self.sync.room_list.rooms.lock().await;

        let room_id = match OwnedRoomId::from_str(&msg.room_id) {
            Ok(room_id) => room_id,
            Err(err) => {
                tracing::error!(error = %err, "failed to parse room id");
                return MatrixTimelinePaginateResponse::Err {
                    message: err.to_string(),
                };
            }
        };

        let Some(room) = rooms.get(&room_id) else {
            tracing::error!("failed to find room {room_id}");
            return MatrixTimelinePaginateResponse::Err {
                message: format!("failed to find room {room_id}"),
            };
        };

        let pagination_result = match msg.pagination {
            TimelinePagination::Backwards => room.timeline.paginate_backwards(20).await,
            TimelinePagination::Forwards => room.timeline.paginate_forwards(20).await,
        };

        match pagination_result {
            Ok(end_of_timeline) => {
                return MatrixTimelinePaginateResponse::Ok {
                    room_id: msg.room_id,
                    end_of_timeline: end_of_timeline,
                };
            },
            Err(err) => {
                tracing::error!("failed to paginate timeline backwards {room_id}, {err:?}");
                return MatrixTimelinePaginateResponse::Err {
                    message: format!("failed to paginate timeline backwards {room_id}, {err:?}"),
                };
            }
        }
    }
}
