use std::{ops::Deref, sync::Arc};

use matrix_sdk::Error as SdkError;
use rinf::SignalPiece;
use serde::Serialize;

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub enum Error {
    /// Error doing an HTTP request.
    Http(String),

    /// Queried endpoint requires authentication but was called on an anonymous
    /// client.
    AuthenticationRequired,

    /// This request failed because the local data wasn't sufficient.
    InsufficientData,

    /// Attempting to restore a session after the olm-machine has already been
    /// set up fails
    BadCryptoStoreState,

    /// Attempting to access the olm-machine but it is not yet available.
    NoOlmMachine,

    /// An error de/serializing type for the `StateStore`
    SerdeJson(String),

    /// An IO error happened.
    Io(String),

    /// An error occurred in the crypto store.
    CryptoStoreError(String),

    /// An error occurred with a cross-process store lock.
    CrossProcessLockError(String),

    /// An error occurred during a E2EE operation.
    OlmError(String),

    /// An error occurred during a E2EE group operation.
    MegolmError(String),

    /// An error occurred during decryption.
    DecryptorError(String),

    /// An error occurred in the state store.
    StateStore(String),

    /// An error occurred in the event cache store.
    EventCacheStore(String),

    /// An error encountered when trying to parse an identifier.
    Identifier(String),

    /// An error encountered when trying to parse a url.
    Url(String),

    /// An error while scanning a QR code.
    QrCodeScanError(String),

    /// An error encountered when trying to parse a user tag name.
    UserTagName(String),

    /// An error occurred within sliding-sync
    SlidingSync(String),

    /// Attempted to call a method on a room that requires the user to have a
    /// specific membership state in the room, but the membership state is
    /// different.
    WrongRoomState(String),

    /// Session callbacks have been set multiple times.
    MultipleSessionCallbacks,

    /// An error occurred interacting with the OAuth 2.0 API.
    OAuth(String),

    /// A concurrent request to a deduplicated request has failed.
    ConcurrentRequestFailed,

    /// An other error was raised.
    ///
    /// This might happen because encryption was enabled on the base-crate
    /// but not here and that raised.
    UnknownError(String),

    /// An error coming from the event cache subsystem.
    EventCache(String),

    /// An item has been wedged in the send queue.
    SendQueueWedgeError(String),

    /// Backups are not enabled
    BackupNotEnabled,

    /// It's forbidden to ignore your own user.
    CantIgnoreLoggedInUser,

    /// An error happened during handling of a media subrequest.
    Media(String),

    /// An error happened while attempting to reply to an event.
    ReplyError(String),

    /// An error happened while attempting to change power levels.
    PowerLevels(String),
}

impl From<SdkError> for Error {
    fn from(value: SdkError) -> Self {
        // TODO: @orzklv come on and fix me (if you can ofc.)
        Arc::new(value).into()
    }
}

impl From<Arc<SdkError>> for Error {
    fn from(value: Arc<SdkError>) -> Self {
        match value.deref() {
            SdkError::Http(http_error) => Self::Http(http_error.to_string()),
            SdkError::AuthenticationRequired => Self::AuthenticationRequired,
            SdkError::InsufficientData => Self::InsufficientData,
            SdkError::BadCryptoStoreState => Self::BadCryptoStoreState,
            SdkError::NoOlmMachine => Self::NoOlmMachine,
            SdkError::SerdeJson(error) => Self::SerdeJson(error.to_string()),
            SdkError::Io(error) => Self::Io(error.to_string()),
            SdkError::CryptoStoreError(crypto_store_error) => {
                Self::CryptoStoreError(crypto_store_error.to_string())
            }
            SdkError::CrossProcessLockError(lock_store_error) => {
                Self::CrossProcessLockError(lock_store_error.to_string())
            }
            SdkError::OlmError(olm_error) => Self::OlmError(olm_error.to_string()),
            SdkError::MegolmError(megolm_error) => Self::MegolmError(megolm_error.to_string()),
            SdkError::DecryptorError(decryptor_error) => {
                Self::DecryptorError(decryptor_error.to_string())
            }
            SdkError::StateStore(store_error) => Self::StateStore(store_error.to_string()),
            SdkError::EventCacheStore(event_cache_store_error) => {
                Self::EventCacheStore(event_cache_store_error.to_string())
            }
            SdkError::Identifier(error) => Self::Identifier(error.to_string()),
            SdkError::Url(parse_error) => Self::Url(parse_error.to_string()),
            SdkError::UserTagName(invalid_user_tag_name) => {
                Self::UserTagName(invalid_user_tag_name.to_string())
            }
            SdkError::SlidingSync(error) => Self::SlidingSync(error.to_string()),
            SdkError::WrongRoomState(wrong_room_state) => {
                Self::WrongRoomState(wrong_room_state.to_string())
            }
            SdkError::MultipleSessionCallbacks => Self::MultipleSessionCallbacks,
            SdkError::OAuth(oauth_error) => Self::OAuth(oauth_error.to_string()),
            SdkError::ConcurrentRequestFailed => Self::ConcurrentRequestFailed,
            SdkError::UnknownError(error) => Self::UnknownError(error.to_string()),
            SdkError::EventCache(event_cache_error) => {
                Self::EventCache(event_cache_error.to_string())
            }
            SdkError::SendQueueWedgeError(queue_wedge_error) => {
                Self::SendQueueWedgeError(queue_wedge_error.to_string())
            }
            SdkError::BackupNotEnabled => Self::BackupNotEnabled,
            SdkError::CantIgnoreLoggedInUser => Self::CantIgnoreLoggedInUser,
            SdkError::Media(media_error) => Self::Media(media_error.to_string()),
            SdkError::ReplyError(reply_error) => Self::ReplyError(reply_error.to_string()),
            SdkError::PowerLevels(power_levels_error) => {
                Self::PowerLevels(power_levels_error.to_string())
            }
            _ => Error::UnknownError("unmatched".to_string()),
        }
    }
}
