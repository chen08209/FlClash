//! The icon belongs to a hidden top-level window on a thread of its own: a
//! message-only window would miss `TaskbarCreated` and power broadcasts, and
//! `TrackPopupMenu` blocks the thread it runs on.

use super::emit;
use crate::api::tray::{TrayContent, TrayItem, TrayItemKind, TraySignalKind};
use std::mem::{size_of, zeroed};
use std::ptr::{null, null_mut};
use std::sync::{mpsc, Mutex, MutexGuard, OnceLock, PoisonError};

use windows_sys::core::PCSTR;
use windows_sys::Win32::Foundation::{HWND, LPARAM, LRESULT, POINT, WPARAM};
use windows_sys::Win32::Globalization::lstrcmpW;
use windows_sys::Win32::System::LibraryLoader::{
    GetModuleHandleW, GetProcAddress, LoadLibraryExW, LOAD_LIBRARY_SEARCH_SYSTEM32,
};
use windows_sys::Win32::System::SystemInformation::OSVERSIONINFOW;
use windows_sys::Win32::UI::Shell::{
    Shell_NotifyIconW, NIF_ICON, NIF_MESSAGE, NIF_TIP, NIM_ADD, NIM_DELETE, NIM_MODIFY,
    NOTIFYICONDATAW,
};
use windows_sys::Win32::UI::WindowsAndMessaging::{
    AppendMenuW, CreatePopupMenu, CreateWindowExW, DefWindowProcW, DestroyIcon, DestroyMenu,
    DispatchMessageW, GetCursorPos, GetMessageW, GetSystemMetrics, KillTimer, LoadImageW,
    PostMessageW, RegisterClassW, RegisterWindowMessageW, SetForegroundWindow, SetTimer,
    TrackPopupMenu, TranslateMessage, HICON, HMENU, IMAGE_ICON, LR_LOADFROMFILE, MF_CHECKED,
    MF_GRAYED, MF_POPUP, MF_SEPARATOR, MF_STRING, MF_UNCHECKED, MSG, PBT_APMRESUMEAUTOMATIC,
    PBT_APMRESUMESUSPEND, SM_CXSMICON, SM_CYSMICON, TPM_BOTTOMALIGN, TPM_LEFTALIGN, TPM_RETURNCMD,
    TPM_RIGHTBUTTON, WM_APP, WM_LBUTTONUP, WM_NULL, WM_POWERBROADCAST, WM_RBUTTONUP,
    WM_SETTINGCHANGE, WM_TIMER, WNDCLASSW, WS_OVERLAPPED,
};

const WM_TRAY: u32 = WM_APP + 1;
const WM_OPEN_MENU: u32 = WM_APP + 2;
const WM_RETRY: u32 = WM_APP + 3;
const ICON_ID: u32 = 1;
const RETRY_TIMER: usize = 1;
const RETRY_INTERVAL_MS: u32 = 2000;
// SetPreferredAppMode and FlushMenuThemes, the undocumented uxtheme ordinals
// Explorer uses for dark Win32 menus, exist from 1903 on.
const FIRST_DARK_MENU_BUILD: u32 = 18362;
const SET_PREFERRED_APP_MODE: usize = 135;
const FLUSH_MENU_THEMES: usize = 136;
const ALLOW_DARK: i32 = 1;

struct Icon(HICON);

// An HICON is a process-wide handle, not tied to the thread that loaded it.
unsafe impl Send for Icon {}

impl Drop for Icon {
    fn drop(&mut self) {
        unsafe { DestroyIcon(self.0) };
    }
}

#[derive(Default)]
struct State {
    icon: Option<Icon>,
    tool_tip: String,
    menu: Vec<TrayItem>,
    // An add the shell timed out on may still have landed, so `hide` deletes
    // whenever one was attempted.
    requested: bool,
    visible: bool,
}

static STATE: Mutex<State> = Mutex::new(State {
    icon: None,
    tool_tip: String::new(),
    menu: Vec::new(),
    requested: false,
    visible: false,
});
static WINDOW: OnceLock<Option<usize>> = OnceLock::new();
static TASKBAR_CREATED: OnceLock<u32> = OnceLock::new();
static FLUSH_MENUS: OnceLock<Option<unsafe extern "system" fn()>> = OnceLock::new();

pub fn show(content: TrayContent) -> bool {
    let Some(window) = window() else {
        return false;
    };
    let Some(icon) = load_icon(&content.image.path) else {
        return false;
    };
    let mut state = lock();
    state.icon = Some(icon);
    state.tool_tip = content.tool_tip;
    state.menu = content.menu;
    state.requested = true;
    let applied =
        notify(window, &state, !state.visible) || (state.visible && notify(window, &state, true));
    if applied {
        state.visible = true;
    } else {
        unsafe { PostMessageW(window, WM_RETRY, 0, 0) };
    }
    true
}

pub fn set_title(_title: String) -> bool {
    false
}

pub fn hide() {
    let Some(window) = existing_window() else {
        return;
    };
    let mut state = lock();
    if state.requested {
        let mut data = icon_data(window);
        data.uFlags = 0;
        unsafe { Shell_NotifyIconW(NIM_DELETE, &data) };
    }
    *state = State::default();
}

