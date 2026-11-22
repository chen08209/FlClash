use crate::api::tray::TrayContent;

// Android has no status item; these entry points exist only so that one set
// of bindings serves every platform.
pub fn show(_content: TrayContent) -> Result<(), String> {
    Err("this platform has no tray".into())
}

pub fn set_title(_title: String) -> bool {
    false
}

pub fn hide() {}

pub fn open_menu() -> bool {
    false
}
