use matrix_sdk::media::{MediaFormat, MediaThumbnailSettings};
use ruma::media::Method;

/// A const-compatible version of [`MediaFormat`].
#[derive(Clone, Debug)]
pub enum MediaFormatConst {
    /// The file that was uploaded.
    File,
    /// A thumbnail of the file that was uploaded.
    Thumbnail(MediaThumbnailSettingsConst),
}

impl From<MediaFormatConst> for MediaFormat {
    fn from(constant: MediaFormatConst) -> Self {
        match constant {
            MediaFormatConst::File => Self::File,
            MediaFormatConst::Thumbnail(size) => Self::Thumbnail(size.into()),
        }
    }
}

/// A const-compatible version of [`MediaThumbnailSettings`].
#[derive(Clone, Debug)]
pub struct MediaThumbnailSettingsConst {
    /// The desired resizing method.
    pub method: Method,
    /// The desired width of the thumbnail. The actual thumbnail may not match
    /// the size specified.
    pub width: u32,
    /// The desired height of the thumbnail. The actual thumbnail may not match
    /// the size specified.
    pub height: u32,
    /// If we want to request an animated thumbnail from the homeserver.
    ///
    /// If it is `true`, the server should return an animated thumbnail if
    /// the media supports it.
    ///
    /// Defaults to `false`.
    pub animated: bool,
}

impl From<MediaThumbnailSettingsConst> for MediaThumbnailSettings {
    fn from(constant: MediaThumbnailSettingsConst) -> Self {
        Self {
            method: constant.method,
            width: constant.width.into(),
            height: constant.height.into(),
            animated: constant.animated,
        }
    }
}
