//! The natives of `com.follow.clash.core.mobile.Mobile` over Concord's C ABI. Every callback context
//! is a `Box` leaked here for that callback alone, which Concord hands back until its `release`.

#![cfg(target_os = "android")]

mod concord;
mod logcat;

use std::ffi::{CStr, c_char, c_void};
use std::panic::{AssertUnwindSafe, catch_unwind};

use jni::errors::{Error, ErrorPolicy};
use jni::objects::{JByteArray, JObject, JString};
use jni::refs::{Global, LoaderContext};
use jni::sys::{JNI_VERSION_1_6, jboolean, jint, jlong};
use jni::{Env, EnvUnowned, JavaVM, jni_mangle};

#[allow(
    elided_lifetimes_in_paths,
    reason = "expanded by bind_java_type!, which writes the wrapper without its lifetime"
)]
mod java {
    use jni::bind_java_type;

    bind_java_type! {
        pub FrameReceiver => com.follow.clash.core.FrameReceiver,
        methods {
            fn on_frame(frame: jbyte[]) -> jboolean,
        },
    }

    bind_java_type! {
        pub Host => com.follow.clash.core.PlatformHost,
        methods {
            fn protect(fd: jint) -> jboolean,
            fn resolve_uid(protocol: jint, source: JString, target: JString) -> jint,
            fn resolve_package(uid: jint) -> JString,
        },
    }
}

use java::{FrameReceiver, FrameReceiverAPI, Host, HostAPI};

type ReceiverRef = Global<FrameReceiver<'static>>;
type HostRef = Global<Host<'static>>;

fn attached<T>(what: &str, run: impl FnOnce(&mut Env<'_>) -> Result<T, Error>) -> Option<T> {
    let outcome = catch_unwind(AssertUnwindSafe(|| {
        JavaVM::singleton().and_then(|vm| vm.attach_current_thread(run))
    }));
    match outcome {
        Ok(Ok(value)) => Some(value),
        Ok(Err(err)) => {
            logcat::warn(&format!("{what}: {err}"));
            None
        }
        Err(_) => {
            logcat::error(&format!("{what}: panicked"));
            None
        }
    }
}

unsafe fn borrowed<'a, T>(context: *mut c_void) -> &'a T {
    unsafe { &*context.cast::<T>() }
}

unsafe extern "C" fn attach_thread(_context: *mut c_void) {
    attached("attach runtime thread", |_| Ok(()));
}

unsafe extern "C" fn deliver(context: *mut c_void, data: *const u8, len: usize) -> bool {
    let (receiver, frame) = unsafe {
        (
            borrowed::<ReceiverRef>(context),
            std::slice::from_raw_parts(data, len),
        )
    };
    attached("onFrame", |env| {
        let array = env.byte_array_from_slice(frame)?;
        receiver.on_frame(env, &array)
    })
    .unwrap_or(false)
}

unsafe extern "C" fn release_receiver(context: *mut c_void) {
    drop(unsafe { Box::from_raw(context.cast::<ReceiverRef>()) });
}

unsafe extern "C" fn protect(context: *mut c_void, fd: i32) -> bool {
    let host = unsafe { borrowed::<HostRef>(context) };
    attached("protect", |env| host.protect(env, fd)).unwrap_or(false)
}

unsafe extern "C" fn resolve_uid(
    context: *mut c_void,
    protocol: i32,
    source: *const c_char,
    target: *const c_char,
) -> i32 {
    let (host, source, target) = unsafe {
        (
            borrowed::<HostRef>(context),
            CStr::from_ptr(source).to_string_lossy(),
            CStr::from_ptr(target).to_string_lossy(),
        )
    };
    attached("resolveUid", |env| {
        let source = JString::from_str(env, &source)?;
        let target = JString::from_str(env, &target)?;
        host.resolve_uid(env, protocol, &source, &target)
    })
    .unwrap_or(-1)
}

unsafe extern "C" fn resolve_package(
    context: *mut c_void,
    uid: i32,
    buffer: *mut u8,
    capacity: usize,
) -> usize {
    let host = unsafe { borrowed::<HostRef>(context) };
    let package = attached("resolvePackage", |env| {
        let package = host.resolve_package(env, uid)?;
        package.try_to_string(env)
    })
    .unwrap_or_default();
    if package.len() <= capacity {
        unsafe { std::ptr::copy_nonoverlapping(package.as_ptr(), buffer, package.len()) };
    }
    package.len()
}

unsafe extern "C" fn release_host(context: *mut c_void) {
    drop(unsafe { Box::from_raw(context.cast::<HostRef>()) });
}

struct Logcat;

impl<T: Default> ErrorPolicy<T, Error> for Logcat {
    type Captures<'unowned_env_local: 'native_method, 'native_method> = ();

    fn on_error<'unowned_env_local: 'native_method, 'native_method>(
        env: &mut Env<'unowned_env_local>,
        _captures: &mut Self::Captures<'unowned_env_local, 'native_method>,
        err: Error,
    ) -> jni::errors::Result<T> {
        if env.exception_check() {
            env.exception_clear();
        }
        logcat::error(&format!("native method failed: {err}"));
        Ok(T::default())
    }

    fn on_panic<'unowned_env_local: 'native_method, 'native_method>(
        env: &mut Env<'unowned_env_local>,
        _captures: &mut Self::Captures<'unowned_env_local, 'native_method>,
        _payload: Box<dyn std::any::Any + Send + 'static>,
    ) -> jni::errors::Result<T> {
        if env.exception_check() {
            env.exception_clear();
        }
        Ok(T::default())
    }
}

