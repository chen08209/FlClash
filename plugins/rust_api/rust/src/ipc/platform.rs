use std::io;

#[cfg(windows)]
use interprocess::local_socket::RecvHalf;
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

/// The payload of a `connected` frame: the peer process ID where the platform
/// can prove it, empty where it cannot.
#[cfg(windows)]
pub fn connected_payload(stream: &interprocess::local_socket::Stream) -> io::Result<Vec<u8>> {
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
pub fn connected_payload(_stream: &interprocess::local_socket::Stream) -> io::Result<Vec<u8>> {
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
