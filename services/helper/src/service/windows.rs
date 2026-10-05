use crate::service::owner::{owner_sid_arguments, service_command, ServiceCommand};
use crate::service::peer::{process_sid, serve_until};

use anyhow::{bail, Context, Result};
use once_cell::sync::OnceCell;
use std::ffi::{OsStr, OsString};
use std::thread::sleep;
use std::time::{Duration, Instant};

use tokio::runtime::Runtime;
use tokio::sync::watch;

use windows_service::{
    define_windows_service,
    service::{
        Service, ServiceAccess, ServiceAction, ServiceActionType, ServiceControl,
        ServiceControlAccept, ServiceErrorControl, ServiceExitCode, ServiceFailureActions,
        ServiceFailureResetPeriod, ServiceInfo, ServiceStartType, ServiceState, ServiceStatus,
        ServiceType,
    },
    service_control_handler::{self, ServiceControlHandlerResult},
    service_dispatcher,
    service_manager::{ServiceManager, ServiceManagerAccess},
};

const SERVICE_NAME: &str = "FlClashHelperService";
const SERVICE_TYPE: ServiceType = ServiceType::OWN_PROCESS;
const SERVICE_OPERATION_TIMEOUT: Duration = Duration::from_secs(10);
const SERVICE_POLL_INTERVAL: Duration = Duration::from_millis(100);
const SERVICE_RESTART_DELAY: Duration = Duration::from_secs(5);
const SERVICE_FAILURE_RESET_PERIOD: Duration = Duration::from_secs(24 * 60 * 60);

const ERROR_SERVICE_ALREADY_RUNNING: i32 = 1056;
const ERROR_SERVICE_DOES_NOT_EXIST: i32 = 1060;
const ERROR_SERVICE_CANNOT_ACCEPT_CTRL: i32 = 1061;
const ERROR_SERVICE_NOT_ACTIVE: i32 = 1062;
const ERROR_SERVICE_MARKED_FOR_DELETE: i32 = 1072;

static OWNER_SID: OnceCell<String> = OnceCell::new();

pub fn main() -> Result<()> {
    match service_command(std::env::args_os().skip(1))? {
        ServiceCommand::Run { owner_sid } => start_service(owner_sid).map_err(Into::into),
        ServiceCommand::Install { owner_pid } => install_service(owner_pid),
        ServiceCommand::Uninstall => uninstall_service(),
    }
}

fn start_service(owner_sid: String) -> windows_service::Result<()> {
    let _ = OWNER_SID.set(owner_sid);
    service_dispatcher::start(SERVICE_NAME, ffi_service_main)
}

define_windows_service!(ffi_service_main, service_main);

fn service_main(_arguments: Vec<OsString>) {
    let _ = run_windows_service();
}

fn run_windows_service() -> Result<()> {
    let owner_sid = OWNER_SID
        .get()
        .cloned()
        .context("the helper service has no owner")?;
    let (shutdown_tx, mut shutdown_rx) = watch::channel(false);
    let status_handle = service_control_handler::register(
        SERVICE_NAME,
        move |event| -> ServiceControlHandlerResult {
            match event {
                ServiceControl::Interrogate => ServiceControlHandlerResult::NoError,
                ServiceControl::Stop => {
                    let _ = shutdown_tx.send(true);
                    ServiceControlHandlerResult::NoError
                }
                _ => ServiceControlHandlerResult::NotImplemented,
            }
        },
    )
    .context("register helper service control handler")?;

    status_handle
        .set_service_status(service_status(
            ServiceState::StartPending,
            ServiceControlAccept::empty(),
            1,
            SERVICE_OPERATION_TIMEOUT,
            0,
        ))
        .context("report helper service startup")?;

    let runtime = match Runtime::new() {
        Ok(runtime) => runtime,
        Err(error) => {
            let _ = status_handle.set_service_status(service_status(
                ServiceState::Stopped,
                ServiceControlAccept::empty(),
                0,
                Duration::default(),
                1,
            ));
            return Err(error).context("create helper runtime");
        }
    };

    let shutdown_status_handle = status_handle;
    let running_status_handle = status_handle;
    let service_result = runtime.block_on(serve_until(
        owner_sid,
        async move {
            if !*shutdown_rx.borrow() {
                let _ = shutdown_rx.changed().await;
            }
            let _ = shutdown_status_handle.set_service_status(service_status(
                ServiceState::StopPending,
                ServiceControlAccept::empty(),
                1,
                SERVICE_OPERATION_TIMEOUT,
                0,
            ));
        },
        move || {
            running_status_handle
                .set_service_status(service_status(
                    ServiceState::Running,
                    ServiceControlAccept::STOP,
                    0,
                    Duration::default(),
                    0,
                ))
                .context("report helper service running")
        },
    ));
    let exit_code = u32::from(service_result.is_err());
    let status_result = status_handle.set_service_status(service_status(
        ServiceState::Stopped,
        ServiceControlAccept::empty(),
        0,
        Duration::default(),
        exit_code,
    ));

    service_result.context("run helper service")?;
    status_result.context("report helper service stopped")?;
    Ok(())
}

