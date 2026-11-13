//! flutter/flutter#185394, see "Wrong-size back buffer on macOS" in .agents/flutter-upgrade.md.

use objc2::rc::Retained;
use objc2::runtime::{AnyClass, AnyObject, Imp, Sel};
use objc2::{msg_send, sel};
use objc2_foundation::{NSSize, NSString, NSValue};
use std::sync::OnceLock;

type RemoveSurface = unsafe extern "C-unwind" fn(*mut AnyObject, Sel, NSSize) -> *mut AnyObject;

static ORIGINAL: OnceLock<RemoveSurface> = OnceLock::new();

unsafe extern "C-unwind" fn guarded(
    cache: *mut AnyObject,
    selector: Sel,
    size: NSSize,
) -> *mut AnyObject {
    let Some(original) = ORIGINAL.get() else {
        return std::ptr::null_mut();
    };
    let surface = original(cache, selector, size);
    let Some(object) = surface.as_ref() else {
        return surface;
    };
    let value: Option<Retained<NSValue>> =
        msg_send![object, valueForKey: &*NSString::from_str("size")];
    if value.is_some_and(|value| value.sizeValue() == size) {
        surface
    } else {
        std::ptr::null_mut()
    }
}

pub fn install() {
    let selector = sel!(removeSurfaceForSize:);
    let Some(method) =
        AnyClass::get(c"FlutterBackBufferCache").and_then(|class| class.instance_method(selector))
    else {
        return;
    };
    ORIGINAL.get_or_init(|| unsafe {
        let replacement = std::mem::transmute::<RemoveSurface, Imp>(guarded);
        std::mem::transmute::<Imp, RemoveSurface>(method.set_implementation(replacement))
    });
}
