mod back_buffer;
mod effect;
mod title_bar;

use super::{emit, GEOMETRY_SETTLE_MILLISECONDS};
use crate::api::window::{
    TitleBarStyle, WindowBounds, WindowBrightness, WindowDisplay, WindowEffect, WindowPoint,
    WindowSignal,
};
use dispatch2::{DispatchQueue, DispatchTime};
use effect::EffectHost;
use objc2::rc::Retained;
use objc2::runtime::{AnyClass, NSObjectProtocol, ProtocolObject};
use objc2::{define_class, msg_send, sel, MainThreadMarker, MainThreadOnly};
use objc2_app_kit::{
    NSAppearance, NSAppearanceCustomization, NSAppearanceNameAqua, NSAppearanceNameDarkAqua,
    NSApplication, NSApplicationActivationPolicy, NSApplicationDidBecomeActiveNotification,
    NSApplicationWillBecomeActiveNotification, NSApplicationWillResignActiveNotification, NSColor,
    NSEvent, NSFloatingWindowLevel, NSNormalWindowLevel, NSScreen, NSWindow,
    NSWindowCollectionBehavior, NSWindowDelegate, NSWindowStyleMask, NSWindowTitleVisibility,
};
use objc2_foundation::{
    NSArray, NSNotification, NSNotificationCenter, NSNotificationName, NSObject, NSPoint, NSRect,
    NSSize, NSString,
};
use std::cell::{Cell, RefCell};
use std::sync::Once;

const SHOULD_TERMINATE: &str = "FlClashApplicationShouldTerminate";
const REOPEN: &str = "FlClashApplicationReopen";
const OPEN_LINK: &str = "FlClashApplicationOpenLink";
const SHOW_ACTIVATION_WAIT_NANOSECONDS: i64 = 500_000_000;
const SPACE_BEHAVIOR_RESTORE_NANOSECONDS: i64 = 200_000_000;

define_class!(
    #[unsafe(super(NSObject))]
    #[thread_kind = MainThreadOnly]
    #[name = "FlClashWindowDelegate"]
    struct Delegate;

    unsafe impl NSObjectProtocol for Delegate {}

    unsafe impl NSWindowDelegate for Delegate {
        #[unsafe(method(windowShouldClose:))]
        fn window_should_close(&self, _sender: &NSWindow) -> bool {
            emit(WindowSignal::Close);
            !STATE.with(|state| state.prevent_close.get())
        }

        #[unsafe(method(windowDidResize:))]
        fn window_did_resize(&self, _notification: &NSNotification) {
            STATE.with(|state| {
                state.schedule_geometry_changed();
                let Some(window) = state.window() else { return };
                state.remember_normal_frame(&window);
                // AppKit has no maximize call of its own; a resize that flips
                // the maximized state is one.
                let zoomed = is_maximized_window(&window);
                if zoomed != state.was_zoomed.replace(zoomed) {
                    emit(if zoomed {
                        WindowSignal::Maximize
                    } else {
                        WindowSignal::Unmaximize
                    });
                }
            });
        }

        #[unsafe(method(windowDidMove:))]
        fn window_did_move(&self, _notification: &NSNotification) {
            STATE.with(|state| {
                state.schedule_geometry_changed();
                if let Some(window) = state.window() {
                    state.remember_normal_frame(&window);
                }
            });
        }

        #[unsafe(method(windowDidMiniaturize:))]
        fn window_did_miniaturize(&self, _notification: &NSNotification) {
            emit(WindowSignal::Minimize);
        }

        #[unsafe(method(windowDidDeminiaturize:))]
        fn window_did_deminiaturize(&self, _notification: &NSNotification) {
            emit(WindowSignal::Restore);
            STATE.with(State::became_visible);
        }

        #[unsafe(method(windowDidEnterFullScreen:))]
        fn window_did_enter_full_screen(&self, _notification: &NSNotification) {
            emit(WindowSignal::EnterFullScreen);
        }

        #[unsafe(method(windowDidExitFullScreen:))]
        fn window_did_exit_full_screen(&self, _notification: &NSNotification) {
            emit(WindowSignal::LeaveFullScreen);
        }
    }

    impl Delegate {
        // The engine resumes on activation if any app window is visible, and
        // the status item's always is.
        #[unsafe(method(applicationActivityChanged:))]
        fn application_activity_changed(&self, notification: &NSNotification) {
            let active = &*notification.name() == unsafe { NSApplicationWillBecomeActiveNotification };
            STATE.with(|state| state.active.set(active));
            DispatchQueue::main().exec_async(|| {
                STATE.with(|state| {
                    if state.window().is_some_and(|window| !window.isVisible()) {
                        state.reported_hidden.set(true);
                        emit(WindowSignal::LifecycleHidden);
                    }
                });
            });
        }

        #[unsafe(method(applicationDidBecomeActive:))]
        fn application_did_become_active(&self, _notification: &NSNotification) {
            STATE.with(State::finish_show);
        }

        #[unsafe(method(shouldTerminate:))]
        fn should_terminate(&self, _notification: &NSNotification) {
            emit(WindowSignal::ShouldTerminate);
        }

        #[unsafe(method(reopen:))]
        fn reopen(&self, _notification: &NSNotification) {
            emit(WindowSignal::Activate);
        }

        #[unsafe(method(openLink:))]
        fn open_link(&self, notification: &NSNotification) {
            if let Some(link) = notification
                .object()
                .and_then(|object| object.downcast::<NSString>().ok())
            {
                super::link::push(link.to_string());
            }
        }
    }
);

