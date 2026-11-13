use std::collections::HashMap;
use std::ffi::c_void;
use std::mem::{size_of, zeroed};
use std::ptr::{null, null_mut};
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::{Mutex, MutexGuard, Once};
use std::time::Duration;

use windows_sys::core::PWSTR;
use windows_sys::Win32::Foundation::{
    GlobalFree, ERROR_INSUFFICIENT_BUFFER, ERROR_SUCCESS, HWND, LPARAM, LRESULT, NO_ERROR, WPARAM,
};
use windows_sys::Win32::NetworkManagement::IpHelper::{
    GetExtendedTcpTable, MIB_TCP6ROW_OWNER_PID, MIB_TCPROW_OWNER_PID, TCP_TABLE_OWNER_PID_LISTENER,
};
use windows_sys::Win32::NetworkManagement::Rras::{
    RasEnumEntriesW, ERROR_BUFFER_TOO_SMALL, RASENTRYNAMEW,
};
use windows_sys::Win32::Networking::WinInet::{
    InternetQueryOptionW, InternetSetOptionW, INTERNET_OPTION_PER_CONNECTION_OPTION,
    INTERNET_OPTION_REFRESH, INTERNET_OPTION_SETTINGS_CHANGED, INTERNET_PER_CONN_AUTOCONFIG_URL,
    INTERNET_PER_CONN_FLAGS, INTERNET_PER_CONN_OPTIONW, INTERNET_PER_CONN_OPTIONW_0,
    INTERNET_PER_CONN_OPTION_LISTW, INTERNET_PER_CONN_PROXY_BYPASS, INTERNET_PER_CONN_PROXY_SERVER,
    PROXY_TYPE_AUTO_PROXY_URL, PROXY_TYPE_DIRECT, PROXY_TYPE_PROXY,
};
use windows_sys::Win32::Networking::WinSock::{AF_INET, AF_INET6};
use windows_sys::Win32::System::LibraryLoader::GetModuleHandleW;
use windows_sys::Win32::UI::WindowsAndMessaging::{
    CreateWindowExW, DefWindowProcW, DispatchMessageW, GetMessageW, RegisterClassW,
    TranslateMessage, MSG, WM_ENDSESSION, WNDCLASSW,
};

use super::wininet::{bypass_list, local_pac_port, local_proxy_port};
use super::{Target, PROXY_HOST};

static APPLIED: AtomicBool = AtomicBool::new(false);
static SETTINGS: Mutex<()> = Mutex::new(());

pub fn start(target: &Target) -> bool {
    watch_session_end();
    let _settings = lock_settings();
    // A start that reports failure can still have written the setting.
    APPLIED.store(true, Ordering::SeqCst);
    match target {
        Target::Manual {
            port,
            bypass_domain,
        } => {
            let mut server = wide(&format!("{PROXY_HOST}:{port}"));
            let mut bypass = wide(&bypass_list(bypass_domain));
            apply_to_connections(&mut [
                flags_option(PROXY_TYPE_DIRECT | PROXY_TYPE_PROXY),
                string_option(INTERNET_PER_CONN_PROXY_SERVER, server.as_mut_ptr()),
                string_option(INTERNET_PER_CONN_PROXY_BYPASS, bypass.as_mut_ptr()),
            ])
        }
        Target::Pac { url } => {
            let mut url = wide(url);
            apply_to_connections(&mut [
                flags_option(PROXY_TYPE_DIRECT | PROXY_TYPE_AUTO_PROXY_URL),
                string_option(INTERNET_PER_CONN_AUTOCONFIG_URL, url.as_mut_ptr()),
            ])
        }
    }
}

pub fn stop() -> bool {
    let _settings = lock_settings();
    stop_locked()
}

fn stop_locked() -> bool {
    let stopped = apply_to_connections(&mut [flags_option(PROXY_TYPE_DIRECT)]);
    if stopped {
        APPLIED.store(false, Ordering::SeqCst);
    }
    stopped
}

/// Clears a `127.0.0.1:<port>` proxy or PAC URL that nothing listens behind. The
/// installer and uninstaller call it after killing the app, whose exit path is
/// what normally turns the system proxy off.
fn clear_stale() -> bool {
    let _settings = lock_settings();
    let mut released = HashMap::new();
    let cleared =
        for_each_connection(|connection| clear_stale_for_connection(connection, &mut released));
    let notified = notify_settings_changed();
    cleared && notified
}

#[no_mangle]
pub extern "C" fn flclash_clear_stale_proxy() -> bool {
    clear_stale()
}

fn lock_settings() -> MutexGuard<'static, ()> {
    SETTINGS
        .lock()
        .unwrap_or_else(|poisoned| poisoned.into_inner())
}

