use crate::api::wifi::WifiSsidPermission;
use std::ffi::{c_void, CStr};
use std::ptr::{null, null_mut};
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::OnceLock;
use windows::core::HSTRING;
use windows::Devices::WiFi::WiFiAdapter;
use windows::Security::Authorization::AppCapabilityAccess::{
    AppCapability, AppCapabilityAccessStatus,
};
use windows_sys::core::GUID;
use windows_sys::Win32::Foundation::{ERROR_ACCESS_DENIED, ERROR_SUCCESS, HANDLE, HMODULE};
use windows_sys::Win32::NetworkManagement::WiFi::{
    wlan_interface_state_connected, wlan_intf_opcode_current_connection, WLAN_API_VERSION_2_0,
    WLAN_CONNECTION_ATTRIBUTES, WLAN_INTERFACE_INFO_LIST, WLAN_INTF_OPCODE, WLAN_OPCODE_VALUE_TYPE,
};
use windows_sys::Win32::System::LibraryLoader::{
    GetProcAddress, LoadLibraryExW, LOAD_LIBRARY_SEARCH_SYSTEM32,
};

// From Windows 11 24H2 the WLAN API withholds the SSID without location consent.
const LOCATION_GATED_BUILD: u32 = 26100;

static REQUESTING: AtomicBool = AtomicBool::new(false);

type OpenHandle = unsafe extern "system" fn(u32, *const c_void, *mut u32, *mut HANDLE) -> u32;
type CloseHandle = unsafe extern "system" fn(HANDLE, *const c_void) -> u32;
type FreeMemory = unsafe extern "system" fn(*const c_void);
type EnumInterfaces =
    unsafe extern "system" fn(HANDLE, *const c_void, *mut *mut WLAN_INTERFACE_INFO_LIST) -> u32;
type QueryInterface = unsafe extern "system" fn(
    HANDLE,
    *const GUID,
    WLAN_INTF_OPCODE,
    *const c_void,
    *mut u32,
    *mut *mut c_void,
    *mut WLAN_OPCODE_VALUE_TYPE,
) -> u32;

// Windows Server and any install without the Wireless LAN feature ships no
// wlanapi.dll, and a load-time import of it would stop the app from starting.
struct WlanApi {
    open_handle: OpenHandle,
    close_handle: CloseHandle,
    free_memory: FreeMemory,
    enum_interfaces: EnumInterfaces,
    query_interface: QueryInterface,
}

fn wlan_api() -> Option<&'static WlanApi> {
    static API: OnceLock<Option<WlanApi>> = OnceLock::new();
    API.get_or_init(|| unsafe {
        let name: Vec<u16> = "wlanapi.dll\0".encode_utf16().collect();
        let module = LoadLibraryExW(name.as_ptr(), null_mut(), LOAD_LIBRARY_SEARCH_SYSTEM32);
        if module.is_null() {
            return None;
        }
        Some(WlanApi {
            open_handle: symbol(module, c"WlanOpenHandle")?,
            close_handle: symbol(module, c"WlanCloseHandle")?,
            free_memory: symbol(module, c"WlanFreeMemory")?,
            enum_interfaces: symbol(module, c"WlanEnumInterfaces")?,
            query_interface: symbol(module, c"WlanQueryInterface")?,
        })
    })
    .as_ref()
}

unsafe fn symbol<F: Copy>(module: HMODULE, name: &CStr) -> Option<F> {
    let address = unsafe { GetProcAddress(module, name.as_ptr().cast()) }?;
    Some(unsafe { std::mem::transmute_copy::<unsafe extern "system" fn() -> isize, F>(&address) })
}

struct Client<'a> {
    api: &'a WlanApi,
    handle: HANDLE,
}

impl Drop for Client<'_> {
    fn drop(&mut self) {
        unsafe { (self.api.close_handle)(self.handle, null()) };
    }
}

struct WlanMemory<'a, T> {
    api: &'a WlanApi,
    data: *mut T,
}

impl<T> Drop for WlanMemory<'_, T> {
    fn drop(&mut self) {
        if !self.data.is_null() {
            unsafe { (self.api.free_memory)(self.data.cast()) };
        }
    }
}

