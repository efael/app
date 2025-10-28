use matrix_sdk_ui::eyeball_im::VectorDiff as OriginVectorDiff;
use rinf::SignalPiece;
use serde::Serialize;

use crate::{extensions::iter_await::IterAwait, matrix::room::Room};

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub enum VectorDiffRoom {
    /// Multiple elements were appended.
    Append {
        /// The appended elements.
        values: Vec<Room>,
    },
    /// The vector was cleared.
    Clear,
    /// An element was added at the front.
    PushFront {
        /// The new element.
        value: Room,
    },
    /// An element was added at the back.
    PushBack {
        /// The new element.
        value: Room,
    },
    /// The element at the front was removed.
    PopFront,
    /// The element at the back was removed.
    PopBack,
    /// An element was inserted at the given position.
    Insert {
        /// The index of the new element.
        ///
        /// The element that was previously at that index as well as all the
        /// ones after it were shifted to the right.
        index: u64,
        /// The new element.
        value: Room,
    },
    /// A replacement of the previous value at the given position.
    Set {
        /// The index of the element that was replaced.
        index: u64,
        /// The new element.
        value: Room,
    },
    /// Removal of an element.
    Remove {
        /// The index that the removed element had.
        index: u64,
    },
    /// Truncation of the vector.
    Truncate {
        /// The number of elements that remain.
        length: u64,
    },
    /// The subscriber lagged too far behind, and the next update that should
    /// have been received has already been discarded from the internal buffer.
    Reset {
        /// The full list of elements.
        values: Vec<Room>,
    },
}

impl VectorDiffRoom {
    pub async fn from_sdk(value: OriginVectorDiff<matrix_sdk::Room>) -> Self {
        match value {
            OriginVectorDiff::Append { values } => Self::Append {
                values: IterAwait::new(values.into_iter().map(Room::from_sdk_room))
                    .join_all_sorted()
                    .await,
            },
            OriginVectorDiff::Clear => Self::Clear,
            OriginVectorDiff::PushFront { value } => Self::PushFront {
                value: Room::from_sdk_room(value).await,
            },
            OriginVectorDiff::PushBack { value } => Self::PushBack {
                value: Room::from_sdk_room(value).await,
            },
            OriginVectorDiff::PopFront => Self::PopFront,
            OriginVectorDiff::PopBack => Self::PopBack,
            OriginVectorDiff::Insert { index, value } => Self::Insert {
                index: Usize::from(index).into(),
                value: Room::from_sdk_room(value).await,
            },
            OriginVectorDiff::Set { index, value } => Self::Set {
                index: Usize::from(index).into(),
                value: Room::from_sdk_room(value).await,
            },
            OriginVectorDiff::Remove { index } => Self::Remove {
                index: Usize::from(index).into(),
            },
            OriginVectorDiff::Truncate { length } => Self::Truncate {
                length: Usize::from(length).into(),
            },
            OriginVectorDiff::Reset { values } => Self::Reset {
                values: IterAwait::new(values.into_iter().map(Room::from_sdk_room))
                    .join_all_sorted()
                    .await,
            },
        }
    }
}

struct Usize(usize);

impl From<usize> for Usize {
    fn from(value: usize) -> Self {
        Self(value)
    }
}

impl From<Usize> for u64 {
    fn from(value: Usize) -> Self {
        value.0.try_into().expect("should convert to u64")
    }
}
