//! The root half of Root TUN mode, run through `su`: the routes last as long as the app's connection.

#[cfg(target_os = "android")]
#[path = "../logcat.rs"]
mod logcat;

#[cfg(not(target_os = "android"))]
fn main() {}

#[cfg(target_os = "android")]
fn main() {
    std::process::exit(helper::run());
}

#[cfg(target_os = "android")]
mod helper {
    use std::ffi::{CStr, CString, c_char, c_int};
    use std::io::{BufRead, BufReader, Write};
    use std::os::android::net::SocketAddrExt;
    use std::os::fd::AsRawFd;
    use std::os::unix::net::{SocketAddr, UnixStream};
    use std::sync::atomic::{AtomicI32, Ordering};

    use crate::logcat;

    const ERROR_CAPACITY: usize = 512;

    #[link(name = "concord")]
    unsafe extern "C" {
        fn concord_tun_provision(
            request: *const u8,
            len: usize,
            fd: *mut i32,
            error: *mut u8,
            capacity: usize,
        ) -> u64;
        fn concord_tun_release(handle: u64) -> i32;
        fn concord_socket_uid(protocol: i32, source: *const c_char) -> i32;
        fn concord_tun_clean_stale() -> i32;
    }

    static CONNECTION: AtomicI32 = AtomicI32::new(-1);

    extern "C" fn on_signal(_: c_int) {
        let fd = CONNECTION.load(Ordering::Relaxed);
        if fd >= 0 {
            // SAFETY: shutdown(2) is async-signal-safe; the read loop then runs the release.
            unsafe { libc::shutdown(fd, libc::SHUT_RD) };
        }
    }

    fn watch_signals() {
        for signal in [libc::SIGTERM, libc::SIGHUP, libc::SIGINT] {
            // SAFETY: `on_signal` only calls an async-signal-safe function.
            unsafe { libc::signal(signal, on_signal as *const () as libc::sighandler_t) };
        }
    }

    fn send_with_fd(stream: &UnixStream, line: &[u8], fd: c_int) -> std::io::Result<()> {
        let mut control = [0u8; 64];
        let mut iov = libc::iovec {
            iov_base: line.as_ptr().cast_mut().cast(),
            iov_len: line.len(),
        };
        // SAFETY: a zeroed `msghdr` is valid, and `iov` and `control` (room for one descriptor) outlive it.
        let sent = unsafe {
            let mut message: libc::msghdr = std::mem::zeroed();
            message.msg_iov = &raw mut iov;
            message.msg_iovlen = 1;
            message.msg_control = control.as_mut_ptr().cast();
            message.msg_controllen = libc::CMSG_SPACE(size_of::<c_int>() as u32) as _;
            let header = libc::CMSG_FIRSTHDR(&raw const message);
            (*header).cmsg_level = libc::SOL_SOCKET;
            (*header).cmsg_type = libc::SCM_RIGHTS;
            (*header).cmsg_len = libc::CMSG_LEN(size_of::<c_int>() as u32) as _;
            libc::CMSG_DATA(header).cast::<c_int>().write_unaligned(fd);
            libc::sendmsg(stream.as_raw_fd(), &raw const message, 0)
        };
        if sent < 0 {
            return Err(std::io::Error::last_os_error());
        }
        Ok(())
    }

    fn provision(request: &str) -> Result<(u64, c_int), String> {
        let mut fd = -1;
        let mut error = [0u8; ERROR_CAPACITY];
        // SAFETY: the request, `fd` and `error` are valid for the lengths given.
        let handle = unsafe {
            concord_tun_provision(
                request.as_ptr(),
                request.len(),
                &raw mut fd,
                error.as_mut_ptr(),
                error.len(),
            )
        };
        if handle == 0 {
            return Err(CStr::from_bytes_until_nul(&error)
                .map(|reason| reason.to_string_lossy().into_owned())
                .unwrap_or_default());
        }
        Ok((handle, fd))
    }

    fn owner(line: &str) -> Option<String> {
        let mut fields = line.split_ascii_whitespace();
        let (Some("uid"), Some(id), Some(protocol), Some(source)) =
            (fields.next(), fields.next(), fields.next(), fields.next())
        else {
            return None;
        };
        let uid = match (protocol.parse(), CString::new(source)) {
            // SAFETY: `source` is NUL-terminated and outlives the call.
            (Ok(protocol), Ok(source)) => unsafe { concord_socket_uid(protocol, source.as_ptr()) },
            _ => -1,
        };
        Some(format!("uid {id} {uid}\n"))
    }

    pub fn run() -> i32 {
        let Some(name) = std::env::args().nth(1) else {
            logcat::error("tun: no socket name");
            return 2;
        };
        if name == "--clean" {
            // SAFETY: takes no arguments.
            let removed = unsafe { concord_tun_clean_stale() };
            if removed != 0 {
                logcat::warn(&format!("tun: stale rules removed: {removed}"));
            }
            return i32::from(removed < 0);
        }
        let stream = match SocketAddr::from_abstract_name(name.as_bytes())
            .and_then(|address| UnixStream::connect_addr(&address))
        {
            Ok(stream) => stream,
            Err(err) => {
                logcat::error(&format!("tun: connect: {err}"));
                return 1;
            }
        };
        CONNECTION.store(stream.as_raw_fd(), Ordering::Relaxed);
        watch_signals();
        let mut reader = BufReader::new(&stream);
        let mut writer = &stream;
        let mut request = String::new();
        if reader.read_line(&mut request).unwrap_or(0) == 0 {
            return 1;
        }
        let handle = match provision(request.trim_end()) {
            Ok((handle, fd)) => {
                let sent = send_with_fd(&stream, b"ok\n", fd);
                // SAFETY: the descriptor is this process's own copy; the app holds the device now.
                unsafe { libc::close(fd) };
                if let Err(err) = sent {
                    logcat::error(&format!("tun: pass descriptor: {err}"));
                    release(handle);
                    return 1;
                }
                handle
            }
            Err(reason) => {
                let _ = writer.write_all(format!("err {}\n", reason.replace('\n', " ")).as_bytes());
                return 1;
            }
        };
        let mut line = String::new();
        loop {
            line.clear();
            match reader.read_line(&mut line) {
                Ok(0) | Err(_) => break,
                Ok(_) => {
                    if let Some(answer) = owner(&line)
                        && writer.write_all(answer.as_bytes()).is_err()
                    {
                        break;
                    }
                }
            }
        }
        release(handle);
        0
    }

    fn release(handle: u64) {
        // SAFETY: every caller passes a handle `concord_tun_provision` returned, once.
        let failures = unsafe { concord_tun_release(handle) };
        if failures != 0 {
            logcat::warn(&format!("tun: {failures} route steps not undone"));
        }
    }
}
