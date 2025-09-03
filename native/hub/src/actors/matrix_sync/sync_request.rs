use std::time::Duration;

use async_trait::async_trait;
use matrix_sdk::{
    config::SyncSettings,
    ruma::api::client::{error::ErrorKind, filter::FilterDefinition},
};
use messages::prelude::{Context, Notifiable};
use rinf::debug_print;

use crate::{
    actors::matrix_sync::MatrixSync,
    signals::{MatrixProcessSyncResponseRequest, MatrixRefreshTokenRequest, MatrixSyncRequest},
};

#[async_trait]
impl Notifiable<MatrixSyncRequest> for MatrixSync {
    async fn notify(&mut self, msg: MatrixSyncRequest, _: &Context<Self>) {
        // debug_print!("MatrixSyncRequest: sync started {msg:?}");

        match msg {
            MatrixSyncRequest::Init { client, sync_token } => {
                // Enable room members lazy-loading, it will speed up the initial sync a lot
                // with accounts in lots of rooms.
                // See <https://spec.matrix.org/v1.6/client-server-api/#lazy-loading-room-members>.
                let filter = FilterDefinition::with_lazy_loading();

                let mut sync_settings = SyncSettings::default()
                    .filter(filter.into())
                    .timeout(Duration::from_millis(500));

                self.client = Some(client);

                if let Some(ref sync_token) = sync_token {
                    sync_settings = sync_settings.token(sync_token);
                }

                self.emit_sync_request(MatrixSyncRequest::Continue {
                    sync_settings,
                    sync_token,
                });
            }
            MatrixSyncRequest::Continue {
                mut sync_settings,
                sync_token,
            } => {
                let client = match self.client.as_ref() {
                    Some(client) => client,
                    None => {
                        return;
                    }
                };

                let response = match client
                    .sync_once_with_origin_response(sync_settings.clone())
                    .await
                {
                    Ok((response, origin_response)) => Some((response, origin_response)),
                    Err(error) => match error.client_api_error_kind() {
                        Some(ErrorKind::UnknownToken { soft_logout: true }) => {
                            self.emit_logout_request();
                            return;
                        }
                        Some(ErrorKind::UnknownToken { soft_logout: false }) => {
                            self.emit_refresh_token_request(MatrixRefreshTokenRequest {
                                sync_token,
                            });
                            return;
                        }
                        _ => {
                            debug_print!(
                                "MatrixSyncRequest: an error occurred during sync: {error}"
                            );
                            return;
                        }
                    },
                };

                let sync_token = response
                    .as_ref()
                    .map(|(request, _)| request.next_batch.clone());

                if let Some((_, origin_response)) = response {
                    sync_settings = sync_settings.token(origin_response.next_batch.clone());

                    self.emit_process_sync_response_request(
                        MatrixProcessSyncResponseRequest::Response(origin_response),
                    );
                }

                self.emit_sync_request(MatrixSyncRequest::Continue {
                    sync_settings,
                    sync_token,
                });
            }
        };
    }
}
