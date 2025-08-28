use rinf::SignalPiece;
use serde::Serialize;

use matrix_sdk::ruma::api::client::discovery::get_authorization_server_metadata::v1::Prompt as RumaOidcPrompt;

#[derive(Serialize, SignalPiece, Debug)]
pub enum OidcPrompt {
    /// The Authorization Server should prompt the End-User to create a user
    /// account.
    ///
    /// Defined in [Initiating User Registration via OpenID Connect](https://openid.net/specs/openid-connect-prompt-create-1_0.html).
    Create,

    /// The Authorization Server should prompt the End-User for
    /// reauthentication.
    Login,

    /// The Authorization Server should prompt the End-User for consent before
    /// returning information to the Client.
    Consent,

    /// An unknown value.
    Unknown { value: String },
}

impl From<RumaOidcPrompt> for OidcPrompt {
    fn from(value: RumaOidcPrompt) -> Self {
        match value {
            RumaOidcPrompt::Create => Self::Create,
            value => match value.as_str() {
                "consent" => Self::Consent,
                "login" => Self::Login,
                _ => Self::Unknown {
                    value: value.to_string(),
                },
            },
        }
    }
}

impl From<OidcPrompt> for RumaOidcPrompt {
    fn from(value: OidcPrompt) -> Self {
        match value {
            OidcPrompt::Create => Self::Create,
            OidcPrompt::Consent => Self::from("consent"),
            OidcPrompt::Login => Self::from("login"),
            OidcPrompt::Unknown { value } => value.into(),
        }
    }
}
