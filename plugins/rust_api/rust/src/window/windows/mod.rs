mod display;
mod instance;
mod style;
mod taskbar;

use super::{emit, GEOMETRY_SETTLE_MILLISECONDS};
use crate::api::window::{
    TitleBarStyle, WindowBounds, WindowBrightness, WindowDisplay, WindowEffect, WindowPoint,
    WindowSignal,
};
use std::cell::Cell;
use std::collections::VecDeque;
use std::ptr::null_mut;
use std::sync::atomic::{AtomicPtr, Ordering};
use std::sync::{mpsc, Mutex, OnceLock};
use style::Style;
use windows_sys::Win32::Foundation::{HWND, LPARAM, LRESULT, POINT, RECT, WPARAM};
use windows_sys::Win32::Graphics::Gdi::{
    BeginPaint, EndPaint, FillRect, GetMonitorInfoW, GetStockObject, MonitorFromWindow,
    BLACK_BRUSH, MONITORINFO, MONITOR_DEFAULTTONEAREST, PAINTSTRUCT,
};
use windows_sys::Win32::System::DataExchange::COPYDATASTRUCT;
use windows_sys::Win32::System::Threading::GetCurrentThreadId;
use windows_sys::Win32::UI::HiDpi::{AdjustWindowRectExForDpi, GetDpiForWindow};
use windows_sys::Win32::UI::Input::KeyboardAndMouse::ReleaseCapture;
use windows_sys::Win32::UI::WindowsAndMessaging::{
    DefWindowProcW, FindWindowExW, GetClientRect, GetCursorPos, GetWindowLongPtrW,
    GetWindowPlacement, GetWindowRect, GetWindowThreadProcessId, IsWindowVisible, IsZoomed,
    KillTimer, MoveWindow, PostMessageW, RegisterWindowMessageW, SendMessageW, SetForegroundWindow,
    SetTimer, SetWindowLongPtrW, SetWindowPos, ShowWindow, GWL_EXSTYLE, GWL_STYLE, HTCAPTION,
    HTCLIENT, HTTOP, HTTOPLEFT, HTTOPRIGHT, HWND_NOTOPMOST, HWND_TOP, HWND_TOPMOST, MINMAXINFO,
    NCCALCSIZE_PARAMS, SC_CLOSE, SC_MAXIMIZE, SC_MINIMIZE, SC_MOVE, SC_RESTORE, SIZE_MAXIMIZED,
    SIZE_MINIMIZED, SIZE_RESTORED, SWP_FRAMECHANGED, SWP_NOACTIVATE, SWP_NOMOVE, SWP_NOOWNERZORDER,
    SWP_NOSIZE, SWP_NOZORDER, SW_HIDE, SW_MAXIMIZE, SW_NORMAL, SW_SHOW, SW_SHOWMINIMIZED,
    WINDOWPLACEMENT, WINDOWPOS, WM_CLOSE, WM_COPYDATA, WM_DESTROY, WM_GETMINMAXINFO, WM_NCACTIVATE,
    WM_NCCALCSIZE, WM_NCHITTEST, WM_PAINT, WM_SIZE, WM_SYSCOMMAND, WM_TIMER, WM_WINDOWPOSCHANGED,
    WS_EX_TOPMOST, WS_MAXIMIZEBOX, WS_OVERLAPPEDWINDOW, WS_THICKFRAME,
};

const GEOMETRY_TIMER: usize = 0x5749_4E47;
const DEFAULT_DPI: f64 = 96.0;

type Job = Box<dyn FnOnce() + Send>;

static WINDOW: AtomicPtr<core::ffi::c_void> = AtomicPtr::new(null_mut());
static JOBS: Mutex<VecDeque<Job>> = Mutex::new(VecDeque::new());

#[derive(Clone, Copy, PartialEq, Eq)]
enum Placement {
    Normal,
    Maximized,
    Minimized,
}

#[derive(Clone, Copy)]
struct FullScreenSaved {
    maximized: bool,
    style: isize,
    frame: RECT,
}