#[derive(Clone, Copy)]
struct Style {
    title_bar_hidden: bool,
    effect: WindowEffect,
    tint: Option<u32>,
    brightness: Option<WindowBrightness>,
}

struct State {
    delegate: RefCell<Option<Retained<Delegate>>>,
    window: RefCell<Option<Retained<NSWindow>>>,
    host: RefCell<Option<EffectHost>>,
    style: Cell<Style>,
    prevent_close: Cell<bool>,
    was_zoomed: Cell<bool>,
    normal_frame: Cell<Option<NSRect>>,
    space_behavior: Cell<Option<NSWindowCollectionBehavior>>,
    show_pending: Cell<bool>,
    active: Cell<bool>,
    reported_hidden: Cell<bool>,
    geometry_generation: Cell<u64>,
}

thread_local! {
    static STATE: State = const {
        State {
            delegate: RefCell::new(None),
            window: RefCell::new(None),
            host: RefCell::new(None),
            style: Cell::new(Style {
                title_bar_hidden: false,
                effect: WindowEffect::None,
                tint: None,
                brightness: None,
            }),
            prevent_close: Cell::new(false),
            was_zoomed: Cell::new(false),
            normal_frame: Cell::new(None),
            space_behavior: Cell::new(None),
            show_pending: Cell::new(false),
            active: Cell::new(false),
            reported_hidden: Cell::new(false),
            geometry_generation: Cell::new(0),
        }
    };
}

impl State {
    fn window(&self) -> Option<Retained<NSWindow>> {
        self.window.borrow().clone()
    }

    fn require_window(&self) -> Result<Retained<NSWindow>, String> {
        self.window()
            .ok_or_else(|| "ensureInitialized has not run".to_owned())
    }

    fn delegate(&self, mtm: MainThreadMarker) -> Retained<Delegate> {
        self.delegate
            .borrow_mut()
            .get_or_insert_with(|| unsafe { msg_send![Delegate::alloc(mtm), init] })
            .clone()
    }

    fn remember_normal_frame(&self, window: &NSWindow) {
        if !is_maximized_window(window)
            && !is_full_screen_window(window)
            && !window.isMiniaturized()
        {
            self.normal_frame.set(Some(window.frame()));
        }
    }

    // A hidden window otherwise returns to the Space it was first shown on,
    // switching the user there; a fullscreen one keeps its own Space.
    // MoveToActiveSpace moves it only when it is ordered in while the app is
    // active, so an inactive app orders it in once its activation completes.
    fn show_on_active_space(&self, window: &NSWindow, mtm: MainThreadMarker) {
        let app = NSApplication::sharedApplication(mtm);
        if !is_full_screen_window(window) && self.space_behavior.get().is_none() {
            let behavior = window.collectionBehavior();
            self.space_behavior.set(Some(behavior));
            window.setCollectionBehavior(behavior | NSWindowCollectionBehavior::MoveToActiveSpace);
        }
        if app.isActive() {
            self.order_in(window);
        } else {
            self.show_pending.set(true);
            let _ = DispatchQueue::main().after(
                DispatchTime::NOW.time(SHOW_ACTIVATION_WAIT_NANOSECONDS),
                || STATE.with(State::finish_show),
            );
        }
        #[allow(deprecated)]
        app.activateIgnoringOtherApps(true);
    }

