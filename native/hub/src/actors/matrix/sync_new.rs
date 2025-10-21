use async_trait::async_trait;
use matrix_sdk_ui::sync_service::SyncService;
use messages::prelude::{Context, Notifiable};
use rinf::debug_print;

use crate::{
    actors::matrix::Matrix, extensions::easy_listener::EasyListener,
    signals::MatrixSyncBackgroundRequest,
};

#[async_trait]
impl Notifiable<MatrixSyncBackgroundRequest> for Matrix {
    async fn notify(&mut self, _msg: MatrixSyncBackgroundRequest, _: &Context<Self>) {
        let Some(client) = self.client.as_ref() else {
            debug_print!("[sync] client is not initialized");
            return;
        };

        let sync_service = match SyncService::builder(client.clone())
            .with_offline_mode()
            .build()
            .await
        {
            Ok(ss) => ss,
            Err(err) => {
                debug_print!("[sync] encountered error while initializing sync service {err:?}");
                return;
            }
        };

        sync_service.start().await;

        let _address = self.get_address();

        self.owned_tasks.spawn(async move {
            let rls = sync_service.room_list_service();
            let rooms = rls.all_rooms().await;
            let mut loading_state = rooms.map(|r| r.loading_state());

            loop {
                if let Some(_state) = sync_service.state().next().await {
                    // debug_print!("[sync] new state {state:?}");
                }

                if let Ok(loading_state) = loading_state.as_mut()
                    && let Some(state) = loading_state.next().await
                {
                    debug_print!("[sync] new room state {state:?}");
                }
            }
        });
    }
}