struct State {
    hwnd: Cell<HWND>,
    view: Cell<HWND>,
    relaunch_allowed: Cell<bool>,
    prevent_close: Cell<bool>,
    minimum_size: Cell<(f64, f64)>,
    last_placement: Cell<Placement>,
    full_screen: Cell<bool>,
    full_screen_saved: Cell<FullScreenSaved>,
    style: Cell<Style>,
}

thread_local! {
    static STATE: State = const {
        State {
            hwnd: Cell::new(null_mut()),
            view: Cell::new(null_mut()),
            relaunch_allowed: Cell::new(false),
            prevent_close: Cell::new(false),
            minimum_size: Cell::new((0.0, 0.0)),
            last_placement: Cell::new(Placement::Normal),
            full_screen: Cell::new(false),
            full_screen_saved: Cell::new(FullScreenSaved {
                maximized: false,
                style: 0,
                frame: RECT { left: 0, top: 0, right: 0, bottom: 0 },
            }),
            style: Cell::new(Style::new()),
        }
    };
}

fn job_message() -> u32 {
    static MESSAGE: OnceLock<u32> = OnceLock::new();
    *MESSAGE.get_or_init(|| {
        let name: Vec<u16> = "flclash.window.job".encode_utf16().chain(Some(0)).collect();
        unsafe { RegisterWindowMessageW(name.as_ptr()) }
    })
}

/// Runs `f` on the window's thread from its message loop and waits for it.
fn on_main<T, F>(f: F) -> Result<T, String>
where
    T: Send + 'static,
    F: FnOnce(&State) -> Result<T, String> + Send + 'static,
{
    let window = WINDOW.load(Ordering::Acquire);
    if window.is_null() {
        return Err("The window does not exist yet".into());
    }
    let thread = unsafe { GetWindowThreadProcessId(window, null_mut()) };
    if thread == unsafe { GetCurrentThreadId() } {
        return STATE.with(f);
    }
    let (tx, rx) = mpsc::channel();
    lock_jobs().push_back(Box::new(move || {
        let _ = tx.send(STATE.with(f));
    }));
    if unsafe { PostMessageW(window, job_message(), 0, 0) } == 0 {
        lock_jobs().clear();
        return Err("The window is gone".into());
    }
    rx.recv()
        .map_err(|_| "The window closed before the call ran".to_owned())?
}

fn lock_jobs() -> std::sync::MutexGuard<'static, VecDeque<Job>> {
    JOBS.lock().unwrap_or_else(|poisoned| poisoned.into_inner())
}

fn run_jobs() {
    loop {
        let job = lock_jobs().pop_front();
        match job {
            Some(job) => job(),
            None => break,
        }
    }
}

/// The runner's top-level window procedure calls this after the engine's
/// delegates, where a plugin's `RegisterTopLevelWindowProcDelegate` ran.
///
/// # Safety
/// `result` must be valid for a write, and the call must come from the
/// thread that owns `hwnd`.
#[no_mangle]
pub unsafe extern "C" fn flclash_window_message(
    hwnd: HWND,
    message: u32,
    wparam: WPARAM,
    lparam: LPARAM,
    result: *mut LRESULT,
) -> bool {
    if message == WM_DESTROY {
        WINDOW.store(null_mut(), Ordering::Release);
        lock_jobs().clear();
        return false;
    }
    WINDOW.store(hwnd, Ordering::Release);
    if message == job_message() {
        run_jobs();
        *result = 0;
        return true;
    }
    match STATE.with(|state| handle_message(state, hwnd, message, wparam, lparam)) {
        Some(value) => {
            *result = value;
            true
        }
        None => false,
    }
}

fn to_physical(logical: f64, scale: f64) -> i32 {
    (logical * scale).round() as i32
}

fn dpi_scale(hwnd: HWND) -> f64 {
    if hwnd.is_null() {
        return 1.0;
    }
    f64::from(unsafe { GetDpiForWindow(hwnd) }) / DEFAULT_DPI
}

