//! Calls reach the main thread as event-loop tasks, never as synchronous bridge
//! calls: a resize or drag spins nested loops that would re-enter Dart mid-FFI.

use crate::api::window::WindowSignal;
use crate::frb_generated::StreamSink;
use flutter_rust_bridge::for_generated::SseCodec;
use std::sync::Mutex;

mod link;
#[cfg(target_os = "linux")]
mod linux;
#[cfg(target_os = "macos")]
mod macos;
#[cfg(not(any(target_os = "linux", target_os = "macos", windows)))]
mod unsupported;
#[cfg(windows)]
mod windows;

#[cfg(target_os = "linux")]
pub use linux::*;
#[cfg(target_os = "macos")]
pub use macos::*;
#[cfg(not(any(target_os = "linux", target_os = "macos", windows)))]
pub use unsupported::*;
#[cfg(windows)]
pub use windows::*;

pub use link::listen as listen_links;

static SINK: Mutex<Option<StreamSink<WindowSignal, SseCodec>>> = Mutex::new(None);

pub fn listen(sink: StreamSink<WindowSignal, SseCodec>) {
    *SINK.lock().unwrap_or_else(|poisoned| poisoned.into_inner()) = Some(sink);
    #[cfg(any(target_os = "linux", target_os = "macos"))]
    observe();
}

#[cfg_attr(
    not(any(target_os = "linux", target_os = "macos", windows)),
    allow(dead_code)
)]
fn emit(signal: WindowSignal) {
    if let Some(sink) = SINK
        .lock()
        .unwrap_or_else(|poisoned| poisoned.into_inner())
        .as_ref()
    {
        let _ = sink.add(signal);
    }
}

#[cfg_attr(
    not(any(target_os = "linux", target_os = "macos", windows)),
    allow(dead_code)
)]
const GEOMETRY_SETTLE_MILLISECONDS: u32 = 150;
