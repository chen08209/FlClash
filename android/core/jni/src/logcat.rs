use std::ffi::{CStr, CString, c_char, c_int};

const ANDROID_LOG_WARN: c_int = 5;
const ANDROID_LOG_ERROR: c_int = 6;
const TAG: &CStr = c"FlClash";

#[link(name = "log")]
unsafe extern "C" {
    fn __android_log_write(priority: c_int, tag: *const c_char, text: *const c_char) -> c_int;
}

pub fn warn(message: &str) {
    write(ANDROID_LOG_WARN, message);
}

pub fn error(message: &str) {
    write(ANDROID_LOG_ERROR, message);
}

fn write(priority: c_int, message: &str) {
    let Ok(text) = CString::new(message.replace('\0', " ")) else {
        return;
    };
    // SAFETY: the tag and the text are NUL-terminated and outlive the call.
    unsafe {
        __android_log_write(priority, TAG.as_ptr(), text.as_ptr());
    }
}
