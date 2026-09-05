use super::{keys, owner};
use crate::api::hotkey::{HotKeyFailure, HotKeySpec};
use crate::frb_generated::StreamSink;
use flutter_rust_bridge::for_generated::SseCodec;
use global_hotkey::hotkey::HotKey;
use global_hotkey::{GlobalHotKeyEvent, GlobalHotKeyManager, HotKeyState};
use std::collections::BTreeMap;
use std::sync::{Mutex, Once};
use std::thread;

static SINK: Mutex<Option<StreamSink<u32, SseCodec>>> = Mutex::new(None);
static IDS: Mutex<BTreeMap<u32, u32>> = Mutex::new(BTreeMap::new());
static FORWARDER: Once = Once::new();

pub struct Registry {
    manager: Option<GlobalHotKeyManager>,
    registered: Vec<HotKey>,
}

impl Registry {
    pub const fn new() -> Self {
        Self {
            manager: None,
            registered: Vec::new(),
        }
    }

    fn ensure_manager(&mut self) -> Result<&GlobalHotKeyManager, String> {
        if self.manager.is_none() {
            ensure_display()?;
            let manager = GlobalHotKeyManager::new()
                .map_err(|e| format!("Failed to create the hotkey manager: {e}"))?;
            self.manager = Some(manager);
        }
        Ok(self.manager.as_ref().expect("manager was just created"))
    }

    fn replace(&mut self, specs: Vec<HotKeySpec>) -> Result<Vec<HotKeyFailure>, String> {
        let previous = std::mem::take(&mut self.registered);
        let manager = self.ensure_manager()?;
        let _ = manager.unregister_all(&previous);

        let mut ids = BTreeMap::new();
        let mut failures = Vec::new();
        let mut registered = Vec::new();
        for spec in specs {
            let outcome = keys::to_hot_key(&spec).and_then(|hot_key| {
                manager
                    .register(hot_key)
                    .map(|_| hot_key)
                    .map_err(|e| e.to_string())
            });
            match outcome {
                Ok(hot_key) => {
                    ids.insert(hot_key.id(), spec.id);
                    registered.push(hot_key);
                }
                Err(reason) => failures.push(HotKeyFailure {
                    id: spec.id,
                    reason,
                }),
            }
        }
        self.registered = registered;
        *IDS.lock()
            .map_err(|e| format!("Hotkey id lock poisoned: {e}"))? = ids;
        Ok(failures)
    }
}

pub fn listen(sink: StreamSink<u32, SseCodec>) -> Result<(), String> {
    *SINK
        .lock()
        .map_err(|e| format!("Hotkey sink lock poisoned: {e}"))? = Some(sink);
    FORWARDER.call_once(|| {
        let _ = thread::Builder::new()
            .name("hotkey-events".into())
            .spawn(forward_events);
    });
    Ok(())
}

pub fn set_hot_keys(specs: Vec<HotKeySpec>) -> Result<Vec<HotKeyFailure>, String> {
    owner::with_registry(move |registry| registry.replace(specs))?
}

fn forward_events() {
    let receiver = GlobalHotKeyEvent::receiver();
    while let Ok(event) = receiver.recv() {
        if event.state() != HotKeyState::Pressed {
            continue;
        }
        let id = IDS
            .lock()
            .ok()
            .and_then(|ids| ids.get(&event.id()).copied());
        let Some(id) = id else { continue };
        if let Ok(sink) = SINK.lock() {
            if let Some(sink) = sink.as_ref() {
                let _ = sink.add(id);
            }
        }
    }
}

// The X11 backend spawns its own thread and reports a missing display only
// there, so a Wayland session without XWayland would otherwise look registered.
#[cfg(target_os = "linux")]
fn ensure_display() -> Result<(), String> {
    match std::env::var_os("DISPLAY") {
        Some(display) if !display.is_empty() => Ok(()),
        _ => Err("Global hotkeys need an X11 display; DISPLAY is not set".into()),
    }
}

#[cfg(not(target_os = "linux"))]
fn ensure_display() -> Result<(), String> {
    Ok(())
}
