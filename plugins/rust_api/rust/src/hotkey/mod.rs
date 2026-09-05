#[cfg(not(target_os = "android"))]
mod keys;
#[cfg(not(target_os = "android"))]
mod owner;
#[cfg(not(target_os = "android"))]
mod service;
#[cfg(target_os = "android")]
mod unsupported;

#[cfg(not(target_os = "android"))]
pub use service::{listen, set_hot_keys};
#[cfg(target_os = "android")]
pub use unsupported::{listen, set_hot_keys};
