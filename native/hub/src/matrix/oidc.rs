use std::{collections::HashMap, fmt::Debug};

use matrix_sdk::{
    Client, Error,
    authentication::oauth::{
        ClientId, ClientRegistrationData, OAuthAuthorizationData, OAuthError as SdkOAuthError,
        error::OAuthAuthorizationCodeError,
        registration::{ApplicationType, ClientMetadata, Localized, OAuthGrantType},
    },
};
use rinf::SignalPiece;
use ruma::{api::client::discovery::get_authorization_server_metadata::v1::Prompt, serde::Raw};
use serde::{Deserialize, Serialize};
use url::Url;

/// The configuration to use when authenticating with OIDC.
#[derive(Serialize, Deserialize, SignalPiece, Debug)]
pub struct OidcConfiguration {
    /// The name of the client that will be shown during OIDC authentication.
    pub client_name: Option<String>,
    /// The redirect URI that will be used when OIDC authentication is
    /// successful.
    pub redirect_uri: String,
    /// A URI that contains information about the client.
    pub client_uri: String,
    /// A URI that contains the client's logo.
    pub logo_uri: Option<String>,
    /// A URI that contains the client's terms of service.
    pub tos_uri: Option<String>,
    /// A URI that contains the client's privacy policy.
    pub policy_uri: Option<String>,

    /// Pre-configured registrations for use with homeservers that don't support
    /// dynamic client registration.
    ///
    /// The keys of the map should be the URLs of the homeservers, but keys
    /// using `issuer` URLs are also supported.
    pub static_registrations: HashMap<String, String>,
}

impl OidcConfiguration {
    pub async fn url(&self, client: &mut Client) -> Result<OAuthAuthorizationData, OidcError> {
        let registration_data = self.registration_data()?;
        let redirect_uri = self.redirect_uri()?;

        let mut url_builder =
            client
                .oauth()
                .login(redirect_uri, None, Some(registration_data), None);

        url_builder = url_builder.prompt(vec![Prompt::from("consent")]);
        Ok(url_builder.build().await?)
    }

    pub fn redirect_uri(&self) -> Result<Url, OidcError> {
        Url::parse(&self.redirect_uri).map_err(|_| OidcError::CallbackUrlInvalid)
    }

    pub fn client_metadata(&self) -> Result<Raw<ClientMetadata>, OidcError> {
        let redirect_uri = self.redirect_uri()?;
        let client_name = self
            .client_name
            .as_ref()
            .map(|n| Localized::new(n.to_owned(), []));
        let client_uri = self.client_uri.localized_url()?;
        let logo_uri = self.logo_uri.localized_url()?;
        let policy_uri = self.policy_uri.localized_url()?;
        let tos_uri = self.tos_uri.localized_url()?;

        let metadata = ClientMetadata {
            // The server should display the following fields when getting the user's consent.
            client_name,
            logo_uri,
            policy_uri,
            tos_uri,
            ..ClientMetadata::new(
                ApplicationType::Native,
                vec![
                    OAuthGrantType::AuthorizationCode {
                        redirect_uris: vec![redirect_uri],
                    },
                    OAuthGrantType::DeviceCode,
                ],
                client_uri,
            )
        };

        Raw::new(&metadata).map_err(|_| OidcError::MetadataInvalid)
    }

    pub fn registration_data(&self) -> Result<ClientRegistrationData, OidcError> {
        let client_metadata = self.client_metadata()?;

        let mut registration_data = ClientRegistrationData::new(client_metadata);

        if !self.static_registrations.is_empty() {
            let static_registrations = self
                .static_registrations
                .iter()
                .filter_map(|(issuer, client_id)| {
                    let Ok(issuer) = Url::parse(issuer) else {
                        return None;
                    };
                    Some((issuer, ClientId::new(client_id.clone())))
                })
                .collect();

            registration_data.static_registrations = Some(static_registrations);
        }

        Ok(registration_data)
    }
}

#[derive(Debug, thiserror::Error, Serialize, Deserialize)]
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

/* Helpers */

trait OptionExt {
    /// Convenience method to convert an `Option<String>` to a URL and returns
    /// it as a Localized URL. No localization is actually performed.
    fn localized_url(&self) -> Result<Option<Localized<Url>>, OidcError>;
}

impl OptionExt for Option<String> {
    fn localized_url(&self) -> Result<Option<Localized<Url>>, OidcError> {
        self.as_deref().map(StrExt::localized_url).transpose()
    }
}

trait StrExt {
    /// Convenience method to convert a string to a URL and returns it as a
    /// Localized URL. No localization is actually performed.
    fn localized_url(&self) -> Result<Localized<Url>, OidcError>;
}

impl StrExt for str {
    fn localized_url(&self) -> Result<Localized<Url>, OidcError> {
        Ok(Localized::new(
            Url::parse(self).map_err(|_| OidcError::MetadataInvalid)?,
            [],
        ))
    }
}