    fn finish_show(&self) {
        if self.show_pending.replace(false) {
            if let Some(window) = self.window() {
                self.order_in(&window);
            }
        }
    }

    fn order_in(&self, window: &NSWindow) {
        window.makeKeyAndOrderFront(None);
        if window.isVisible() {
            self.became_visible();
        }
        let _ = DispatchQueue::main().after(
            DispatchTime::NOW.time(SPACE_BEHAVIOR_RESTORE_NANOSECONDS),
            || STATE.with(State::restore_space_behavior),
        );
    }

    fn restore_space_behavior(&self) {
        if self.show_pending.get() {
            return;
        }
        if let (Some(behavior), Some(window)) = (self.space_behavior.take(), self.window()) {
            window.setCollectionBehavior(behavior);
        }
    }

    fn maximize(&self, window: &NSWindow) {
        if !is_maximized_window(window) {
            window.zoom(None);
        }
    }

    fn unmaximize(&self, window: &NSWindow) {
        if window.isZoomed() {
            window.zoom(None);
        }
        if is_maximized_window(window) {
            if let Some(frame) = self.normal_frame.get() {
                window.setFrame_display_animate(frame, true, true);
            }
        }
    }

    fn schedule_geometry_changed(&self) {
        let generation = self.geometry_generation.get().wrapping_add(1);
        self.geometry_generation.set(generation);
        let delay = i64::from(GEOMETRY_SETTLE_MILLISECONDS) * 1_000_000;
        let _ = DispatchQueue::main().after(DispatchTime::NOW.time(delay), move || {
            STATE.with(|state| {
                if state.geometry_generation.get() == generation {
                    emit(WindowSignal::GeometryChanged);
                }
            });
        });
    }

    // Back without another activation change, the window would wait on an
    // occlusion notification macOS may not post.
    fn became_visible(&self) {
        if self.reported_hidden.replace(false) {
            emit(if self.active.get() {
                WindowSignal::LifecycleResumed
            } else {
                WindowSignal::LifecycleInactive
            });
        }
    }

    fn apply_style(&self, window: &NSWindow, mtm: MainThreadMarker) {
        let style = self.style.get();
        let mut mask = window.styleMask();
        if style.title_bar_hidden {
            window.setTitleVisibility(NSWindowTitleVisibility::Hidden);
            window.setTitlebarAppearsTransparent(true);
            mask |= NSWindowStyleMask::FullSizeContentView;
        } else {
            window.setTitleVisibility(NSWindowTitleVisibility::Visible);
            window.setTitlebarAppearsTransparent(false);
            mask &= !NSWindowStyleMask::FullSizeContentView;
        }
        window.setStyleMask(mask);

        let opaque = matches!(style.effect, WindowEffect::None | WindowEffect::Glass);
        window.setOpaque(opaque);
        let background = if opaque {
            NSColor::windowBackgroundColor()
        } else {
            NSColor::clearColor()
        };
        window.setBackgroundColor(Some(&background));
        window.setHasShadow(true);
        let appearance = appearance(style.brightness);
        // Glass takes its light or dark material from the window, not its view.
        let window_appearance = (style.effect == WindowEffect::Glass)
            .then_some(appearance.as_deref())
            .flatten();
        window.setAppearance(window_appearance);

        let host = self.host.borrow().clone();
        if let Some(host) = host {
            let tint = style.tint.map(color);
            host.apply(style.effect, tint.as_deref(), appearance.as_deref(), mtm);
        }
    }
}

fn appearance(brightness: Option<WindowBrightness>) -> Option<Retained<NSAppearance>> {
    let name = match brightness? {
        WindowBrightness::Light => unsafe { NSAppearanceNameAqua },
        WindowBrightness::Dark => unsafe { NSAppearanceNameDarkAqua },
    };
    NSAppearance::appearanceNamed(name)
}

fn argb_channels(argb: u32) -> [f64; 4] {
    let channel = |shift: u32| f64::from((argb >> shift) & 0xFF) / 255.0;
    [channel(24), channel(16), channel(8), channel(0)]
}