fn show_command(hwnd: HWND) -> u32 {
    let mut placement: WINDOWPLACEMENT = unsafe { std::mem::zeroed() };
    placement.length = std::mem::size_of::<WINDOWPLACEMENT>() as u32;
    unsafe { GetWindowPlacement(hwnd, &mut placement) };
    placement.showCmd
}

fn is_minimized_window(hwnd: HWND) -> bool {
    !hwnd.is_null() && show_command(hwnd) == SW_SHOWMINIMIZED as u32
}

fn is_maximized_window(hwnd: HWND) -> bool {
    !hwnd.is_null() && show_command(hwnd) == SW_MAXIMIZE as u32
}

fn frame_insets(hwnd: HWND, style: u32, ex_style: u32) -> RECT {
    let mut frame = RECT {
        left: 0,
        top: 0,
        right: 0,
        bottom: 0,
    };
    unsafe { AdjustWindowRectExForDpi(&mut frame, style, 0, ex_style, GetDpiForWindow(hwnd)) };
    frame
}

impl State {
    fn top_border_height(&self) -> i32 {
        self.style.get().top_border_height(self.hwnd.get())
    }

    // Minimizing changes the frame too; fitting the view to what is left would
    // lay the app out at mobile width, which a restore then shows.
    fn place_view(&self) {
        let (hwnd, view) = (self.hwnd.get(), self.view.get());
        if hwnd.is_null() || view.is_null() || is_minimized_window(hwnd) {
            return;
        }
        let mut client: RECT = unsafe { std::mem::zeroed() };
        unsafe { GetClientRect(hwnd, &mut client) };
        let border = self.top_border_height();
        let height = (client.bottom - border).max(0);
        unsafe { MoveWindow(view, 0, border, client.right, height, 1) };
    }

    fn set_style(&self, update: impl FnOnce(&mut Style)) {
        let mut style = self.style.get();
        update(&mut style);
        self.style.set(style);
        style.apply(self.hwnd.get());
    }

    fn require_window(&self) -> Result<HWND, String> {
        let hwnd = self.hwnd.get();
        if hwnd.is_null() {
            Err("ensureInitialized has not run".into())
        } else {
            Ok(hwnd)
        }
    }
}

