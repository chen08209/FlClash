use once_cell::sync::Lazy;
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::collections::VecDeque;
use std::fs::{File, OpenOptions};
#[cfg(not(all(feature = "windows-service", target_os = "windows")))]
use std::future::pending;
use std::future::Future;
use std::io::{BufRead, Error, Read};
#[cfg(windows)]
use std::os::windows::fs::OpenOptionsExt;
use std::path::{Path, PathBuf};
use std::process::{Command, Stdio};
use std::sync::{Arc, Mutex};
use std::{io, thread};
use warp::http::StatusCode;
use warp::{Filter, Rejection, Reply};
#[cfg(windows)]
use windows_sys::Win32::Storage::FileSystem::FILE_SHARE_READ;

const LISTEN_PORT: u16 = 47890;
const CORE_PIPE_PREFIX: &str = r"\\.\pipe\FlClashCore_";
const PROTOCOL_VERSION_HEADER: &str = "x-flclash-helper-protocol";
const PROTOCOL_VERSION: &str = "4";
const EXPECTED_CORE_SHA256: &str = env!("CORE_SHA256");

#[derive(Debug, Deserialize, Serialize, Clone)]
#[serde(deny_unknown_fields)]
pub struct StartParams {
    pub address: String,
}

fn core_path() -> Result<PathBuf, Error> {
    let helper_path = std::env::current_exe()?;
    let directory = helper_path
        .parent()
        .ok_or_else(|| Error::other("helper executable has no parent directory"))?;
    Ok(directory.join(env!("CORE_NAME")))
}

fn open_core(path: &Path) -> Result<File, Error> {
    let mut options = OpenOptions::new();
    options.read(true);
    #[cfg(windows)]
    options.share_mode(FILE_SHARE_READ);
    options.open(path)
}

fn sha256_file(file: &mut File) -> Result<String, Error> {
    let mut hasher = Sha256::new();
    let mut buffer = [0; 4096];

    loop {
        let bytes_read = file.read(&mut buffer)?;
        if bytes_read == 0 {
            break;
        }
        hasher.update(&buffer[..bytes_read]);
    }

    Ok(format!("{:x}", hasher.finalize()))
}

fn open_verified_core(path: &Path, expected_sha256: &str) -> Result<File, Error> {
    if expected_sha256.is_empty() {
        return Err(Error::other("expected Core SHA256 is empty"));
    }
    let mut core_file = open_core(path)?;
    if sha256_file(&mut core_file)? != expected_sha256 {
        return Err(Error::other("Core executable SHA256 mismatch"));
    }
    Ok(core_file)
}

fn open_fixed_verified_core() -> Result<(PathBuf, File), Error> {
    let path = core_path()?;
    let file = open_verified_core(&path, EXPECTED_CORE_SHA256)?;
    Ok((path, file))
}

fn is_allowed_core_pipe(address: &str) -> bool {
    let Some(suffix) = address.strip_prefix(CORE_PIPE_PREFIX) else {
        return false;
    };
    suffix.len() == 32 && suffix.bytes().all(|value| value.is_ascii_hexdigit())
}

static LOGS: Lazy<Arc<Mutex<VecDeque<String>>>> =
    Lazy::new(|| Arc::new(Mutex::new(VecDeque::with_capacity(100))));
static PROCESS: Lazy<Arc<Mutex<Option<std::process::Child>>>> =
    Lazy::new(|| Arc::new(Mutex::new(None)));

