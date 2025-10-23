use async_trait::async_trait;
use messages::prelude::{Context, Notifiable};

use crate::{actors::matrix::Matrix, signals::MatrixSyncCompleted};

#[async_trait]
impl Notifiable<MatrixSyncCompleted> for Matrix {
    #[tracing::instrument(skip(self))]
    async fn notify(&mut self, msg: MatrixSyncCompleted, _: &Context<Self>) {
        let Some(session) = self.session.as_mut() else {
            tracing::error!("client does have session");
            return;
        };

        session.set_sync_token(msg.next_batch);
        session
            .save_to_disk()
            .expect("failed to save session to disk");
    }
}