fn install_service(owner_pid: u32) -> Result<()> {
    let owner_sid = process_sid(owner_pid)
        .with_context(|| format!("read the account of process {owner_pid}"))?;
    let manager = ServiceManager::local_computer(
        None::<&str>,
        ServiceManagerAccess::CONNECT | ServiceManagerAccess::CREATE_SERVICE,
    )
    .context("open Windows service manager")?;
    remove_existing_service(&manager)?;

    let executable_path = std::env::current_exe().context("resolve helper executable path")?;
    let service_info = ServiceInfo {
        name: OsString::from(SERVICE_NAME),
        display_name: OsString::from(SERVICE_NAME),
        service_type: SERVICE_TYPE,
        start_type: ServiceStartType::AutoStart,
        error_control: ServiceErrorControl::Normal,
        executable_path,
        launch_arguments: owner_sid_arguments(&owner_sid),
        dependencies: Vec::new(),
        account_name: None,
        account_password: None,
    };
    let service = manager
        .create_service(
            &service_info,
            ServiceAccess::QUERY_STATUS | ServiceAccess::START | ServiceAccess::CHANGE_CONFIG,
        )
        .context("create helper service")?;
    service
        .update_failure_actions(crash_recovery())
        .context("configure helper service recovery")?;
    if let Err(error) = service.start::<&OsStr>(&[]) {
        if !has_error_code(&error, ERROR_SERVICE_ALREADY_RUNNING) {
            return Err(error).context("start helper service");
        }
    }
    wait_for_running(&service)
}

/// The SCM side of the Linux unit's `Restart=on-failure`; a clean stop stays stopped.
fn crash_recovery() -> ServiceFailureActions {
    let restart = ServiceAction {
        action_type: ServiceActionType::Restart,
        delay: SERVICE_RESTART_DELAY,
    };
    ServiceFailureActions {
        reset_period: ServiceFailureResetPeriod::After(SERVICE_FAILURE_RESET_PERIOD),
        reboot_msg: None,
        command: None,
        actions: Some(vec![restart.clone(), restart.clone(), restart]),
    }
}

fn uninstall_service() -> Result<()> {
    let manager = ServiceManager::local_computer(None::<&str>, ServiceManagerAccess::CONNECT)
        .context("open Windows service manager")?;
    remove_existing_service(&manager)
}

fn remove_existing_service(manager: &ServiceManager) -> Result<()> {
    let access = ServiceAccess::QUERY_STATUS | ServiceAccess::STOP | ServiceAccess::DELETE;
    let service = match manager.open_service(SERVICE_NAME, access) {
        Ok(service) => service,
        Err(error) if has_error_code(&error, ERROR_SERVICE_DOES_NOT_EXIST) => return Ok(()),
        Err(error) if has_error_code(&error, ERROR_SERVICE_MARKED_FOR_DELETE) => {
            return wait_for_deletion(manager)
        }
        Err(error) => return Err(error).context("open existing helper service"),
    };

    stop_service(&service)?;
    if let Err(error) = service.delete() {
        if !has_error_code(&error, ERROR_SERVICE_MARKED_FOR_DELETE)
            && !has_error_code(&error, ERROR_SERVICE_DOES_NOT_EXIST)
        {
            return Err(error).context("delete helper service");
        }
    }
    drop(service);
    wait_for_deletion(manager)
}

fn stop_service(service: &Service) -> Result<()> {
    let started_at = Instant::now();
    loop {
        let state = service
            .query_status()
            .context("query helper service before stopping")?
            .current_state;
        if state == ServiceState::Stopped {
            return Ok(());
        }
        if state != ServiceState::StopPending {
            if let Err(error) = service.stop() {
                if has_error_code(&error, ERROR_SERVICE_NOT_ACTIVE) {
                    return Ok(());
                }
                if !has_error_code(&error, ERROR_SERVICE_CANNOT_ACCEPT_CTRL) {
                    return Err(error).context("stop helper service");
                }
            }
        }
        if started_at.elapsed() >= SERVICE_OPERATION_TIMEOUT {
            bail!("timed out waiting for helper service to stop from {state:?}");
        }
        sleep(SERVICE_POLL_INTERVAL);
    }
}

fn wait_for_deletion(manager: &ServiceManager) -> Result<()> {
    let started_at = Instant::now();
    loop {
        match manager.open_service(SERVICE_NAME, ServiceAccess::QUERY_STATUS) {
            Err(error) if has_error_code(&error, ERROR_SERVICE_DOES_NOT_EXIST) => return Ok(()),
            Err(error) if !has_error_code(&error, ERROR_SERVICE_MARKED_FOR_DELETE) => {
                return Err(error).context("check helper service deletion")
            }
            Ok(service) => drop(service),
            Err(_) => {}
        }
        if started_at.elapsed() >= SERVICE_OPERATION_TIMEOUT {
            bail!("timed out waiting for helper service deletion");
        }
        sleep(SERVICE_POLL_INTERVAL);
    }
}

fn wait_for_running(service: &Service) -> Result<()> {
    let started_at = Instant::now();
    loop {
        let state = service
            .query_status()
            .context("query helper service after starting")?
            .current_state;
        match state {
            ServiceState::Running => return Ok(()),
            ServiceState::Stopped => bail!("helper service stopped during startup"),
            _ => {}
        }
        if started_at.elapsed() >= SERVICE_OPERATION_TIMEOUT {
            bail!("timed out waiting for helper service to run from {state:?}");
        }
        sleep(SERVICE_POLL_INTERVAL);
    }
}

fn has_error_code(error: &windows_service::Error, code: i32) -> bool {
    matches!(error, windows_service::Error::Winapi(error) if error.raw_os_error() == Some(code))
}

fn service_status(
    current_state: ServiceState,
    controls_accepted: ServiceControlAccept,
    checkpoint: u32,
    wait_hint: Duration,
    exit_code: u32,
) -> ServiceStatus {
    ServiceStatus {
        service_type: SERVICE_TYPE,
        current_state,
        controls_accepted,
        exit_code: ServiceExitCode::Win32(exit_code),
        checkpoint,
        wait_hint,
        process_id: None,
    }
}
