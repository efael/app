use std::ops::Deref;

use async_trait::async_trait;
use matrix_sdk::{Error, HttpError};
use messages::prelude::{Context, Notifiable};

use crate::{
    actors::matrix::Matrix,
    matrix::sync,
    signals::{
        MatrixListChatsRequest, MatrixLogoutRequest, MatrixSyncCompleted, MatrixSyncOnceRequest,
    },
};

#[async_trait]
impl Notifiable<MatrixSyncOnceRequest> for Matrix {
    #[tracing::instrument(skip(self))]
    async fn notify(&mut self, msg: MatrixSyncOnceRequest, _: &Context<Self>) {
        let Some(client) = self.client.as_ref() else {
            tracing::error!("client is not initialized");
            return;
        };

        tracing::trace!("starting - {:?}", msg.sync_token);
        let settings = sync::build_sync_settings(msg.sync_token);

        for attempt in 0..10 {
            match client.sync_once(settings.clone()).await {
                Ok(response) => {
                    tracing::trace!("next batch - {}", response.next_batch);

                    self.emit(MatrixSyncCompleted {
                        next_batch: response.next_batch,
                    });

                    // self.emit(MatrixSyncBackgroundRequest::Start);
                    self.emit(MatrixListChatsRequest {
                        url: "".to_string(),
                    });
                    // self.emit(MatrixSessionVerificationRequest::Start);

                    return;
                }
                Err(error) => {
                    if let Error::Http(http_error) = &error
                        && let HttpError::RefreshToken(refresh_token_error) = http_error.deref()
                    {
                        tracing::error!("refresh token error, {refresh_token_error:?}");
                        match refresh_token_error {
                            matrix_sdk::RefreshTokenError::RefreshTokenRequired => {
                                tracing::error!("refresh token required")
                            }
                            matrix_sdk::RefreshTokenError::MatrixAuth(http_error) => {
                                tracing::error!("matrix auth {http_error:?}")
                            }
                            matrix_sdk::RefreshTokenError::OAuth(oauth_error) => {
                                tracing::error!("oauth {oauth_error:?}")
                            }
                        };

                        self.emit(MatrixLogoutRequest {});

                        return;
                    }

                    tracing::error!(error = %error, "an error occurred during initial sync, attempt {attempt}");
                }
            }
        }
    }
}