fn start(start_params: StartParams) -> impl Reply {
    if !is_allowed_core_pipe(&start_params.address) {
        return "invalid Core pipe address".to_string();
    }

    let (core_path, _core_file) = match open_fixed_verified_core() {
        Ok(core) => core,
        Err(error) => return error.to_string(),
    };

    stop_core();
    let mut process = PROCESS.lock().unwrap();
    match Command::new(&core_path)
        .current_dir(core_path.parent().unwrap())
        .stderr(Stdio::piped())
        .arg(&start_params.address)
        .spawn()
    {
        Ok(child) => {
            let process_id = child.id();
            *process = Some(child);
            if let Some(ref mut child) = *process {
                let stderr = child.stderr.take().unwrap();
                let reader = io::BufReader::new(stderr);
                thread::spawn(move || {
                    for line in reader.lines() {
                        match line {
                            Ok(output) => {
                                log_message(output);
                            }
                            Err(_) => {
                                break;
                            }
                        }
                    }
                });
            }
            process_id.to_string()
        }
        Err(e) => {
            log_message(e.to_string());
            e.to_string()
        }
    }
}

fn stop_core() -> String {
    let mut process = PROCESS.lock().unwrap();
    if let Some(mut child) = process.take() {
        let _ = child.kill();
        let _ = child.wait();
    }
    *process = None;
    String::new()
}

fn log_message(message: String) {
    let mut log_buffer = LOGS.lock().unwrap();
    if log_buffer.len() == 100 {
        log_buffer.pop_front();
    }
    log_buffer.push_back(format!("{}\n", message));
}

fn get_logs() -> impl Reply {
    let log_buffer = LOGS.lock().unwrap();
    let value = log_buffer
        .iter()
        .cloned()
        .collect::<Vec<String>>()
        .join("\n");
    warp::reply::with_header(
        warp::reply::with_header(value, "Content-Type", "text/plain; charset=utf-8"),
        "Cache-Control",
        "no-store",
    )
}

fn ping_response(result: Result<PathBuf, Error>) -> warp::reply::Response {
    let (value, status) = match result {
        Ok(path) => (path.to_string_lossy().into_owned(), StatusCode::OK),
        Err(error) => (error.to_string(), StatusCode::CONFLICT),
    };
    warp::reply::with_header(
        warp::reply::with_status(value, status),
        PROTOCOL_VERSION_HEADER,
        PROTOCOL_VERSION,
    )
    .into_response()
}

fn ping() -> warp::reply::Response {
    let result = open_fixed_verified_core().and_then(|_| std::env::current_exe());
    if let Err(error) = &result {
        log_message(format!("Helper ping failed: {error}"));
    }
    ping_response(result)
}

fn routes() -> impl Filter<Extract = (impl Reply,), Error = Rejection> + Clone {
    let api_ping = warp::get()
        .and(warp::path("ping"))
        .and(warp::path::end())
        .map(ping);

    let api_start = warp::post()
        .and(warp::path("start"))
        .and(warp::path::end())
        .and(warp::body::json())
        .map(start);

    let api_stop = warp::post()
        .and(warp::path("stop"))
        .and(warp::path::end())
        .map(stop_core);

    let api_logs = warp::get()
        .and(warp::path("logs"))
        .and(warp::path::end())
        .map(get_logs);

    api_ping.or(api_start).or(api_stop).or(api_logs)
}

#[cfg(not(all(feature = "windows-service", target_os = "windows")))]
pub async fn run_service() -> anyhow::Result<()> {
    run_service_until(pending(), || Ok(())).await
}

