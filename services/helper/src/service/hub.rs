use once_cell::sync::Lazy;
use serde::{Deserialize, Serialize};
use sha2::{Digest, Sha256};
use std::collections::VecDeque;
use std::convert::Infallible;
use std::fs::{File, OpenOptions};
#[cfg(not(all(feature = "windows-service", target_os = "windows")))]
use std::future::pending;
use std::future::Future;
use std::io::{BufRead, Error, Read};
#[cfg(windows)]
use std::os::windows::fs::OpenOptionsExt;
use std::path::{Path, PathBuf};
use std::process::{Child, Command, Stdio};
use std::sync::Mutex;
use std::time::{Duration, Instant};
use std::{io, thread};
use warp::http::StatusCode;
use warp::{Filter, Rejection, Reply};
#[cfg(windows)]
use windows_sys::Win32::Storage::FileSystem::FILE_SHARE_READ;

const LISTEN_PORT: u16 = 47890;
const CORE_PIPE_PREFIX: &str = r"\\.\pipe\FlClashCore_";
const PROTOCOL_VERSION_HEADER: &str = "x-flclash-helper-protocol";
const PROTOCOL_VERSION: &str = "6";
const EXPECTED_CORE_SHA256: &str = env!("CORE_SHA256");
const LOG_CAPACITY: usize = 100;
const CORE_EXIT_TIMEOUT: Duration = Duration::from_millis(1500);
const CORE_EXIT_POLL_INTERVAL: Duration = Duration::from_millis(20);

#[derive(Debug, Deserialize, Serialize, Clone)]
#[serde(deny_unknown_fields)]
pub struct StartParams {
    pub address: String,
    #[serde(rename = "sessionId")]
    pub session_id: String,
}

#[derive(Debug, Deserialize, Serialize, Clone)]
#[serde(deny_unknown_fields)]
pub struct StopParams {
    #[serde(rename = "sessionId")]
    pub session_id: String,
}

#[derive(Debug, Deserialize)]
#[serde(deny_unknown_fields)]
struct PingParams {
    #[serde(rename = "coreSha256")]
    core_sha256: String,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
struct StartResponse {
    session_id: String,
    pid: u32,
}

#[derive(Serialize)]
#[serde(rename_all = "camelCase")]
struct StopResponse {
    session_id: String,
    stopped: bool,
    #[serde(skip_serializing_if = "Option::is_none")]
    reason: Option<&'static str>,
}

#[derive(Serialize)]
struct ErrorResponse {
    code: &'static str,
    message: String,
}

struct ManagedCore {
    session_id: String,
    child: Child,
}

impl ManagedCore {
    fn terminate(&mut self) -> Result<(), Error> {
        let _ = self.child.kill();
        let deadline = Instant::now() + CORE_EXIT_TIMEOUT;
        loop {
            if self.child.try_wait()?.is_some() {
                return Ok(());
            }
            if Instant::now() >= deadline {
                return Err(Error::other("Core did not exit after termination"));
            }
            thread::sleep(CORE_EXIT_POLL_INTERVAL);
        }
    }
}

struct VerifiedCore {
    path: PathBuf,
    directory: PathBuf,
    _handle: File,
}

impl VerifiedCore {
    fn open() -> Result<Self, Error> {
        let path = core_path()?;
        let directory = path
            .parent()
            .ok_or_else(|| Error::other("Core executable has no parent directory"))?
            .to_path_buf();
        let handle = open_verified_core(&path, EXPECTED_CORE_SHA256)?;
        Ok(Self {
            path,
            directory,
            _handle: handle,
        })
    }

