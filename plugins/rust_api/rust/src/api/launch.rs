use flutter_rust_bridge::frb;

pub fn is_autostart_enabled(name: String, executable: String) -> bool {
    crate::launch::autostart_enabled(&name, &executable)
}

pub fn set_autostart(name: String, executable: String, enabled: bool) -> bool {
    crate::launch::set_autostart(&name, &executable, enabled)
}

pub fn register_url_scheme(scheme: String, executable: String) -> bool {
    crate::launch::register_url_scheme(&scheme, &executable)
}

#[frb(sync)]
pub fn read_local_machine_dword(key: String, value: String) -> Option<u32> {
    crate::launch::read_local_machine_dword(&key, &value)
}
