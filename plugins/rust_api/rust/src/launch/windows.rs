use std::ffi::c_void;
use std::ptr::{null, null_mut};

use windows_sys::Win32::Foundation::{ERROR_FILE_NOT_FOUND, ERROR_MORE_DATA, ERROR_SUCCESS};
use windows_sys::Win32::System::Registry::{
    RegCloseKey, RegCreateKeyExW, RegDeleteValueW, RegGetValueW, RegOpenKeyExW, RegSetValueExW,
    HKEY, HKEY_CURRENT_USER, HKEY_LOCAL_MACHINE, KEY_READ, KEY_WRITE, REG_BINARY,
    REG_OPTION_NON_VOLATILE, REG_ROUTINE_FLAGS, REG_SZ, REG_VALUE_TYPE, RRF_RT_REG_BINARY,
    RRF_RT_REG_DWORD, RRF_RT_REG_SZ,
};

use super::entries::{
    run_value, startup_approved, url_command, url_protocol_key, RUN_KEY, STARTUP_APPROVED_ENABLED,
    STARTUP_APPROVED_KEY, URL_COMMAND_KEY, URL_PROTOCOL_VALUE,
};

pub fn autostart_enabled(id: &str, executable: &str) -> bool {
    let registered = Key::open(HKEY_CURRENT_USER, RUN_KEY)
        .and_then(|key| key.string(id))
        .is_some_and(|value| value == run_value(executable));
    registered
        && startup_approved(
            Key::open(HKEY_CURRENT_USER, STARTUP_APPROVED_KEY)
                .and_then(|key| key.binary(id))
                .as_deref(),
        )
}

pub fn set_autostart(id: &str, _display_name: &str, executable: &str, enabled: bool) -> bool {
    if enabled {
        Key::create(HKEY_CURRENT_USER, RUN_KEY)
            .is_some_and(|key| key.set_string(id, run_value(executable)))
            && Key::create(HKEY_CURRENT_USER, STARTUP_APPROVED_KEY)
                .is_some_and(|key| key.set(id, REG_BINARY, &STARTUP_APPROVED_ENABLED))
    } else {
        let run = Key::open_writable(HKEY_CURRENT_USER, RUN_KEY).is_none_or(|key| key.delete(id));
        let approved = Key::open_writable(HKEY_CURRENT_USER, STARTUP_APPROVED_KEY)
            .is_none_or(|key| key.delete(id));
        run && approved
    }
}

pub fn register_url_scheme(scheme: &str, executable: &str) -> bool {
    let Some(protocol) = Key::create(HKEY_CURRENT_USER, &url_protocol_key(scheme)) else {
        return false;
    };
    protocol.set_string(URL_PROTOCOL_VALUE, "")
        && Key::create(protocol.0, URL_COMMAND_KEY)
            .is_some_and(|command| command.set_string("", &url_command(executable)))
}

pub fn read_local_machine_dword(key: &str, value: &str) -> Option<u32> {
    let bytes = Key::open(HKEY_LOCAL_MACHINE, key)?.read(value, RRF_RT_REG_DWORD)?;
    Some(u32::from_le_bytes(bytes.try_into().ok()?))
}

fn wide(value: &str) -> Vec<u16> {
    value.encode_utf16().chain(std::iter::once(0)).collect()
}

struct Key(HKEY);

impl Key {
    fn open(root: HKEY, path: &str) -> Option<Self> {
        Self::open_with(root, path, KEY_READ)
    }

    fn open_writable(root: HKEY, path: &str) -> Option<Self> {
        Self::open_with(root, path, KEY_READ | KEY_WRITE)
    }

    fn open_with(root: HKEY, path: &str, access: u32) -> Option<Self> {
        let path = wide(path);
        let mut key: HKEY = null_mut();
        // SAFETY: `path` is NUL-terminated and outlives the call.
        let status = unsafe { RegOpenKeyExW(root, path.as_ptr(), 0, access, &mut key) };
        (status == ERROR_SUCCESS).then_some(Self(key))
    }

    fn create(root: HKEY, path: &str) -> Option<Self> {
        let path = wide(path);
        let mut key: HKEY = null_mut();
        // SAFETY: `path` is NUL-terminated and outlives the call.
        let status = unsafe {
            RegCreateKeyExW(
                root,
                path.as_ptr(),
                0,
                null(),
                REG_OPTION_NON_VOLATILE,
                KEY_READ | KEY_WRITE,
                null(),
                &mut key,
                null_mut(),
            )
        };
        (status == ERROR_SUCCESS).then_some(Self(key))
    }

    fn read(&self, name: &str, flags: REG_ROUTINE_FLAGS) -> Option<Vec<u8>> {
        let name = wide(name);
        let mut buffer = Vec::<u8>::new();
        loop {
            let mut size = buffer.len() as u32;
            let data = if buffer.is_empty() {
                null_mut()
            } else {
                buffer.as_mut_ptr().cast::<c_void>()
            };
            // SAFETY: `data` is null or points at `size` writable bytes.
            let status = unsafe {
                RegGetValueW(
                    self.0,
                    null(),
                    name.as_ptr(),
                    flags,
                    null_mut(),
                    data,
                    &mut size,
                )
            };
            match status {
                ERROR_SUCCESS if !buffer.is_empty() || size == 0 => {
                    buffer.truncate(size as usize);
                    return Some(buffer);
                }
                ERROR_SUCCESS | ERROR_MORE_DATA => buffer.resize(size as usize, 0),
                _ => return None,
            }
        }
    }

    fn string(&self, name: &str) -> Option<String> {
        let bytes = self.read(name, RRF_RT_REG_SZ)?;
        let units: Vec<u16> = bytes
            .as_chunks::<2>()
            .0
            .iter()
            .map(|pair| u16::from_le_bytes(*pair))
            .collect();
        let end = units
            .iter()
            .position(|&unit| unit == 0)
            .unwrap_or(units.len());
        String::from_utf16(&units[..end]).ok()
    }

    fn binary(&self, name: &str) -> Option<Vec<u8>> {
        self.read(name, RRF_RT_REG_BINARY)
    }

    fn set_string(&self, name: &str, value: &str) -> bool {
        let bytes: Vec<u8> = wide(value)
            .iter()
            .flat_map(|unit| unit.to_le_bytes())
            .collect();
        self.set(name, REG_SZ, &bytes)
    }

    fn set(&self, name: &str, kind: REG_VALUE_TYPE, data: &[u8]) -> bool {
        let name = wide(name);
        // SAFETY: both buffers outlive the call and `data.len()` bounds the read.
        let status = unsafe {
            RegSetValueExW(
                self.0,
                name.as_ptr(),
                0,
                kind,
                data.as_ptr(),
                data.len() as u32,
            )
        };
        status == ERROR_SUCCESS
    }

    fn delete(&self, name: &str) -> bool {
        let name = wide(name);
        // SAFETY: `name` is NUL-terminated and outlives the call.
        let status = unsafe { RegDeleteValueW(self.0, name.as_ptr()) };
        status == ERROR_SUCCESS || status == ERROR_FILE_NOT_FOUND
    }
}

impl Drop for Key {
    fn drop(&mut self) {
        // SAFETY: the handle came from a successful open or create.
        unsafe {
            RegCloseKey(self.0);
        }
    }
}