#[unsafe(no_mangle)]
#[allow(
    clippy::not_unsafe_ptr_arg_deref,
    reason = "only the JVM calls it, with its own JavaVM"
)]
pub extern "system" fn JNI_OnLoad(vm: *mut jni::sys::JavaVM, _reserved: *mut c_void) -> jint {
    let _ = catch_unwind(|| {
        let vm = unsafe { JavaVM::from_raw(vm) };
        // Core threads attach with the system class loader, which cannot find app classes later.
        let cached = vm.attach_current_thread(|env| {
            FrameReceiverAPI::get(env, &LoaderContext::default())?;
            HostAPI::get(env, &LoaderContext::default())?;
            Ok::<(), Error>(())
        });
        if let Err(err) = cached {
            logcat::error(&format!("JNI_OnLoad: {err}"));
        }
        if unsafe { concord::concord_start(Some(attach_thread), std::ptr::null_mut()) } != 0 {
            logcat::error("the Concord core did not start");
        }
    });
    JNI_VERSION_1_6
}

#[jni_mangle("com.follow.clash.core.mobile.Mobile")]
pub fn open_session<'local>(
    mut env: EnvUnowned<'local>,
    _class: JObject<'local>,
    receiver: FrameReceiver<'local>,
) -> jlong {
    env.with_env(|env| -> Result<jlong, Error> {
        let context = Box::into_raw(Box::new(env.new_global_ref(&receiver)?));
        let session = unsafe {
            concord::concord_open_callback(deliver, context.cast(), Some(release_receiver))
        };
        Ok(session as jlong)
    })
    .resolve::<Logcat>()
}

#[jni_mangle("com.follow.clash.core.mobile.Mobile")]
pub fn send_frame<'local>(
    mut env: EnvUnowned<'local>,
    _class: JObject<'local>,
    session: jlong,
    frame: JByteArray<'local>,
) -> jboolean {
    env.with_env(|env| -> Result<jboolean, Error> {
        let frame = env.convert_byte_array(&frame)?;
        Ok(unsafe { concord::concord_send(session as u64, frame.as_ptr(), frame.len()) } != 0)
    })
    .resolve::<Logcat>()
}

#[jni_mangle("com.follow.clash.core.mobile.Mobile")]
pub fn close_session<'local>(mut env: EnvUnowned<'local>, _class: JObject<'local>, session: jlong) {
    env.with_env(|_| -> Result<(), Error> {
        unsafe { concord::concord_close(session as u64) };
        Ok(())
    })
    .resolve::<Logcat>()
}

#[jni_mangle("com.follow.clash.core.mobile.Mobile")]
pub fn set_platform_host<'local>(
    mut env: EnvUnowned<'local>,
    _class: JObject<'local>,
    host: Host<'local>,
) {
    env.with_env(|env| -> Result<(), Error> {
        if host.is_null() {
            unsafe { concord::concord_set_platform_host(std::ptr::null()) };
            return Ok(());
        }
        let host = concord::PlatformHost {
            context: Box::into_raw(Box::new(env.new_global_ref(&host)?)).cast(),
            protect,
            resolve_uid,
            resolve_package,
            release: Some(release_host),
        };
        unsafe { concord::concord_set_platform_host(&host) };
        Ok(())
    })
    .resolve::<Logcat>()
}

#[jni_mangle("com.follow.clash.core.mobile.Mobile")]
pub fn adopt_fd<'local>(mut env: EnvUnowned<'local>, _class: JObject<'local>, fd: jint) -> jlong {
    env.with_env(|_| -> Result<jlong, Error> {
        Ok(unsafe { concord::concord_adopt_fd(fd) } as jlong)
    })
    .resolve::<Logcat>()
}
