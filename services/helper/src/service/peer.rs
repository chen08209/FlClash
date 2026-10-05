use crate::service::hub::{
    ensure_core_sha256_configured, log_message, release_managed_core_on_shutdown, routes,
    LISTEN_PORT,
};
use crate::service::owner::{client_pid, same_sid, TcpConnection};

use std::ffi::c_void;
use std::future::Future;
use std::io::{Error, Result as IoResult};
use std::net::{Ipv4Addr, SocketAddr, SocketAddrV4};
use std::pin::Pin;
use std::ptr::null_mut;
use std::sync::atomic::{AtomicBool, Ordering};
use std::task::{Context, Poll};
use std::time::Duration;
use tokio::net::{TcpListener, TcpStream};
use tokio::time::Sleep;
use tokio_stream::Stream;
use windows_sys::Win32::Foundation::{
    CloseHandle, LocalFree, ERROR_INSUFFICIENT_BUFFER, HANDLE, NO_ERROR,
};
use windows_sys::Win32::NetworkManagement::IpHelper::{
    GetExtendedTcpTable, MIB_TCPTABLE_OWNER_PID, TCP_TABLE_OWNER_PID_ALL,
};
use windows_sys::Win32::Security::Authorization::ConvertSidToStringSidW;
use windows_sys::Win32::Security::{GetTokenInformation, TokenUser, TOKEN_QUERY, TOKEN_USER};
use windows_sys::Win32::System::Threading::{
    OpenProcess, OpenProcessToken, PROCESS_QUERY_LIMITED_INFORMATION,
};

const AF_INET: u32 = 2;
const TABLE_ATTEMPTS: usize = 5;
const ACCEPT_RETRY_DELAY: Duration = Duration::from_secs(1);

static REJECTION_LOGGED: AtomicBool = AtomicBool::new(false);

struct Handle(HANDLE);

impl Drop for Handle {
    fn drop(&mut self) {
        // SAFETY: the handle came from a successful Open* call.
        unsafe {
            CloseHandle(self.0);
        }
    }
}

pub fn process_sid(pid: u32) -> IoResult<String> {
    // SAFETY: both handles are owned by a Handle; the u64 buffer gives the
    // pointer-bearing TOKEN_USER the alignment it needs.
    unsafe {
        let process = OpenProcess(PROCESS_QUERY_LIMITED_INFORMATION, 0, pid);
        if process == 0 {
            return Err(Error::last_os_error());
        }
        let process = Handle(process);

        let mut token: HANDLE = 0;
        if OpenProcessToken(process.0, TOKEN_QUERY, &mut token) == 0 {
            return Err(Error::last_os_error());
        }
        let token = Handle(token);

        let mut length = 0u32;
        GetTokenInformation(token.0, TokenUser, null_mut(), 0, &mut length);
        if length == 0 {
            return Err(Error::last_os_error());
        }
        let mut buffer = vec![0u64; (length as usize).div_ceil(8)];
        if GetTokenInformation(
            token.0,
            TokenUser,
            buffer.as_mut_ptr() as *mut c_void,
            length,
            &mut length,
        ) == 0
        {
            return Err(Error::last_os_error());
        }
        let user = &*(buffer.as_ptr() as *const TOKEN_USER);
        sid_to_string(user.User.Sid)
    }
}

unsafe fn sid_to_string(sid: *mut c_void) -> IoResult<String> {
    let mut wide: *mut u16 = null_mut();
    if ConvertSidToStringSidW(sid, &mut wide) == 0 {
        return Err(Error::last_os_error());
    }
    let mut length = 0;
    while *wide.add(length) != 0 {
        length += 1;
    }
    let value = String::from_utf16_lossy(std::slice::from_raw_parts(wide, length));
    LocalFree(wide as *mut c_void);
    Ok(value)
}

fn tcp_connections() -> IoResult<Vec<TcpConnection>> {
    let mut size = 0u32;
    for _ in 0..TABLE_ATTEMPTS {
        let mut buffer = vec![0u32; (size as usize).div_ceil(4)];
        let pointer = if buffer.is_empty() {
            null_mut()
        } else {
            buffer.as_mut_ptr() as *mut c_void
        };
        let status = unsafe {
            GetExtendedTcpTable(pointer, &mut size, 0, AF_INET, TCP_TABLE_OWNER_PID_ALL, 0)
        };
        match status {
            NO_ERROR => return Ok(read_table(&buffer)),
            ERROR_INSUFFICIENT_BUFFER => continue,
            other => return Err(Error::from_raw_os_error(other as i32)),
        }
    }
    Err(Error::other("the TCP table kept growing"))
}

fn read_table(buffer: &[u32]) -> Vec<TcpConnection> {
    // SAFETY: a successful call left `dwNumEntries` rows in the buffer it was
    // sized for.
    unsafe {
        let table = &*(buffer.as_ptr() as *const MIB_TCPTABLE_OWNER_PID);
        std::slice::from_raw_parts(table.table.as_ptr(), table.dwNumEntries as usize)
            .iter()
            .map(|row| TcpConnection {
                local: socket_address(row.dwLocalAddr, row.dwLocalPort),
                remote: socket_address(row.dwRemoteAddr, row.dwRemotePort),
                pid: row.dwOwningPid,
            })
            .collect()
    }
}

