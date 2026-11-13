//! The window's content view is an `NSVisualEffectView` holding the Flutter view, the shape
//! macos_window_utils gives flutter_acrylic: as a sibling beneath it, AppKit would hand the
//! effect view an unhandled `mouseDown` before the Flutter view controller ever saw it.

use crate::api::window::WindowEffect;
use objc2::rc::Retained;
use objc2::runtime::{AnyClass, AnyObject, NSObjectProtocol, Sel};
use objc2::{msg_send, MainThreadMarker, Message};
use objc2_app_kit::{
    NSAppearance, NSAppearanceCustomization, NSAutoresizingMaskOptions, NSColor, NSImage,
    NSSplitViewController, NSSplitViewItem, NSView, NSViewController, NSVisualEffectBlendingMode,
    NSVisualEffectMaterial, NSVisualEffectState, NSVisualEffectView, NSWindow,
};
use objc2_foundation::{NSPoint, NSRect, NSSize, NSString};
use std::cell::{OnceCell, RefCell};

const SIDEBAR_KEYS: [&str; 2] = ["_variant", "_adaptiveAppearance"];

type GlassAttributes = Vec<(Retained<NSString>, Retained<AnyObject>)>;

thread_local! {
    static SIDEBAR_GLASS: OnceCell<Option<GlassAttributes>> = const { OnceCell::new() };
    static GLASS: RefCell<Option<Retained<NSView>>> = const { RefCell::new(None) };
}

fn glass_class() -> Option<&'static AnyClass> {
    AnyClass::get(c"NSGlassEffectView")
}

/// A split view's sidebar glass is a private variant that the public styles
/// lack and each release redraws, so it is copied off one laid out offscreen.
fn sidebar_glass_attributes(mtm: MainThreadMarker) -> Option<GlassAttributes> {
    let glass_class = glass_class()?;
    let split = NSSplitViewController::new(mtm);
    let item = |view_controller: &NSViewController| {
        view_controller.setView(&NSView::new(mtm));
        view_controller.retain()
    };
    let sidebar = item(&NSViewController::new(mtm));
    let content = item(&NSViewController::new(mtm));
    split.addSplitViewItem(&NSSplitViewItem::sidebarWithViewController(&sidebar));
    split.addSplitViewItem(&NSSplitViewItem::splitViewItemWithViewController(&content));
    let view = split.view();
    view.setFrame(NSRect::new(
        NSPoint::new(0.0, 0.0),
        NSSize::new(600.0, 400.0),
    ));
    view.layoutSubtreeIfNeeded();
    let glass = first_view_of(&view, glass_class)?;
    let attributes = SIDEBAR_KEYS
        .iter()
        .filter(|key| glass.respondsToSelector(Sel::register(&cstring(key))))
        .filter_map(|key| {
            let key = NSString::from_str(key);
            let value: Option<Retained<AnyObject>> =
                unsafe { msg_send![&*glass, valueForKey: &*key] };
            value.map(|value| (key, value))
        })
        .collect();
    Some(attributes)
}

fn cstring(value: &str) -> std::ffi::CString {
    std::ffi::CString::new(value).expect("selector names hold no NUL")
}

fn first_view_of(view: &NSView, class: &AnyClass) -> Option<Retained<NSView>> {
    if view.isKindOfClass(class) {
        return Some(view.retain());
    }
    view.subviews()
        .iter()
        .find_map(|subview| first_view_of(&subview, class))
}

fn with_sidebar_glass<T>(
    mtm: MainThreadMarker,
    f: impl FnOnce(Option<&GlassAttributes>) -> T,
) -> T {
    SIDEBAR_GLASS.with(|cell| f(cell.get_or_init(|| sidebar_glass_attributes(mtm)).as_ref()))
}

pub fn is_supported(effect: WindowEffect, mtm: MainThreadMarker) -> bool {
    match effect {
        WindowEffect::None | WindowEffect::Blur => true,
        WindowEffect::Mica => false,
        WindowEffect::Glass => with_sidebar_glass(mtm, |attributes| attributes.is_some()),
    }
}

#[derive(Clone)]
pub struct EffectHost {
    flutter: Retained<NSViewController>,
    effect_view: Retained<NSVisualEffectView>,
}