fn color(argb: u32) -> Retained<NSColor> {
    let [alpha, red, green, blue] = argb_channels(argb);
    NSColor::colorWithRed_green_blue_alpha(red, green, blue, alpha)
}

fn on_main<T, F>(f: F) -> Result<T, String>
where
    T: Send,
    F: FnOnce(&State, MainThreadMarker) -> Result<T, String> + Send,
{
    let run = |f: F| {
        let mtm = MainThreadMarker::new().expect("runs on the main thread");
        STATE.with(|state| f(state, mtm))
    };
    if MainThreadMarker::new().is_some() {
        return run(f);
    }
    let mut result = None;
    DispatchQueue::main().exec_sync(|| result = Some(run(f)));
    result.unwrap_or_else(|| Err("The main queue did not run the call".into()))
}

pub(super) fn observe() {
    static OBSERVE: Once = Once::new();
    OBSERVE.call_once(|| {
        DispatchQueue::main().exec_async(|| {
            let mtm = MainThreadMarker::new().expect("the main queue runs on the main thread");
            STATE.with(|state| {
                state
                    .active
                    .set(NSApplication::sharedApplication(mtm).isActive());
                let delegate = state.delegate(mtm);
                let center = NSNotificationCenter::defaultCenter();
                let observe = |selector, name: &NSNotificationName| unsafe {
                    center.addObserver_selector_name_object(&delegate, selector, Some(name), None)
                };
                let activity = sel!(applicationActivityChanged:);
                observe(activity, unsafe {
                    NSApplicationWillBecomeActiveNotification
                });
                observe(activity, unsafe {
                    NSApplicationWillResignActiveNotification
                });
                observe(sel!(applicationDidBecomeActive:), unsafe {
                    NSApplicationDidBecomeActiveNotification
                });
                observe(
                    sel!(shouldTerminate:),
                    &NSString::from_str(SHOULD_TERMINATE),
                );
                observe(sel!(reopen:), &NSString::from_str(REOPEN));
            });
        });
    });
}

pub(super) fn observe_links() {
    static OBSERVE: Once = Once::new();
    OBSERVE.call_once(|| {
        DispatchQueue::main().exec_async(|| {
            let mtm = MainThreadMarker::new().expect("the main queue runs on the main thread");
            if let Some(app_delegate) = NSApplication::sharedApplication(mtm).delegate() {
                if app_delegate.respondsToSelector(sel!(takePendingLinks)) {
                    let links: Retained<NSArray<NSString>> =
                        unsafe { msg_send![&*app_delegate, takePendingLinks] };
                    for link in &links {
                        super::link::push(link.to_string());
                    }
                }
            }
            STATE.with(|state| unsafe {
                NSNotificationCenter::defaultCenter().addObserver_selector_name_object(
                    &state.delegate(mtm),
                    sel!(openLink:),
                    Some(&NSString::from_str(OPEN_LINK)),
                    None,
                );
            });
        });
    });
}

fn find_flutter_window(mtm: MainThreadMarker) -> Option<Retained<NSWindow>> {
    let flutter = AnyClass::get(c"FlutterViewController")?;
    NSApplication::sharedApplication(mtm)
        .windows()
        .iter()
        .find(|window| {
            window
                .contentViewController()
                .is_some_and(|controller| controller.isKindOfClass(flutter))
        })
}

pub fn ensure_initialized() -> Result<(), String> {
    on_main(|state, mtm| {
        if state.window().is_some() {
            return Ok(());
        }
        back_buffer::install();
        let window = find_flutter_window(mtm).ok_or("No window hosts the Flutter view")?;
        let delegate = state.delegate(mtm);
        window.setDelegate(Some(ProtocolObject::from_ref(&*delegate)));
        state.was_zoomed.set(is_maximized_window(&window));
        state.remember_normal_frame(&window);
        title_bar::observe(mtm);
        let host = EffectHost::install(&window, mtm);
        *state.host.borrow_mut() = host;
        *state.window.borrow_mut() = Some(window);
        Ok(())
    })
}

pub fn show() -> Result<(), String> {
    on_main(|state, mtm| {
        let window = state.require_window()?;
        if window.isVisible() {
            window.makeKeyAndOrderFront(None);
            #[allow(deprecated)]
            NSApplication::sharedApplication(mtm).activateIgnoringOtherApps(true);
        } else if !state.show_pending.get() {
            state.show_on_active_space(&window, mtm);
        }
        Ok(())
    })
}

