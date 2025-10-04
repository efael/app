use async_trait::async_trait;
use matrix_sdk::stream::StreamExt;
use messages::prelude::{Context, Notifiable};
use rinf::debug_print;

use crate::{
    actors::matrix::{
        session_verification_delegate::SessionVerificationDelegateImplementation, Matrix
    }, extensions::easy_listener::EasyListener, signals::{MatrixListChatsRequest, MatrixSessionVerificationRequest}
};

#[async_trait]
impl Notifiable<MatrixSessionVerificationRequest> for Matrix {
    async fn notify(&mut self, _msg: MatrixSessionVerificationRequest, _: &Context<Self>) {
        let client = match self.client.as_mut() {
            Some(client) => client,
            None => {
                debug_print!("MatrixSessionVerificationRequest: client is not initialized");
                return;
            }
        };

        let session = match client.session() {
            Ok(session) => session,
            Err(error) => {
                debug_print!(
                    "MatrixSessionVerificationRequest: client does have session: {error:?}"
                );
                return;
            }
        };

        let encrpyption = client
            .encryption();

        debug_print!("[verification] waiting for e2ee intialization");
        encrpyption
            .wait_for_e2ee_initialization_tasks()
            .await;

        let identity = encrpyption
            .user_identity(session.user_id.clone())
            .await
            .expect("failed to fetch user identity");

        if identity.map_or(false, |i| i.is_verified()) {
            debug_print!("[verification] identity verified ✅");
            self.emit(MatrixListChatsRequest { url: "".to_string() });

            return;
        }

        debug_print!("[verification] fetching controller");
        let controller = client
            .get_session_verification_controller()
            .await
            .expect("should have session verification controller");

        let addr = self.get_address();
        let delegate = SessionVerificationDelegateImplementation::new(addr);

        controller.set_delegate(Some(Box::new(delegate)));

        debug_print!("[verification] sending request for device verification");
        let request = controller
            .request_device_verification()
            .await
            .expect("failed to start device verification");

        self.verification_controller = Some(controller);

        // tokio::spawn(async move {
        //     while let Some(state) = request.changes().next().await {
        //         debug_print!("[verification] request state: {:?}", state);
        //     }
        // });
    }
}