fn handle_message(
    state: &State,
    hwnd: HWND,
    message: u32,
    wparam: WPARAM,
    lparam: LPARAM,
) -> Option<LRESULT> {
    if !state.relaunch_allowed.get() {
        state.relaunch_allowed.set(true);
        instance::allow_relaunch_messages(hwnd);
    }
    let title_bar_hidden = state.style.get().title_bar_hidden;
    match message {
        WM_NCCALCSIZE if wparam != 0 => {
            if !title_bar_hidden {
                return None;
            }
            if state.full_screen.get() {
                return Some(0);
            }
            // Insets come from the styles rather than DefWindowProc, so they do
            // not hinge on the runner's window class. A maximized window hangs
            // past the monitor edge by one frame width.
            let (style, ex_style) = unsafe {
                (
                    GetWindowLongPtrW(hwnd, GWL_STYLE),
                    GetWindowLongPtrW(hwnd, GWL_EXSTYLE),
                )
            };
            let frame = frame_insets(hwnd, style as u32, ex_style as u32);
            let rect = unsafe { &mut (*(lparam as *mut NCCALCSIZE_PARAMS)).rgrc[0] };
            rect.left -= frame.left;
            rect.right -= frame.right;
            rect.bottom -= frame.bottom;
            // Windows 11 draws the top border only into a non-client strip;
            // Windows 10 draws the whole caption over any strip shorter than one
            // (Windows Terminal, NonClientIslandWindow::_UpdateFrameMargins).
            rect.top += if is_maximized_window(hwnd) {
                frame.bottom
            } else {
                i32::from(style::is_windows_11())
            };
            Some(0)
        }
        WM_GETMINMAXINFO => {
            let info = unsafe { &mut *(lparam as *mut MINMAXINFO) };
            let scale = dpi_scale(hwnd);
            let (width, height) = state.minimum_size.get();
            if width != 0.0 {
                info.ptMinTrackSize.x = (width * scale) as i32;
            }
            if height != 0.0 {
                info.ptMinTrackSize.y = (height * scale) as i32;
            }
            Some(0)
        }
        WM_NCACTIVATE if title_bar_hidden => Some(1),
        WM_WINDOWPOSCHANGED => {
            let position = unsafe { &*(lparam as *const WINDOWPOS) };
            if position.flags & SWP_FRAMECHANGED != 0 {
                state.place_view();
            }
            if position.flags & SWP_NOMOVE == 0 || position.flags & SWP_NOSIZE == 0 {
                unsafe { SetTimer(hwnd, GEOMETRY_TIMER, GEOMETRY_SETTLE_MILLISECONDS, None) };
            }
            None
        }
        WM_TIMER if wparam == GEOMETRY_TIMER => {
            unsafe { KillTimer(hwnd, GEOMETRY_TIMER) };
            emit(WindowSignal::GeometryChanged);
            Some(0)
        }
        WM_SIZE => {
            if !state.full_screen.get() {
                match wparam as u32 {
                    SIZE_MAXIMIZED => {
                        emit(WindowSignal::Maximize);
                        state.last_placement.set(Placement::Maximized);
                    }
                    SIZE_MINIMIZED => {
                        emit(WindowSignal::Minimize);
                        state.last_placement.set(Placement::Minimized);
                        return Some(0);
                    }
                    SIZE_RESTORED => match state.last_placement.get() {
                        Placement::Maximized => {
                            emit(WindowSignal::Unmaximize);
                            state.last_placement.set(Placement::Normal);
                        }
                        Placement::Minimized => {
                            emit(WindowSignal::Restore);
                            state.last_placement.set(Placement::Normal);
                        }
                        Placement::Normal => {}
                    },
                    _ => {}
                }
            }
            if state.view.get().is_null() {
                return None;
            }
            state.place_view();
            Some(0)
        }
        WM_PAINT => {
            let border = state.top_border_height();
            if border == 0 {
                return None;
            }
            unsafe {
                let mut paint: PAINTSTRUCT = std::mem::zeroed();
                let dc = BeginPaint(hwnd, &mut paint);
                let mut strip = paint.rcPaint;
                strip.bottom = strip.bottom.min(border);
                // DWM shows the extended frame where the client is black (alpha 0).
                if strip.top < strip.bottom {
                    FillRect(dc, &strip, GetStockObject(BLACK_BRUSH));
                }
                EndPaint(hwnd, &paint);
            }
            Some(0)
        }
        WM_NCHITTEST => {
            let border = state.top_border_height();
            if border == 0 {
                return None;
            }
            let hit = unsafe { DefWindowProcW(hwnd, message, wparam, lparam) };
            let point = POINT {
                x: i32::from(lparam as u16 as i16),
                y: i32::from((lparam >> 16) as u16 as i16),
            };
            let mut window: RECT = unsafe { std::mem::zeroed() };
            unsafe { GetWindowRect(hwnd, &mut window) };
            if hit != HTCLIENT as LRESULT || point.y >= window.top + border {
                return Some(hit);
            }
            let corner = -frame_insets(hwnd, WS_OVERLAPPEDWINDOW, 0).left * 2;
            let edge = if point.x < window.left + corner {
                HTTOPLEFT
            } else if point.x >= window.right - corner {
                HTTOPRIGHT
            } else {
                HTTOP
            };
            Some(edge as LRESULT)
        }
        WM_CLOSE => {
            emit(WindowSignal::Close);
            state.prevent_close.get().then_some(-1)
        }
        WM_COPYDATA => {
            let data = unsafe { &*(lparam as *const COPYDATASTRUCT) };
            if data.dwData != instance::LINK_COPY_DATA || data.lpData.is_null() {
                return None;
            }
            let units = unsafe {
                std::slice::from_raw_parts(data.lpData as *const u16, data.cbData as usize / 2)
            };
            super::link::push(String::from_utf16_lossy(units));
            Some(instance::HANDLED)
        }
        _ if message == instance::activate_message() => {
            emit(WindowSignal::Activate);
            Some(instance::HANDLED)
        }
        _ => None,
    }
}