/// Network byte order, with the port in the low 16 bits.
fn socket_address(address: u32, port: u32) -> SocketAddrV4 {
    SocketAddrV4::new(
        Ipv4Addr::from(u32::from_be(address)),
        u16::from_be(port as u16),
    )
}

fn is_owner_connection(stream: &TcpStream, owner_sid: &str) -> bool {
    let (Ok(SocketAddr::V4(client)), Ok(SocketAddr::V4(server))) =
        (stream.peer_addr(), stream.local_addr())
    else {
        return false;
    };
    let Ok(connections) = tcp_connections() else {
        return false;
    };
    let Some(pid) = client_pid(&connections, client, server) else {
        return false;
    };
    matches!(process_sid(pid), Ok(sid) if same_sid(&sid, owner_sid))
}

/// Loopback TCP has no peer credential, so the TCP table names the process
/// holding the client end, and that process must run as the account the Helper
/// was installed for.
struct AuthorizedIncoming {
    listener: TcpListener,
    owner_sid: String,
    retry: Option<Pin<Box<Sleep>>>,
}

impl Stream for AuthorizedIncoming {
    type Item = IoResult<TcpStream>;

    /// hyper ends the whole server on an accept error, so retry after a pause.
    fn poll_next(mut self: Pin<&mut Self>, context: &mut Context<'_>) -> Poll<Option<Self::Item>> {
        loop {
            if let Some(retry) = self.retry.as_mut() {
                match retry.as_mut().poll(context) {
                    Poll::Ready(()) => self.retry = None,
                    Poll::Pending => return Poll::Pending,
                }
            }
            match self.listener.poll_accept(context) {
                Poll::Ready(Ok((stream, _))) => {
                    if is_owner_connection(&stream, &self.owner_sid) {
                        return Poll::Ready(Some(Ok(stream)));
                    }
                    if !REJECTION_LOGGED.swap(true, Ordering::Relaxed) {
                        log_message(
                            "Helper refused a connection from an account other than its owner"
                                .to_string(),
                        );
                    }
                }
                Poll::Ready(Err(error)) => {
                    log_message(format!("Helper could not accept a connection: {error}"));
                    self.retry = Some(Box::pin(tokio::time::sleep(ACCEPT_RETRY_DELAY)));
                }
                Poll::Pending => return Poll::Pending,
            }
        }
    }
}

pub(super) async fn serve_until<F, S>(
    owner_sid: String,
    shutdown: F,
    on_started: S,
) -> anyhow::Result<()>
where
    F: Future<Output = ()> + Send + 'static,
    S: FnOnce() -> anyhow::Result<()>,
{
    ensure_core_sha256_configured()?;

    let listener = TcpListener::bind((Ipv4Addr::LOCALHOST, LISTEN_PORT))
        .await
        .map_err(|error| anyhow::anyhow!("bind helper server: {error}"))?;
    on_started()?;
    let incoming = AuthorizedIncoming {
        listener,
        owner_sid,
        retry: None,
    };
    warp::serve(routes())
        .serve_incoming_with_graceful_shutdown(incoming, shutdown)
        .await;
    release_managed_core_on_shutdown();

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    fn v4(address: SocketAddr) -> SocketAddrV4 {
        match address {
            SocketAddr::V4(address) => address,
            SocketAddr::V6(_) => panic!("expected an IPv4 address"),
        }
    }

    #[test]
    fn the_tcp_table_names_this_process_on_its_own_loopback_connection() {
        let listener = std::net::TcpListener::bind((Ipv4Addr::LOCALHOST, 0)).unwrap();
        let server = v4(listener.local_addr().unwrap());
        let client = std::net::TcpStream::connect(server).unwrap();
        let _accepted = listener.accept().unwrap();
        let client = v4(client.local_addr().unwrap());

        let connections = tcp_connections().unwrap();

        assert_eq!(
            client_pid(&connections, client, server),
            Some(std::process::id())
        );
    }

    #[test]
    fn reads_the_account_of_a_process() {
        let sid = process_sid(std::process::id()).unwrap();

        assert!(sid.starts_with("S-1-5-"), "{sid}");
        assert!(process_sid(u32::MAX - 3).is_err());
    }

    #[tokio::test]
    async fn admits_the_owner_and_refuses_any_other_account() {
        let listener = TcpListener::bind((Ipv4Addr::LOCALHOST, 0)).await.unwrap();
        let _client = std::net::TcpStream::connect(listener.local_addr().unwrap()).unwrap();
        let (accepted, _) = listener.accept().await.unwrap();
        let owner = process_sid(std::process::id()).unwrap();

        assert!(is_owner_connection(&accepted, &owner));
        assert!(!is_owner_connection(&accepted, "S-1-5-21-1-2-3-1001"));
    }
}