pub fn hide() -> Result<(), String> {
    on_main(|state, _| {
        let window = state.require_window()?;
        state.show_pending.set(false);
        state.restore_space_behavior();
        window.orderOut(None);
        Ok(())
    })
}

pub fn is_visible() -> Result<bool, String> {
    on_main(|state, _| Ok(state.require_window()?.isVisible() || state.show_pending.get()))
}

pub fn focus() -> Result<(), String> {
    on_main(|state, mtm| {
        let window = state.require_window()?;
        #[allow(deprecated)]
        NSApplication::sharedApplication(mtm).activateIgnoringOtherApps(false);
        if !state.show_pending.get() {
            window.makeKeyAndOrderFront(None);
        }
        Ok(())
    })
}

pub fn close() -> Result<(), String> {
    on_main(|state, _| {
        state.require_window()?.performClose(None);
        Ok(())
    })
}

pub fn set_prevent_close(value: bool) -> Result<(), String> {
    on_main(move |state, _| {
        state.prevent_close.set(value);
        Ok(())
    })
}

// isZoomed misses a window macOS tiled to fill the screen, and zoom: has no
// frame to restore it to; unmaximize falls back to the last normal frame.
fn is_maximized_window(window: &NSWindow) -> bool {
    window.isZoomed()
        || window
            .screen()
            .is_some_and(|screen| same_rect(window.frame(), screen.visibleFrame()))
}

fn same_rect(a: NSRect, b: NSRect) -> bool {
    [
        a.origin.x - b.origin.x,
        a.origin.y - b.origin.y,
        a.size.width - b.size.width,
        a.size.height - b.size.height,
    ]
    .iter()
    .all(|delta| delta.abs() < 1.0)
}

pub fn is_maximized() -> Result<bool, String> {
    on_main(|state, _| Ok(is_maximized_window(&*state.require_window()?)))
}

pub fn maximize() -> Result<(), String> {
    on_main(|state, _| {
        state.maximize(&*state.require_window()?);
        Ok(())
    })
}

pub fn unmaximize() -> Result<(), String> {
    on_main(|state, _| {
        state.unmaximize(&*state.require_window()?);
        Ok(())
    })
}

pub fn is_minimized() -> Result<bool, String> {
    on_main(|state, _| Ok(state.require_window()?.isMiniaturized()))
}

pub fn minimize() -> Result<(), String> {
    on_main(|state, _| {
        state.require_window()?.miniaturize(None);
        Ok(())
    })
}

fn is_full_screen_window(window: &NSWindow) -> bool {
    window.styleMask().contains(NSWindowStyleMask::FullScreen)
}

pub fn is_full_screen() -> Result<bool, String> {
    on_main(|state, _| Ok(is_full_screen_window(&*state.require_window()?)))
}

pub fn set_full_screen(value: bool) -> Result<(), String> {
    on_main(move |state, _| {
        let window = state.require_window()?;
        if is_full_screen_window(&window) != value {
            window.toggleFullScreen(None);
        }
        Ok(())
    })
}

fn primary_screen_height(mtm: MainThreadMarker) -> f64 {
    NSScreen::screens(mtm)
        .iter()
        .next()
        .map_or(0.0, |screen| screen.frame().size.height)
}

fn top_left(rect: NSRect, primary_height: f64) -> WindowBounds {
    WindowBounds {
        x: rect.origin.x,
        y: primary_height - rect.origin.y - rect.size.height,
        width: rect.size.width,
        height: rect.size.height,
    }
}

pub fn get_bounds() -> Result<WindowBounds, String> {
    on_main(|state, mtm| {
        Ok(top_left(
            state.require_window()?.frame(),
            primary_screen_height(mtm),
        ))
    })
}

pub fn get_displays() -> Result<Vec<WindowDisplay>, String> {
    on_main(|_, mtm| {
        let primary_height = primary_screen_height(mtm);
        Ok(NSScreen::screens(mtm)
            .iter()
            .enumerate()
            .map(|(index, screen)| WindowDisplay {
                bounds: top_left(screen.frame(), primary_height),
                work_area: top_left(screen.visibleFrame(), primary_height),
                scale_factor: screen.backingScaleFactor(),
                primary: index == 0,
            })
            .collect())
    })
}