pub fn ensure_initialized() -> Result<(), String> {
    on_main(|state| {
        let hwnd = WINDOW.load(Ordering::Acquire);
        if state.hwnd.get() == hwnd {
            return Ok(());
        }
        let class: Vec<u16> = "FLUTTERVIEW".encode_utf16().chain(Some(0)).collect();
        let view = unsafe { FindWindowExW(hwnd, null_mut(), class.as_ptr(), std::ptr::null()) };
        if view.is_null() {
            return Err("The Flutter view is not a child of the window".into());
        }
        state.hwnd.set(hwnd);
        state.view.set(view);
        unsafe { ShowWindow(hwnd, SW_HIDE) };
        Ok(())
    })
}

pub fn show() -> Result<(), String> {
    on_main(|state| {
        let hwnd = state.require_window()?;
        unsafe {
            ShowWindow(hwnd, SW_SHOW);
            SetForegroundWindow(hwnd);
        }
        Ok(())
    })
}

pub fn hide() -> Result<(), String> {
    on_main(|state| {
        unsafe { ShowWindow(state.require_window()?, SW_HIDE) };
        Ok(())
    })
}

pub fn is_visible() -> Result<bool, String> {
    on_main(|state| {
        let hwnd = state.hwnd.get();
        Ok(!hwnd.is_null() && unsafe { IsWindowVisible(hwnd) } != 0)
    })
}

pub fn focus() -> Result<(), String> {
    on_main(|state| {
        let hwnd = state.require_window()?;
        if is_minimized_window(hwnd) {
            restore_window(hwnd);
        }
        unsafe {
            SetWindowPos(hwnd, HWND_TOP, 0, 0, 0, 0, SWP_NOSIZE | SWP_NOMOVE);
            SetForegroundWindow(hwnd);
        }
        Ok(())
    })
}

fn post_command(hwnd: HWND, command: u32) {
    unsafe { PostMessageW(hwnd, WM_SYSCOMMAND, command as WPARAM, 0) };
}

fn restore_window(hwnd: HWND) {
    if show_command(hwnd) != SW_NORMAL as u32 {
        post_command(hwnd, SC_RESTORE);
    }
}

pub fn close() -> Result<(), String> {
    on_main(|state| {
        post_command(state.require_window()?, SC_CLOSE);
        Ok(())
    })
}

pub fn set_prevent_close(value: bool) -> Result<(), String> {
    on_main(move |state| {
        state.prevent_close.set(value);
        Ok(())
    })
}

pub fn is_maximized() -> Result<bool, String> {
    on_main(|state| Ok(is_maximized_window(state.hwnd.get())))
}

pub fn maximize() -> Result<(), String> {
    on_main(|state| {
        let hwnd = state.require_window()?;
        if !is_maximized_window(hwnd) {
            post_command(hwnd, SC_MAXIMIZE);
        }
        Ok(())
    })
}

pub fn unmaximize() -> Result<(), String> {
    on_main(|state| {
        let hwnd = state.require_window()?;
        if is_maximized_window(hwnd) {
            post_command(hwnd, SC_RESTORE);
        }
        Ok(())
    })
}

pub fn is_minimized() -> Result<bool, String> {
    on_main(|state| Ok(is_minimized_window(state.hwnd.get())))
}

pub fn minimize() -> Result<(), String> {
    on_main(|state| {
        let hwnd = state.require_window()?;
        if !state.full_screen.get() && !is_minimized_window(hwnd) {
            post_command(hwnd, SC_MINIMIZE);
        }
        Ok(())
    })
}

pub fn is_full_screen() -> Result<bool, String> {
    on_main(|state| Ok(state.full_screen.get()))
}

