use crate::frb_generated::StreamSink;
use flutter_rust_bridge::for_generated::SseCodec;
use flutter_rust_bridge::frb;
use interprocess::local_socket::prelude::*;
use interprocess::local_socket::{GenericFilePath, ListenerNonblockingMode, ListenerOptions};
use std::io::{self, Read, Write};
use std::path::Path;
use std::sync::atomic::{AtomicBool, AtomicU64, Ordering};
use std::sync::mpsc::{self, Sender};
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::Duration;

#[cfg(unix)]
use std::os::unix::io::RawFd;

macro_rules! ipc_debug {
    ($($arg:tt)*) => {
        #[cfg(debug_assertions)]
        eprintln!($($arg)*);
    };
}

static RUNNING: AtomicBool = AtomicBool::new(false);
static CONNECTED: AtomicBool = AtomicBool::new(false);
static LAST_ERROR: Mutex<Option<String>> = Mutex::new(None);
static GENERATION: AtomicU64 = AtomicU64::new(0);
#[cfg(unix)]
static SHUTDOWN_FD: Mutex<Option<RawFd>> = Mutex::new(None);

struct ServerState {
    tx: Option<Sender<Vec<u8>>>,
    handle: Option<thread::JoinHandle<()>>,
}

static STATE: Mutex<ServerState> = Mutex::new(ServerState {
    tx: None,
    handle: None,
});

const TYPE_READY: u8 = 0x00;
const TYPE_CONNECTED: u8 = 0x01;
const TYPE_DISCONNECTED: u8 = 0x02;
const TYPE_DATA: u8 = 0x03;
const TYPE_ERROR: u8 = 0x04;

fn make_frame(ty: u8, payload: &[u8]) -> Vec<u8> {
    let mut v = Vec::with_capacity(1 + payload.len());
    v.push(ty);
    v.extend_from_slice(payload);
    v
}

fn cleanup_socket(path: &str) {
    #[cfg(unix)]
    {
        if Path::new(path).exists() {
            let _ = std::fs::remove_file(path);
        }
    }
    #[cfg(windows)]
    {
        let _ = path;
    }
}

#[frb]
pub fn restart_ipc_server(
    name: String,
    sink: StreamSink<Vec<u8>, SseCodec>,
) -> Result<(), String> {
    let new_gen = GENERATION.fetch_add(1, Ordering::SeqCst) + 1;
    ipc_debug!("[IPC] restart_ipc_server: gen={new_gen}, name={name}");

    shutdown_old_fd();

    RUNNING.store(false, Ordering::SeqCst);
    CONNECTED.store(false, Ordering::SeqCst);

    let old_handle = STATE
        .lock()
        .map(|mut guard| {
            guard.tx = None;
            guard.handle.take()
        })
        .unwrap_or(None);
    if let Some(handle) = old_handle {
        ipc_debug!("[IPC] restart_ipc_server: joining old thread...");
        let _ = handle.join();
        ipc_debug!("[IPC] restart_ipc_server: old thread joined");
    }

    cleanup_socket(&name);

    RUNNING.store(true, Ordering::SeqCst);
    ipc_debug!("[IPC] restart_ipc_server: RUNNING=true, spawning io_loop");

    let handle = thread::Builder::new()
        .name("ipc-server".into())
        .spawn(move || io_loop(name, sink, new_gen))
        .map_err(|e| {
            RUNNING.store(false, Ordering::SeqCst);
            ipc_debug!("[IPC] restart_ipc_server: spawn failed: {e}");
            format!("Failed to spawn thread: {e}")
        })?;

    if let Ok(mut guard) = STATE.lock() {
        guard.handle = Some(handle);
    }
    ipc_debug!("[IPC] restart_ipc_server: done, thread spawned");

    Ok(())
}

#[cfg(unix)]
fn shutdown_old_fd() {
    if let Ok(mut guard) = SHUTDOWN_FD.lock() {
        if let Some(fd) = guard.take() {
            ipc_debug!("[IPC] shutdown_old_fd: shutting down fd={fd}");
            if unsafe { libc::shutdown(fd, libc::SHUT_RDWR) } != 0 {
                ipc_debug!(
                    "[IPC] shutdown_old_fd: shutdown failed: {}",
                    io::Error::last_os_error()
                );
            }
        }
    }
}

#[cfg(not(unix))]
fn shutdown_old_fd() {}

