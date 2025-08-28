use matrix_sdk::sliding_sync::Version as SdkSlidingSyncVersion;
use rinf::SignalPiece;
use serde::Serialize;

#[derive(Serialize, SignalPiece, Debug)]
pub enum SlidingSyncVersion {
    None,
    Native,
}

impl From<SdkSlidingSyncVersion> for SlidingSyncVersion {
    fn from(value: SdkSlidingSyncVersion) -> Self {
        match value {
            SdkSlidingSyncVersion::None => Self::None,
            SdkSlidingSyncVersion::Native => Self::Native,
        }
    }
}

impl TryFrom<SlidingSyncVersion> for SdkSlidingSyncVersion {
    type Error = ();

    fn try_from(value: SlidingSyncVersion) -> Result<Self, Self::Error> {
        Ok(match value {
            SlidingSyncVersion::None => Self::None,
            SlidingSyncVersion::Native => Self::Native,
        })
    }
}
