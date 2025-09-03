use async_trait::async_trait;
use messages::prelude::{Context, Notifiable};
use rinf::{RustSignal, debug_print};

use crate::{
    actors::matrix::Matrix,
    signals::{MatrixListChatsRequest, MatrixListChatsResponse, room::Room},
};

#[async_trait]
impl Notifiable<MatrixListChatsRequest> for Matrix {
    async fn notify(&mut self, _msg: MatrixListChatsRequest, _: &Context<Self>) {
        let client = match self.client.as_mut() {
            Some(client) => client,
            None => {
                debug_print!("MatrixOidcAuthFinishRequest: client is not initialized");
                MatrixListChatsResponse::Err {
                    message: "Client is not initialized".to_string(),
                }
                .send_signal_to_dart();
                return;
            }
        };

        debug_print!("{:?}", client.rooms());
        debug_print!("{}", client.rooms().len());
        for room in client.rooms() {
            debug_print!("{:?}", Room::from_matrix(room).await);
        }
    }
}
