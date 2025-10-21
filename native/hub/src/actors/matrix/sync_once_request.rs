use std::ops::Deref;

use async_trait::async_trait;
use matrix_sdk::{Error, HttpError, RumaApiError};
use messages::prelude::{Context, Notifiable};
use rinf::debug_print;
use ruma::api::error::FromHttpResponseError;

use crate::{
    actors::matrix::Matrix,
    matrix::sync,
    signals::{
        MatrixListChatsRequest, MatrixLogoutRequest, MatrixSessionVerificationRequest,
        MatrixSyncBackgroundRequest, MatrixSyncCompleted, MatrixSyncOnceRequest,
    },
};

#[async_trait]
impl Notifiable<MatrixSyncOnceRequest> for Matrix {
    async fn notify(&mut self, msg: MatrixSyncOnceRequest, _: &Context<Self>) {
        let client = match self.client.as_mut() {
            Some(client) => client,
            None => {
                debug_print!("MatrixSyncServiceRequest: client is not initialized");
                return;
            }
        };

        debug_print!("[sync-once] starting - {:?}", msg.sync_token);
        let settings = sync::build_sync_settings(msg.sync_token);

        for attempt in 0..10 {
            match client.sync_once(settings.clone()).await {
                Ok(response) => {
                    debug_print!("[sync-once] next batch - {}", response.next_batch);

                    self.emit(MatrixSyncCompleted {
                        next_batch: response.next_batch,
                    });

                    self.emit(MatrixSyncBackgroundRequest::Start);
                    self.emit(MatrixListChatsRequest {
                        url: "".to_string(),
                    });
                    // self.emit(MatrixSessionVerificationRequest::Start);

                    return;
                }
                Err(error) => {
                    // 401 token expired
                    if let Error::Http(http_error) = &error
                        && let HttpError::Api(server) = http_error.deref()
                        && let FromHttpResponseError::Server(RumaApiError::ClientApi(ruma_error)) =
                            server.deref()
                        && ruma_error.status_code.eq(&401)
                    {
                        // do something
                        debug_print!("[sync-once] token expired");
                        return;
                    }

                    if let Error::Http(http_error) = &error
                        && let HttpError::RefreshToken(refresh_token_error) = http_error.deref()
                    {
                        debug_print!("refresh token error, {refresh_token_error:?}");
                        match refresh_token_error {
                            matrix_sdk::RefreshTokenError::RefreshTokenRequired => {
                                debug_print!("refresh token required")
                            }
                            matrix_sdk::RefreshTokenError::MatrixAuth(http_error) => {
                                debug_print!("matrix auth {http_error:?}")
                            }
                            matrix_sdk::RefreshTokenError::OAuth(oauth_error) => {
                                debug_print!("oauth {oauth_error:?}")
                            }
                        };

                        self.emit(MatrixLogoutRequest {});

                        return;
                    }

                    debug_print!(
                        "[sync-once] An error occurred during initial sync, attempt {attempt}: {error}"
                    );
                }
            }
        }
    }
}
