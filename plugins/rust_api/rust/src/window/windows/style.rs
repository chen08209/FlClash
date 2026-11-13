use crate::api::window::WindowEffect;
use std::ffi::c_void;
use std::mem::size_of;
use std::sync::OnceLock;
use windows_sys::core::BOOL;
use windows_sys::Win32::Foundation::{HWND, RECT};
use windows_sys::Win32::Graphics::Dwm::{DwmExtendFrameIntoClientArea, DwmSetWindowAttribute};
use windows_sys::Win32::System::LibraryLoader::{GetModuleHandleW, GetProcAddress};
use windows_sys::Win32::System::SystemInformation::OSVERSIONINFOW;
use windows_sys::Win32::UI::Controls::MARGINS;
use windows_sys::Win32::UI::HiDpi::{AdjustWindowRectExForDpi, GetDpiForWindow};
use windows_sys::Win32::UI::WindowsAndMessaging::{
    GetWindowLongPtrW, IsZoomed, SetWindowLongPtrW, SetWindowPos, GWL_STYLE, SWP_FRAMECHANGED,
    SWP_NOACTIVATE, SWP_NOMOVE, SWP_NOOWNERZORDER, SWP_NOSIZE, SWP_NOZORDER, WS_OVERLAPPEDWINDOW,
    WS_SYSMENU, WS_THICKFRAME,
};

const DWMWA_USE_IMMERSIVE_DARK_MODE_BEFORE_20H1: u32 = 19;
const DWMWA_USE_IMMERSIVE_DARK_MODE: u32 = 20;
const DWMWA_WINDOW_CORNER_PREFERENCE: u32 = 33;
const DWMWA_SYSTEMBACKDROP_TYPE: u32 = 38;
const DWMWA_MICA_EFFECT: u32 = 1029;
const DWMWCP_DONOTROUND: i32 = 1;
const DWMWCP_ROUND: i32 = 2;
const DWMSBT_NONE: i32 = 1;
const DWMSBT_MAINWINDOW: i32 = 2;
const SYSTEM_BACKDROP_BUILD: u32 = 22621;
const WINDOWS_11_BUILD: u32 = 22000;
const ACCENT_DISABLED: i32 = 0;
const ACCENT_ENABLE_BLURBEHIND: i32 = 3;
const WCA_ACCENT_POLICY: i32 = 19;

#[repr(C)]
struct AccentPolicy {
    accent_state: i32,
    accent_flags: i32,
    gradient_color: u32,
    animation_id: i32,
}

#[repr(C)]
struct CompositionAttributeData {
    attribute: i32,
    data: *mut c_void,
    size: usize,
}

type SetWindowCompositionAttribute =
    unsafe extern "system" fn(HWND, *mut CompositionAttributeData) -> BOOL;
type RtlGetVersion = unsafe extern "system" fn(*mut OSVERSIONINFOW) -> i32;
type Farproc = unsafe extern "system" fn() -> isize;

fn wide(value: &str) -> Vec<u16> {
    value.encode_utf16().chain(Some(0)).collect()
}

fn composition_attribute() -> Option<SetWindowCompositionAttribute> {
    static FUNCTION: OnceLock<Option<SetWindowCompositionAttribute>> = OnceLock::new();
    *FUNCTION.get_or_init(|| unsafe {
        let user32 = GetModuleHandleW(wide("user32.dll").as_ptr());
        if user32.is_null() {
            return None;
        }
        GetProcAddress(user32, c"SetWindowCompositionAttribute".as_ptr().cast())
            .map(|function| std::mem::transmute::<Farproc, SetWindowCompositionAttribute>(function))
    })
}

pub fn build_number() -> u32 {
    static BUILD: OnceLock<u32> = OnceLock::new();
    *BUILD.get_or_init(|| unsafe {
        let ntdll = GetModuleHandleW(wide("ntdll.dll").as_ptr());
        if ntdll.is_null() {
            return 0;
        }
        let Some(function) = GetProcAddress(ntdll, c"RtlGetVersion".as_ptr().cast()) else {
            return 0;
        };
        let rtl_get_version = std::mem::transmute::<Farproc, RtlGetVersion>(function);
        let mut info: OSVERSIONINFOW = std::mem::zeroed();
        info.dwOSVersionInfoSize = size_of::<OSVERSIONINFOW>() as u32;
        if rtl_get_version(&mut info) != 0 {
            return 0;
        }
        info.dwBuildNumber
    })
}

pub fn is_windows_11() -> bool {
    build_number() >= WINDOWS_11_BUILD
}

pub fn is_effect_supported(effect: WindowEffect) -> bool {
    match effect {
        WindowEffect::None => true,
        WindowEffect::Blur => composition_attribute().is_some(),
        WindowEffect::Mica => is_windows_11(),
        WindowEffect::Glass => false,
    }
}

/// Reapplied whole on every change, so the settings never fight.
#[derive(Clone, Copy)]
pub struct Style {
    pub title_bar_hidden: bool,
    pub rounded_corners: Option<bool>,
    pub effect: WindowEffect,
    pub tint: u32,
    pub dark: Option<bool>,
}

impl Style {
    pub const fn new() -> Self {
        Self {
            title_bar_hidden: false,
            rounded_corners: None,
            effect: WindowEffect::None,
            tint: 0,
            dark: None,
        }
    }

