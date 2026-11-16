use crate::api::tray::{TraySignal, TraySignalKind};
use crate::frb_generated::StreamSink;
use flutter_rust_bridge::for_generated::SseCodec;
use std::sync::{Mutex, PoisonError};

#[cfg(target_os = "linux")]
mod linux;
#[cfg(target_os = "macos")]
mod macos;
#[cfg(not(any(target_os = "linux", target_os = "macos", windows)))]
mod unsupported;
#[cfg(windows)]
mod windows;

#[cfg(target_os = "linux")]
pub use linux::{hide, open_menu, set_title, show};
#[cfg(target_os = "macos")]
pub use macos::{hide, open_menu, set_title, show};
#[cfg(not(any(target_os = "linux", target_os = "macos", windows)))]
pub use unsupported::{hide, open_menu, set_title, show};
#[cfg(windows)]
pub use windows::{hide, open_menu, set_title, show};

static SINK: Mutex<Option<StreamSink<TraySignal, SseCodec>>> = Mutex::new(None);

pub fn listen(sink: StreamSink<TraySignal, SseCodec>) {
    *SINK.lock().unwrap_or_else(PoisonError::into_inner) = Some(sink);
}

#[cfg_attr(
    not(any(target_os = "linux", target_os = "macos", windows)),
    allow(dead_code)
)]
fn emit(kind: TraySignalKind, item_id: u32) {
    if let Some(sink) = SINK.lock().unwrap_or_else(PoisonError::into_inner).as_ref() {
        let _ = sink.add(TraySignal { kind, item_id });
    }
}
