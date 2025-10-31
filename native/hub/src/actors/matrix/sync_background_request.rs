use async_trait::async_trait;
use messages::prelude::{Context, Notifiable};

use crate::{
    actors::matrix::Matrix, extensions::easy_listener::EasyListener,
    signals::internal::InternalSyncBackgroundRequest,
};

#[async_trait]
impl Notifiable<InternalSyncBackgroundRequest> for Matrix {
    #[tracing::instrument(skip(self))]
    async fn notify(&mut self, _msg: InternalSyncBackgroundRequest, _: &Context<Self>) {
        let Some(client) = self.client.as_ref() else {
            tracing::error!("client is not initialized");
            return;
        };

        self.sync.should_sync = true;
        self.sync.start(self.get_address(), client.clone()).await;
    }
}
