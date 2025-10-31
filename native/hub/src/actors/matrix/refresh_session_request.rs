use async_trait::async_trait;
use messages::prelude::{Context, Notifiable};

use crate::{
    actors::matrix::Matrix, extensions::easy_listener::EasyListener, matrix::session::Session,
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

        self.sync.stop().await;

        let Some(client) = self.client.as_ref() else {
            tracing::error!("client is not initialized");
            return;
        };

        self.sync.start(self.get_address(), client.clone()).await;
    }
}
