use std::str::FromStr;

use async_trait::async_trait;
use messages::prelude::{Context, Handler};
use ruma::{OwnedRoomId};

use crate::{
    actors::matrix::Matrix,
    signals::dart::{MatrixUploadEncryptedFileRequest, MatrixUploadEncryptedFileResponse},
};

#[async_trait]
impl Handler<MatrixUploadEncryptedFileRequest> for Matrix {
    type Result = MatrixUploadEncryptedFileResponse;

    #[tracing::instrument(skip(self))]
    async fn handle(
        &mut self,
        msg: MatrixUploadEncryptedFileRequest,
        _context: &Context<Self>,
    ) -> Self::Result {
        let Some(client) = self.client.as_mut() else {
            tracing::error!("client is not initialized");
            return MatrixUploadEncryptedFileResponse::Err {
                message: "Client is not initialized".to_string(),
            };
        };

        let room_id = match OwnedRoomId::from_str(&msg.room_id) {
            Ok(room_id) => room_id,
            Err(err) => {
                tracing::error!(error = %err, "failed to parse room id");
                return MatrixUploadEncryptedFileResponse::Err {
                    message: "failed to parse room id".to_string(),
                };
            }
        };

        let mut rooms = self.sync.room_list.rooms.lock().await;

        let Some(room) = rooms.get_mut(&room_id) else {
            tracing::error!("failed to find room by room id");
            return MatrixUploadEncryptedFileResponse::Err {
                message: "failed to find room by room id".to_string(),
            };
        };

        let mut cursor = std::io::Cursor::new(msg.bytes);
        let upload = client.upload_encrypted_file(&mut cursor);

        let progress = upload.subscribe_to_send_progress();

        MatrixUploadEncryptedFileResponse::Ok { 
            file: upload.into()
         }
    }
}
