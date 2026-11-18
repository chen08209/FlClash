use flutter_rust_bridge::frb;

pub fn is_autostart_enabled(id: String, executable: String) -> bool {
    crate::launch::autostart_enabled(&id, &executable)
}

/// `id` names the registration, the Windows Run value or the Linux autostart
/// file; a Linux session lists the entry under the display name.
pub fn set_autostart(id: String, display_name: String, executable: String, enabled: bool) -> bool {
    crate::launch::set_autostart(&id, &display_name, &executable, enabled)
}

pub fn register_url_scheme(scheme: String, executable: String) -> bool {
    crate::launch::register_url_scheme(&scheme, &executable)
}

#[frb(sync)]
pub fn read_local_machine_dword(key: String, value: String) -> Option<u32> {
    crate::launch::read_local_machine_dword(&key, &value)
}