fn wide(value: &str) -> Vec<u16> {
    value.encode_utf16().chain(std::iter::once(0)).collect()
}

fn flags_option(flags: u32) -> INTERNET_PER_CONN_OPTIONW {
    INTERNET_PER_CONN_OPTIONW {
        dwOption: INTERNET_PER_CONN_FLAGS,
        Value: INTERNET_PER_CONN_OPTIONW_0 { dwValue: flags },
    }
}

fn string_option(kind: u32, value: PWSTR) -> INTERNET_PER_CONN_OPTIONW {
    INTERNET_PER_CONN_OPTIONW {
        dwOption: kind,
        Value: INTERNET_PER_CONN_OPTIONW_0 { pszValue: value },
    }
}

fn option_list(
    connection: PWSTR,
    options: &mut [INTERNET_PER_CONN_OPTIONW],
) -> INTERNET_PER_CONN_OPTION_LISTW {
    INTERNET_PER_CONN_OPTION_LISTW {
        dwSize: size_of::<INTERNET_PER_CONN_OPTION_LISTW>() as u32,
        pszConnection: connection,
        dwOptionCount: options.len() as u32,
        dwOptionError: 0,
        pOptions: options.as_mut_ptr(),
    }
}

fn set_options(connection: PWSTR, options: &mut [INTERNET_PER_CONN_OPTIONW]) -> bool {
    let list = option_list(connection, options);
    unsafe {
        InternetSetOptionW(
            null(),
            INTERNET_OPTION_PER_CONNECTION_OPTION,
            (&list as *const INTERNET_PER_CONN_OPTION_LISTW).cast(),
            size_of::<INTERNET_PER_CONN_OPTION_LISTW>() as u32,
        ) != 0
    }
}

fn apply_to_connections(options: &mut [INTERNET_PER_CONN_OPTIONW]) -> bool {
    let applied = for_each_connection(|connection| set_options(connection, options));
    let notified = notify_settings_changed();
    applied && notified
}

fn notify_settings_changed() -> bool {
    let changed =
        unsafe { InternetSetOptionW(null(), INTERNET_OPTION_SETTINGS_CHANGED, null(), 0) != 0 };
    let refreshed = unsafe { InternetSetOptionW(null(), INTERNET_OPTION_REFRESH, null(), 0) != 0 };
    changed && refreshed
}

/// The LAN settings, then every dial-up and VPN entry, each of which keeps
/// its own proxy configuration.
fn for_each_connection(mut visit: impl FnMut(PWSTR) -> bool) -> bool {
    let mut success = visit(null_mut());
    let mut size = 0u32;
    let mut count = 0u32;
    let ret = unsafe { RasEnumEntriesW(null(), null(), null_mut(), &mut size, &mut count) };
    if ret == ERROR_BUFFER_TOO_SMALL && count > 0 {
        let entry_size = size_of::<RASENTRYNAMEW>();
        let len = (count as usize).max((size as usize).div_ceil(entry_size));
        let mut entries = vec![
            RASENTRYNAMEW {
                dwSize: entry_size as u32,
                ..Default::default()
            };
            len
        ];
        size = (len * entry_size) as u32;
        let ret =
            unsafe { RasEnumEntriesW(null(), null(), entries.as_mut_ptr(), &mut size, &mut count) };
        if ret == ERROR_SUCCESS {
            for entry in entries.iter_mut().take(count as usize) {
                success = visit(entry.szEntryName.as_mut_ptr()) && success;
            }
        } else {
            success = false;
        }
    } else if ret != ERROR_SUCCESS {
        success = false;
    }
    success
}

fn clear_stale_for_connection(connection: PWSTR, released: &mut HashMap<u16, bool>) -> bool {
    let mut options = [
        flags_option(0),
        string_option(INTERNET_PER_CONN_PROXY_SERVER, null_mut()),
        string_option(INTERNET_PER_CONN_AUTOCONFIG_URL, null_mut()),
    ];
    let mut list = option_list(connection, &mut options);
    let mut size = size_of::<INTERNET_PER_CONN_OPTION_LISTW>() as u32;
    let queried = unsafe {
        InternetQueryOptionW(
            null(),
            INTERNET_OPTION_PER_CONNECTION_OPTION,
            (&mut list as *mut INTERNET_PER_CONN_OPTION_LISTW).cast(),
            &mut size,
        ) != 0
    };
    if !queried {
        return false;
    }
    let flags = unsafe { options[0].Value.dwValue };
    let server = unsafe { take_global_string(options[1].Value.pszValue) };
    let pac_url = unsafe { take_global_string(options[2].Value.pszValue) };
    let mut is_released = |port: u16| {
        *released
            .entry(port)
            .or_insert_with(|| is_port_released(port))
    };
    let mut cleared = flags;
    if flags & PROXY_TYPE_PROXY != 0 && local_proxy_port(&server).is_some_and(&mut is_released) {
        cleared &= !PROXY_TYPE_PROXY;
    }
    if flags & PROXY_TYPE_AUTO_PROXY_URL != 0
        && local_pac_port(&pac_url).is_some_and(&mut is_released)
    {
        cleared &= !PROXY_TYPE_AUTO_PROXY_URL;
    }
    if cleared == flags {
        return true;
    }
    set_options(connection, &mut [flags_option(cleared | PROXY_TYPE_DIRECT)])
}

