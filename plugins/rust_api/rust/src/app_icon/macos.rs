#[cfg(target_os = "macos")]
use super::Owner;
use std::path::{Path, PathBuf};

/// The outermost `.app` on the path, so a helper nested inside another
/// bundle, such as Google Chrome Helper, shows the app the user started.
pub fn outermost_bundle(process_path: &Path) -> Option<PathBuf> {
    let mut bundle = PathBuf::new();
    for component in process_path.components() {
        bundle.push(component);
        if bundle
            .extension()
            .is_some_and(|extension| extension == "app")
        {
            return Some(bundle);
        }
    }
    None
}

#[cfg(target_os = "macos")]
pub fn owner(process_path: &Path, _size: u32) -> Option<Owner<()>> {
    let key = outermost_bundle(process_path)?;
    let stamp = key.join("Contents").join("Info.plist");
    key.is_dir().then_some(Owner {
        key,
        stamp,
        source: (),
    })
}

#[cfg(target_os = "macos")]
pub fn render(owner: &Owner<()>, size: u32) -> Result<Option<Vec<u8>>, String> {
    use objc2_app_kit::NSWorkspace;
    use objc2_foundation::NSString;

    let path = NSString::from_str(&owner.key.to_string_lossy());
    objc2::rc::autoreleasepool(|_| png(&NSWorkspace::sharedWorkspace().iconForFile(&path), size))
}

#[cfg(target_os = "macos")]
pub fn render_default(size: u32) -> Result<Option<Vec<u8>>, String> {
    use objc2_app_kit::NSWorkspace;
    use objc2_foundation::NSString;

    let application = NSString::from_str("com.apple.application-bundle");
    objc2::rc::autoreleasepool(|_| {
        #[allow(deprecated)]
        let image = NSWorkspace::sharedWorkspace().iconForFileType(&application);
        png(&image, size)
    })
}

/// Draws the image into a bitmap of `size` pixels, so the representation
/// AppKit picks is the one meant for that size.
#[cfg(target_os = "macos")]
fn png(image: &objc2_app_kit::NSImage, size: u32) -> Result<Option<Vec<u8>>, String> {
    use objc2::AllocAnyThread;
    use objc2_app_kit::{
        NSBitmapImageFileType, NSBitmapImageRep, NSCompositingOperation, NSDeviceRGBColorSpace,
        NSGraphicsContext,
    };
    use objc2_foundation::{NSDictionary, NSPoint, NSRect, NSSize};

    let pixels = size as isize;
    // SAFETY: null planes let the representation allocate its own buffer.
    let bitmap = unsafe {
        NSBitmapImageRep::initWithBitmapDataPlanes_pixelsWide_pixelsHigh_bitsPerSample_samplesPerPixel_hasAlpha_isPlanar_colorSpaceName_bytesPerRow_bitsPerPixel(
            NSBitmapImageRep::alloc(),
            std::ptr::null_mut(),
            pixels,
            pixels,
            8,
            4,
            true,
            false,
            NSDeviceRGBColorSpace,
            0,
            0,
        )
    }
    .ok_or("NSBitmapImageRep could not be created")?;
    let context = NSGraphicsContext::graphicsContextWithBitmapImageRep(&bitmap)
        .ok_or("NSGraphicsContext could not be created")?;
    let side = f64::from(size);
    NSGraphicsContext::saveGraphicsState_class();
    NSGraphicsContext::setCurrentContext(Some(&context));
    image.drawInRect_fromRect_operation_fraction(
        NSRect::new(NSPoint::new(0.0, 0.0), NSSize::new(side, side)),
        NSRect::ZERO,
        NSCompositingOperation::Copy,
        1.0,
    );
    context.flushGraphics();
    NSGraphicsContext::restoreGraphicsState_class();
    // SAFETY: an empty dictionary is valid for every file type.
    let data = unsafe {
        bitmap.representationUsingType_properties(NSBitmapImageFileType::PNG, &NSDictionary::new())
    }
    .ok_or("the icon could not be encoded as PNG")?;
    Ok(Some(data.to_vec()))
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn a_nested_helper_belongs_to_the_outermost_app() {
        let helper = Path::new(
            "/Applications/Google Chrome.app/Contents/Frameworks/Google Chrome Framework.framework\
             /Versions/1/Helpers/Google Chrome Helper.app/Contents/MacOS/Google Chrome Helper",
        );
        assert_eq!(
            outermost_bundle(helper),
            Some(PathBuf::from("/Applications/Google Chrome.app")),
        );
    }

    #[cfg(target_os = "macos")]
    #[test]
    fn an_update_is_told_by_the_info_plist_not_the_bundle_directory() {
        let bundle =
            std::env::temp_dir().join(format!("app_icon_stamp_{}/X.app", std::process::id()));
        std::fs::create_dir_all(bundle.join("Contents/MacOS")).unwrap();
        let owner = owner(&bundle.join("Contents/MacOS/X"), 64).unwrap();
        assert_eq!(owner.key, bundle);
        assert_eq!(owner.stamp, bundle.join("Contents/Info.plist"));
        std::fs::remove_dir_all(bundle.parent().unwrap()).unwrap();
    }

    #[test]
    fn a_binary_outside_any_app_has_no_bundle() {
        assert_eq!(outermost_bundle(Path::new("/usr/bin/curl")), None);
        assert_eq!(
            outermost_bundle(Path::new("/opt/x.application/bin/x")),
            None
        );
    }
}
