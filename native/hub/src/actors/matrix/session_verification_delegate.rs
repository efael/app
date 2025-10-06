use crate::{actors::matrix::Matrix, signals::MatrixSASConfirmRequest};
use matrix_sdk_rinf::session_verification::{
    SessionVerificationControllerDelegate, SessionVerificationData,
    SessionVerificationRequestDetails,
};
use messages::prelude::Address;
use rinf::debug_print;

pub struct SessionVerificationDelegateImplementation {
    notifier_addr: Address<Matrix>,
}

impl SessionVerificationDelegateImplementation {
    pub fn new(notifier_addr: Address<Matrix>) -> Self {
        Self { notifier_addr }
    }
}

impl SessionVerificationControllerDelegate for SessionVerificationDelegateImplementation {
    fn did_receive_verification_request(&self, details: SessionVerificationRequestDetails) {
        debug_print!("[verification] got request from {:?}", details.device_id);
    }

    fn did_accept_verification_request(&self) {
        debug_print!("[verification] request accepted");
    }

    fn did_start_sas_verification(&self) {
        debug_print!("[verification] SAS verification started");
    }

    fn did_receive_verification_data(&self, data: SessionVerificationData) {
        let mut addr = self.notifier_addr.clone();
        tokio::spawn(async move {
            let msg = MatrixSASConfirmRequest { data };

            addr.notify(msg).await.unwrap();
        });
    }

    fn did_fail(&self) {
        debug_print!("[verification] verification failed");
    }

    fn did_cancel(&self) {
        debug_print!("[verification] verification cancelled");
    }

    fn did_finish(&self) {
        debug_print!("[verification] verification finished successfully");
    }
}
