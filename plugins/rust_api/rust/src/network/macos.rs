use std::ffi::{c_char, c_int, c_void};
use std::ptr::{null, null_mut};
use std::sync::Mutex;

use block2::RcBlock;
use objc2_core_foundation::{CFArray, CFRetained, CFString};

use super::Notifier;
use crate::api::network::NetworkState;

const NW_PATH_STATUS_SATISFIED: c_int = 1;
const NW_INTERFACE_TYPE_WIFI: c_int = 1;

#[repr(C)]
struct SCDynamicStoreContext {
    version: isize,
    info: *mut c_void,
    retain: *const c_void,
    release: *const c_void,
    copy_description: *const c_void,
}

type StoreCallout = extern "C" fn(*mut c_void, *const CFArray, *mut c_void);

#[link(name = "Network", kind = "framework")]
unsafe extern "C" {
    fn nw_path_monitor_create() -> *mut c_void;
    fn nw_path_monitor_set_queue(monitor: *mut c_void, queue: *mut c_void);
    fn nw_path_monitor_set_update_handler(
        monitor: *mut c_void,
        handler: &block2::Block<dyn Fn(*mut c_void)>,
    );
    fn nw_path_monitor_start(monitor: *mut c_void);
    fn nw_path_get_status(path: *mut c_void) -> c_int;
    fn nw_path_uses_interface_type(path: *mut c_void, kind: c_int) -> bool;
}

#[link(name = "SystemConfiguration", kind = "framework")]
unsafe extern "C" {
    fn SCDynamicStoreCreate(
        allocator: *const c_void,
        name: &CFString,
        callout: StoreCallout,
        context: *mut SCDynamicStoreContext,
    ) -> *mut c_void;
    fn SCDynamicStoreSetNotificationKeys(
        store: *mut c_void,
        keys: *const CFArray,
        patterns: *const CFArray,
    ) -> u8;
    fn SCDynamicStoreSetDispatchQueue(store: *mut c_void, queue: *mut c_void) -> u8;
}

unsafe extern "C" {
    fn dispatch_queue_create(label: *const c_char, attr: *mut c_void) -> *mut c_void;
}

static WIFI: Mutex<Option<bool>> = Mutex::new(None);

pub fn state() -> Option<NetworkState> {
    let wifi = (*WIFI.lock().ok()?)?;
    Some(NetworkState { wifi, vpn: false })
}

/// The path monitor answers whether the default path runs over Wi-Fi, as
/// connectivity_plus read it; the dynamic store adds the address and primary
/// service changes a path update does not carry. Both live for the process.
pub fn watch(notifier: Notifier) {
    // SAFETY: the queue, monitor, handler and store are never released, so
    // every callback finds them alive.
    unsafe {
        let queue = dispatch_queue_create(c"network-watch".as_ptr(), null_mut());
        let monitor = nw_path_monitor_create();
        let paths = notifier.clone();
        let handler = RcBlock::new(move |path: *mut c_void| {
            let wifi = nw_path_get_status(path) == NW_PATH_STATUS_SATISFIED
                && nw_path_uses_interface_type(path, NW_INTERFACE_TYPE_WIFI);
            if let Ok(mut current) = WIFI.lock() {
                *current = Some(wifi);
            }
            paths.changed();
        });
        nw_path_monitor_set_queue(monitor, queue);
        nw_path_monitor_set_update_handler(monitor, &handler);
        nw_path_monitor_start(monitor);
        std::mem::forget(handler);
        watch_store(queue, notifier);
    }
}

extern "C" fn store_changed(_store: *mut c_void, _keys: *const CFArray, info: *mut c_void) {
    // SAFETY: `info` is the leaked notifier `watch_store` registered.
    unsafe { &*info.cast::<Notifier>() }.changed();
}

unsafe fn watch_store(queue: *mut c_void, notifier: Notifier) {
    let mut context = SCDynamicStoreContext {
        version: 0,
        info: Box::into_raw(Box::new(notifier)).cast(),
        retain: null(),
        release: null(),
        copy_description: null(),
    };
    let name = CFString::from_static_str("FlClash network watch");
    let keys = strings(&["State:/Network/Global/IPv4", "State:/Network/Global/IPv6"]);
    let patterns = strings(&[
        "State:/Network/Interface/[^/]+/IPv4",
        "State:/Network/Interface/[^/]+/IPv6",
    ]);
    unsafe {
        let store = SCDynamicStoreCreate(null(), &name, store_changed, &mut context);
        if store.is_null() {
            return;
        }
        SCDynamicStoreSetNotificationKeys(store, &*keys, &*patterns);
        SCDynamicStoreSetDispatchQueue(store, queue);
    }
}

fn strings(values: &[&str]) -> CFRetained<CFArray> {
    let strings: Vec<CFRetained<CFString>> = values
        .iter()
        .map(|value| CFString::from_str(value))
        .collect();
    let array = CFArray::from_retained_objects(&strings);
    // SAFETY: an array of CFString is a CFArray of CFType.
    unsafe { CFRetained::cast_unchecked(array) }
}
