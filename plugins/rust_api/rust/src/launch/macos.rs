use objc2::runtime::AnyClass;
use objc2_service_management::{SMAppService, SMAppServiceStatus};

// LaunchAtLogin registered through this service, and on macOS 12 never worked.
fn main_app() -> Option<objc2::rc::Retained<SMAppService>> {
    AnyClass::get(c"SMAppService")?;
    Some(unsafe { SMAppService::mainAppService() })
}

fn status(service: &SMAppService) -> SMAppServiceStatus {
    unsafe { service.status() }
}

pub fn autostart_enabled(_id: &str, _executable: &str) -> bool {
    main_app().is_some_and(|service| status(&service) == SMAppServiceStatus::Enabled)
}

pub fn set_autostart(_id: &str, _display_name: &str, _executable: &str, enabled: bool) -> bool {
    let Some(service) = main_app() else {
        return false;
    };
    let current = status(&service);
    if enabled {
        current == SMAppServiceStatus::Enabled
            || unsafe { service.registerAndReturnError() }.is_ok()
    } else {
        current == SMAppServiceStatus::NotRegistered
            || unsafe { service.unregisterAndReturnError() }.is_ok()
    }
}
