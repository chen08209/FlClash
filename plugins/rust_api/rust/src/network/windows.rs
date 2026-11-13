use std::collections::{HashMap, HashSet};
use std::ffi::c_void;
use std::ptr::{null, null_mut};
use std::sync::Mutex;

use windows_sys::Win32::Foundation::{ERROR_BUFFER_OVERFLOW, ERROR_SUCCESS, HANDLE};
use windows_sys::Win32::NetworkManagement::IpHelper::{
    FreeMibTable, GetAdaptersAddresses, GetIpForwardTable2, GetIpInterfaceEntry,
    GetIpInterfaceTable, MibAddInstance, MibDeleteInstance, NotifyIpInterfaceChange,
    NotifyRouteChange2, NotifyUnicastIpAddressChange, GAA_FLAG_SKIP_ANYCAST,
    GAA_FLAG_SKIP_DNS_SERVER, GAA_FLAG_SKIP_FRIENDLY_NAME, GAA_FLAG_SKIP_MULTICAST,
    GAA_FLAG_SKIP_UNICAST, IP_ADAPTER_ADDRESSES_LH, MIB_IPFORWARD_ROW2, MIB_IPFORWARD_TABLE2,
    MIB_IPINTERFACE_ROW, MIB_IPINTERFACE_TABLE, MIB_NOTIFICATION_TYPE, MIB_UNICASTIPADDRESS_ROW,
};
use windows_sys::Win32::NetworkManagement::Ndis::IfOperStatusUp;
use windows_sys::Win32::Networking::WinSock::AF_UNSPEC;

use super::Notifier;
use crate::api::network::NetworkState;

const IF_TYPE_PPP: u32 = 23;
const IF_TYPE_IEEE80211: u32 = 71;
const IF_TYPE_TUNNEL: u32 = 131;

/// An adapter counts once it is up and holds a default route, which is what
/// puts it in a connected network for NLM. Wi-Fi and the tunnel and PPP
/// types are the ones connectivity_plus reported as wifi and vpn; wintun,
/// the Core's TUN, is a virtual adapter and neither.
pub fn state() -> Option<NetworkState> {
    let routed = default_route_interfaces()?;
    let mut state = NetworkState {
        wifi: false,
        vpn: false,
    };
    for (if_type, luid) in up_adapters()? {
        if !routed.contains(&luid) {
            continue;
        }
        state.wifi |= if_type == IF_TYPE_IEEE80211;
        state.vpn |= matches!(if_type, IF_TYPE_PPP | IF_TYPE_TUNNEL);
    }
    Some(state)
}

fn default_route_interfaces() -> Option<HashSet<u64>> {
    let mut table: *mut MIB_IPFORWARD_TABLE2 = null_mut();
    // SAFETY: the table is read within its entry count and freed once.
    unsafe {
        if GetIpForwardTable2(AF_UNSPEC, &mut table) != ERROR_SUCCESS {
            return None;
        }
        let rows =
            std::slice::from_raw_parts((*table).Table.as_ptr(), (*table).NumEntries as usize);
        let interfaces = rows
            .iter()
            .filter(|row| row.DestinationPrefix.PrefixLength == 0)
            .map(|row| row.InterfaceLuid.Value)
            .collect();
        FreeMibTable(table.cast());
        Some(interfaces)
    }
}

fn up_adapters() -> Option<Vec<(u32, u64)>> {
    let flags = GAA_FLAG_SKIP_UNICAST
        | GAA_FLAG_SKIP_ANYCAST
        | GAA_FLAG_SKIP_MULTICAST
        | GAA_FLAG_SKIP_DNS_SERVER
        | GAA_FLAG_SKIP_FRIENDLY_NAME;
    let mut size = 16 * 1024u32;
    let mut buffer: Vec<u64> = Vec::new();
    for _ in 0..4 {
        buffer.resize((size as usize).div_ceil(8), 0);
        let first = buffer.as_mut_ptr().cast::<IP_ADAPTER_ADDRESSES_LH>();
        // SAFETY: `buffer` is 8-byte aligned and `size` bytes long.
        let status =
            unsafe { GetAdaptersAddresses(u32::from(AF_UNSPEC), flags, null(), first, &mut size) };
        if status == ERROR_BUFFER_OVERFLOW {
            continue;
        }
        if status != ERROR_SUCCESS {
            return None;
        }
        let mut adapters = Vec::new();
        let mut adapter = first.cast_const();
        // SAFETY: the list lives in `buffer` and ends with a null `Next`.
        while let Some(current) = unsafe { adapter.as_ref() } {
            if current.OperStatus == IfOperStatusUp {
                adapters.push((current.IfType, unsafe { current.Luid.Value }));
            }
            adapter = current.Next;
        }
        return Some(adapters);
    }
    None
}