#[frb]
pub fn stop_ipc_server() -> Result<(), String> {
    ipc_debug!(
        "[IPC] stop_ipc_server: RUNNING={}",
        RUNNING.load(Ordering::SeqCst)
    );
    if !RUNNING.load(Ordering::SeqCst) {
        return Err("IPC server is not running".into());
    }

    // Bump the generation so a still-parked io_loop cannot clear RUNNING or
    // STATE out from under a server started later.
    GENERATION.fetch_add(1, Ordering::SeqCst);

    shutdown_old_fd();

    RUNNING.store(false, Ordering::SeqCst);
    CONNECTED.store(false, Ordering::SeqCst);

    // The guard must be released before joining: io_loop needs STATE on its
    // exit path, so joining while holding it deadlocks both threads.
    let old_handle = STATE
        .lock()
        .map(|mut guard| {
            guard.tx = None;
            guard.handle.take()
        })
        .unwrap_or(None);
    if let Some(handle) = old_handle {
        ipc_debug!("[IPC] stop_ipc_server: joining old thread...");
        let _ = handle.join();
        ipc_debug!("[IPC] stop_ipc_server: old thread joined");
    }
    Ok(())
}

#[frb]
pub fn ipc_server_status() -> bool {
    RUNNING.load(Ordering::SeqCst)
}

#[frb]
pub fn is_ipc_connected() -> bool {
    CONNECTED.load(Ordering::SeqCst)
}

#[frb]
pub fn send_ipc_message(data: Vec<u8>) -> Result<(), String> {
    if !CONNECTED.load(Ordering::SeqCst) {
        return Err("IPC client is not connected".into());
    }
    if let Ok(mut guard) = LAST_ERROR.lock() {
        if let Some(err) = guard.take() {
            ipc_debug!("[IPC] send_ipc_message: returning cached error: {err}");
            return Err(err);
        }
    }
    let guard = STATE.lock().map_err(|e| format!("Lock poisoned: {e}"))?;
    let tx = guard.tx.as_ref().ok_or("IPC server is not running")?;
    tx.send(data)
        .map_err(|e| format!("Failed to send: {e}"))
}

fn write_frame(mut writer: impl Write, data: &[u8]) -> io::Result<()> {
    let len = data.len() as u32;
    writer.write_all(&len.to_le_bytes())?;
    writer.write_all(data)?;
    writer.flush()
}

fn read_frame(mut reader: impl Read) -> io::Result<Vec<u8>> {
    let mut len_buf = [0u8; 4];
    reader.read_exact(&mut len_buf)?;
    let len = u32::from_le_bytes(len_buf) as usize;
    let mut payload = vec![0u8; len];
    reader.read_exact(&mut payload)?;
    Ok(payload)
}

fn is_current_gen(gen: u64) -> bool {
    GENERATION.load(Ordering::SeqCst) == gen
}

fn save_shutdown_fd(stream: &LocalSocketStream) {
    #[cfg(unix)]
    {
        use std::os::fd::AsRawFd;
        use std::os::unix::io::AsFd;
        let LocalSocketStream::UdSocket(ref s) = stream;
        if let Ok(mut guard) = SHUTDOWN_FD.lock() {
            *guard = Some(s.as_fd().as_raw_fd());
        }
    }
    #[cfg(not(unix))]
    {
        let _ = stream;
    }
}

fn clear_shutdown_fd() {
    #[cfg(unix)]
    {
        if let Ok(mut guard) = SHUTDOWN_FD.lock() {
            *guard = None;
        }
    }
}

