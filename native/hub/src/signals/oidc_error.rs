use matrix_sdk::{
    Error,
    authentication::oauth::{OAuthError as SdkOAuthError, error::OAuthAuthorizationCodeError},
};

#[derive(Debug, thiserror::Error)]
pub enum OidcError {
    #[error(
        "The homeserver doesn't provide an authentication issuer in its well-known configuration."
    )]
    NotSupported,
    #[error("Unable to use OIDC as the supplied client metadata is invalid.")]
    MetadataInvalid,
    #[error("The supplied callback URL used to complete OIDC is invalid.")]
    CallbackUrlInvalid,
    #[error("The OIDC login was cancelled by the user.")]
    Cancelled,

    #[error("An error occurred: {message}")]
    Generic { message: String },
}

impl From<SdkOAuthError> for OidcError {
    fn from(e: SdkOAuthError) -> OidcError {
        match e {
            SdkOAuthError::Discovery(error) if error.is_not_supported() => OidcError::NotSupported,
            SdkOAuthError::AuthorizationCode(OAuthAuthorizationCodeError::RedirectUri(_))
            | SdkOAuthError::AuthorizationCode(OAuthAuthorizationCodeError::InvalidState) => {
                OidcError::CallbackUrlInvalid
            }
            SdkOAuthError::AuthorizationCode(OAuthAuthorizationCodeError::Cancelled) => {
                OidcError::Cancelled
            }
            _ => OidcError::Generic {
                message: e.to_string(),
            },
        }
    }
}

impl From<Error> for OidcError {
    fn from(e: Error) -> OidcError {
        match e {
            Error::OAuth(e) => (*e).into(),
            _ => OidcError::Generic {
                message: e.to_string(),
            },
        }
    }
}
