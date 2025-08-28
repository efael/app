use std::collections::HashMap;

use matrix_sdk::{
    authentication::oauth::{
        ClientId, ClientRegistrationData,
        registration::{ApplicationType, ClientMetadata, Localized, OAuthGrantType},
    },
    reqwest::Url,
    ruma::serde::Raw,
};
use rinf::SignalPiece;
use serde::Deserialize;

use crate::signals::oidc_error::OidcError;

/// The configuration to use when authenticating with OIDC.
#[derive(Deserialize, SignalPiece, Debug)]
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
                        // tracing::error!("Failed to parse {issuer:?}");
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
