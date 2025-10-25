use rinf::SignalPiece;
use ruma::media::Method;
use serde::{Deserialize, Serialize};

use crate::matrix::media::{MediaFormatConst, MediaThumbnailSettingsConst};

#[derive(Clone, Serialize, Deserialize, SignalPiece)]
pub enum RoomPreviewAvatar {
    Text(String),
    Image(Vec<u8>),
}

impl Default for RoomPreviewAvatar {
    fn default() -> Self {
        RoomPreviewAvatar::Text(String::from("?"))
    }
}

impl std::fmt::Debug for RoomPreviewAvatar {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            RoomPreviewAvatar::Text(text) => f.debug_tuple("Text").field(text).finish(),
            RoomPreviewAvatar::Image(_) => f.debug_tuple("Image").finish(),
        }
    }
}

pub const AVATAR_THUMBNAIL_FORMAT: MediaFormatConst = MediaFormatConst::Thumbnail(
    MediaThumbnailSettingsConst {
        method: Method::Scale,
        width: 40,
        height: 40,
        animated: false,
    }
);