//! `global-hotkey` binds registrations to a thread: on Windows the hidden
//! window must be created and pumped by one thread, and on macOS Carbon wants
//! the main thread. `with_registry` runs the caller's closure wherever the
//! platform requires; flutter_rust_bridge otherwise calls from a worker pool.

use super::service::Registry;

#[cfg(target_os = "windows")]
pub use windows::with_registry;

#[cfg(target_os = "macos")]
pub use macos::with_registry;

#[cfg(not(any(target_os = "windows", target_os = "macos")))]
pub use direct::with_registry;

#[cfg(not(target_os = "windows"))]
mod shared {
    use super::Registry;
    use std::sync::Mutex;

    static REGISTRY: Mutex<Registry> = Mutex::new(Registry::new());

    pub fn locked<T>(f: impl FnOnce(&mut Registry) -> T) -> Result<T, String> {
        let mut registry = REGISTRY
            .lock()
            .map_err(|e| format!("Hotkey registry lock poisoned: {e}"))?;
        Ok(f(&mut registry))
    }
}

#[cfg(not(any(target_os = "windows", target_os = "macos")))]
mod direct {
    use super::Registry;

    pub fn with_registry<T, F>(f: F) -> Result<T, String>
    where
        T: Send + 'static,
        F: FnOnce(&mut Registry) -> T + Send + 'static,
    {
        super::shared::locked(f)
    }
}

#[cfg(target_os = "macos")]
mod macos {
    use super::Registry;
    use dispatch2::DispatchQueue;

    pub fn with_registry<T, F>(f: F) -> Result<T, String>
    where
        T: Send + 'static,
        F: FnOnce(&mut Registry) -> T + Send + 'static,
    {
        if unsafe { libc::pthread_main_np() } != 0 {
            return super::shared::locked(f);
        }
        let mut result = None;
        DispatchQueue::main().exec_sync(|| result = Some(super::shared::locked(f)));
        result.unwrap_or_else(|| Err("Main-thread dispatch did not run".into()))
    }
}

#[cfg(target_os = "windows")]
mod windows {
    use super::Registry;
    use std::sync::{mpsc, Mutex, OnceLock};
    use std::thread;
    use windows_sys::Win32::System::Threading::GetCurrentThreadId;
    use windows_sys::Win32::UI::WindowsAndMessaging::{
        DispatchMessageW, GetMessageW, PeekMessageW, PostThreadMessageW, TranslateMessage, MSG,
        PM_NOREMOVE, WM_APP, WM_USER,
    };

    type Job = Box<dyn FnOnce(&mut Registry) + Send>;

    struct Owner {
        jobs: Mutex<mpsc::Sender<Job>>,
        thread_id: u32,
    }

    static OWNER: OnceLock<Option<Owner>> = OnceLock::new();

    pub fn with_registry<T, F>(f: F) -> Result<T, String>
    where
        T: Send + 'static,
        F: FnOnce(&mut Registry) -> T + Send + 'static,
    {
        let owner = OWNER
            .get_or_init(spawn_owner)
            .as_ref()
            .ok_or_else(|| "Failed to start the hotkey thread".to_owned())?;
        let (tx, rx) = mpsc::channel();
        let job: Job = Box::new(move |registry| {
            let _ = tx.send(f(registry));
        });
        owner
            .jobs
            .lock()
            .map_err(|e| format!("Hotkey job lock poisoned: {e}"))?
            .send(job)
            .map_err(|_| "Hotkey thread has stopped".to_owned())?;
        unsafe { PostThreadMessageW(owner.thread_id, WM_APP, 0, 0) };
        rx.recv()
            .map_err(|_| "Hotkey thread dropped the request".to_owned())
    }

    fn spawn_owner() -> Option<Owner> {
        let (jobs, job_rx) = mpsc::channel::<Job>();
        let (ready_tx, ready_rx) = mpsc::channel::<u32>();
        thread::Builder::new()
            .name("hotkey-owner".into())
            .spawn(move || message_loop(job_rx, ready_tx))
            .ok()?;
        let thread_id = ready_rx.recv().ok()?;
        Some(Owner {
            jobs: Mutex::new(jobs),
            thread_id,
        })
    }

    fn message_loop(jobs: mpsc::Receiver<Job>, ready: mpsc::Sender<u32>) {
        let mut registry = Registry::new();
        unsafe {
            let mut msg: MSG = std::mem::zeroed();
            // A thread has no message queue until it asks for one; without this
            // PostThreadMessageW from the caller fails and the loop never wakes.
            PeekMessageW(
                &mut msg,
                std::ptr::null_mut(),
                WM_USER,
                WM_USER,
                PM_NOREMOVE,
            );
            let _ = ready.send(GetCurrentThreadId());
            loop {
                while let Ok(job) = jobs.try_recv() {
                    job(&mut registry);
                }
                if GetMessageW(&mut msg, std::ptr::null_mut(), 0, 0) <= 0 {
                    break;
                }
                TranslateMessage(&msg);
                DispatchMessageW(&msg);
            }
        }
    }
}
