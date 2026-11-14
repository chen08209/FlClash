use crate::api::wifi::WifiSsidPermission;
use dispatch2::DispatchQueue;
use objc2::rc::Retained;
use objc2::runtime::ProtocolObject;
use objc2::{available, define_class, msg_send, MainThreadMarker, MainThreadOnly};
use objc2_core_location::{CLAuthorizationStatus, CLLocationManager, CLLocationManagerDelegate};
use objc2_core_wlan::CWWiFiClient;
use objc2_foundation::{NSObject, NSObjectProtocol};
use std::cell::RefCell;
use tokio::sync::oneshot;

struct Location {
    manager: Retained<CLLocationManager>,
    _delegate: Retained<LocationDelegate>,
    pending: Vec<oneshot::Sender<WifiSsidPermission>>,
}

thread_local! {
    static LOCATION: RefCell<Option<Location>> = const { RefCell::new(None) };
}

define_class!(
    #[unsafe(super(NSObject))]
    #[thread_kind = MainThreadOnly]
    #[name = "FlClashWifiLocationDelegate"]
    struct LocationDelegate;

    unsafe impl NSObjectProtocol for LocationDelegate {}

    unsafe impl CLLocationManagerDelegate for LocationDelegate {
        #[unsafe(method(locationManagerDidChangeAuthorization:))]
        fn did_change_authorization(&self, manager: &CLLocationManager) {
            authorization_changed(manager);
        }
    }
);

impl LocationDelegate {
    fn new(mtm: MainThreadMarker) -> Retained<Self> {
        unsafe { msg_send![Self::alloc(mtm), init] }
    }
}

// CoreWLAN asks for location authorization only from macOS 14.
fn location_gated() -> bool {
    available!(macos = 14.0)
}

fn permission_of(status: CLAuthorizationStatus) -> WifiSsidPermission {
    match status {
        CLAuthorizationStatus::AuthorizedAlways | CLAuthorizationStatus::AuthorizedWhenInUse => {
            WifiSsidPermission::Granted
        }
        CLAuthorizationStatus::Denied | CLAuthorizationStatus::Restricted => {
            WifiSsidPermission::PermanentlyDenied
        }
        _ => WifiSsidPermission::Denied,
    }
}

fn with_location<R>(mtm: MainThreadMarker, f: impl FnOnce(&mut Location) -> R) -> R {
    LOCATION.with_borrow_mut(|location| {
        let location = location.get_or_insert_with(|| {
            let manager = unsafe { CLLocationManager::new() };
            let delegate = LocationDelegate::new(mtm);
            unsafe { manager.setDelegate(Some(ProtocolObject::from_ref(&*delegate))) };
            Location {
                manager,
                _delegate: delegate,
                pending: Vec::new(),
            }
        });
        f(location)
    })
}

fn current_permission(mtm: MainThreadMarker) -> WifiSsidPermission {
    let manager = with_location(mtm, |location| location.manager.clone());
    permission_of(unsafe { manager.authorizationStatus() })
}

// A new manager reports its status once, and the request itself builds it, so
// that report can land while the prompt is still up.
fn authorization_changed(manager: &CLLocationManager) {
    let status = unsafe { manager.authorizationStatus() };
    if status == CLAuthorizationStatus::NotDetermined {
        return;
    }
    let pending = LOCATION.with_borrow_mut(|location| {
        location
            .as_mut()
            .map(|location| std::mem::take(&mut location.pending))
            .unwrap_or_default()
    });
    let permission = permission_of(status);
    for sender in pending {
        let _ = sender.send(permission);
    }
}

async fn on_main<R: Send + 'static>(
    work: impl FnOnce(MainThreadMarker) -> R + Send + 'static,
) -> Option<R> {
    let (sender, receiver) = oneshot::channel();
    DispatchQueue::main().exec_async(move || {
        let mtm = MainThreadMarker::new().expect("the main queue runs on the main thread");
        let _ = sender.send(work(mtm));
    });
    receiver.await.ok()
}

pub async fn check_permission() -> WifiSsidPermission {
    if !location_gated() {
        return WifiSsidPermission::Granted;
    }
    on_main(current_permission)
        .await
        .unwrap_or(WifiSsidPermission::Denied)
}

// A request made while the prompt is up waits for the same answer.
pub async fn request_permission() -> WifiSsidPermission {
    if !location_gated() {
        return WifiSsidPermission::Granted;
    }
    let answer = on_main(|mtm| {
        let permission = current_permission(mtm);
        if permission != WifiSsidPermission::Denied {
            return Err(permission);
        }
        let (sender, receiver) = oneshot::channel();
        let manager = with_location(mtm, |location| {
            location.pending.push(sender);
            location.manager.clone()
        });
        unsafe { manager.requestWhenInUseAuthorization() };
        Ok(receiver)
    })
    .await;
    match answer {
        Some(Ok(receiver)) => receiver.await.unwrap_or(WifiSsidPermission::Denied),
        Some(Err(permission)) => permission,
        None => WifiSsidPermission::Denied,
    }
}

// CoreWLAN reaches wifid over XPC, where a wedged daemon holds the asking thread.
pub async fn ssid() -> Result<Option<String>, String> {
    if location_gated() && check_permission().await != WifiSsidPermission::Granted {
        return Ok(None);
    }
    let ssid = tokio::task::spawn_blocking(|| {
        let interface = unsafe { CWWiFiClient::sharedWiFiClient().interface() }?;
        unsafe { interface.ssid() }.map(|ssid| ssid.to_string())
    })
    .await
    .map_err(|error| error.to_string())?;
    Ok(super::non_empty(ssid))
}
