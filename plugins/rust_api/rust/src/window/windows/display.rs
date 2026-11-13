use super::DEFAULT_DPI;
use crate::api::window::{WindowBounds, WindowDisplay};
use std::ptr::{null, null_mut};
use windows_sys::core::BOOL;
use windows_sys::Win32::Foundation::{LPARAM, RECT};
use windows_sys::Win32::Graphics::Gdi::{
    EnumDisplayMonitors, GetMonitorInfoW, HDC, HMONITOR, MONITORINFO,
};
use windows_sys::Win32::UI::HiDpi::{GetDpiForMonitor, MDT_EFFECTIVE_DPI};
use windows_sys::Win32::UI::WindowsAndMessaging::MONITORINFOF_PRIMARY;

// Each display is in its own logical pixels, physical over its own scale, as
// screen_retriever reported them; only physical pixels compare across scales.
pub(super) fn all() -> Vec<WindowDisplay> {
    let mut displays = Vec::new();
    unsafe {
        EnumDisplayMonitors(
            null_mut(),
            null(),
            Some(collect),
            &mut displays as *mut Vec<WindowDisplay> as LPARAM,
        )
    };
    displays
}

unsafe extern "system" fn collect(
    monitor: HMONITOR,
    _: HDC,
    _: *mut RECT,
    displays: LPARAM,
) -> BOOL {
    let displays = &mut *(displays as *mut Vec<WindowDisplay>);
    let mut info: MONITORINFO = std::mem::zeroed();
    info.cbSize = std::mem::size_of::<MONITORINFO>() as u32;
    if GetMonitorInfoW(monitor, &mut info) == 0 {
        return 1;
    }
    let (mut dpi, mut unused) = (0, 0);
    let scale = if GetDpiForMonitor(monitor, MDT_EFFECTIVE_DPI, &mut dpi, &mut unused) == 0 {
        f64::from(dpi) / DEFAULT_DPI
    } else {
        1.0
    };
    displays.push(WindowDisplay {
        bounds: scaled(info.rcMonitor, scale),
        work_area: scaled(info.rcWork, scale),
        scale_factor: scale,
        primary: info.dwFlags & MONITORINFOF_PRIMARY != 0,
    });
    1
}

fn scaled(rect: RECT, scale: f64) -> WindowBounds {
    WindowBounds {
        x: f64::from(rect.left) / scale,
        y: f64::from(rect.top) / scale,
        width: f64::from(rect.right - rect.left) / scale,
        height: f64::from(rect.bottom - rect.top) / scale,
    }
}
