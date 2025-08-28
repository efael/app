use std::fmt::Display;

use matrix_sdk::ClientBuildError;

#[derive(Debug)]
pub enum InitClientError {
    FailedToCreateStorageFolder(std::io::Error),
    ClientBuildError(ClientBuildError),
}

impl Display for InitClientError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let str = match self {
            InitClientError::FailedToCreateStorageFolder(error) => error.to_string(),
            InitClientError::ClientBuildError(client_build_error) => client_build_error.to_string(),
        };

        write!(f, "{str}")
    }
}
