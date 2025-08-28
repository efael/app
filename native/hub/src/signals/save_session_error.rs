use std::fmt::Display;

#[derive(Debug)]
pub enum SaveSessionError {
    Serialize(serde_json::Error),
    Save(std::io::Error),
}

impl Display for SaveSessionError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        let str = match self {
            SaveSessionError::Serialize(error) => error.to_string(),
            SaveSessionError::Save(error) => error.to_string(),
        };

        write!(f, "{str}")
    }
}