pub fn open_menu() -> bool {
    let Some(window) = existing_window() else {
        return false;
    };
    if !lock().visible {
        return false;
    }
    unsafe { PostMessageW(window, WM_OPEN_MENU, 0, 0) != 0 }
}

fn lock() -> MutexGuard<'static, State> {
    STATE.lock().unwrap_or_else(PoisonError::into_inner)
}

fn wide(text: &str) -> Vec<u16> {
    text.encode_utf16().chain(std::iter::once(0)).collect()
}

fn existing_window() -> Option<HWND> {
    WINDOW.get().copied().flatten().map(|window| window as HWND)
}

fn window() -> Option<HWND> {
    WINDOW
        .get_or_init(|| {
            let (ready, window) = mpsc::channel();
            std::thread::Builder::new()
                .name("tray".into())
                .spawn(move || run_window(ready))
                .ok()?;
            window.recv().ok().flatten()
        })
        .map(|window| window as HWND)
}

fn run_window(ready: mpsc::Sender<Option<usize>>) {
    let _ = TASKBAR_CREATED.set(unsafe { RegisterWindowMessageW(wide("TaskbarCreated").as_ptr()) });
    let _ = FLUSH_MENUS.set(allow_dark_menus());
    unsafe {
        let instance = GetModuleHandleW(null());
        let class = wide("FlClashTray");
        let window_class = WNDCLASSW {
            lpfnWndProc: Some(window_proc),
            hInstance: instance,
            lpszClassName: class.as_ptr(),
            ..zeroed()
        };
        RegisterClassW(&window_class);
        let window = CreateWindowExW(
            0,
            class.as_ptr(),
            null(),
            WS_OVERLAPPED,
            0,
            0,
            0,
            0,
            null_mut(),
            null_mut(),
            instance,
            null(),
        );
        let created = !window.is_null();
        let _ = ready.send(created.then_some(window as usize));
        if !created {
            return;
        }
        let mut message: MSG = zeroed();
        while GetMessageW(&mut message, null_mut(), 0, 0) > 0 {
            TranslateMessage(&message);
            DispatchMessageW(&message);
        }
    }
}

unsafe extern "system" fn window_proc(
    window: HWND,
    message: u32,
    wparam: WPARAM,
    lparam: LPARAM,
) -> LRESULT {
    match message {
        WM_TRAY => {
            match lparam as u32 {
                WM_LBUTTONUP => emit(TraySignalKind::IconActivated, 0),
                WM_RBUTTONUP => emit(TraySignalKind::MenuRequested, 0),
                _ => {}
            }
            return 0;
        }
        WM_OPEN_MENU => {
            popup_menu(window);
            return 0;
        }
        WM_RETRY => {
            SetTimer(window, RETRY_TIMER, RETRY_INTERVAL_MS, None);
            return 0;
        }
        WM_TIMER if wparam == RETRY_TIMER => {
            restore(window);
            return 0;
        }
        WM_SETTINGCHANGE if is_color_set_change(lparam) => {
            if let Some(flush) = FLUSH_MENUS.get().copied().flatten() {
                flush();
            }
        }
        WM_POWERBROADCAST
            if wparam == PBT_APMRESUMEAUTOMATIC as usize
                || wparam == PBT_APMRESUMESUSPEND as usize =>
        {
            restore(window);
        }
        _ if Some(&message) == TASKBAR_CREATED.get() => restore(window),
        _ => {}
    }
    DefWindowProcW(window, message, wparam, lparam)
}

fn icon_data(window: HWND) -> NOTIFYICONDATAW {
    let mut data: NOTIFYICONDATAW = unsafe { zeroed() };
    data.cbSize = size_of::<NOTIFYICONDATAW>() as u32;
    data.hWnd = window;
    data.uID = ICON_ID;
    data
}

fn notify(window: HWND, state: &State, add: bool) -> bool {
    let Some(icon) = &state.icon else {
        return false;
    };
    let mut data = icon_data(window);
    data.uFlags = NIF_MESSAGE | NIF_ICON | NIF_TIP;
    data.uCallbackMessage = WM_TRAY;
    data.hIcon = icon.0;
    let tip: Vec<u16> = state
        .tool_tip
        .encode_utf16()
        .take(data.szTip.len() - 1)
        .collect();
    data.szTip[..tip.len()].copy_from_slice(&tip);
    let action = if add { NIM_ADD } else { NIM_MODIFY };
    unsafe { Shell_NotifyIconW(action, &data) != 0 }
}

// An add that timed out may still have landed, so modify goes first.
fn restore(window: HWND) {
    let mut state = lock();
    if !state.requested {
        unsafe { KillTimer(window, RETRY_TIMER) };
        return;
    }
    if notify(window, &state, false) || notify(window, &state, true) {
        state.visible = true;
        unsafe { KillTimer(window, RETRY_TIMER) };
    } else {
        unsafe { SetTimer(window, RETRY_TIMER, RETRY_INTERVAL_MS, None) };
    }
}