impl EffectHost {
    pub fn install(window: &NSWindow, mtm: MainThreadMarker) -> Option<Self> {
        let flutter = window.contentViewController()?;
        let frame = window.frame();
        let effect_view = NSVisualEffectView::new(mtm);
        effect_view.setFrame(flutter.view().frame());
        effect_view.setAutoresizingMask(
            NSAutoresizingMaskOptions::ViewWidthSizable
                | NSAutoresizingMaskOptions::ViewHeightSizable,
        );
        effect_view.setBlendingMode(NSVisualEffectBlendingMode::BehindWindow);
        let host_controller = NSViewController::new(mtm);
        host_controller.setView(&effect_view);
        host_controller.addChildViewController(&flutter);
        let host = Self {
            flutter,
            effect_view,
        };
        host.attach_flutter_view();
        window.setContentViewController(Some(&host_controller));
        // macOS 12 detaches the outgoing controller's view only after loading
        // the host, by then from the effect view, which leaves the window blank.
        host.attach_flutter_view();
        window.setFrame_display(frame, true);
        Some(host)
    }

    fn attach_flutter_view(&self) {
        let flutter_view = self.flutter.view();
        let effect_view: &NSView = &self.effect_view;
        if unsafe { flutter_view.superview() }.is_some_and(|superview| &*superview == effect_view) {
            return;
        }
        flutter_view.setTranslatesAutoresizingMaskIntoConstraints(true);
        flutter_view.setFrame(effect_view.bounds());
        flutter_view.setAutoresizingMask(
            NSAutoresizingMaskOptions::ViewWidthSizable
                | NSAutoresizingMaskOptions::ViewHeightSizable,
        );
        effect_view.addSubview(&flutter_view);
    }

    fn set_flutter_background(&self, color: &NSColor) {
        let _: () = unsafe { msg_send![&*self.flutter, setBackgroundColor: color] };
    }

    pub fn apply(
        &self,
        effect: WindowEffect,
        tint: Option<&NSColor>,
        appearance: Option<&NSAppearance>,
        mtm: MainThreadMarker,
    ) {
        let effect_view = &self.effect_view;
        match effect {
            WindowEffect::None | WindowEffect::Mica | WindowEffect::Glass => {
                effect_view.setMaskImage(Some(&NSImage::new()));
                effect_view.setState(NSVisualEffectState::Inactive);
                let background = if effect == WindowEffect::None {
                    NSColor::windowBackgroundColor()
                } else {
                    NSColor::clearColor()
                };
                self.set_flutter_background(&background);
                if effect == WindowEffect::Glass {
                    self.show_glass(tint, mtm);
                } else {
                    self.remove_glass();
                }
            }
            WindowEffect::Blur => {
                self.remove_glass();
                effect_view.setMaskImage(None);
                effect_view.setMaterial(NSVisualEffectMaterial::Sidebar);
                effect_view.setState(NSVisualEffectState::FollowsWindowActiveState);
                effect_view.setAppearance(appearance);
                // The material is painted by the view itself, so a translucent
                // layer color is the only tint that keeps it.
                effect_view.setWantsLayer(tint.is_some());
                if let Some(layer) = effect_view.layer() {
                    let color = tint.map(|tint| tint.CGColor());
                    let _: () = unsafe { msg_send![&*layer, setBackgroundColor: color.as_deref()] };
                }
                self.set_flutter_background(&NSColor::clearColor());
            }
        }
    }

    // Glass cannot lie beneath the Flutter view for the same reason the effect
    // view cannot, so it holds the view as its content, as a sidebar's does.
    fn show_glass(&self, tint: Option<&NSColor>, mtm: MainThreadMarker) {
        let Some(class) = glass_class() else { return };
        let existing = GLASS.with(|glass| glass.borrow().clone());
        let glass = existing.unwrap_or_else(|| {
            let glass: Retained<NSView> = unsafe { msg_send![class, new] };
            with_sidebar_glass(mtm, |attributes| {
                for (key, value) in attributes.into_iter().flatten() {
                    let setter = format!("set{key}:");
                    if glass.respondsToSelector(Sel::register(&cstring(&setter))) {
                        let _: () =
                            unsafe { msg_send![&*glass, setValue: &**value, forKey: &**key] };
                    }
                }
            });
            glass.setFrame(self.effect_view.bounds());
            glass.setAutoresizingMask(
                NSAutoresizingMaskOptions::ViewWidthSizable
                    | NSAutoresizingMaskOptions::ViewHeightSizable,
            );
            self.effect_view.addSubview(&glass);
            let _: () = unsafe { msg_send![&*glass, setContentView: &*self.flutter.view()] };
            GLASS.with(|cell| *cell.borrow_mut() = Some(glass.clone()));
            glass
        });
        let _: () = unsafe { msg_send![&*glass, setTintColor: tint] };
    }

    fn remove_glass(&self) {
        let Some(glass) = GLASS.with(|glass| glass.borrow_mut().take()) else {
            return;
        };
        self.attach_flutter_view();
        glass.removeFromSuperview();
    }
}
