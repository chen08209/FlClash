use objc2_core_foundation::{CFArray, CFRetained, CFString};
use objc2_core_text::CTFontManagerCopyAvailableFontFamilyNames;

pub fn families() -> Vec<String> {
    // SAFETY: the function takes no arguments and returns an array of
    // CFString family names.
    let names = unsafe {
        CFRetained::cast_unchecked::<CFArray<CFString>>(CTFontManagerCopyAvailableFontFamilyNames())
    };
    names.iter().map(|name| name.to_string()).collect()
}
