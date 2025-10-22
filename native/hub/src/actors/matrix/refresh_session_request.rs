use async_trait::async_trait;
use messages::prelude::{Context, Notifiable};

use crate::{
    actors::matrix::Matrix, matrix::session::Session, signals::MatrixRefreshSessionRequest,
};

#[async_trait]
impl Notifiable<MatrixRefreshSessionRequest> for Matrix {
    async fn notify(&mut self, _msg: MatrixRefreshSessionRequest, _: &Context<Self>) {
        let path = self.session_path();

        if let Ok(session) = Session::load_from_disk(path) {
            self.session.replace(session);
        }
    }
}
