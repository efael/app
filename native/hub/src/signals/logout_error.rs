use std::fmt::Display;

use matrix_sdk::ClientBuildError;

use crate::signals::init_client_error::InitClientError;

#[derive(Debug)]
pub enum LogoutError {
    FailedToCreateStorageFolder(std::io::Error),
    ClientBuildError(ClientBuildError),
    ClientNotInitialized,
    FailedToRemoveDirectory(std::io::Error),
}

impl Display for LogoutError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let str = match self {
            LogoutError::FailedToCreateStorageFolder(error) => error.to_string(),
            LogoutError::ClientBuildError(client_build_error) => client_build_error.to_string(),
            LogoutError::ClientNotInitialized => "Client is not initialized".to_string(),
            LogoutError::FailedToRemoveDirectory(error) => error.to_string(),
        };

        write!(f, "{str}")
    }
}

impl From<InitClientError> for LogoutError {
    fn from(value: InitClientError) -> Self {
        match value {
            InitClientError::FailedToCreateStorageFolder(error) => {
                LogoutError::FailedToCreateStorageFolder(error)
            }
            InitClientError::ClientBuildError(client_build_error) => {
                LogoutError::ClientBuildError(client_build_error)
            }
        }
    }
}