unsafe fn take_global_string(value: PWSTR) -> String {
    if value.is_null() {
        return String::new();
    }
    let mut len = 0;
    while *value.add(len) != 0 {
        len += 1;
    }
    let text = String::from_utf16_lossy(std::slice::from_raw_parts(value, len));
    GlobalFree(value.cast());
    text
}

/// `taskkill /f` returns once TerminateProcess has been issued, which is
/// before the killed Core has released its listening socket.
fn is_port_released(port: u16) -> bool {
    for _ in 0..20 {
        if !is_port_listening(port) {
            return true;
        }
        std::thread::sleep(Duration::from_millis(100));
    }
    false
}

/// A lookup that fails counts as listening, so a live proxy is never cleared.
fn is_port_listening(port: u16) -> bool {
    [AF_INET, AF_INET6]
        .into_iter()
        .any(|family| has_listener(u32::from(family), port).unwrap_or(true))
}

fn has_listener(family: u32, port: u16) -> Option<bool> {
    // u32 words keep the table's rows aligned.
    let mut buffer: Vec<u32> = Vec::new();
    let mut size = 0u32;
    let mut result = ERROR_INSUFFICIENT_BUFFER;
    for _ in 0..3 {
        if result != ERROR_INSUFFICIENT_BUFFER {
            break;
        }
        buffer.resize((size as usize).div_ceil(size_of::<u32>()), 0);
        let table = if buffer.is_empty() {
            null_mut()
        } else {
            buffer.as_mut_ptr().cast::<c_void>()
        };
        result = unsafe {
            GetExtendedTcpTable(table, &mut size, 0, family, TCP_TABLE_OWNER_PID_LISTENER, 0)
        };
    }
    if result != NO_ERROR || buffer.is_empty() {
        return None;
    }
    let found = unsafe {
        if family == u32::from(AF_INET) {
            rows::<MIB_TCPROW_OWNER_PID>(&buffer).any(|row| local_port(row.dwLocalPort) == port)
        } else {
            rows::<MIB_TCP6ROW_OWNER_PID>(&buffer).any(|row| local_port(row.dwLocalPort) == port)
        }
    };
    Some(found)
}

unsafe fn rows<Row>(table: &[u32]) -> std::slice::Iter<'_, Row> {
    let count = table[0] as usize;
    std::slice::from_raw_parts(table.as_ptr().add(1).cast::<Row>(), count).iter()
}

fn local_port(value: u32) -> u16 {
    u16::from_be(value as u16)
}

/// Shutting Windows down kills the process without running the Dart exit
/// path, so the setting would survive into a boot with nothing listening
/// behind it. Every top-level window hears `WM_ENDSESSION`, hidden ones too,
/// so this one needs nothing from the Flutter window.
fn watch_session_end() {
    static WATCH: Once = Once::new();
    WATCH.call_once(|| {
        let _ = std::thread::Builder::new()
            .name("system-proxy-session".into())
            .spawn(run_session_window);
    });
}

fn run_session_window() {
    unsafe {
        let instance = GetModuleHandleW(null());
        let class = wide("FlClashSystemProxySession");
        let window_class = WNDCLASSW {
            lpfnWndProc: Some(session_window_proc),
            hInstance: instance,
            lpszClassName: class.as_ptr(),
            ..zeroed()
        };
        if RegisterClassW(&window_class) == 0 {
            return;
        }
        let window = CreateWindowExW(
            0,
            class.as_ptr(),
            null(),
            0,
            0,
            0,
            0,
            0,
            null_mut(),
            null_mut(),
            instance,
            null(),
        );
        if window.is_null() {
            return;
        }
        let mut message: MSG = zeroed();
        while GetMessageW(&mut message, null_mut(), 0, 0) > 0 {
            TranslateMessage(&message);
            DispatchMessageW(&message);
        }
    }
}

unsafe extern "system" fn session_window_proc(
    window: HWND,
    message: u32,
    wparam: WPARAM,
    lparam: LPARAM,
) -> LRESULT {
    if message == WM_ENDSESSION && wparam != 0 && APPLIED.load(Ordering::SeqCst) {
        let _settings = lock_settings();
        stop_locked();
        return 0;
    }
    DefWindowProcW(window, message, wparam, lparam)
}
