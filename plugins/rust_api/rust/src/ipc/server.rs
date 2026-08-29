use super::frame::{
    self, FrameReader, IO_POLL_INTERVAL, TYPE_CONNECTED, TYPE_DATA, TYPE_DISCONNECTED, TYPE_ERROR,
    TYPE_READY,
};
use super::platform;
use super::queue::{enqueue_message, MessageSender, MAX_PENDING_MESSAGES, SEND_QUEUE_TIMEOUT};
use crate::frb_generated::StreamSink;
use flutter_rust_bridge::for_generated::SseCodec;
use interprocess::local_socket::prelude::*;
use interprocess::local_socket::{GenericFilePath, ListenerNonblockingMode, ListenerOptions};
use std::io;
use std::sync::atomic::{AtomicBool, Ordering};
use std::sync::mpsc;
use std::sync::{Arc, Mutex};
use std::thread;

macro_rules! ipc_debug {
    ($($arg:tt)*) => {
        if cfg!(debug_assertions) {
            eprintln!($($arg)*);
        }
    };
}

const ACCEPT_POLL_INTERVAL: std::time::Duration = std::time::Duration::from_millis(50);

static RUNNING: AtomicBool = AtomicBool::new(false);
static LIFECYCLE: Mutex<()> = Mutex::new(());

struct ServerState {
    sender: Option<MessageSender>,
    handle: Option<thread::JoinHandle<()>>,
}

static STATE: Mutex<ServerState> = Mutex::new(ServerState {
    sender: None,
    handle: None,
});

fn server_active() -> bool {
    RUNNING.load(Ordering::SeqCst)
}

fn stop_server_thread() -> Result<(), String> {
    RUNNING.store(false, Ordering::SeqCst);
    let handle = {
        let mut state = STATE.lock().map_err(|e| format!("Lock poisoned: {e}"))?;
        state.sender = None;
        state.handle.take()
    };
    if let Some(handle) = handle {
        handle
            .join()
            .map_err(|_| "IPC server thread panicked".to_owned())?;
    }
    Ok(())
}

pub fn restart_server(name: String, sink: StreamSink<Vec<u8>, SseCodec>) -> Result<(), String> {
    let _lifecycle = LIFECYCLE
        .lock()
        .map_err(|e| format!("Lifecycle lock poisoned: {e}"))?;

    stop_server_thread()?;
    platform::cleanup_socket(&name).map_err(|e| format!("Failed to remove stale socket: {e}"))?;

    RUNNING.store(true, Ordering::SeqCst);
    let handle = thread::Builder::new()
        .name("ipc-server".into())
        .spawn(move || io_loop(name, sink))
        .map_err(|e| {
            RUNNING.store(false, Ordering::SeqCst);
            format!("Failed to spawn IPC server thread: {e}")
        })?;

    let mut state = STATE.lock().map_err(|e| format!("Lock poisoned: {e}"))?;
    state.handle = Some(handle);
    Ok(())
}

pub fn stop_server() -> Result<(), String> {
    let _lifecycle = LIFECYCLE
        .lock()
        .map_err(|e| format!("Lifecycle lock poisoned: {e}"))?;
    stop_server_thread()
}

pub fn send_message(data: Vec<u8>) -> Result<(), String> {
    frame::validate_frame_len(data.len()).map_err(|e| e.to_string())?;
    let sender = STATE
        .lock()
        .map_err(|e| format!("Lock poisoned: {e}"))?
        .sender
        .clone()
        .ok_or("IPC client is not connected")?;

    enqueue_message(&sender, data, SEND_QUEUE_TIMEOUT, &RUNNING)
}

fn report_error(sink: &StreamSink<Vec<u8>, SseCodec>, message: impl AsRef<str>) {
    let _ = sink.add(frame::make_frame(TYPE_ERROR, message.as_ref().as_bytes()));
}

fn finish_server(name: &str) {
    RUNNING.store(false, Ordering::SeqCst);
    if let Ok(mut state) = STATE.lock() {
        state.sender = None;
    }
    if let Err(e) = platform::cleanup_socket(name) {
        ipc_debug!("[IPC] cleanup socket failed: {e}");
    }
}

