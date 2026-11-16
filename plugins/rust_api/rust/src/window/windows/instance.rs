use std::ffi::OsString;
use std::os::windows::ffi::OsStringExt;
use std::sync::OnceLock;
use windows_sys::Win32::Foundation::{
    CloseHandle, GetLastError, ERROR_ACCESS_DENIED, ERROR_ALREADY_EXISTS, HWND, LPARAM,
};
use windows_sys::Win32::System::DataExchange::COPYDATASTRUCT;
use windows_sys::Win32::System::LibraryLoader::GetModuleFileNameW;
use windows_sys::Win32::System::Threading::{
    CreateMutexW, GetCurrentProcessId, OpenProcess, QueryFullProcessImageNameW, PROCESS_NAME_WIN32,
    PROCESS_QUERY_LIMITED_INFORMATION,
};
use windows_sys::Win32::UI::WindowsAndMessaging::{
    AllowSetForegroundWindow, ChangeWindowMessageFilterEx, EnumWindows, GetClassNameW,
    GetWindowThreadProcessId, RegisterWindowMessageW, SendMessageTimeoutW, MSGFLT_ALLOW,
    SMTO_ABORTIFHUNG, WM_COPYDATA,
};

const RUNNER_WINDOW_CLASS: &str = "flutter_runner_win32_window";
pub const LINK_COPY_DATA: usize = 0x464C_4C4B;
const FORWARD_TIMEOUT_MILLISECONDS: u32 = 5_000;
pub const HANDLED: isize = 1;
const WINDOW_WAIT: std::time::Duration = std::time::Duration::from_secs(10);
const WINDOW_POLL: std::time::Duration = std::time::Duration::from_millis(50);

fn executable_path() -> String {
    let mut buffer = vec![0u16; 260];
    loop {
        let length = unsafe {
            GetModuleFileNameW(
                std::ptr::null_mut(),
                buffer.as_mut_ptr(),
                buffer.len() as u32,
            )
        } as usize;
        if length == 0 {
            return String::new();
        }
        if length < buffer.len() {
            buffer.truncate(length);
            break;
        }
        buffer.resize(buffer.len() * 2, 0);
    }
    lowercase(&buffer)
}

// GetModuleFileNameW keeps launch-time casing, and one executable must always
// hash to one message.
fn lowercase(units: &[u16]) -> String {
    OsString::from_wide(units).to_string_lossy().to_lowercase()
}

pub fn fnv1a(units: impl IntoIterator<Item = u16>) -> u64 {
    units
        .into_iter()
        .fold(14_695_981_039_346_656_037, |hash, unit| {
            (hash ^ u64::from(unit)).wrapping_mul(1_099_511_628_211)
        })
}

fn instance_name(prefix: &str) -> Vec<u16> {
    let hash = fnv1a(executable_path().encode_utf16());
    format!("{prefix}{hash:x}")
        .encode_utf16()
        .chain(Some(0))
        .collect()
}

pub fn activate_message() -> u32 {
    static MESSAGE: OnceLock<u32> = OnceLock::new();
    *MESSAGE.get_or_init(|| {
        let name = instance_name("flclash.activate:");
        unsafe { RegisterWindowMessageW(name.as_ptr()) }
    })
}

// The handle stays open for the life of the process. An elevated owner's
// mutex is denied to a non-elevated launch: taken all the same.
fn claim_instance() -> bool {
    let name = instance_name("Local\\flclash.instance:");
    let mutex = unsafe { CreateMutexW(std::ptr::null(), 0, name.as_ptr()) };
    let error = unsafe { GetLastError() };
    if mutex.is_null() {
        return error != ERROR_ACCESS_DENIED;
    }
    if error == ERROR_ALREADY_EXISTS {
        unsafe { CloseHandle(mutex) };
        return false;
    }
    true
}

/// Lets a lower-integrity relaunch reach an elevated window with the activate
/// message and its forwarded links; UIPI drops both otherwise.
pub fn allow_relaunch_messages(window: HWND) {
    unsafe {
        ChangeWindowMessageFilterEx(
            window,
            activate_message(),
            MSGFLT_ALLOW,
            std::ptr::null_mut(),
        );
        ChangeWindowMessageFilterEx(window, WM_COPYDATA, MSGFLT_ALLOW, std::ptr::null_mut());
    }
}