fn context(notifier: &'static Notifier) -> *const c_void {
    (notifier as *const Notifier).cast()
}

unsafe fn notify(context: *const c_void) {
    unsafe { &*context.cast::<Notifier>() }.changed();
}

fn added_or_removed(kind: MIB_NOTIFICATION_TYPE) -> bool {
    kind == MibAddInstance || kind == MibDeleteInstance
}

/// A pulled cable leaves the adapter's address and default route in place
/// and only clears its `Connected` flag, which arrives as a parameter change.
static CONNECTED: Mutex<Option<HashMap<(u64, u16), bool>>> = Mutex::new(None);

fn seed_connected() {
    let mut table: *mut MIB_IPINTERFACE_TABLE = null_mut();
    let rows = unsafe {
        if GetIpInterfaceTable(AF_UNSPEC, &mut table) != ERROR_SUCCESS {
            return;
        }
        let rows: HashMap<(u64, u16), bool> =
            std::slice::from_raw_parts((*table).Table.as_ptr(), (*table).NumEntries as usize)
                .iter()
                .map(|row| ((row.InterfaceLuid.Value, row.Family), row.Connected))
                .collect();
        FreeMibTable(table.cast());
        rows
    };
    if let Ok(mut connected) = CONNECTED.lock() {
        *connected = Some(rows);
    }
}

fn connected_changed(row: &MIB_IPINTERFACE_ROW, kind: MIB_NOTIFICATION_TYPE) -> bool {
    let key = (unsafe { row.InterfaceLuid.Value }, row.Family);
    let Ok(mut connected) = CONNECTED.lock() else {
        return true;
    };
    let connected = connected.get_or_insert_with(HashMap::new);
    if kind == MibDeleteInstance {
        connected.remove(&key);
        return true;
    }
    let mut entry: MIB_IPINTERFACE_ROW = unsafe { std::mem::zeroed() };
    entry.Family = row.Family;
    entry.InterfaceLuid = row.InterfaceLuid;
    entry.InterfaceIndex = row.InterfaceIndex;
    if unsafe { GetIpInterfaceEntry(&mut entry) } != ERROR_SUCCESS {
        return kind == MibAddInstance;
    }
    connected.insert(key, entry.Connected) != Some(entry.Connected) || kind == MibAddInstance
}

unsafe extern "system" fn interface_changed(
    context: *const c_void,
    row: *const MIB_IPINTERFACE_ROW,
    kind: MIB_NOTIFICATION_TYPE,
) {
    if unsafe { row.as_ref() }.is_some_and(|row| connected_changed(row, kind)) {
        unsafe { notify(context) };
    }
}

unsafe extern "system" fn address_changed(
    context: *const c_void,
    _row: *const MIB_UNICASTIPADDRESS_ROW,
    kind: MIB_NOTIFICATION_TYPE,
) {
    if added_or_removed(kind) {
        unsafe { notify(context) };
    }
}

/// A metric change on a default route can move the default to another
/// adapter, so every notification about one counts.
unsafe extern "system" fn route_changed(
    context: *const c_void,
    row: *const MIB_IPFORWARD_ROW2,
    _kind: MIB_NOTIFICATION_TYPE,
) {
    if unsafe { row.as_ref() }.is_some_and(|row| row.DestinationPrefix.PrefixLength == 0) {
        unsafe { notify(context) };
    }
}

/// The three registrations live for the process and call back on system
/// threads, which only hand a signal to the watcher.
pub fn watch(notifier: Notifier) {
    seed_connected();
    let notifier: &'static Notifier = Box::leak(Box::new(notifier));
    let mut handle: HANDLE = null_mut();
    // SAFETY: the callbacks match the documented signatures and the context
    // outlives every registration.
    unsafe {
        NotifyIpInterfaceChange(
            AF_UNSPEC,
            Some(interface_changed),
            context(notifier),
            false,
            &mut handle,
        );
        NotifyUnicastIpAddressChange(
            AF_UNSPEC,
            Some(address_changed),
            context(notifier),
            false,
            &mut handle,
        );
        NotifyRouteChange2(
            AF_UNSPEC,
            Some(route_changed),
            context(notifier),
            false,
            &mut handle,
        );
    }
}
