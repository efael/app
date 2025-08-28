use matrix_sdk::{Client, ruma::api::client::session::get_login_types};
use rinf::{SignalPiece, debug_print};
use serde::Serialize;

use crate::signals::{oidc_prompt::OidcPrompt, sliding_sync_version::SlidingSyncVersion};

#[derive(Serialize, SignalPiece, Debug)]
pub struct HomeserverLoginDetails {
    pub url: String,
    pub sliding_sync_version: SlidingSyncVersion,
    pub supports_oidc_login: bool,
    pub supported_oidc_prompts: Vec<OidcPrompt>,
    pub supports_sso_login: bool,
    pub supports_password_login: bool,
}

impl HomeserverLoginDetails {
    pub async fn from_client(client: &Client) -> Self {
        let oauth = client.oauth();
        let (supports_oidc_login, supported_oidc_prompts) = match oauth.server_metadata().await {
            Ok(metadata) => {
                let prompts = metadata
                    .prompt_values_supported
                    .into_iter()
                    .map(Into::into)
                    .collect();

                (true, prompts)
            }
            Err(err) => {
                debug_print!(
                    "HomeserverLoginDetails: Failed to fetch OIDC provider metadata: {err}"
                );
                (false, Default::default())
            }
        };

        let login_types = client.matrix_auth().get_login_types().await.ok();
        let supports_password_login = login_types
            .as_ref()
            .map(|login_types| {
                login_types.flows.iter().any(|login_type| {
                    matches!(login_type, get_login_types::v3::LoginType::Password(_))
                })
            })
            .unwrap_or(false);
        let supports_sso_login = login_types
            .as_ref()
            .map(|login_types| {
                login_types
                    .flows
                    .iter()
                    .any(|login_type| matches!(login_type, get_login_types::v3::LoginType::Sso(_)))
            })
            .unwrap_or(false);
        let sliding_sync_version = client.sliding_sync_version().into();

        HomeserverLoginDetails {
            url: client.homeserver().into(),
            sliding_sync_version,
            supports_oidc_login,
            supported_oidc_prompts,
            supports_sso_login,
            supports_password_login,
        }
    }
}
