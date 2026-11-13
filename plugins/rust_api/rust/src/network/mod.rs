#[cfg(target_os = "linux")]
mod linux;
#[cfg(target_os = "macos")]
mod macos;
#[cfg(any(target_os = "linux", test))]
#[cfg_attr(not(target_os = "linux"), allow(dead_code))]
mod netlink;
#[cfg(any(target_os = "linux", test))]
#[cfg_attr(not(target_os = "linux"), allow(dead_code))]
mod procfs;
#[cfg(windows)]
mod windows;

use std::sync::mpsc::{self, Receiver, RecvTimeoutError, Sender};
use std::sync::{Mutex, OnceLock};
use std::time::{Duration, Instant};

use flutter_rust_bridge::for_generated::SseCodec;

use crate::api::network::NetworkState;
use crate::frb_generated::StreamSink;

/// One switch reaches the OS as a burst of interface, address and route
/// notifications. Kept short because a late report leaves the Core resolving
/// with the old network's DNS cache, while an extra one costs only a cache
/// clear: a staged Linux reconnect (link, DHCP, router advertisement) may
/// report once per stage.
const QUIET: Duration = Duration::from_millis(300);
const MAX_DELAY: Duration = Duration::from_secs(1);

enum Signal {
    Listen,
    Changed,
}

static SINK: Mutex<Option<StreamSink<NetworkState, SseCodec>>> = Mutex::new(None);
static SIGNALS: OnceLock<Option<Sender<Signal>>> = OnceLock::new();

pub fn listen(sink: StreamSink<NetworkState, SseCodec>) {
    if let Ok(mut current) = SINK.lock() {
        *current = Some(sink);
    }
    if let Some(signals) = SIGNALS.get_or_init(start) {
        let _ = signals.send(Signal::Listen);
    }
}

#[cfg_attr(
    not(any(target_os = "linux", target_os = "macos", windows)),
    allow(dead_code)
)]
#[derive(Clone)]
pub struct Notifier(Sender<Signal>);

impl Notifier {
    pub fn changed(&self) {
        let _ = self.0.send(Signal::Changed);
    }
}

fn start() -> Option<Sender<Signal>> {
    let (sender, receiver) = mpsc::channel();
    #[cfg(any(target_os = "linux", target_os = "macos", windows))]
    platform::watch(Notifier(sender.clone()));
    std::thread::Builder::new()
        .name("network-watch".to_owned())
        .spawn(move || run(receiver))
        .ok()?;
    Some(sender)
}

fn run(receiver: Receiver<Signal>) {
    while let Ok(signal) = receiver.recv() {
        if matches!(signal, Signal::Changed) && !settle(&receiver, QUIET, MAX_DELAY) {
            return;
        }
        let Some(state) = platform::state() else {
            continue;
        };
        if let Ok(sink) = SINK.lock() {
            if let Some(sink) = sink.as_ref() {
                let _ = sink.add(state);
            }
        }
    }
}

/// Waits until `quiet` passes without a signal, or `max` since the first one;
/// false once every sender is gone.
fn settle(receiver: &Receiver<Signal>, quiet: Duration, max: Duration) -> bool {
    let deadline = Instant::now() + max;
    loop {
        let wait = quiet.min(deadline.saturating_duration_since(Instant::now()));
        if wait.is_zero() {
            return true;
        }
        match receiver.recv_timeout(wait) {
            Ok(_) => {}
            Err(RecvTimeoutError::Timeout) => return true,
            Err(RecvTimeoutError::Disconnected) => return false,
        }
    }
}

#[cfg(any(target_os = "linux", target_os = "macos", windows))]
mod platform {
    #[cfg(target_os = "linux")]
    pub use super::linux::{state, watch};
    #[cfg(target_os = "macos")]
    pub use super::macos::{state, watch};
    #[cfg(windows)]
    pub use super::windows::{state, watch};
}

#[cfg(not(any(target_os = "linux", target_os = "macos", windows)))]
mod platform {
    pub fn state() -> Option<super::NetworkState> {
        None
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn settles_once_the_burst_goes_quiet() {
        let (sender, receiver) = mpsc::channel();
        let started = Instant::now();
        let burst = std::thread::spawn(move || {
            for _ in 0..5 {
                sender.send(Signal::Changed).unwrap();
                std::thread::sleep(Duration::from_millis(20));
            }
            sender
        });
        assert!(settle(
            &receiver,
            Duration::from_millis(80),
            Duration::from_secs(5)
        ));
        let elapsed = started.elapsed();
        assert!(elapsed >= Duration::from_millis(160), "{elapsed:?}");
        drop(burst.join());
    }

    #[test]
    fn a_burst_that_never_stops_settles_at_the_cap() {
        let (sender, receiver) = mpsc::channel();
        let stop = std::sync::Arc::new(std::sync::atomic::AtomicBool::new(false));
        let flag = stop.clone();
        let burst = std::thread::spawn(move || {
            while !flag.load(std::sync::atomic::Ordering::Relaxed) {
                let _ = sender.send(Signal::Changed);
                std::thread::sleep(Duration::from_millis(10));
            }
        });
        let started = Instant::now();
        assert!(settle(
            &receiver,
            Duration::from_millis(50),
            Duration::from_millis(200)
        ));
        assert!(started.elapsed() < Duration::from_millis(400));
        stop.store(true, std::sync::atomic::Ordering::Relaxed);
        burst.join().unwrap();
    }

    #[test]
    fn stops_when_the_watchers_are_gone() {
        let (sender, receiver) = mpsc::channel::<Signal>();
        drop(sender);
        assert!(!settle(
            &receiver,
            Duration::from_millis(50),
            Duration::from_secs(1)
        ));
    }
}
