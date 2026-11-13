use std::ffi::{c_char, c_int, c_void, CStr};

#[repr(C)]
struct FcFontSet {
    nfont: c_int,
    _sfont: c_int,
    fonts: *mut *mut c_void,
}

const FC_MATCH: c_int = 0;

struct Fontconfig {
    pattern_create: unsafe extern "C" fn() -> *mut c_void,
    pattern_add_bool: unsafe extern "C" fn(*mut c_void, *const c_char, c_int) -> c_int,
    pattern_get_string:
        unsafe extern "C" fn(*mut c_void, *const c_char, c_int, *mut *const c_char) -> c_int,
    pattern_destroy: unsafe extern "C" fn(*mut c_void),
    object_set_create: unsafe extern "C" fn() -> *mut c_void,
    object_set_add: unsafe extern "C" fn(*mut c_void, *const c_char) -> c_int,
    object_set_destroy: unsafe extern "C" fn(*mut c_void),
    font_list: unsafe extern "C" fn(*mut c_void, *mut c_void, *mut c_void) -> *mut FcFontSet,
    font_set_destroy: unsafe extern "C" fn(*mut FcFontSet),
}

impl Fontconfig {
    /// Loaded at run time so a desktop without fontconfig gets an empty
    /// picker rather than an app that fails to start.
    fn load() -> Result<Self, String> {
        // SAFETY: never closed, so the symbols outlive every caller.
        let library = unsafe { libc::dlopen(c"libfontconfig.so.1".as_ptr(), libc::RTLD_NOW) };
        if library.is_null() {
            return Err("libfontconfig.so.1 is not available".to_owned());
        }
        // SAFETY: each field's type is the signature fontconfig declares for
        // the symbol it is loaded from.
        unsafe {
            Ok(Self {
                pattern_create: symbol(library, c"FcPatternCreate")?,
                pattern_add_bool: symbol(library, c"FcPatternAddBool")?,
                pattern_get_string: symbol(library, c"FcPatternGetString")?,
                pattern_destroy: symbol(library, c"FcPatternDestroy")?,
                object_set_create: symbol(library, c"FcObjectSetCreate")?,
                object_set_add: symbol(library, c"FcObjectSetAdd")?,
                object_set_destroy: symbol(library, c"FcObjectSetDestroy")?,
                font_list: symbol(library, c"FcFontList")?,
                font_set_destroy: symbol(library, c"FcFontSetDestroy")?,
            })
        }
    }
}

unsafe fn symbol<F: Copy>(library: *mut c_void, name: &CStr) -> Result<F, String> {
    let address = unsafe { libc::dlsym(library, name.as_ptr()) };
    if address.is_null() {
        return Err(format!("fontconfig has no {}", name.to_string_lossy()));
    }
    Ok(unsafe { std::mem::transmute_copy::<*mut c_void, F>(&address) })
}

pub fn families() -> Result<Vec<String>, String> {
    let fc = Fontconfig::load()?;
    let family = c"family".as_ptr();
    // SAFETY: pattern strings are copied before the set is destroyed.
    unsafe {
        let pattern = (fc.pattern_create)();
        let objects = (fc.object_set_create)();
        (fc.pattern_add_bool)(pattern, c"scalable".as_ptr(), 1);
        (fc.object_set_add)(objects, family);
        let set = (fc.font_list)(std::ptr::null_mut(), pattern, objects);
        let mut names = Vec::new();
        if !set.is_null() {
            for index in 0..usize::try_from((*set).nfont).unwrap_or(0) {
                let mut value: *const c_char = std::ptr::null();
                if (fc.pattern_get_string)(*(*set).fonts.add(index), family, 0, &mut value)
                    == FC_MATCH
                {
                    names.push(CStr::from_ptr(value).to_string_lossy().into_owned());
                }
            }
            (fc.font_set_destroy)(set);
        }
        (fc.object_set_destroy)(objects);
        (fc.pattern_destroy)(pattern);
        Ok(names)
    }
}
