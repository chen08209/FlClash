use crate::frb_generated::StreamSink;
use flutter_rust_bridge::for_generated::SseCodec;
use std::sync::{Mutex, MutexGuard};

struct Links {
    sink: Option<StreamSink<String, SseCodec>>,
    pending: Vec<String>,
    seeded: bool,
}

static LINKS: Mutex<Links> = Mutex::new(Links {
    sink: None,
    pending: Vec::new(),
    seeded: false,
});

fn lock() -> MutexGuard<'static, Links> {
    LINKS
        .lock()
        .unwrap_or_else(|poisoned| poisoned.into_inner())
}

pub fn listen(sink: StreamSink<String, SseCodec>) {
    {
        let mut links = lock();
        if !links.seeded {
            links.seeded = true;
            #[cfg(any(windows, target_os = "linux"))]
            {
                let launch = launch_links(std::env::args_os().skip(1));
                links.pending.splice(0..0, launch);
            }
        }
        let pending = std::mem::take(&mut links.pending);
        links.pending = deliver(&sink, pending);
        links.sink = Some(sink);
    }
    #[cfg(any(target_os = "linux", target_os = "macos"))]
    super::observe_links();
}

// A link no listener takes waits for the next one rather than being dropped.
#[cfg_attr(
    not(any(target_os = "linux", target_os = "macos", windows)),
    allow(dead_code)
)]
pub(super) fn push(link: String) {
    let mut links = lock();
    let undelivered = match &links.sink {
        Some(sink) => deliver(sink, vec![link]),
        None => vec![link],
    };
    links.pending.extend(undelivered);
}

fn deliver(sink: &StreamSink<String, SseCodec>, links: Vec<String>) -> Vec<String> {
    let mut links = links.into_iter();
    while let Some(link) = links.next() {
        if sink.add(link.clone()).is_err() {
            return std::iter::once(link).chain(links).collect();
        }
    }
    Vec::new()
}

#[cfg(any(windows, target_os = "linux", test))]
pub(super) fn launch_links(arguments: impl Iterator<Item = std::ffi::OsString>) -> Vec<String> {
    arguments
        .filter_map(|argument| argument.into_string().ok())
        .filter(|argument| argument.contains("://"))
        .collect()
}

#[cfg(test)]
mod tests {
    use super::launch_links;
    use std::ffi::OsString;

    #[test]
    fn only_url_arguments_are_links() {
        let arguments = [
            "--clear-stale-proxy",
            "clash://install-config?url=x",
            "a.yaml",
        ]
        .map(OsString::from)
        .into_iter();
        assert_eq!(
            launch_links(arguments),
            vec!["clash://install-config?url=x".to_owned()]
        );
    }
}
