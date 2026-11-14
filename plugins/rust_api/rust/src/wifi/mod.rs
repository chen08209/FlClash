#[cfg(target_os = "linux")]
mod linux;
#[cfg(target_os = "macos")]
mod macos;
#[cfg(any(target_os = "linux", test))]
mod nmcli;
#[cfg(not(any(target_os = "linux", target_os = "macos", windows)))]
mod unsupported;
#[cfg(windows)]
mod windows;

#[cfg(target_os = "linux")]
pub use linux::{check_permission, request_permission, ssid};
#[cfg(target_os = "macos")]
pub use macos::{check_permission, request_permission, ssid};
#[cfg(not(any(target_os = "linux", target_os = "macos", windows)))]
pub use unsupported::{check_permission, request_permission, ssid};
#[cfg(windows)]
pub use windows::{check_permission, request_permission, ssid};

#[cfg(any(target_os = "linux", target_os = "macos"))]
fn non_empty(ssid: Option<String>) -> Option<String> {
    ssid.filter(|ssid| !ssid.is_empty())
}
