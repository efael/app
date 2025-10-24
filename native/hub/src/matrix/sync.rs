use std::time::Duration;

use matrix_sdk::config::SyncSettings;
use ruma::api::client::filter::{FilterDefinition, LazyLoadOptions, RoomEventFilter, RoomFilter};

pub fn build_sync_settings(sync_token: Option<String>) -> SyncSettings {
    let mut state_filter = RoomEventFilter::empty();
    state_filter.lazy_load_options = LazyLoadOptions::Enabled {
        include_redundant_members: false,
    };

    let mut room_filter = RoomFilter::empty();
    room_filter.state = state_filter;

    let mut filter = FilterDefinition::empty();
    filter.room = room_filter;

    let mut sync_settings = SyncSettings::default()
        .filter(filter.into())
        .timeout(Duration::from_secs(3));

    if let Some(token) = sync_token {
        sync_settings = sync_settings.token(token);
    }

    sync_settings
}