fn io_loop(name: String, sink: StreamSink<Vec<u8>, SseCodec>, gen: u64) {
    ipc_debug!("[IPC] io_loop[{gen}]: started");

    let fs_name = match name.clone().to_fs_name::<GenericFilePath>() {
        Ok(n) => n,
        Err(e) => {
            ipc_debug!("[IPC] io_loop[{gen}]: name error: {e}");
            let _ = sink.add(make_frame(TYPE_ERROR, format!("name error: {e}").as_bytes()));
            if is_current_gen(gen) {
                RUNNING.store(false, Ordering::SeqCst);
            }
            return;
        }
    };

    let listener = match ListenerOptions::new().name(fs_name).create_sync() {
        Ok(l) => l,
        Err(e) => {
            ipc_debug!("[IPC] io_loop[{gen}]: bind error: {e}");
            let _ = sink.add(make_frame(TYPE_ERROR, format!("bind error: {e}").as_bytes()));
            if is_current_gen(gen) {
                RUNNING.store(false, Ordering::SeqCst);
            }
            return;
        }
    };

    if let Err(e) = listener.set_nonblocking(ListenerNonblockingMode::Accept) {
        ipc_debug!("[IPC] io_loop[{gen}]: set_nonblocking error: {e}");
        let _ = sink.add(make_frame(
            TYPE_ERROR,
            format!("set_nonblocking error: {e}").as_bytes(),
        ));
        if is_current_gen(gen) {
            RUNNING.store(false, Ordering::SeqCst);
        }
        return;
    }

    ipc_debug!("[IPC] io_loop[{gen}]: listener bound, sending TYPE_READY");
    let _ = sink.add(make_frame(TYPE_READY, &[]));

    while RUNNING.load(Ordering::SeqCst) {
        let stream = match listener.accept() {
            Ok(s) => {
                ipc_debug!("[IPC] io_loop[{gen}]: client accepted");
                s
            }
            Err(e) if e.kind() == io::ErrorKind::WouldBlock => {
                thread::sleep(Duration::from_millis(100));
                continue;
            }
            Err(e) => {
                ipc_debug!("[IPC] io_loop[{gen}]: accept error: {e}");
                if RUNNING.load(Ordering::SeqCst) {
                    let _ = sink.add(
                        make_frame(TYPE_ERROR, format!("accept error: {e}").as_bytes()),
                    );
                }
                break;
            }
        };

        if let Err(e) = stream.set_nonblocking(false) {
            ipc_debug!("[IPC] io_loop[{gen}]: set_nonblocking(false) error: {e}");
            let _ = sink.add(
                make_frame(TYPE_ERROR, format!("stream nonblocking error: {e}").as_bytes()),
            );
            continue;
        }

        save_shutdown_fd(&stream);

        let (tx, rx) = mpsc::channel::<Vec<u8>>();
        if let Ok(mut guard) = STATE.lock() {
            guard.tx = Some(tx);
        }

        ipc_debug!("[IPC] io_loop[{gen}]: client connected, sending TYPE_CONNECTED");
        CONNECTED.store(true, Ordering::SeqCst);
        if sink.add(make_frame(TYPE_CONNECTED, &[])).is_err() {
            ipc_debug!("[IPC] io_loop[{gen}]: sink closed on TYPE_CONNECTED");
            CONNECTED.store(false, Ordering::SeqCst);
            break;
        }

        let (recv_half, send_half) = stream.split();
        let running = Arc::new(AtomicBool::new(true));
        let wr = Arc::clone(&running);

        let (err_tx, err_rx) = mpsc::channel::<String>();

        let writer = thread::spawn(move || {
            let mut sender = send_half;
            while wr.load(Ordering::SeqCst) {
                match rx.recv() {
                    Ok(data) => {
                        if let Err(e) = write_frame(&mut sender, &data) {
                            let _ = err_tx.send(format!("write error: {e}"));
                            break;
                        }
                    }
                    Err(mpsc::RecvError) => break,
                }
            }
            wr.store(false, Ordering::SeqCst);
        });

        let mut receiver = recv_half;
        loop {
            match read_frame(&mut receiver) {
                Ok(data) => {
                    if sink.add(make_frame(TYPE_DATA, &data)).is_err() {
                        ipc_debug!("[IPC] io_loop[{gen}]: sink closed on TYPE_DATA");
                        break;
                    }
                }
                Err(e) => {
                    ipc_debug!("[IPC] io_loop[{gen}]: read error: {e}");
                    let _ = sink.add(
                        make_frame(TYPE_ERROR, format!("read error: {e}").as_bytes()),
                    );
                    break;
                }
            }
        }

        running.store(false, Ordering::SeqCst);

        clear_shutdown_fd();

        if is_current_gen(gen) {
            if let Ok(mut guard) = STATE.lock() {
                guard.tx = None;
            }
        }
        writer.join().ok();

        if let Ok(msg) = err_rx.try_recv() {
            ipc_debug!("[IPC] io_loop[{gen}]: writer error: {msg}");
            if is_current_gen(gen) {
                if let Ok(mut guard) = LAST_ERROR.lock() {
                    *guard = Some(msg.clone());
                }
            }
            let _ = sink.add(make_frame(TYPE_ERROR, msg.as_bytes()));
        }

        ipc_debug!("[IPC] io_loop[{gen}]: disconnected, sending TYPE_DISCONNECTED");
        if is_current_gen(gen) {
            CONNECTED.store(false, Ordering::SeqCst);
        }
        if sink.add(make_frame(TYPE_DISCONNECTED, &[])).is_err() {
            ipc_debug!("[IPC] io_loop[{gen}]: sink closed on TYPE_DISCONNECTED");
            break;
        }
    }

    ipc_debug!(
        "[IPC] io_loop[{gen}]: exiting (RUNNING={})",
        RUNNING.load(Ordering::SeqCst)
    );
    if is_current_gen(gen) {
        ipc_debug!("[IPC] io_loop[{gen}]: is current gen, cleaning up");
        RUNNING.store(false, Ordering::SeqCst);
        if let Ok(mut guard) = STATE.lock() {
            guard.tx = None;
            guard.handle = None;
        }
        cleanup_socket(&name);
    } else {
        ipc_debug!(
            "[IPC] io_loop[{gen}]: stale gen (current={}), skipping cleanup",
            GENERATION.load(Ordering::SeqCst)
        );
    }
}
