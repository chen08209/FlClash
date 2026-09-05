#[cfg(not(target_os = "android"))]
mod frame;
#[cfg(not(target_os = "android"))]
mod platform;
#[cfg(not(target_os = "android"))]
mod queue;
#[cfg(not(target_os = "android"))]
mod server;
#[cfg(target_os = "android")]
mod unsupported;

#[cfg(not(target_os = "android"))]
pub use server::{restart_server, send_message, stop_server};
#[cfg(target_os = "android")]
pub use unsupported::{restart_server, send_message, stop_server};