pub fn set_full_screen(value: bool) -> Result<(), String> {
    on_main(move |state| {
        let hwnd = state.require_window()?;
        if value == state.full_screen.get() {
            return Ok(());
        }
        unsafe {
            if value {
                let mut saved = FullScreenSaved {
                    maximized: IsZoomed(hwnd) != 0,
                    style: GetWindowLongPtrW(hwnd, GWL_STYLE),
                    frame: std::mem::zeroed(),
                };
                GetWindowRect(hwnd, &mut saved.frame);
                state.full_screen_saved.set(saved);
                state.full_screen.set(true);
                state.last_placement.set(Placement::Normal);

                let mut monitor: MONITORINFO = std::mem::zeroed();
                monitor.cbSize = std::mem::size_of::<MONITORINFO>() as u32;
                GetMonitorInfoW(
                    MonitorFromWindow(hwnd, MONITOR_DEFAULTTONEAREST),
                    &mut monitor,
                );
                let bounds = monitor.rcMonitor;
                SetWindowLongPtrW(
                    hwnd,
                    GWL_STYLE,
                    saved.style & !((WS_THICKFRAME | WS_MAXIMIZEBOX) as isize),
                );
                SetWindowPos(
                    hwnd,
                    HWND_TOP,
                    bounds.left,
                    bounds.top,
                    0,
                    0,
                    SWP_NOSIZE | SWP_NOOWNERZORDER | SWP_FRAMECHANGED,
                );
                SetWindowPos(
                    hwnd,
                    HWND_TOP,
                    0,
                    0,
                    bounds.right - bounds.left,
                    bounds.bottom - bounds.top,
                    SWP_NOMOVE | SWP_NOOWNERZORDER | SWP_FRAMECHANGED,
                );
                emit(WindowSignal::EnterFullScreen);
                return Ok(());
            }

            let saved = state.full_screen_saved.get();
            state.full_screen.set(false);
            SetWindowLongPtrW(
                hwnd,
                GWL_STYLE,
                saved.style | (WS_THICKFRAME | WS_MAXIMIZEBOX) as isize,
            );
            if IsZoomed(hwnd) != 0 {
                SetWindowPos(
                    hwnd,
                    null_mut(),
                    0,
                    0,
                    0,
                    0,
                    SWP_NOACTIVATE | SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED,
                );
                if saved.maximized {
                    post_command(hwnd, SC_MAXIMIZE);
                }
            } else {
                let frame = saved.frame;
                SetWindowPos(
                    hwnd,
                    null_mut(),
                    frame.left,
                    frame.top,
                    frame.right - frame.left,
                    frame.bottom - frame.top,
                    SWP_NOACTIVATE | SWP_NOZORDER,
                );
            }
            state.style.get().apply(hwnd);
            emit(WindowSignal::LeaveFullScreen);
        }
        Ok(())
    })
}

pub fn get_bounds() -> Result<WindowBounds, String> {
    on_main(|state| {
        let hwnd = state.require_window()?;
        let mut rect: RECT = unsafe { std::mem::zeroed() };
        unsafe { GetWindowRect(hwnd, &mut rect) };
        let scale = dpi_scale(hwnd);
        Ok(WindowBounds {
            x: f64::from(rect.left) / scale,
            y: f64::from(rect.top) / scale,
            width: f64::from(rect.right - rect.left) / scale,
            height: f64::from(rect.bottom - rect.top) / scale,
        })
    })
}

pub fn get_displays() -> Result<Vec<WindowDisplay>, String> {
    on_main(|state| Ok(display::all(dpi_scale(state.hwnd.get()))))
}

pub fn get_cursor_position() -> Result<WindowPoint, String> {
    on_main(|state| {
        let mut point = POINT { x: 0, y: 0 };
        unsafe { GetCursorPos(&mut point) };
        let scale = dpi_scale(state.hwnd.get());
        Ok(WindowPoint {
            x: f64::from(point.x) / scale,
            y: f64::from(point.y) / scale,
        })
    })
}

