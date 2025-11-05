use rinf::SignalPiece;
use serde::{Deserialize, Serialize};


#[derive(Clone, Debug, Serialize, Deserialize, SignalPiece)]
pub enum TimelinePagination {
    Backwards,
    Forwards,
}