pub fn get_cursor_position() -> Result<WindowPoint, String> {
    on_main(|_, mtm| {
        let location = NSEvent::mouseLocation();
        Ok(WindowPoint {
            x: location.x,
            y: primary_screen_height(mtm) - location.y,
        })
    })
}

pub fn set_bounds(position: Option<(f64, f64)>, size: Option<(f64, f64)>) -> Result<(), String> {
    on_main(move |state, mtm| {
        let window = state.require_window()?;
        let mut frame: NSRect = window.frame();
        if let Some((width, height)) = size {
            // The origin is bottom-left, so the top edge stays put.
            frame.origin.y += frame.size.height - height;
            frame.size = NSSize::new(width, height);
        }
        if let Some((x, y)) = position {
            frame.origin = NSPoint::new(x, primary_screen_height(mtm) - y - frame.size.height);
        }
        window.setFrame_display(frame, true);
        Ok(())
    })
}

pub fn is_position_supported() -> Result<bool, String> {
    Ok(true)
}

pub fn set_minimum_size(width: f64, height: f64) -> Result<(), String> {
    on_main(move |state, _| {
        state
            .require_window()?
            .setMinSize(NSSize::new(width, height));
        Ok(())
    })
}

pub fn is_always_on_top() -> Result<bool, String> {
    on_main(|state, _| Ok(state.require_window()?.level() == NSFloatingWindowLevel))
}

pub fn set_always_on_top(value: bool) -> Result<(), String> {
    on_main(move |state, _| {
        let level = if value {
            NSFloatingWindowLevel
        } else {
            NSNormalWindowLevel
        };
        state.require_window()?.setLevel(level);
        Ok(())
    })
}

pub fn set_title_bar_style(style: TitleBarStyle) -> Result<(), String> {
    on_main(move |state, mtm| {
        let window = state.require_window()?;
        let mut current = state.style.get();
        current.title_bar_hidden = style == TitleBarStyle::Hidden;
        state.style.set(current);
        state.apply_style(&window, mtm);
        Ok(())
    })
}

pub fn set_skip_taskbar(value: bool) -> Result<(), String> {
    on_main(move |_, mtm| {
        let policy = if value {
            NSApplicationActivationPolicy::Accessory
        } else {
            NSApplicationActivationPolicy::Regular
        };
        NSApplication::sharedApplication(mtm).setActivationPolicy(policy);
        Ok(())
    })
}

pub fn set_rounded_corners(_value: bool) -> Result<(), String> {
    Ok(())
}

pub fn is_effect_supported(effect: WindowEffect) -> Result<bool, String> {
    on_main(move |_, mtm| Ok(effect::is_supported(effect, mtm)))
}

pub fn set_effect(
    effect: WindowEffect,
    tint: Option<u32>,
    brightness: Option<WindowBrightness>,
) -> Result<(), String> {
    on_main(move |state, mtm| {
        if !effect::is_supported(effect, mtm) {
            return Err(format!("{effect:?} is not supported"));
        }
        let window = state.require_window()?;
        state.style.set(Style {
            effect,
            tint,
            brightness,
            ..state.style.get()
        });
        state.apply_style(&window, mtm);
        Ok(())
    })
}

pub fn start_dragging() -> Result<(), String> {
    on_main(|state, _| {
        let window = state.require_window()?;
        let Some(event) = window.currentEvent() else {
            return Ok(());
        };
        // performDrag ignores an event handed to it before the call that
        // asked for the drag has returned.
        let pending = PendingDrag(window, event);
        DispatchQueue::main().exec_async(move || pending.perform());
        Ok(())
    })
}

struct PendingDrag(Retained<NSWindow>, Retained<NSEvent>);

impl PendingDrag {
    fn perform(self) {
        self.0.performWindowDragWithEvent(&self.1);
    }
}

// SAFETY: built on the main thread and only unpacked on the main queue.
unsafe impl Send for PendingDrag {}

#[cfg(test)]
mod tests {
    use super::argb_channels;

    #[test]
    fn argb_splits_into_alpha_red_green_blue() {
        assert_eq!(argb_channels(0xFF00_80FF), [1.0, 0.0, 128.0 / 255.0, 1.0]);
        assert_eq!(argb_channels(0), [0.0; 4]);
    }
}
