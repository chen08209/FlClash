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

// In the window's units, the cursor's and the bounds', whatever each monitor's own scale.
pub(super) fn all(window_scale: f64) -> Vec<WindowDisplay> {
    let mut displays: Vec<WindowDisplay> = Vec::new();
    unsafe {
        EnumDisplayMonitors(
            null_mut(),
            null(),
            Some(collect),
            &mut displays as *mut Vec<WindowDisplay> as LPARAM,
        )
    };
    for display in &mut displays {
        display.bounds = scaled(display.bounds, window_scale);
        display.work_area = scaled(display.work_area, window_scale);
    }
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
        bounds: physical(info.rcMonitor),
        work_area: physical(info.rcWork),
        scale_factor: scale,
        primary: info.dwFlags & MONITORINFOF_PRIMARY != 0,
    });
    1
}

fn physical(rect: RECT) -> WindowBounds {
    WindowBounds {
        x: f64::from(rect.left),
        y: f64::from(rect.top),
        width: f64::from(rect.right - rect.left),
        height: f64::from(rect.bottom - rect.top),
    }
}

fn scaled(bounds: WindowBounds, scale: f64) -> WindowBounds {
    WindowBounds {
        x: bounds.x / scale,
        y: bounds.y / scale,
        width: bounds.width / scale,
        height: bounds.height / scale,
    }
}
