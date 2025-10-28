use matrix_sdk::RoomInfo as SdkRoomInfo;

pub struct RoomInfo {}

impl From<SdkRoomInfo> for RoomInfo {
    fn from(value: SdkRoomInfo) -> Self {
        todo!()
    }
}
