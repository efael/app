use std::path::PathBuf;

#[cfg(not(target_family = "wasm"))]
use matrix_sdk::{Client, SessionTokens};
use messages::prelude::{Address, Notifiable};

use crate::{
    extensions::emitter::Emitter, matrix::session::Session, signals::MatrixRefreshSessionRequest,
};

pub(crate) type SessionCallbackError = Box<dyn std::error::Error + Send + Sync>;

#[cfg(not(target_family = "wasm"))]
pub(crate) type SaveSessionCallback =
    dyn Fn(Client) -> Result<(), SessionCallbackError> + Send + Sync;
#[cfg(target_family = "wasm")]
pub(crate) type SaveSessionCallback = dyn Fn(Client) -> Result<(), SessionCallbackError>;

#[cfg(not(target_family = "wasm"))]
pub(crate) type ReloadSessionCallback =
    dyn Fn(Client) -> Result<SessionTokens, SessionCallbackError> + Send + Sync;
#[cfg(target_family = "wasm")]
pub(crate) type ReloadSessionCallback =
    dyn Fn(Client) -> Result<SessionTokens, SessionCallbackError>;

#[tracing::instrument]
pub fn save_session_callback<A>(
    session_path: PathBuf,
    address: Address<A>,
) -> Box<SaveSessionCallback>
where
    Address<A>: Emitter<A>,
    A: Notifiable<MatrixRefreshSessionRequest>,
{
    Box::new(move |client| {
        tracing::trace!("session save start");

        let oauth_session = client
            .oauth()
            .full_session()
            .expect("after login, should have session");

        let session = Session::from_oauth(oauth_session, session_path.clone());
        session
            .save_to_disk()
            .map_err(|err| Box::new(err) as Box<dyn std::error::Error + Send + Sync + 'static>)?;

        address.clone().emit(MatrixRefreshSessionRequest);

        Ok(())
    })
}

#[tracing::instrument]
pub fn reload_session_callback<A>(
    session_path: PathBuf,
    address: Address<A>,
) -> Box<ReloadSessionCallback>
where
    Address<A>: Emitter<A>,
    A: Notifiable<MatrixRefreshSessionRequest>,
{
    Box::new(move |_client| {
        tracing::trace!("session reload start");

        let session = Session::load_from_disk(session_path.clone())
            .map_err(|err| Box::new(err) as Box<dyn std::error::Error + Send + Sync + 'static>)?;

        address.clone().emit(MatrixRefreshSessionRequest);

        Ok(session.user_session.tokens)
    })
}
