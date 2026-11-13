use super::{is_full_screen_window, is_maximized_window, State, STATE};
use block2::RcBlock;
use objc2::rc::Retained;
use objc2::runtime::AnyObject;
use objc2::MainThreadMarker;
use objc2_app_kit::{NSEvent, NSEventMask, NSEventType, NSWindow, NSWindowButton};
use objc2_foundation::{ns_string, NSPoint, NSUserDefaults};
use std::cell::{Cell, RefCell};
use std::ptr::{null_mut, NonNull};

thread_local! {
    static MONITOR: RefCell<Option<Retained<AnyObject>>> = const { RefCell::new(None) };
    static SWALLOW_MOUSE_UP: Cell<bool> = const { Cell::new(false) };
}

/// Answers a double click on the hidden title bar the way the system setting
/// says. The Flutter view covers that bar, so AppKit acts on it only
/// sometimes; the click is taken here so neither it nor Flutter acts again.
pub(super) fn observe(mtm: MainThreadMarker) {
    MONITOR.with(|monitor| {
        if monitor.borrow().is_some() {
            return;
        }
        let handler = RcBlock::new(move |event: NonNull<NSEvent>| -> *mut NSEvent {
            let event_ref = unsafe { event.as_ref() };
            if take(event_ref, mtm) {
                null_mut()
            } else {
                event.as_ptr()
            }
        });
        *monitor.borrow_mut() = unsafe {
            NSEvent::addLocalMonitorForEventsMatchingMask_handler(
                NSEventMask::LeftMouseDown | NSEventMask::LeftMouseUp,
                &handler,
            )
        };
    });
}

fn take(event: &NSEvent, mtm: MainThreadMarker) -> bool {
    match event.r#type() {
        NSEventType::LeftMouseUp => SWALLOW_MOUSE_UP.with(|swallow| swallow.replace(false)),
        NSEventType::LeftMouseDown if event.clickCount() == 2 => STATE.with(|state| {
            let Some(window) = state.window() else {
                return false;
            };
            let in_window = event
                .window(mtm)
                .is_some_and(|target| std::ptr::eq(&*target, &*window));
            if !in_window
                || !state.style.get().title_bar_hidden
                || !in_title_bar(&window, event.locationInWindow())
            {
                return false;
            }
            SWALLOW_MOUSE_UP.with(|swallow| swallow.set(true));
            perform_double_click_action(state, &window);
            true
        }),
        _ => false,
    }
}

fn in_title_bar(window: &NSWindow, point: NSPoint) -> bool {
    if is_full_screen_window(window) {
        return false;
    }
    let content = window.contentLayoutRect();
    if point.y < content.origin.y + content.size.height {
        return false;
    }
    let buttons_end = window
        .standardWindowButton(NSWindowButton::ZoomButton)
        .map_or(0.0, |button| {
            let frame = button.convertRect_toView(button.bounds(), None);
            frame.origin.x + frame.size.width
        });
    point.x > buttons_end
}

fn perform_double_click_action(state: &State, window: &NSWindow) {
    let defaults = NSUserDefaults::standardUserDefaults();
    let action = defaults
        .stringForKey(ns_string!("AppleActionOnDoubleClick"))
        .map(|action| action.to_string());
    let minimize = match action.as_deref() {
        Some("None") => return,
        Some(action) => action == "Minimize",
        None => defaults.boolForKey(ns_string!("AppleMiniaturizeOnDoubleClick")),
    };
    if minimize {
        window.miniaturize(None);
    } else if is_maximized_window(window) {
        state.unmaximize(window);
    } else {
        state.maximize(window);
    }
}
