use std::{fs, path::PathBuf};

use matrix_sdk::{
    AuthSession,
    authentication::oauth::{ClientId, OAuthSession, UserSession},
};
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub struct Session {
    pub client_id: ClientId,
    pub user_session: UserSession,
    pub sync_token: Option<String>,

    #[serde(skip)]
    pub path: PathBuf,
}

impl Session {
    pub fn from_oauth(oauth_session: OAuthSession, path: PathBuf) -> Self {
        Self {
            client_id: oauth_session.client_id,
            user_session: oauth_session.user,
            sync_token: None,
            path: path,
        }
    }

    pub fn save_to_disk(&self) -> Result<(), std::io::Error> {
        serde_json::to_string::<Session>(&self)
            .map(|session| fs::write(self.path.clone(), session))?
    }

    pub fn set_sync_token(&mut self, sync_token: String) {
        self.sync_token = Some(sync_token);
    }
}

impl From<&Session> for AuthSession {
    /// Only restoring OAuth session implemented 
    fn from(value: &Session) -> Self {
        Self::OAuth(Box::new(OAuthSession {
            client_id: value.client_id.clone(),
            user: value.user_session.clone(),
        }))
    }
}