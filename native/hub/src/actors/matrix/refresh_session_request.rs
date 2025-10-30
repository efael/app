use async_trait::async_trait;
use messages::prelude::{Context, Notifiable};

use crate::{
    actors::matrix::Matrix, matrix::session::Session,
    signals::internal::InternalRefreshSessionRequest,
};

#[async_trait]
impl Notifiable<InternalRefreshSessionRequest> for Matrix {
    #[tracing::instrument(skip(self))]
    async fn notify(&mut self, _msg: InternalRefreshSessionRequest, _: &Context<Self>) {
        let path = self.session_path();

        if let Ok(session) = Session::load_from_disk(path) {
            self.session.replace(session);
        }
    }
}