struct Search {
    executable: String,
    found: HWND,
}

unsafe extern "system" fn match_running_window(window: HWND, lparam: LPARAM) -> i32 {
    let search = &mut *(lparam as *mut Search);
    let mut class = [0u16; 64];
    let length = GetClassNameW(window, class.as_mut_ptr(), class.len() as i32);
    if length <= 0 || lowercase(&class[..length as usize]) != RUNNER_WINDOW_CLASS {
        return 1;
    }
    let mut pid = 0;
    GetWindowThreadProcessId(window, &mut pid);
    if pid == GetCurrentProcessId() {
        return 1;
    }
    let process = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, 0, pid);
    if process.is_null() {
        return 1;
    }
    let mut image = vec![0u16; search.executable.encode_utf16().count() + 1];
    let mut length = image.len() as u32;
    let queried =
        QueryFullProcessImageNameW(process, PROCESS_NAME_WIN32, image.as_mut_ptr(), &mut length);
    CloseHandle(process);
    if queried != 0 && lowercase(&image[..length as usize]) == search.executable {
        search.found = window;
        return 0;
    }
    1
}

fn running_window() -> HWND {
    let mut search = Search {
        executable: executable_path(),
        found: std::ptr::null_mut(),
    };
    unsafe {
        EnumWindows(
            Some(match_running_window),
            &mut search as *mut Search as LPARAM,
        )
    };
    search.found
}

#[no_mangle]
pub extern "C" fn flclash_find_running_window() -> HWND {
    let deadline = std::time::Instant::now() + WINDOW_WAIT;
    loop {
        if claim_instance() {
            return std::ptr::null_mut();
        }
        let window = running_window();
        if !window.is_null() || std::time::Instant::now() >= deadline {
            return window;
        }
        std::thread::sleep(WINDOW_POLL);
    }
}

// The runner's window exists before its engine does, and until then a
// message gets the default answer, 0, and is dropped.
fn send_until_handled(
    window: HWND,
    message: u32,
    lparam: LPARAM,
    deadline: std::time::Instant,
) -> bool {
    loop {
        let mut result = 0;
        let sent = unsafe {
            SendMessageTimeoutW(
                window,
                message,
                0,
                lparam,
                SMTO_ABORTIFHUNG,
                FORWARD_TIMEOUT_MILLISECONDS,
                &mut result,
            )
        };
        if sent != 0 && result as isize == HANDLED {
            return true;
        }
        if std::time::Instant::now() >= deadline {
            return false;
        }
        std::thread::sleep(WINDOW_POLL);
    }
}

#[no_mangle]
pub extern "C" fn flclash_forward_links(window: HWND) {
    if window.is_null() {
        return;
    }
    let deadline = std::time::Instant::now() + WINDOW_WAIT;
    for link in super::super::link::launch_links(std::env::args_os().skip(1)) {
        let units: Vec<u16> = link.encode_utf16().collect();
        let data = COPYDATASTRUCT {
            dwData: LINK_COPY_DATA,
            cbData: (units.len() * 2) as u32,
            lpData: units.as_ptr() as *mut core::ffi::c_void,
        };
        let lparam = &data as *const COPYDATASTRUCT as LPARAM;
        send_until_handled(window, WM_COPYDATA, lparam, deadline);
    }
}

#[no_mangle]
pub extern "C" fn flclash_activate_window(window: HWND) {
    if window.is_null() {
        return;
    }
    let mut pid = 0;
    unsafe {
        GetWindowThreadProcessId(window, &mut pid);
        AllowSetForegroundWindow(pid);
    }
    let deadline = std::time::Instant::now() + WINDOW_WAIT;
    send_until_handled(window, activate_message(), 0, deadline);
}

#[cfg(test)]
mod tests {
    use super::{fnv1a, lowercase};

    #[test]
    fn fnv1a_matches_the_reference_vectors() {
        assert_eq!(fnv1a([]), 0xcbf2_9ce4_8422_2325);
        assert_eq!(fnv1a("a".encode_utf16()), 0xaf63_dc4c_8601_ec8c);
    }

    #[test]
    fn executable_paths_compare_without_case() {
        let path: Vec<u16> = r"C:\Program Files\FlClash\FlClash.exe"
            .encode_utf16()
            .collect();
        assert_eq!(lowercase(&path), r"c:\program files\flclash\flclash.exe");
    }
}
