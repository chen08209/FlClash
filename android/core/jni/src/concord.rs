use std::ffi::{c_char, c_void};

pub type Callback = unsafe extern "C" fn(context: *mut c_void);

#[repr(C)]
pub struct PlatformHost {
    pub context: *mut c_void,
    pub protect: unsafe extern "C" fn(context: *mut c_void, fd: i32) -> bool,
    pub resolve_uid: unsafe extern "C" fn(
        context: *mut c_void,
        protocol: i32,
        source: *const c_char,
        target: *const c_char,
    ) -> i32,
    pub resolve_package: unsafe extern "C" fn(
        context: *mut c_void,
        uid: i32,
        buffer: *mut u8,
        capacity: usize,
    ) -> usize,
    pub release: Option<Callback>,
}

pub type Deliver = unsafe extern "C" fn(context: *mut c_void, data: *const u8, len: usize) -> bool;

#[link(name = "concord")]
unsafe extern "C" {
    pub fn concord_start(on_thread_start: Option<Callback>, context: *mut c_void) -> i32;
    pub fn concord_set_platform_host(host: *const PlatformHost) -> i32;
    pub fn concord_open_callback(
        deliver: Deliver,
        context: *mut c_void,
        release: Option<Callback>,
    ) -> u64;
    pub fn concord_send(session: u64, data: *const u8, len: usize) -> i32;
    pub fn concord_close(session: u64);
    pub fn concord_adopt_fd(fd: i32) -> u64;
}