fn read_ssid() -> Result<Option<String>, String> {
    let Some(api) = wlan_api() else {
        return Ok(None);
    };
    let mut version = 0;
    let mut handle: HANDLE = null_mut();
    match unsafe { (api.open_handle)(WLAN_API_VERSION_2_0, null(), &mut version, &mut handle) } {
        ERROR_SUCCESS => {}
        ERROR_ACCESS_DENIED => return Ok(None),
        code => return Err(format!("WlanOpenHandle failed: {code}")),
    }
    let client = Client { api, handle };

    let mut list = WlanMemory::<WLAN_INTERFACE_INFO_LIST> {
        api,
        data: null_mut(),
    };
    match unsafe { (api.enum_interfaces)(client.handle, null(), &mut list.data) } {
        ERROR_SUCCESS => {}
        ERROR_ACCESS_DENIED => return Ok(None),
        code => return Err(format!("WlanEnumInterfaces failed: {code}")),
    }
    let interfaces = unsafe {
        std::slice::from_raw_parts(
            (*list.data).InterfaceInfo.as_ptr(),
            (*list.data).dwNumberOfItems as usize,
        )
    };

    for interface in interfaces {
        if interface.isState != wlan_interface_state_connected {
            continue;
        }
        let mut connection = WlanMemory::<WLAN_CONNECTION_ATTRIBUTES> {
            api,
            data: null_mut(),
        };
        let mut size = 0;
        let code = unsafe {
            (api.query_interface)(
                client.handle,
                &interface.InterfaceGuid,
                wlan_intf_opcode_current_connection,
                null(),
                &mut size,
                (&raw mut connection.data).cast(),
                null_mut(),
            )
        };
        if code == ERROR_ACCESS_DENIED {
            return Ok(None);
        }
        if code != ERROR_SUCCESS || connection.data.is_null() {
            continue;
        }
        let ssid = unsafe { &(*connection.data).wlanAssociationAttributes.dot11Ssid };
        if let Some(bytes) = ssid.ucSSID.get(..ssid.uSSIDLength as usize) {
            if !bytes.is_empty() {
                return Ok(Some(String::from_utf8_lossy(bytes).into_owned()));
            }
        }
    }
    Ok(None)
}

fn location_gated() -> bool {
    static GATED: OnceLock<bool> = OnceLock::new();
    *GATED.get_or_init(|| crate::device::windows_build() >= LOCATION_GATED_BUILD)
}

fn current_permission() -> WifiSsidPermission {
    if !location_gated() {
        return WifiSsidPermission::Granted;
    }
    match AppCapability::Create(&HSTRING::from("wiFiControl")).and_then(|c| c.CheckAccess()) {
        Ok(AppCapabilityAccessStatus::UserPromptRequired) => WifiSsidPermission::Denied,
        Ok(AppCapabilityAccessStatus::DeniedByUser | AppCapabilityAccessStatus::DeniedBySystem) => {
            WifiSsidPermission::PermanentlyDenied
        }
        _ => WifiSsidPermission::Granted,
    }
}

pub async fn ssid() -> Result<Option<String>, String> {
    tokio::task::spawn_blocking(read_ssid)
        .await
        .map_err(|error| error.to_string())?
}

pub async fn check_permission() -> WifiSsidPermission {
    tokio::task::spawn_blocking(current_permission)
        .await
        .unwrap_or(WifiSsidPermission::Denied)
}

// RequestAccessAsync completes once the user answers; a request made while the
// prompt is up reports the current state instead of raising a second prompt.
pub async fn request_permission() -> WifiSsidPermission {
    tokio::task::spawn_blocking(|| {
        let permission = current_permission();
        if permission != WifiSsidPermission::Denied || REQUESTING.swap(true, Ordering::AcqRel) {
            return permission;
        }
        let _ = WiFiAdapter::RequestAccessAsync().and_then(|operation| operation.join());
        REQUESTING.store(false, Ordering::Release);
        current_permission()
    })
    .await
    .unwrap_or(WifiSsidPermission::Denied)
}
