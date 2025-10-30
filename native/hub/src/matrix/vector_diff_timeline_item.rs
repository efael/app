use matrix_sdk_ui::eyeball_im::{Vector, VectorDiff as OriginVectorDiff};
use rinf::SignalPiece;
use serde::Serialize;

use crate::{extensions::usize::Usize, matrix::timeline::TimelineItem};

#[derive(Debug, Clone, Serialize, SignalPiece)]
pub enum VectorDiffTimelineItem {
    /// Multiple elements were appended.
    Append {
        /// The appended elements.
        values: Vec<TimelineItem>,
    },
    /// The vector was cleared.
    Clear,
    /// An element was added at the front.
    PushFront {
        /// The new element.
        value: TimelineItem,
    },
    /// An element was added at the back.
    PushBack {
        /// The new element.
        value: TimelineItem,
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
        value: TimelineItem,
    },
    /// A replacement of the previous value at the given position.
    Set {
        /// The index of the element that was replaced.
        index: u64,
        /// The new element.
        value: TimelineItem,
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
        values: Vec<TimelineItem>,
    },
}

impl VectorDiffTimelineItem {
    pub async fn from_sdk(value: OriginVectorDiff<TimelineItem>) -> Self {
        match value {
            OriginVectorDiff::Append { values } => Self::Append {
                values: values.into_iter().collect(),
            },
            OriginVectorDiff::Clear => Self::Clear,
            OriginVectorDiff::PushFront { value } => Self::PushFront { value },
            OriginVectorDiff::PushBack { value } => Self::PushBack { value },
            OriginVectorDiff::PopFront => Self::PopFront,
            OriginVectorDiff::PopBack => Self::PopBack,
            OriginVectorDiff::Insert { index, value } => Self::Insert {
                index: Usize::from(index).into(),
                value,
            },
            OriginVectorDiff::Set { index, value } => Self::Set {
                index: Usize::from(index).into(),
                value,
            },
            OriginVectorDiff::Remove { index } => Self::Remove {
                index: Usize::from(index).into(),
            },
            OriginVectorDiff::Truncate { length } => Self::Truncate {
                length: Usize::from(length).into(),
            },
            OriginVectorDiff::Reset { values } => Self::Reset {
                values: values.into_iter().collect(),
            },
        }
    }

    pub fn apply(self, vec: &mut Vector<TimelineItem>) {
        match self {
            Self::Append { values } => {
                vec.append(values.into());
            }
            Self::Clear => {
                vec.clear();
            }
            Self::PushFront { value } => {
                vec.push_front(value);
            }
            Self::PushBack { value } => {
                vec.push_back(value);
            }
            Self::PopFront => {
                vec.pop_front();
            }
            Self::PopBack => {
                vec.pop_back();
            }
            Self::Insert { index, value } => {
                vec.insert(index.try_into().unwrap(), value);
            }
            Self::Set { index, value } => {
                vec.set(index.try_into().unwrap(), value);
            }
            Self::Remove { index } => {
                vec.remove(index.try_into().unwrap());
            }
            Self::Truncate { length } => {
                vec.truncate(length.try_into().unwrap());
            }
            Self::Reset { values } => {
                *vec = values.into();
            }
        }
    }
}
