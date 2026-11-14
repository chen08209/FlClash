#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum WifiSsidPermission {
    Granted,
    Denied,
    PermanentlyDenied,
}

pub async fn current_wifi_ssid() -> Result<Option<String>, String> {
    crate::wifi::ssid().await
}

pub async fn check_wifi_ssid_permission() -> WifiSsidPermission {
    crate::wifi::check_permission().await
}

pub async fn request_wifi_ssid_permission() -> WifiSsidPermission {
    crate::wifi::request_permission().await
}
