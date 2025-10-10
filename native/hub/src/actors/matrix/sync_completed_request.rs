use async_trait::async_trait;
use messages::prelude::{Context, Notifiable};
use rinf::debug_print;

use crate::{actors::matrix::Matrix, signals::MatrixSyncCompleted};

#[async_trait]
impl Notifiable<MatrixSyncCompleted> for Matrix {
    async fn notify(&mut self, msg: MatrixSyncCompleted, _: &Context<Self>) {
        let session = match self.session.as_mut() {
            Some(session) => session,
            None => {
                debug_print!("[sync-completed] session does not exist");
                return;
            }
        };

        session.set_sync_token(msg.next_batch);
        session
            .save_to_disk()
            .expect("failed to save session to disk");
    }
}
