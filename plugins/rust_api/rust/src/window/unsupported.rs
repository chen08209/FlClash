use crate::api::window::{
    TitleBarStyle, WindowBounds, WindowBrightness, WindowDisplay, WindowEffect, WindowPoint,
};

const UNSUPPORTED: &str = "Desktop window control is not available on this platform";

fn unsupported<T>() -> Result<T, String> {
    Err(UNSUPPORTED.into())
}

pub fn ensure_initialized() -> Result<(), String> {
    unsupported()
}

pub fn show() -> Result<(), String> {
    unsupported()
}

pub fn hide() -> Result<(), String> {
    unsupported()
}

pub fn is_visible() -> Result<bool, String> {
    unsupported()
}

pub fn focus() -> Result<(), String> {
    unsupported()
}

pub fn close() -> Result<(), String> {
    unsupported()
}

pub fn set_prevent_close(_value: bool) -> Result<(), String> {
    unsupported()
}

pub fn is_maximized() -> Result<bool, String> {
    unsupported()
}

pub fn maximize() -> Result<(), String> {
    unsupported()
}

pub fn unmaximize() -> Result<(), String> {
    unsupported()
}

pub fn is_minimized() -> Result<bool, String> {
    unsupported()
}

pub fn minimize() -> Result<(), String> {
    unsupported()
}

pub fn is_full_screen() -> Result<bool, String> {
    unsupported()
}

pub fn set_full_screen(_value: bool) -> Result<(), String> {
    unsupported()
}

pub fn get_bounds() -> Result<WindowBounds, String> {
    unsupported()
}

pub fn set_bounds(_position: Option<(f64, f64)>, _size: Option<(f64, f64)>) -> Result<(), String> {
    unsupported()
}

pub fn is_position_supported() -> Result<bool, String> {
    unsupported()
}

pub fn set_minimum_size(_width: f64, _height: f64) -> Result<(), String> {
    unsupported()
}

pub fn is_always_on_top() -> Result<bool, String> {
    unsupported()
}

pub fn set_always_on_top(_value: bool) -> Result<(), String> {
    unsupported()
}

pub fn set_title_bar_style(_style: TitleBarStyle) -> Result<(), String> {
    unsupported()
}

pub fn set_skip_taskbar(_value: bool) -> Result<(), String> {
    unsupported()
}

pub fn set_rounded_corners(_value: bool) -> Result<(), String> {
    unsupported()
}

pub fn is_effect_supported(_effect: WindowEffect) -> Result<bool, String> {
    unsupported()
}

pub fn set_effect(
    _effect: WindowEffect,
    _tint: Option<u32>,
    _brightness: Option<WindowBrightness>,
) -> Result<(), String> {
    unsupported()
}

pub fn start_dragging() -> Result<(), String> {
    unsupported()
}

pub fn get_displays() -> Result<Vec<WindowDisplay>, String> {
    unsupported()
}

pub fn get_cursor_position() -> Result<WindowPoint, String> {
    unsupported()
}
