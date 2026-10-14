#[cfg(not(target_os = "android"))]
mod access;
#[cfg(not(target_os = "android"))]
mod frame;
#[cfg(not(target_os = "android"))]
mod outbox;
#[cfg(not(target_os = "android"))]
mod server;
#[cfg(target_os = "android")]
mod unsupported;

#[cfg(not(target_os = "android"))]
pub use server::Server;
#[cfg(target_os = "android")]
pub use unsupported::Server;

#[cfg_attr(target_os = "android", allow(dead_code))]
#[derive(Debug, PartialEq, Eq)]
pub enum Event {
    Connected { pid: Option<u32> },
    Message(Vec<u8>),
    Disconnected { error: Option<String> },
    Failed(String),
}

/// Returns false once nobody listens any more, which ends the server.
pub type EventSink = Box<dyn Fn(Event) -> bool + Send>;
