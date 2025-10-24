use crate::{
    actors::matrix::Matrix,
    signals::{MatrixListChatsRequest, MatrixListChatsResponse},
};
use async_trait::async_trait;
use messages::prelude::{Context, Notifiable};
use rinf::RustSignal;

#[async_trait]
impl Notifiable<MatrixListChatsRequest> for Matrix {
    #[tracing::instrument(skip(self))]
    async fn notify(&mut self, _msg: MatrixListChatsRequest, _: &Context<Self>) {
        let Some(client) = self.client.as_mut() else {
            tracing::error!("client is not initialized");
            MatrixListChatsResponse::Err {
                message: "Client is not initialized".to_string(),
            }
            .send_signal_to_dart();
            return;
        };

        self.room_list.populate(client).await;
        let rooms = self.room_list.get_rooms();

        for r in &rooms {
            tracing::info!("room: {r:?}");
        }

        MatrixListChatsResponse::Ok { rooms }.send_signal_to_dart();
    }
}
