use std::{fmt::Display, fs, path::PathBuf};

use matrix_sdk::{
    AuthSession,
    authentication::oauth::{ClientId, OAuthSession, UserSession},
};
use rinf::debug_print;
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Session {
    pub client_id: ClientId,
    pub user_session: UserSession,
    pub sync_token: Option<String>,

    #[serde(skip)]
    pub path: PathBuf,
}

#[derive(Debug)]
pub enum SessionError
where
    Self: Send + Sync + 'static,
{
    Deserialize(serde_json::Error),
    FileRead(std::io::Error),
}

impl Display for SessionError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            SessionError::Deserialize(error) => error.fmt(f),
            SessionError::FileRead(error) => error.fmt(f),
        }
    }
}

impl std::error::Error for SessionError {}

impl Session {
    pub fn from_oauth(oauth_session: OAuthSession, path: PathBuf) -> Self {
        Self {
            client_id: oauth_session.client_id,
            user_session: oauth_session.user,
            sync_token: None,
            path,
        }
    }

    pub fn load_from_disk(path: PathBuf) -> Result<Self, SessionError> {
        match std::fs::read_to_string(&path).map(|file| serde_json::from_str::<Session>(&file)) {
            Ok(Ok(mut session)) => {
                debug_print!("[init] session found: {:?}", session);
                session.set_path(path);
                Ok(session)
            }
            Ok(Err(err)) => {
                debug_print!("[init] failed to parse file: {err:?}");
                Err(SessionError::Deserialize(err))
            }
            Err(err) => {
                debug_print!("[init] failed to read session file: {err:?}");
                Err(SessionError::FileRead(err))
            }
        }
    }

    pub fn save_to_disk(&self) -> Result<(), std::io::Error> {
        debug_print!("[session] saving to: {:?}", self.path.clone());
        serde_json::to_string::<Session>(&self)
            .map(|session| fs::write(self.path.clone(), session))?
    }

    pub fn set_sync_token(&mut self, sync_token: String) {
        self.sync_token = Some(sync_token);
    }

    pub fn set_path(&mut self, path: PathBuf) {
        self.path = path;
    }

    pub fn update_from_oauth_session(&mut self, oauth_session: OAuthSession) {
        self.client_id = oauth_session.client_id;
        self.user_session = oauth_session.user;
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
