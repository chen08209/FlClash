use crate::frb_generated::StreamSink;
use crate::hotkey;
use flutter_rust_bridge::for_generated::SseCodec;
use flutter_rust_bridge::frb;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum HotKeyModifier {
    Alt,
    CapsLock,
    Control,
    Fn,
    Meta,
    Shift,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct HotKeySpec {
    pub id: u32,
    pub key: u32,
    pub modifiers: Vec<HotKeyModifier>,
}

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct HotKeyFailure {
    pub id: u32,
    pub reason: String,
}

#[frb]
pub fn hot_key_events(sink: StreamSink<u32, SseCodec>) -> Result<(), String> {
    hotkey::listen(sink)
}

#[frb]
pub fn set_hot_keys(specs: Vec<HotKeySpec>) -> Result<Vec<HotKeyFailure>, String> {
    hotkey::set_hot_keys(specs)
}