fn io_loop(name: String, sink: StreamSink<Vec<u8>, SseCodec>) {
    let fs_name = match name.clone().to_fs_name::<GenericFilePath>() {
        Ok(name) => name,
        Err(e) => {
            report_error(&sink, format!("name error: {e}"));
            finish_server(&name);
            return;
        }
    };

    let listener = match ListenerOptions::new().name(fs_name).create_sync() {
        Ok(listener) => listener,
        Err(e) => {
            report_error(&sink, format!("bind error: {e}"));
            finish_server(&name);
            return;
        }
    };

    if let Err(e) = listener.set_nonblocking(ListenerNonblockingMode::Accept) {
        report_error(&sink, format!("listener nonblocking error: {e}"));
        finish_server(&name);
        return;
    }

    if sink.add(frame::make_frame(TYPE_READY, &[])).is_err() {
        finish_server(&name);
        return;
    }

    while server_active() {
        let stream = match listener.accept() {
            Ok(stream) => stream,
            Err(e) if e.kind() == io::ErrorKind::WouldBlock => {
                thread::sleep(ACCEPT_POLL_INTERVAL);
                continue;
            }
            Err(e) => {
                if server_active() {
                    report_error(&sink, format!("accept error: {e}"));
                }
                break;
            }
        };

        if let Err(e) = stream.set_nonblocking(true) {
            report_error(&sink, format!("stream nonblocking error: {e}"));
            continue;
        }

        let connected_payload = match platform::connected_payload(&stream) {
            Ok(payload) => payload,
            Err(e) => {
                report_error(&sink, format!("peer credentials error: {e}"));
                continue;
            }
        };

        let (sender, rx, pending_bytes) = MessageSender::channel(MAX_PENDING_MESSAGES);
        match STATE.lock() {
            Ok(mut state) if server_active() => state.sender = Some(sender),
            Ok(_) => break,
            Err(e) => {
                report_error(&sink, format!("state lock error: {e}"));
                break;
            }
        }

        if sink
            .add(frame::make_frame(TYPE_CONNECTED, &connected_payload))
            .is_err()
        {
            break;
        }

        let (mut receiver, mut sender) = stream.split();
        let connection_running = Arc::new(AtomicBool::new(true));
        let writer_running = Arc::clone(&connection_running);
        let writer = thread::spawn(move || {
            let mut error = None;
            let is_running = || writer_running.load(Ordering::SeqCst) && server_active();
            while is_running() {
                match rx.recv_timeout(IO_POLL_INTERVAL) {
                    Ok(data) => {
                        pending_bytes.fetch_sub(data.len(), Ordering::SeqCst);
                        if let Err(e) = frame::write_frame(&mut sender, &data, &is_running) {
                            if e.kind() != io::ErrorKind::Interrupted {
                                error = Some(format!("write error: {e}"));
                            }
                            break;
                        }
                    }
                    Err(mpsc::RecvTimeoutError::Timeout) => continue,
                    Err(mpsc::RecvTimeoutError::Disconnected) => break,
                }
            }
            writer_running.store(false, Ordering::SeqCst);
            error
        });

        let mut frame_reader = FrameReader::default();
        while connection_running.load(Ordering::SeqCst) && server_active() {
            #[cfg(windows)]
            let poll_result = frame_reader.poll(&mut platform::PipeReader {
                receiver: &mut receiver,
            });
            #[cfg(not(windows))]
            let poll_result = frame_reader.poll(&mut receiver);

            match poll_result {
                Ok(Some(data)) => {
                    if sink.add(frame::make_frame(TYPE_DATA, &data)).is_err() {
                        break;
                    }
                }
                Ok(None) => thread::sleep(IO_POLL_INTERVAL),
                Err(e) => {
                    if !frame::is_expected_disconnect_error(&e) && server_active() {
                        ipc_debug!("[IPC] read error: {e}, raw={:?}", e.raw_os_error());
                        report_error(&sink, format!("read error: {e}"));
                    }
                    break;
                }
            }
        }

        connection_running.store(false, Ordering::SeqCst);
        if let Ok(mut state) = STATE.lock() {
            state.sender = None;
        }
        if let Ok(Some(message)) = writer.join() {
            report_error(&sink, message);
        }
        if server_active() && sink.add(frame::make_frame(TYPE_DISCONNECTED, &[])).is_err() {
            break;
        }
    }

    finish_server(&name);
}