pub fn set_bounds(position: Option<(f64, f64)>, size: Option<(f64, f64)>) -> Result<(), String> {
    on_main(move |state| {
        let hwnd = state.require_window()?;
        let dpi = unsafe { GetDpiForWindow(hwnd) };
        let scale = dpi_scale(hwnd);
        let mut flags = SWP_NOZORDER | SWP_NOACTIVATE;
        let (x, y) = position.map_or_else(
            || {
                flags |= SWP_NOMOVE;
                (0, 0)
            },
            |(x, y)| (to_physical(x, scale), to_physical(y, scale)),
        );
        let (width, height) = size.map_or_else(
            || {
                flags |= SWP_NOSIZE;
                (0, 0)
            },
            |(width, height)| (to_physical(width, scale), to_physical(height, scale)),
        );
        unsafe { SetWindowPos(hwnd, null_mut(), x, y, width, height, flags) };
        // The runner applied the WM_DPICHANGED rect, whose origin Windows picks.
        if position.is_some() && unsafe { GetDpiForWindow(hwnd) } != dpi {
            unsafe {
                SetWindowPos(
                    hwnd,
                    null_mut(),
                    x,
                    y,
                    0,
                    0,
                    SWP_NOZORDER | SWP_NOACTIVATE | SWP_NOSIZE,
                )
            };
        }
        Ok(())
    })
}

pub fn is_position_supported() -> Result<bool, String> {
    Ok(true)
}

pub fn set_minimum_size(width: f64, height: f64) -> Result<(), String> {
    on_main(move |state| {
        let size = if width >= 0.0 && height >= 0.0 {
            (width.trunc(), height.trunc())
        } else {
            (0.0, 0.0)
        };
        state.minimum_size.set(size);
        Ok(())
    })
}

pub fn is_always_on_top() -> Result<bool, String> {
    on_main(|state| {
        let hwnd = state.hwnd.get();
        Ok(!hwnd.is_null()
            && unsafe { GetWindowLongPtrW(hwnd, GWL_EXSTYLE) } as u32 & WS_EX_TOPMOST != 0)
    })
}

pub fn set_always_on_top(value: bool) -> Result<(), String> {
    on_main(move |state| {
        let after = if value { HWND_TOPMOST } else { HWND_NOTOPMOST };
        unsafe {
            SetWindowPos(
                state.require_window()?,
                after,
                0,
                0,
                0,
                0,
                SWP_NOMOVE | SWP_NOSIZE,
            )
        };
        Ok(())
    })
}

pub fn set_title_bar_style(style: TitleBarStyle) -> Result<(), String> {
    on_main(move |state| {
        state.require_window()?;
        state.set_style(|current| current.title_bar_hidden = style == TitleBarStyle::Hidden);
        Ok(())
    })
}

pub fn set_skip_taskbar(value: bool) -> Result<(), String> {
    on_main(move |state| taskbar::set_tab(state.require_window()?, !value))
}

pub fn set_rounded_corners(value: bool) -> Result<(), String> {
    on_main(move |state| {
        state.require_window()?;
        state.set_style(|current| current.rounded_corners = Some(value));
        Ok(())
    })
}

pub fn is_effect_supported(effect: WindowEffect) -> Result<bool, String> {
    Ok(style::is_effect_supported(effect))
}

pub fn set_effect(
    effect: WindowEffect,
    tint: Option<u32>,
    brightness: Option<WindowBrightness>,
) -> Result<(), String> {
    if !style::is_effect_supported(effect) {
        return Err(format!("{effect:?} is not supported"));
    }
    on_main(move |state| {
        state.require_window()?;
        state.set_style(|current| {
            current.effect = effect;
            current.tint = tint.unwrap_or(0);
            current.dark = brightness.map(|brightness| brightness == WindowBrightness::Dark);
        });
        Ok(())
    })
}

pub fn start_dragging() -> Result<(), String> {
    on_main(|state| {
        let hwnd = state.require_window()?;
        unsafe {
            ReleaseCapture();
            SendMessageW(hwnd, WM_SYSCOMMAND, (SC_MOVE | HTCAPTION) as WPARAM, 0);
        }
        Ok(())
    })
}
