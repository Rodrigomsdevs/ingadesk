use hbb_common::{config, log};
use std::collections::HashMap;

// Embedded at build time so the server and key stay fixed in the shipped binary.
const INGASOFT_JSON: &str = include_str!("../ingasoft.json");

const SERVER_OPTIONS: &[(&str, &str)] = &[
    ("id_server", "custom-rendezvous-server"),
    ("relay_server", "relay-server"),
    ("api_server", "api-server"),
    ("key", "key"),
];

fn parse(json: &str) -> serde_json::Result<HashMap<String, String>> {
    serde_json::from_str(json)
}

pub fn apply() {
    let data = match parse(INGASOFT_JSON) {
        Ok(data) => data,
        Err(e) => {
            log::error!("Failed to parse ingasoft.json: {e}");
            return;
        }
    };
    if let Some(app_name) = data.get("app_name").filter(|v| !v.is_empty()) {
        *config::APP_NAME.write().unwrap() = app_name.to_owned();
    }
    let mut overwrite = config::OVERWRITE_SETTINGS.write().unwrap();
    for (field, option) in SERVER_OPTIONS {
        if let Some(v) = data.get(*field).filter(|v| !v.is_empty()) {
            overwrite.insert(option.to_string(), v.to_owned());
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn bundled_json_parses() {
        let data = parse(INGASOFT_JSON).unwrap();
        assert!(!data.get("app_name").unwrap().is_empty());
    }
}
