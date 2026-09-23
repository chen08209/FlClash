use std::io;

#[cfg(windows)]
use interprocess::local_socket::RecvHalf;
use interprocess::local_socket::{ListenerOptions, Stream};
#[cfg(windows)]
use std::io::Read;
#[cfg(unix)]
use std::path::Path;
#[cfg(windows)]
use std::{
    os::windows::io::{AsHandle, AsRawHandle},
    ptr,
};
#[cfg(windows)]
use windows_sys::Win32::System::Pipes::PeekNamedPipe;

pub fn cleanup_socket(path: &str) -> io::Result<()> {
    #[cfg(unix)]
    {
        if Path::new(path).exists() {
            std::fs::remove_file(path)?;
        }
    }
    #[cfg(windows)]
    {
        let _ = path;
    }
    Ok(())
}

/// Linux carries an `fchmod` on the unbound socket over to the file `bind`
/// creates; other Unixes reject it and keep the chmod after `bind`.
pub fn restrict_listener_mode(options: ListenerOptions<'_>) -> ListenerOptions<'_> {
    #[cfg(target_os = "linux")]
    {
        use interprocess::os::unix::local_socket::ListenerOptionsExt as _;

        options.mode(0o600)
    }
    #[cfg(not(target_os = "linux"))]
    {
        options
    }
}

pub fn restrict_socket_to_owner(path: &str) -> io::Result<()> {
    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;

        std::fs::set_permissions(path, std::fs::Permissions::from_mode(0o600))?;
    }
    #[cfg(windows)]
    {
        let _ = path;
    }
    Ok(())
}

#[cfg(unix)]
pub fn authorize_peer(stream: &Stream) -> io::Result<()> {
    use interprocess::local_socket::traits::StreamCommon as _;

    let peer_uid = stream.peer_creds()?.euid().ok_or_else(|| {
        io::Error::new(
            io::ErrorKind::PermissionDenied,
            "peer user ID is unavailable",
        )
    })?;
    // SAFETY: geteuid() takes no arguments and cannot fail.
    let own_uid = unsafe { libc::geteuid() };
    if is_permitted_uid(peer_uid, own_uid) {
        return Ok(());
    }
    Err(io::Error::new(
        io::ErrorKind::PermissionDenied,
        format!("peer uid {peer_uid} is neither {own_uid} nor root"),
    ))
}

#[cfg(unix)]
fn is_permitted_uid(peer_uid: libc::uid_t, own_uid: libc::uid_t) -> bool {
    peer_uid == own_uid || peer_uid == 0
}

#[cfg(windows)]
pub fn authorize_peer(_stream: &Stream) -> io::Result<()> {
    Ok(())
}

#[cfg(windows)]
pub fn connected_payload(stream: &Stream) -> io::Result<Vec<u8>> {
    use interprocess::local_socket::traits::StreamCommon as _;

    let credentials = stream.peer_creds()?;
    let process_id = credentials.pid().ok_or_else(|| {
        io::Error::new(
            io::ErrorKind::PermissionDenied,
            "peer process ID is unavailable",
        )
    })?;
    Ok(process_id.to_le_bytes().to_vec())
}

#[cfg(not(windows))]
pub fn connected_payload(_stream: &Stream) -> io::Result<Vec<u8>> {
    Ok(Vec::new())
}

#[cfg(windows)]
fn bytes_available(receiver: &RecvHalf) -> io::Result<u32> {
    let RecvHalf::NamedPipe(pipe) = receiver;
    let mut available = 0_u32;
    // SAFETY: `pipe` owns a live named-pipe handle for this receive half, and
    // `available` is a valid output pointer. No input buffer is supplied.
    let result = unsafe {
        PeekNamedPipe(
            pipe.as_handle().as_raw_handle(),
            ptr::null_mut(),
            0,
            ptr::null_mut(),
            &mut available,
            ptr::null_mut(),
        )
    };
    if result == 0 {
        Err(io::Error::last_os_error())
    } else {
        Ok(available)
    }
}

/// A blocking read on a Windows named pipe waits for the peer, which would park
/// the loop that also has to notice a stop request.
#[cfg(windows)]
pub struct PipeReader<'a> {
    pub receiver: &'a mut RecvHalf,
}

#[cfg(windows)]
impl Read for PipeReader<'_> {
    fn read(&mut self, buffer: &mut [u8]) -> io::Result<usize> {
        if bytes_available(self.receiver)? == 0 {
            return Err(io::ErrorKind::WouldBlock.into());
        }
        self.receiver.read(buffer)
    }
}

#[cfg(all(test, unix))]
mod tests {
    use super::is_permitted_uid;

    #[test]
    fn admits_the_socket_owner() {
        assert!(is_permitted_uid(501, 501));
    }

    #[test]
    fn admits_root_because_the_core_runs_privileged_for_tun() {
        assert!(is_permitted_uid(0, 501));
    }

    #[test]
    fn rejects_every_other_user() {
        assert!(!is_permitted_uid(502, 501));
        assert!(!is_permitted_uid(501, 0));
    }
}
