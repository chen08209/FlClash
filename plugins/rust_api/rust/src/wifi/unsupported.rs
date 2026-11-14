use crate::api::wifi::WifiSsidPermission;

pub async fn ssid() -> Result<Option<String>, String> {
    Ok(None)
}

pub async fn check_permission() -> WifiSsidPermission {
    WifiSsidPermission::Granted
}

pub async fn request_permission() -> WifiSsidPermission {
    WifiSsidPermission::Granted
}