fn load_icon(path: &str) -> Option<Icon> {
    let icon = unsafe {
        LoadImageW(
            null_mut(),
            wide(path).as_ptr(),
            IMAGE_ICON,
            GetSystemMetrics(SM_CXSMICON),
            GetSystemMetrics(SM_CYSMICON),
            LR_LOADFROMFILE,
        )
    };
    (!icon.is_null()).then_some(Icon(icon))
}

fn popup_menu(window: HWND) {
    let items = {
        let state = lock();
        if !state.visible {
            return;
        }
        state.menu.clone()
    };
    unsafe {
        let menu = build_menu(&items);
        let mut cursor = POINT { x: 0, y: 0 };
        GetCursorPos(&mut cursor);
        // Without the foreground the menu does not close when clicked away from.
        SetForegroundWindow(window);
        let command = TrackPopupMenu(
            menu,
            TPM_BOTTOMALIGN | TPM_LEFTALIGN | TPM_RETURNCMD | TPM_RIGHTBUTTON,
            cursor.x,
            cursor.y,
            0,
            window,
            null(),
        );
        PostMessageW(window, WM_NULL, 0, 0);
        DestroyMenu(menu);
        if command > 0 {
            emit(TraySignalKind::ItemSelected, command as u32);
        }
    }
}

unsafe fn build_menu(items: &[TrayItem]) -> HMENU {
    let menu = CreatePopupMenu();
    for item in items {
        if item.kind == TrayItemKind::Separator {
            AppendMenuW(menu, MF_SEPARATOR, 0, null());
            continue;
        }
        let mut flags = MF_STRING;
        if !item.enabled {
            flags |= MF_GRAYED;
        }
        let mut id = item.id as usize;
        match item.kind {
            TrayItemKind::Checkbox if item.checked => flags |= MF_CHECKED,
            TrayItemKind::Checkbox => flags |= MF_UNCHECKED,
            TrayItemKind::Submenu => {
                flags |= MF_POPUP;
                id = build_menu(&item.items) as usize;
            }
            _ => {}
        }
        AppendMenuW(menu, flags, id, wide(&menu_text(item)).as_ptr());
    }
    menu
}

// Win32 menus read `&` as a mnemonic marker, so a literal one is doubled.
fn menu_text(item: &TrayItem) -> String {
    let label = item.label.replace('&', "&&");
    match item.detail.as_deref() {
        Some(detail) if !detail.is_empty() => format!("{label}\t{}", detail.replace('&', "&&")),
        _ => label,
    }
}

fn is_color_set_change(lparam: LPARAM) -> bool {
    lparam != 0
        && unsafe { lstrcmpW(lparam as *const u16, wide("ImmersiveColorSet").as_ptr()) } == 0
}

fn allow_dark_menus() -> Option<unsafe extern "system" fn()> {
    if os_build()? < FIRST_DARK_MENU_BUILD {
        return None;
    }
    unsafe {
        let uxtheme = LoadLibraryExW(
            wide("uxtheme.dll").as_ptr(),
            null_mut(),
            LOAD_LIBRARY_SEARCH_SYSTEM32,
        );
        if uxtheme.is_null() {
            return None;
        }
        let set_mode = GetProcAddress(uxtheme, SET_PREFERRED_APP_MODE as PCSTR)?;
        let flush = GetProcAddress(uxtheme, FLUSH_MENU_THEMES as PCSTR)?;
        let set_mode: unsafe extern "system" fn(i32) -> i32 = std::mem::transmute(set_mode);
        let flush: unsafe extern "system" fn() = std::mem::transmute(flush);
        set_mode(ALLOW_DARK);
        flush();
        Some(flush)
    }
}

fn os_build() -> Option<u32> {
    unsafe {
        let ntdll = GetModuleHandleW(wide("ntdll.dll").as_ptr());
        if ntdll.is_null() {
            return None;
        }
        let get_version = GetProcAddress(ntdll, c"RtlGetVersion".as_ptr().cast())?;
        let get_version: unsafe extern "system" fn(*mut OSVERSIONINFOW) -> i32 =
            std::mem::transmute(get_version);
        let mut info: OSVERSIONINFOW = zeroed();
        info.dwOSVersionInfoSize = size_of::<OSVERSIONINFOW>() as u32;
        (get_version(&mut info) == 0).then_some(info.dwBuildNumber)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn item(label: &str, detail: Option<&str>) -> TrayItem {
        TrayItem {
            id: 1024,
            kind: TrayItemKind::Action,
            label: label.into(),
            detail: detail.map(Into::into),
            enabled: true,
            checked: false,
            items: Vec::new(),
        }
    }

    #[test]
    fn a_detail_goes_to_the_accelerator_column() {
        assert_eq!(menu_text(&item("Show", Some("Ctrl+S"))), "Show\tCtrl+S");
        assert_eq!(menu_text(&item("Show", Some(""))), "Show");
        assert_eq!(menu_text(&item("Show", None)), "Show");
    }

    #[test]
    fn an_ampersand_is_shown_rather_than_read_as_a_mnemonic() {
        assert_eq!(menu_text(&item("R&D", Some("A&B"))), "R&&D\tA&&B");
    }
}
