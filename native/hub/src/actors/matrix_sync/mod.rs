pub mod sync_request;

use matrix_sdk::Client;
use messages::{actor::Actor, prelude::Address};
use tokio::task::JoinSet;

use crate::{
    actors::matrix::Matrix,
    extensions::easy_listener::EasyListener,
    signals::{
        MatrixLogoutRequest, MatrixProcessSyncResponseRequest, MatrixRefreshTokenRequest,
        MatrixSyncRequest,
    },
};

pub struct MatrixSync {
    self_addr: Address<Self>,
    owned_tasks: JoinSet<()>,
    matrix_addr: Address<Matrix>,
    client: Option<Client>,
}

impl Actor for MatrixSync {}

impl EasyListener for MatrixSync {
    fn spawn_listener<F>(&mut self, task: F)
    where
        F: Future<Output = ()>,
        F: Send + 'static,
    {
        self.owned_tasks.spawn(task);
    }

    fn get_address(&self) -> Address<Self> {
        self.self_addr.clone()
    }
}

impl MatrixSync {
    pub fn new(self_addr: Address<Self>, matrix_addr: Address<Matrix>) -> Self {
        let owned_tasks = JoinSet::new();

        let mut actor = Self {
            self_addr,
            owned_tasks,
            matrix_addr,
            client: None,
        };

        actor.listen_to::<MatrixSyncRequest>();

        actor
    }

    pub fn emit_sync_request(&mut self, request: MatrixSyncRequest) {
        let mut addr = self.self_addr.clone();
        self.owned_tasks.spawn(async move {
            let _ = addr.notify(request).await;
        });
    }

    pub fn emit_process_sync_response_request(
        &mut self,
        request: MatrixProcessSyncResponseRequest,
    ) {
        let mut addr = self.matrix_addr.clone();
        self.owned_tasks.spawn(async move {
            let _ = addr.notify(request).await;
        });
    }

    pub fn emit_logout_request(&mut self) {
        let mut addr = self.matrix_addr.clone();
        self.owned_tasks.spawn(async move {
            let request = MatrixLogoutRequest {};
            let _ = addr.notify(request).await;
        });
    }

    pub fn emit_refresh_token_request(&mut self, request: MatrixRefreshTokenRequest) {
        let mut addr = self.matrix_addr.clone();
        self.owned_tasks.spawn(async move {
            let _ = addr.notify(request).await;
        });
    }
}
