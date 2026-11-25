use crate::frb_generated::StreamSink;
use crate::window;
use flutter_rust_bridge::for_generated::SseCodec;
use flutter_rust_bridge::frb;

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum WindowEffect {
    None,
    Blur,
    Mica,
    Glass,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum TitleBarStyle {
    Normal,
    Hidden,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum WindowBrightness {
    Light,
    Dark,
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub struct WindowBounds {
    pub x: f64,
    pub y: f64,
    pub width: f64,
    pub height: f64,
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub struct WindowPoint {
    pub x: f64,
    pub y: f64,
}

#[derive(Debug, Clone, Copy, PartialEq)]
pub struct WindowDisplay {
    pub bounds: WindowBounds,
    pub work_area: WindowBounds,
    pub scale_factor: f64,
    pub primary: bool,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum WindowSignal {
    Close,
    Maximize,
    Unmaximize,
    Minimize,
    Restore,
    GeometryChanged,
    EnterFullScreen,
    LeaveFullScreen,
    ShouldTerminate,
    Activate,
    LifecycleHidden,
    LifecycleInactive,
    LifecycleResumed,
    ScreensUnseen,
    ScreensSeen,
}

#[frb]
pub fn window_signals(sink: StreamSink<WindowSignal, SseCodec>) {
    window::listen(sink);
}

pub fn window_ensure_initialized() -> Result<(), String> {
    window::ensure_initialized()
}

pub fn window_show() -> Result<(), String> {
    window::show()
}

pub fn window_hide() -> Result<(), String> {
    window::hide()
}

pub fn window_is_visible() -> Result<bool, String> {
    window::is_visible()
}

pub fn window_focus() -> Result<(), String> {
    window::focus()
}

pub fn window_close() -> Result<(), String> {
    window::close()
}

pub fn window_set_prevent_close(value: bool) -> Result<(), String> {
    window::set_prevent_close(value)
}

pub fn window_is_maximized() -> Result<bool, String> {
    window::is_maximized()
}

pub fn window_maximize() -> Result<(), String> {
    window::maximize()
}

pub fn window_unmaximize() -> Result<(), String> {
    window::unmaximize()
}

pub fn window_is_minimized() -> Result<bool, String> {
    window::is_minimized()
}

pub fn window_minimize() -> Result<(), String> {
    window::minimize()
}

pub fn window_is_full_screen() -> Result<bool, String> {
    window::is_full_screen()
}

pub fn window_set_full_screen(value: bool) -> Result<(), String> {
    window::set_full_screen(value)
}

pub fn window_get_bounds() -> Result<WindowBounds, String> {
    window::get_bounds()
}

pub fn window_set_bounds(
    x: Option<f64>,
    y: Option<f64>,
    width: Option<f64>,
    height: Option<f64>,
) -> Result<(), String> {
    window::set_bounds(x.zip(y), width.zip(height))
}

pub fn window_get_displays() -> Result<Vec<WindowDisplay>, String> {
    window::get_displays()
}

pub fn window_get_cursor_position() -> Result<WindowPoint, String> {
    window::get_cursor_position()
}

pub fn window_is_position_supported() -> Result<bool, String> {
    window::is_position_supported()
}

pub fn window_set_minimum_size(width: f64, height: f64) -> Result<(), String> {
    window::set_minimum_size(width, height)
}

pub fn window_is_always_on_top() -> Result<bool, String> {
    window::is_always_on_top()
}

pub fn window_set_always_on_top(value: bool) -> Result<(), String> {
    window::set_always_on_top(value)
}

pub fn window_set_title_bar_style(style: TitleBarStyle) -> Result<(), String> {
    window::set_title_bar_style(style)
}

pub fn window_set_skip_taskbar(value: bool) -> Result<(), String> {
    window::set_skip_taskbar(value)
}

pub fn window_set_rounded_corners(value: bool) -> Result<(), String> {
    window::set_rounded_corners(value)
}

pub fn window_is_effect_supported(effect: WindowEffect) -> Result<bool, String> {
    window::is_effect_supported(effect)
}

pub fn window_set_effect(
    effect: WindowEffect,
    tint: Option<u32>,
    brightness: Option<WindowBrightness>,
) -> Result<(), String> {
    window::set_effect(effect, tint, brightness)
}

pub fn window_start_dragging() -> Result<(), String> {
    window::start_dragging()
}