pub(super) async fn run_service_until<F, S>(shutdown: F, on_started: S) -> anyhow::Result<()>
where
    F: Future<Output = ()> + Send + 'static,
    S: FnOnce() -> anyhow::Result<()>,
{
    if EXPECTED_CORE_SHA256.is_empty() {
        anyhow::bail!("expected Core SHA256 is empty");
    }

    let (_, server) = warp::serve(routes())
        .try_bind_with_graceful_shutdown(([127, 0, 0, 1], LISTEN_PORT), shutdown)
        .map_err(|error| anyhow::anyhow!("bind helper server: {error}"))?;
    on_started()?;
    server.await;
    stop_core();

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::io::Write;

    #[tokio::test]
    async fn ping_returns_running_helper_path_for_verified_core() {
        let response = ping_response(Ok(PathBuf::from("FlClashHelperService.exe")));

        assert_eq!(response.status(), StatusCode::OK);
        assert_eq!(
            response.headers().get(PROTOCOL_VERSION_HEADER).unwrap(),
            PROTOCOL_VERSION
        );
        assert_eq!(
            warp::hyper::body::to_bytes(response.into_body())
                .await
                .unwrap(),
            "FlClashHelperService.exe"
        );
    }

    #[tokio::test]
    async fn ping_rejects_unverified_core() {
        let response = ping_response(Err(Error::other("Core executable SHA256 mismatch")));

        assert_eq!(response.status(), StatusCode::CONFLICT);
        assert_eq!(
            response.headers().get(PROTOCOL_VERSION_HEADER).unwrap(),
            PROTOCOL_VERSION
        );
        assert_eq!(
            warp::hyper::body::to_bytes(response.into_body())
                .await
                .unwrap(),
            "Core executable SHA256 mismatch"
        );
    }

    #[tokio::test]
    async fn ping_is_available_without_authentication() {
        let response = warp::test::request()
            .method("GET")
            .path("/ping")
            .reply(&routes())
            .await;

        assert!(response.status() == StatusCode::OK || response.status() == StatusCode::CONFLICT);
        assert_eq!(
            response.headers().get(PROTOCOL_VERSION_HEADER).unwrap(),
            PROTOCOL_VERSION
        );
    }

    #[tokio::test]
    async fn logs_are_available_without_authentication() {
        let response = warp::test::request()
            .method("GET")
            .path("/logs")
            .reply(&routes())
            .await;

        assert_eq!(response.status(), StatusCode::OK);
        assert_eq!(
            response.headers().get("content-type").unwrap(),
            "text/plain; charset=utf-8"
        );
        assert_eq!(response.headers().get("cache-control").unwrap(), "no-store");
    }

    #[tokio::test]
    async fn start_rejects_a_caller_supplied_core_argument() {
        let response = warp::test::request()
            .method("POST")
            .path("/start")
            .header("content-type", "application/json")
            .body(
                r#"{"address":"\\\\.\\pipe\\FlClashCore_0123456789abcdef0123456789abcdef","path":"attacker.exe"}"#,
            )
            .reply(&routes())
            .await;

        assert_eq!(response.status(), StatusCode::BAD_REQUEST);
    }

    #[test]
    fn verifies_core_sha256_in_all_build_modes() {
        let path =
            std::env::temp_dir().join(format!("flclash-helper-core-sha256-{}", std::process::id()));
        let mut file = File::create(&path).unwrap();
        file.write_all(b"test").unwrap();
        drop(file);

        assert!(open_verified_core(
            &path,
            "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08"
        )
        .is_ok());
        assert_eq!(
            open_verified_core(&path, "invalid")
                .unwrap_err()
                .to_string(),
            "Core executable SHA256 mismatch"
        );
        std::fs::remove_file(path).unwrap();
    }

    #[tokio::test]
    async fn stop_is_available_without_authentication() {
        let response = warp::test::request()
            .method("POST")
            .path("/stop")
            .reply(&routes())
            .await;

        assert_eq!(response.status(), StatusCode::OK);
    }

    #[test]
    fn core_path_is_fixed_beside_the_helper() {
        assert_eq!(
            core_path().unwrap().file_name().unwrap(),
            std::ffi::OsStr::new(env!("CORE_NAME"))
        );
    }

    #[test]
    fn only_accepts_random_core_pipe_namespace() {
        assert!(is_allowed_core_pipe(
            r"\\.\pipe\FlClashCore_0123456789abcdef0123456789abcdef"
        ));
        assert!(!is_allowed_core_pipe(r"\\.\pipe\FlClashCore"));
        assert!(!is_allowed_core_pipe(
            r"\\.\pipe\Other_0123456789abcdef0123456789abcdef"
        ));
        assert!(!is_allowed_core_pipe(
            r"\\.\pipe\FlClashCore_0123456789abcdef"
        ));
        assert!(!is_allowed_core_pipe(
            r"\\.\pipe\FlClashCore_0123456789abcdef0123456789abcdeg"
        ));
    }
}