    fn spawn(&self, address: &str) -> Result<Child, Error> {
        Command::new(&self.path)
            .current_dir(&self.directory)
            .stderr(Stdio::piped())
            .arg(address)
            .spawn()
    }
}

#[derive(Debug, PartialEq, Eq)]
enum StopDecision {
    NotRunning,
    Stop,
    SessionMismatch,
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

fn is_allowed_core_pipe(address: &str) -> bool {
    let Some(suffix) = address.strip_prefix(CORE_PIPE_PREFIX) else {
        return false;
    };
    is_valid_session_id(suffix)
}

fn is_valid_session_id(value: &str) -> bool {
    value.len() == 32
        && value
            .bytes()
            .all(|byte| byte.is_ascii_digit() || (b'a'..=b'f').contains(&byte))
}

fn stop_decision(current: Option<&str>, requested: &str) -> StopDecision {
    match current {
        None => StopDecision::NotRunning,
        Some(session_id) if session_id == requested => StopDecision::Stop,
        Some(_) => StopDecision::SessionMismatch,
    }
}

static LOGS: Lazy<Mutex<VecDeque<String>>> =
    Lazy::new(|| Mutex::new(VecDeque::with_capacity(LOG_CAPACITY)));
static MANAGED_CORE: Lazy<Mutex<Option<ManagedCore>>> = Lazy::new(|| Mutex::new(None));

fn release_managed_core(managed: &mut Option<ManagedCore>) -> Result<(), Error> {
    let Some(core) = managed.as_mut() else {
        return Ok(());
    };
    core.terminate()?;
    *managed = None;
    Ok(())
}

fn json_response<T: Serialize>(value: &T, status: StatusCode) -> warp::reply::Response {
    warp::reply::with_status(warp::reply::json(value), status).into_response()
}

fn error_response(
    code: &'static str,
    message: impl Into<String>,
    status: StatusCode,
) -> warp::reply::Response {
    json_response(
        &ErrorResponse {
            code,
            message: message.into(),
        },
        status,
    )
}

fn start(start_params: StartParams) -> warp::reply::Response {
    if !is_allowed_core_pipe(&start_params.address) {
        return error_response(
            "invalidRequest",
            "invalid Core pipe address",
            StatusCode::BAD_REQUEST,
        );
    }
    if !is_valid_session_id(&start_params.session_id) {
        return error_response(
            "invalidRequest",
            "invalid Core session ID",
            StatusCode::BAD_REQUEST,
        );
    }

    let mut managed = MANAGED_CORE.lock().unwrap();
    if let Err(error) = release_managed_core(&mut managed) {
        log_message(format!(
            "Helper could not release the managed Core: {error}"
        ));
        return error_response(
            "coreStopFailed",
            error.to_string(),
            StatusCode::INTERNAL_SERVER_ERROR,
        );
    }
    let core = match VerifiedCore::open() {
        Ok(core) => core,
        Err(error) => {
            return error_response(
                "coreVerificationFailed",
                error.to_string(),
                StatusCode::CONFLICT,
            )
        }
    };

    match core.spawn(&start_params.address) {
        Ok(mut child) => {
            let process_id = child.id();
            if let Some(stderr) = child.stderr.take() {
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
            *managed = Some(ManagedCore {
                session_id: start_params.session_id.clone(),
                child,
            });
            json_response(
                &StartResponse {
                    session_id: start_params.session_id,
                    pid: process_id,
                },
                StatusCode::OK,
            )
        }
        Err(e) => {
            log_message(e.to_string());
            error_response(
                "processLaunchFailed",
                e.to_string(),
                StatusCode::INTERNAL_SERVER_ERROR,
            )
        }
    }
}

fn stop_core(stop_params: StopParams) -> warp::reply::Response {
    if !is_valid_session_id(&stop_params.session_id) {
        return error_response(
            "invalidRequest",
            "invalid Core session ID",
            StatusCode::BAD_REQUEST,
        );
    }
    let mut managed = MANAGED_CORE.lock().unwrap();
    match stop_decision(
        managed.as_ref().map(|core| core.session_id.as_str()),
        &stop_params.session_id,
    ) {
        StopDecision::NotRunning => json_response(
            &StopResponse {
                session_id: stop_params.session_id,
                stopped: false,
                reason: Some("notRunning"),
            },
            StatusCode::OK,
        ),
        StopDecision::SessionMismatch => json_response(
            &StopResponse {
                session_id: stop_params.session_id,
                stopped: false,
                reason: Some("sessionMismatch"),
            },
            StatusCode::CONFLICT,
        ),
        StopDecision::Stop => match release_managed_core(&mut managed) {
            Ok(()) => json_response(
                &StopResponse {
                    session_id: stop_params.session_id,
                    stopped: true,
                    reason: None,
                },
                StatusCode::OK,
            ),
            Err(error) => {
                log_message(format!("Helper could not stop the managed Core: {error}"));
                error_response(
                    "coreStopFailed",
                    error.to_string(),
                    StatusCode::INTERNAL_SERVER_ERROR,
                )
            }
        },
    }
}

fn log_message(message: String) {
    let mut log_buffer = LOGS.lock().unwrap();
    while log_buffer.len() >= LOG_CAPACITY {
        log_buffer.pop_front();
    }
    log_buffer.push_back(message);
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

fn ping_core_sha256_mismatch() -> warp::reply::Response {
    warp::reply::with_header(
        error_response(
            "coreSha256Mismatch",
            "Core SHA256 mismatch",
            StatusCode::CONFLICT,
        ),
        PROTOCOL_VERSION_HEADER,
        PROTOCOL_VERSION,
    )
    .into_response()
}

fn probe_helper_path() -> Result<PathBuf, Error> {
    open_core(&core_path()?)?;
    std::env::current_exe()
}

fn ping(ping_params: PingParams) -> warp::reply::Response {
    if ping_params.core_sha256 != EXPECTED_CORE_SHA256 {
        log_message("Helper ping rejected a Core SHA256 mismatch".to_string());
        return ping_core_sha256_mismatch();
    }

    let result = probe_helper_path();
    if let Err(error) = &result {
        log_message(format!("Helper ping failed: {error}"));
    }
    ping_response(result)
}

async fn start_request(start_params: StartParams) -> Result<warp::reply::Response, Infallible> {
    Ok(
        match tokio::task::spawn_blocking(move || start(start_params)).await {
            Ok(response) => response,
            Err(error) => error_response(
                "internalError",
                format!("Core start task failed: {error}"),
                StatusCode::INTERNAL_SERVER_ERROR,
            ),
        },
    )
}

async fn stop_request(stop_params: StopParams) -> Result<warp::reply::Response, Infallible> {
    Ok(
        match tokio::task::spawn_blocking(move || stop_core(stop_params)).await {
            Ok(response) => response,
            Err(error) => error_response(
                "internalError",
                format!("Core stop task failed: {error}"),
                StatusCode::INTERNAL_SERVER_ERROR,
            ),
        },
    )
}

async fn ping_request(ping_params: PingParams) -> Result<warp::reply::Response, Infallible> {
    Ok(tokio::task::spawn_blocking(move || ping(ping_params))
        .await
        .unwrap_or_else(|error| {
            ping_response(Err(Error::other(format!(
                "Helper ping task failed: {error}"
            ))))
        }))
}

async fn handle_rejection(rejection: Rejection) -> Result<warp::reply::Response, Infallible> {
    if rejection.find::<warp::reject::InvalidQuery>().is_some() {
        return Ok(warp::reply::with_header(
            error_response(
                "invalidRequest",
                "invalid ping query",
                StatusCode::BAD_REQUEST,
            ),
            PROTOCOL_VERSION_HEADER,
            PROTOCOL_VERSION,
        )
        .into_response());
    }
    if rejection
        .find::<warp::filters::body::BodyDeserializeError>()
        .is_some()
    {
        return Ok(error_response(
            "invalidRequest",
            "invalid JSON request body",
            StatusCode::BAD_REQUEST,
        ));
    }
    if rejection.is_not_found() {
        return Ok(error_response(
            "notFound",
            "Helper endpoint not found",
            StatusCode::NOT_FOUND,
        ));
    }
    Ok(error_response(
        "internalError",
        "unhandled Helper request rejection",
        StatusCode::INTERNAL_SERVER_ERROR,
    ))
}

fn routes() -> impl Filter<Extract = (impl Reply,), Error = Infallible> + Clone {
    let api_ping = warp::get()
        .and(warp::path("ping"))
        .and(warp::path::end())
        .and(warp::query::<PingParams>())
        .and_then(ping_request);

    let api_start = warp::post()
        .and(warp::path("start"))
        .and(warp::path::end())
        .and(warp::body::json())
        .and_then(start_request);

    let api_stop = warp::post()
        .and(warp::path("stop"))
        .and(warp::path::end())
        .and(warp::body::json())
        .and_then(stop_request);

    let api_logs = warp::get()
        .and(warp::path("logs"))
        .and(warp::path::end())
        .map(get_logs);

    api_ping
        .or(api_start)
        .or(api_stop)
        .or(api_logs)
        .recover(handle_rejection)
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
    let mut managed = MANAGED_CORE.lock().unwrap();
    if let Err(error) = release_managed_core(&mut managed) {
        log_message(format!(
            "Helper could not stop the managed Core on shutdown: {error}"
        ));
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::io::Write;

    static PROCESS_STATE: Mutex<()> = Mutex::new(());

    fn lock_process_state() -> std::sync::MutexGuard<'static, ()> {
        PROCESS_STATE
            .lock()
            .unwrap_or_else(|error| error.into_inner())
    }

    fn spawn_placeholder_core() -> Child {
        #[cfg(windows)]
        let mut command = {
            let mut command = Command::new("cmd");
            command.args(["/c", "exit"]);
            command
        };
        #[cfg(not(windows))]
        let mut command = Command::new("true");
        command
            .stdout(Stdio::null())
            .stderr(Stdio::null())
            .spawn()
            .expect("spawn placeholder Core")
    }

    fn spawn_running_core() -> Child {
        #[cfg(windows)]
        let mut command = {
            let mut command = Command::new("ping");
            command.args(["-n", "60", "127.0.0.1"]);
            command
        };
        #[cfg(not(windows))]
        let mut command = {
            let mut command = Command::new("sleep");
            command.arg("60");
            command
        };
        command
            .stdout(Stdio::null())
            .stderr(Stdio::null())
            .spawn()
            .expect("spawn running Core")
    }

    fn adopt_core(session_id: &str) {
        *MANAGED_CORE.lock().unwrap() = Some(ManagedCore {
            session_id: session_id.to_string(),
            child: spawn_running_core(),
        });
    }

    #[test]
    fn protocol_6_uses_lowercase_session_ownership() {
        assert_eq!(PROTOCOL_VERSION, "6");
        assert!(is_valid_session_id("0123456789abcdef0123456789abcdef"));
        assert!(!is_valid_session_id("ABCDEF0123456789abcdef0123456789"));
        assert!(!is_valid_session_id("0123456789abcdef"));
    }

    #[test]
    fn stop_decision_never_touches_another_session() {
        let requested = "0123456789abcdef0123456789abcdef";
        let other = "fedcba9876543210fedcba9876543210";

        assert_eq!(stop_decision(None, requested), StopDecision::NotRunning);
        assert_eq!(
            stop_decision(Some(requested), requested),
            StopDecision::Stop
        );
        assert_eq!(
            stop_decision(Some(other), requested),
            StopDecision::SessionMismatch
        );
    }

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
    async fn ping_response_renders_core_verification_error() {
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
            .path(&format!("/ping?coreSha256={EXPECTED_CORE_SHA256}"))
            .reply(&routes())
            .await;

        assert!(response.status() == StatusCode::OK || response.status() == StatusCode::CONFLICT);
        assert_eq!(
            response.headers().get(PROTOCOL_VERSION_HEADER).unwrap(),
            PROTOCOL_VERSION
        );
    }

    #[tokio::test]
    async fn ping_requires_the_core_sha256_query_parameter() {
        let response = warp::test::request()
            .method("GET")
            .path("/ping")
            .reply(&routes())
            .await;

        assert_eq!(response.status(), StatusCode::BAD_REQUEST);
        assert_eq!(
            response.headers().get(PROTOCOL_VERSION_HEADER).unwrap(),
            PROTOCOL_VERSION
        );
    }

    #[tokio::test]
    async fn ping_rejects_a_core_sha256_that_does_not_match() {
        let requested = if EXPECTED_CORE_SHA256.starts_with('0') {
            format!("1{}", EXPECTED_CORE_SHA256.get(1..).unwrap_or(""))
        } else {
            format!("0{}", EXPECTED_CORE_SHA256.get(1..).unwrap_or(""))
        };
        assert_ne!(requested, EXPECTED_CORE_SHA256);

        let response = warp::test::request()
            .method("GET")
            .path(&format!("/ping?coreSha256={requested}"))
            .reply(&routes())
            .await;

        assert_eq!(response.status(), StatusCode::CONFLICT);
        assert_eq!(
            response.headers().get(PROTOCOL_VERSION_HEADER).unwrap(),
            PROTOCOL_VERSION
        );
        let body: serde_json::Value = serde_json::from_slice(response.body()).unwrap();
        assert_eq!(body["code"], "coreSha256Mismatch");
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
                r#"{"address":"\\\\.\\pipe\\FlClashCore_0123456789abcdef0123456789abcdef","sessionId":"0123456789abcdef0123456789abcdef","path":"attacker.exe"}"#,
            )
            .reply(&routes())
            .await;

        assert_eq!(response.status(), StatusCode::BAD_REQUEST);
        let body: serde_json::Value = serde_json::from_slice(response.body()).unwrap();
        assert_eq!(body["code"], "invalidRequest");
    }

    #[tokio::test]
    #[allow(clippy::await_holding_lock)]
    async fn start_releases_the_managed_core_before_rejecting_an_unverified_core() {
        let _state = lock_process_state();
        *MANAGED_CORE.lock().unwrap() = Some(ManagedCore {
            session_id: "fedcba9876543210fedcba9876543210".to_string(),
            child: spawn_placeholder_core(),
        });

        let response = warp::test::request()
            .method("POST")
            .path("/start")
            .json(&StartParams {
                address: r"\\.\pipe\FlClashCore_0123456789abcdef0123456789abcdef".to_string(),
                session_id: "0123456789abcdef0123456789abcdef".to_string(),
            })
            .reply(&routes())
            .await;

        assert_eq!(response.status(), StatusCode::CONFLICT);
        let body: serde_json::Value = serde_json::from_slice(response.body()).unwrap();
        assert_eq!(body["code"], "coreVerificationFailed");
        assert!(MANAGED_CORE.lock().unwrap().is_none());
    }

    #[tokio::test]
    #[allow(clippy::await_holding_lock)]
    async fn stop_confirms_the_exit_before_reporting_success() {
        let _state = lock_process_state();
        let session_id = "0123456789abcdef0123456789abcdef";
        adopt_core(session_id);

        let response = warp::test::request()
            .method("POST")
            .path("/stop")
            .json(&StopParams {
                session_id: session_id.to_string(),
            })
            .reply(&routes())
            .await;

        assert_eq!(response.status(), StatusCode::OK);
        let body: serde_json::Value = serde_json::from_slice(response.body()).unwrap();
        assert_eq!(body["stopped"], true);
        assert!(body.get("reason").is_none());
        assert!(MANAGED_CORE.lock().unwrap().is_none());
    }

    #[tokio::test]
    #[allow(clippy::await_holding_lock)]
    async fn stop_keeps_another_session_owned_and_running() {
        let _state = lock_process_state();
        adopt_core("fedcba9876543210fedcba9876543210");

        let response = warp::test::request()
            .method("POST")
            .path("/stop")
            .json(&StopParams {
                session_id: "0123456789abcdef0123456789abcdef".to_string(),
            })
            .reply(&routes())
            .await;

        assert_eq!(response.status(), StatusCode::CONFLICT);
        let body: serde_json::Value = serde_json::from_slice(response.body()).unwrap();
        assert_eq!(body["reason"], "sessionMismatch");

        let mut managed = MANAGED_CORE.lock().unwrap();
        let core = managed.as_mut().expect("Core stays owned");
        assert_eq!(core.session_id, "fedcba9876543210fedcba9876543210");
        assert!(core.child.try_wait().unwrap().is_none());
        release_managed_core(&mut managed).unwrap();
    }

    #[test]
    fn terminate_confirms_the_exit_of_a_running_core() {
        let mut managed = Some(ManagedCore {
            session_id: "0123456789abcdef0123456789abcdef".to_string(),
            child: spawn_running_core(),
        });

        release_managed_core(&mut managed).unwrap();

        assert!(managed.is_none());
        assert!(release_managed_core(&mut managed).is_ok());
    }

    #[tokio::test]
    async fn start_rejects_an_invalid_session_before_core_verification() {
        let response = warp::test::request()
            .method("POST")
            .path("/start")
            .json(&StartParams {
                address: r"\\.\pipe\FlClashCore_0123456789abcdef0123456789abcdef".to_string(),
                session_id: "ABCDEF0123456789abcdef0123456789".to_string(),
            })
            .reply(&routes())
            .await;

        assert_eq!(response.status(), StatusCode::BAD_REQUEST);
        let body: serde_json::Value = serde_json::from_slice(response.body()).unwrap();
        assert_eq!(body["code"], "invalidRequest");
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
    #[allow(clippy::await_holding_lock)]
    async fn stop_is_available_without_authentication() {
        let _state = lock_process_state();
        let response = warp::test::request()
            .method("POST")
            .path("/stop")
            .json(&StopParams {
                session_id: "0123456789abcdef0123456789abcdef".to_string(),
            })
            .reply(&routes())
            .await;

        assert_eq!(response.status(), StatusCode::OK);
        let body: serde_json::Value = serde_json::from_slice(response.body()).unwrap();
        assert_eq!(body["sessionId"], "0123456789abcdef0123456789abcdef");
        assert_eq!(body["stopped"], false);
        assert_eq!(body["reason"], "notRunning");
    }

    #[tokio::test]
    async fn stop_requires_a_session_json_body() {
        let response = warp::test::request()
            .method("POST")
            .path("/stop")
            .reply(&routes())
            .await;

        assert_eq!(response.status(), StatusCode::BAD_REQUEST);
        let body: serde_json::Value = serde_json::from_slice(response.body()).unwrap();
        assert_eq!(body["code"], "invalidRequest");
    }

    #[tokio::test]
    async fn stop_rejects_unknown_fields() {
        let response = warp::test::request()
            .method("POST")
            .path("/stop")
            .header("content-type", "application/json")
            .body(r#"{"sessionId":"0123456789abcdef0123456789abcdef","force":true}"#)
            .reply(&routes())
            .await;

        assert_eq!(response.status(), StatusCode::BAD_REQUEST);
        let body: serde_json::Value = serde_json::from_slice(response.body()).unwrap();
        assert_eq!(body["code"], "invalidRequest");
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
        assert!(!is_allowed_core_pipe(
            r"\\.\pipe\FlClashCore_ABCDEF0123456789abcdef0123456789"
        ));
    }
}
