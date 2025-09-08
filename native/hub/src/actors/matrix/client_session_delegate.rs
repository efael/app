use std::{fs, path::PathBuf};

use matrix_sdk_rinf::{
    client::{ClientSessionDelegate, Session},
    error::ClientError,
};

pub struct ClientSessionDelegateImplementation {
    pub dir: PathBuf,
}

impl ClientSessionDelegateImplementation {
    pub fn new(dir: PathBuf) -> Self {
        Self { dir }
    }
}

impl ClientSessionDelegate for ClientSessionDelegateImplementation {
    fn retrieve_session_from_keychain(
        &self,
        user_id: String,
    ) -> Result<matrix_sdk_rinf::client::Session, matrix_sdk_rinf::error::ClientError> {
        let mut session_file = self.dir.clone();
        session_file.push(format!("./{user_id}.json"));

        match fs::read_to_string(&session_file).map(|file| serde_json::from_str::<Session>(&file)) {
            Ok(Ok(session)) => Ok(session),
            Ok(Err(err)) => Err(ClientError::Generic {
                msg: format!("Failed to parse a file"),
                details: Some(err.to_string()),
            }),
            Err(err) => Err(ClientError::Generic {
                msg: format!("Failed to save into {session_file:?}"),
                details: Some(err.to_string()),
            }),
        }
    }

    fn save_session_in_keychain(&self, session: matrix_sdk_rinf::client::Session) {
        let mut session_file = self.dir.clone();
        session_file.push(format!("./{}.json", &session.user_id));
        serde_json::to_string::<Session>(&session).map(|session| fs::write(session_file, session));
    }
}