    // Windows 10 draws the top border only inside a frame extended over the
    // whole caption; a shorter non-client strip makes DWM draw the caption.
    fn extends_top_frame(&self) -> bool {
        self.title_bar_hidden && self.effect == WindowEffect::None && !is_windows_11()
    }

    /// Rows kept clear above the view and painted transparent: zero while an
    /// accent effect is on, maximized or full screen, and always on Windows 11.
    pub fn top_border_height(&self, hwnd: HWND) -> i32 {
        if hwnd.is_null() || !self.extends_top_frame() || unsafe { IsZoomed(hwnd) } != 0 {
            return 0;
        }
        let sizable = unsafe { GetWindowLongPtrW(hwnd, GWL_STYLE) } as u32 & WS_THICKFRAME != 0;
        i32::from(sizable)
    }

    /// The only writer of DWM attributes and composition accents.
    pub fn apply(&self, hwnd: HWND) {
        if hwnd.is_null() {
            return;
        }
        let build = build_number();
        unsafe {
            // An extended frame is filled opaque, which would cover an accent effect.
            let mut margins = MARGINS {
                cxLeftWidth: 0,
                cxRightWidth: 0,
                cyTopHeight: 0,
                cyBottomHeight: 0,
            };
            if self.effect == WindowEffect::Mica {
                margins = MARGINS {
                    cxLeftWidth: -1,
                    cxRightWidth: -1,
                    cyTopHeight: -1,
                    cyBottomHeight: -1,
                };
            } else if self.extends_top_frame() {
                let mut frame: RECT = std::mem::zeroed();
                AdjustWindowRectExForDpi(
                    &mut frame,
                    WS_OVERLAPPEDWINDOW,
                    0,
                    0,
                    GetDpiForWindow(hwnd),
                );
                margins.cyTopHeight = -frame.top;
            }
            DwmExtendFrameIntoClientArea(hwnd, &margins);

            if let Some(rounded) = self.rounded_corners {
                let preference = if rounded {
                    DWMWCP_ROUND
                } else {
                    DWMWCP_DONOTROUND
                };
                set_attribute(hwnd, DWMWA_WINDOW_CORNER_PREFERENCE, &preference);
            }

            let mica = self.effect == WindowEffect::Mica;
            if build >= SYSTEM_BACKDROP_BUILD {
                let backdrop = if mica { DWMSBT_MAINWINDOW } else { DWMSBT_NONE };
                set_attribute(hwnd, DWMWA_SYSTEMBACKDROP_TYPE, &backdrop);
            } else if is_windows_11() {
                set_attribute(hwnd, DWMWA_MICA_EFFECT, &BOOL::from(mica));
            }

            // The system backdrops take their light or dark material from this
            // attribute, which also colors the frame border.
            if let Some(dark) = self.dark {
                if build >= 17763 {
                    let attribute = if build >= 18985 {
                        DWMWA_USE_IMMERSIVE_DARK_MODE
                    } else {
                        DWMWA_USE_IMMERSIVE_DARK_MODE_BEFORE_20H1
                    };
                    set_attribute(hwnd, attribute, &BOOL::from(dark));
                }
            }

            // DWM draws the caption buttons into a frame extended under a hidden
            // caption; WS_SYSMENU gates them.
            let hide_buttons = self.title_bar_hidden && mica;
            let style = GetWindowLongPtrW(hwnd, GWL_STYLE);
            let style = if hide_buttons {
                style & !(WS_SYSMENU as isize)
            } else {
                style | WS_SYSMENU as isize
            };
            SetWindowLongPtrW(hwnd, GWL_STYLE, style);

            if let Some(set_composition_attribute) = composition_attribute() {
                let (accent_state, gradient_color) = match self.effect {
                    WindowEffect::Blur => (ACCENT_ENABLE_BLURBEHIND, accent_color(self.tint)),
                    _ => (ACCENT_DISABLED, 0),
                };
                let mut policy = AccentPolicy {
                    accent_state,
                    accent_flags: 2,
                    gradient_color,
                    animation_id: 0,
                };
                let mut data = CompositionAttributeData {
                    attribute: WCA_ACCENT_POLICY,
                    data: (&mut policy as *mut AccentPolicy).cast(),
                    size: size_of::<AccentPolicy>(),
                };
                set_composition_attribute(hwnd, &mut data);
            }

            SetWindowPos(
                hwnd,
                std::ptr::null_mut(),
                0,
                0,
                0,
                0,
                SWP_NOZORDER
                    | SWP_NOOWNERZORDER
                    | SWP_NOMOVE
                    | SWP_NOSIZE
                    | SWP_NOACTIVATE
                    | SWP_FRAMECHANGED,
            );
        }
    }
}

unsafe fn set_attribute<T>(hwnd: HWND, attribute: u32, value: &T) {
    DwmSetWindowAttribute(
        hwnd,
        attribute,
        (value as *const T).cast(),
        size_of::<T>() as u32,
    );
}

/// The composition accent takes ABGR.
pub fn accent_color(argb: u32) -> u32 {
    let a = argb >> 24 & 0xFF;
    let r = argb >> 16 & 0xFF;
    let g = argb >> 8 & 0xFF;
    let b = argb & 0xFF;
    a << 24 | b << 16 | g << 8 | r
}

#[cfg(test)]
mod tests {
    use super::accent_color;

    #[test]
    fn accent_color_swaps_red_and_blue() {
        assert_eq!(accent_color(0x8011_2233), 0x8033_2211);
    }
}
