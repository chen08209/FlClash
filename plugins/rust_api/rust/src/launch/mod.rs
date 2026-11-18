#[cfg(any(windows, test))]
#[cfg_attr(not(windows), allow(dead_code))]
mod entries;
#[cfg(any(target_os = "linux", all(test, unix)))]
#[cfg_attr(not(target_os = "linux"), allow(dead_code))]
mod linux;
#[cfg(target_os = "macos")]
mod macos;
#[cfg(windows)]
mod windows;

#[cfg(target_os = "linux")]
use linux as platform;
#[cfg(target_os = "macos")]
use macos as platform;
#[cfg(windows)]
use windows as platform;

#[cfg(not(any(target_os = "linux", target_os = "macos", windows)))]
mod platform {
    pub fn autostart_enabled(_id: &str, _executable: &str) -> bool {
        false
    }

    pub fn set_autostart(
        _id: &str,
        _display_name: &str,
        _executable: &str,
        _enabled: bool,
    ) -> bool {
        false
    }
}

pub fn autostart_enabled(id: &str, executable: &str) -> bool {
    platform::autostart_enabled(id, executable)
}

pub fn set_autostart(id: &str, display_name: &str, executable: &str, enabled: bool) -> bool {
    platform::set_autostart(id, display_name, executable, enabled)
}

pub fn register_url_scheme(scheme: &str, executable: &str) -> bool {
    #[cfg(windows)]
    return windows::register_url_scheme(scheme, executable);
    #[cfg(not(windows))]
    {
        let _ = (scheme, executable);
        false
    }
}

pub fn read_local_machine_dword(key: &str, value: &str) -> Option<u32> {
    #[cfg(windows)]
    return windows::read_local_machine_dword(key, value);
    #[cfg(not(windows))]
    {
        let _ = (key, value);
        None
    }
}
