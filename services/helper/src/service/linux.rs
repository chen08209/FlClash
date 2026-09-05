use crate::service::hub::{
    ensure_core_sha256_configured, log_message, release_managed_core_on_shutdown, routes,
};

use anyhow::{bail, Context, Result};
use std::ffi::{OsStr, OsString};
use std::fs;
use std::future::Future;
use std::io::{Error, ErrorKind};
use std::os::unix::fs::{FileTypeExt, MetadataExt, PermissionsExt};
use std::path::Path;
use std::pin::Pin;
use std::process::{Command, Stdio};
use std::task::{Context as TaskContext, Poll};
use std::time::Duration;
use tokio::net::{UnixListener, UnixStream};
use tokio::runtime::Runtime;
use tokio::signal::unix::{signal, SignalKind};
use tokio::time::Sleep;
use tokio_stream::Stream;

const SERVICE_NAME: &str = "flclash-helper";
const UNIT_PATH: &str = "/etc/systemd/system/flclash-helper.service";
const RUNTIME_DIR_NAME: &str = "flclash";
const SOCKET_PATH: &str = "/run/flclash/helper.sock";
const OWNER_UID_ENV: &str = "FLCLASH_HELPER_OWNER_UID";
const OWNER_GID_ENV: &str = "FLCLASH_HELPER_OWNER_GID";
const SOCKET_MODE: u32 = 0o660;
const ACCEPT_RETRY_DELAY: Duration = Duration::from_secs(1);

#[derive(Debug, PartialEq, Eq)]
enum ServiceCommand {
    Run,
    Install,
    Uninstall,
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
struct Owner {
    uid: u32,
    gid: u32,
}

pub fn main() -> Result<()> {
    match service_command(std::env::args_os().skip(1))? {
        ServiceCommand::Run => run_service(),
        ServiceCommand::Install => install_service(),
        ServiceCommand::Uninstall => uninstall_service(),
    }
}

fn service_command(args: impl IntoIterator<Item = OsString>) -> Result<ServiceCommand> {
    let mut args = args.into_iter();
    let command = match args.next().as_deref() {
        None => ServiceCommand::Run,
        Some(value) if value == OsStr::new("install") => ServiceCommand::Install,
        Some(value) if value == OsStr::new("uninstall") => ServiceCommand::Uninstall,
        Some(value) => bail!("unknown helper command: {}", value.to_string_lossy()),
    };
    if args.next().is_some() {
        bail!("helper accepts at most one command");
    }
    Ok(command)
}

pub(super) fn core_owner() -> Result<(u32, u32), Error> {
    let owner = owner_from_env().map_err(Error::other)?;
    Ok((owner.uid, owner.gid))
}

pub(super) fn ensure_owner_socket(address: &str) -> Result<(), Error> {
    let owner = owner_from_env().map_err(Error::other)?;
    let metadata = fs::symlink_metadata(address)?;
    if !metadata.file_type().is_socket() || metadata.uid() != owner.uid {
        return Err(Error::other(
            "Core address is not a socket owned by the Helper owner",
        ));
    }
    Ok(())
}

fn owner_from_env() -> Result<Owner> {
    Ok(Owner {
        uid: read_id_env(OWNER_UID_ENV)?,
        gid: read_id_env(OWNER_GID_ENV)?,
    })
}

fn read_id_env(name: &str) -> Result<u32> {
    let value = std::env::var(name).with_context(|| format!("{name} is not set"))?;
    parse_owner_id(&value).with_context(|| format!("{name} is not a usable ID"))
}

/// Root owns the Core already; an owner of 0 would mean the service is running
/// for nobody and would hand the Core the credentials it is trying to avoid.
fn parse_owner_id(value: &str) -> Result<u32> {
    let id: u32 = value.trim().parse().context("expected an unsigned ID")?;
    if id == 0 {
        bail!("expected a non-root ID");
    }
    Ok(id)
}

/// pkexec and sudo both name the user who asked for the elevation; without one
/// there is nobody to grant the socket to, so installation has no owner.
fn invoking_owner() -> Result<Owner> {
    let uid = ["PKEXEC_UID", "SUDO_UID"]
        .into_iter()
        .find_map(|name| std::env::var(name).ok())
        .context("neither PKEXEC_UID nor SUDO_UID is set; run the installer through pkexec")?;
    let uid = parse_owner_id(&uid).context("the invoking user ID is not usable")?;
    let gid = parse_owner_id(&invoking_gid(uid)?).context("the invoking group is not usable")?;
    Ok(Owner { uid, gid })
}

fn invoking_gid(uid: u32) -> Result<String> {
    let output = Command::new("id")
        .args(["-g", &uid.to_string()])
        .output()
        .context("query the invoking user")?;
    if !output.status.success() {
        bail!("id -g {uid} failed with {}", output.status);
    }
    let value = String::from_utf8(output.stdout)
        .context("id returned invalid UTF-8")?
        .trim()
        .to_string();
    if value.is_empty() {
        bail!("id -g {uid} returned nothing");
    }
    Ok(value)
}

/// systemd splits `ExecStart=` on whitespace and expands `%` specifiers, so the
/// path travels double-quoted with its quotes, backslashes and `%` escaped.
fn quoted_unit_argument(path: &Path) -> String {
    let mut quoted = String::from("\"");
    for character in path.to_string_lossy().chars() {
        match character {
            '"' | '\\' => {
                quoted.push('\\');
                quoted.push(character);
            }
            '%' => quoted.push_str("%%"),
            _ => quoted.push(character),
        }
    }
    quoted.push('"');
    quoted
}

fn unit_contents(executable: &Path, owner: Owner) -> String {
    format!(
        "[Unit]\n\
         Description=FlClash Helper starts the FlClash Core with the privileges TUN mode needs.\n\
         After=network-online.target nftables.service iptables.service\n\
         StartLimitIntervalSec=60\n\
         StartLimitBurst=5\n\
         \n\
         [Service]\n\
         Type=simple\n\
         ExecStart={executable}\n\
         Group={gid}\n\
         Environment={OWNER_UID_ENV}={uid}\n\
         Environment={OWNER_GID_ENV}={gid}\n\
         RuntimeDirectory={RUNTIME_DIR_NAME}\n\
         RuntimeDirectoryMode=0755\n\
         Restart=on-failure\n\
         RestartSec=5\n\
         \n\
         [Install]\n\
         WantedBy=multi-user.target\n",
        executable = quoted_unit_argument(executable),
        uid = owner.uid,
        gid = owner.gid,
    )
}

/// The unit runs this binary as root at every boot, so one the invoking user
/// could overwrite would turn a single polkit approval into standing root.
fn ensure_root_owned(executable: &Path) -> Result<()> {
    let directory = executable
        .parent()
        .context("helper executable has no parent directory")?;
    for path in [executable, directory] {
        let metadata = fs::metadata(path).with_context(|| format!("inspect {}", path.display()))?;
        if metadata.uid() != 0 || metadata.mode() & 0o022 != 0 {
            bail!(
                "{} must be owned by root and not writable by group or others to run as a service; \
                 install the package instead of running an unpacked bundle",
                path.display()
            );
        }
    }
    Ok(())
}

fn installed_owner_uid(unit: &str) -> Option<u32> {
    let prefix = format!("Environment={OWNER_UID_ENV}=");
    unit.lines()
        .find_map(|line| line.strip_prefix(prefix.as_str()))
        .and_then(|value| value.trim().parse().ok())
}

fn ensure_unit_is_free_for(owner: Owner) -> Result<()> {
    let existing = match fs::read_to_string(UNIT_PATH) {
        Ok(contents) => contents,
        Err(error) if error.kind() == ErrorKind::NotFound => return Ok(()),
        Err(error) => return Err(error).with_context(|| format!("read {UNIT_PATH}")),
    };
    match installed_owner_uid(&existing) {
        Some(uid) if uid != owner.uid => bail!(
            "the Helper is already installed for UID {uid}; \
             run `FlClashHelperService uninstall` as that user first"
        ),
        _ => Ok(()),
    }
}

fn install_service() -> Result<()> {
    let executable = std::env::current_exe().context("resolve helper executable path")?;
    ensure_root_owned(&executable)?;
    let owner = invoking_owner()?;
    ensure_unit_is_free_for(owner)?;

    fs::write(UNIT_PATH, unit_contents(&executable, owner))
        .with_context(|| format!("write {UNIT_PATH}"))?;
    fs::set_permissions(UNIT_PATH, fs::Permissions::from_mode(0o644))
        .with_context(|| format!("secure {UNIT_PATH}"))?;

    run_systemctl(&["daemon-reload"])?;
    run_systemctl(&["enable", SERVICE_NAME])?;
    run_systemctl(&["restart", SERVICE_NAME])
}

fn uninstall_service() -> Result<()> {
    silence_systemctl(&["disable", "--now", SERVICE_NAME]);
    match fs::remove_file(UNIT_PATH) {
        Ok(()) => {}
        Err(error) if error.kind() == ErrorKind::NotFound => return Ok(()),
        Err(error) => return Err(error).with_context(|| format!("remove {UNIT_PATH}")),
    }
    run_systemctl(&["daemon-reload"])
}

/// A package removal runs this twice, so the second `disable` reporting a unit
/// that is already gone is expected rather than something to print.
fn silence_systemctl(arguments: &[&str]) {
    let _ = Command::new("systemctl")
        .args(arguments)
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status();
}

fn run_systemctl(arguments: &[&str]) -> Result<()> {
    let status = Command::new("systemctl")
        .args(arguments)
        .status()
        .with_context(|| format!("run systemctl {}", arguments.join(" ")))?;
    if !status.success() {
        bail!("systemctl {} failed with {status}", arguments.join(" "));
    }
    Ok(())
}

fn run_service() -> Result<()> {
    ensure_core_sha256_configured()?;
    let owner = owner_from_env()?;
    let runtime = Runtime::new().context("create helper runtime")?;
    runtime.block_on(async move {
        let mut terminate = signal(SignalKind::terminate()).context("listen for SIGTERM")?;
        let mut interrupt = signal(SignalKind::interrupt()).context("listen for SIGINT")?;
        let shutdown = async move {
            tokio::select! {
                _ = terminate.recv() => {}
                _ = interrupt.recv() => {}
            }
        };
        let incoming = AuthorizedIncoming::bind(owner)?;
        warp::serve(routes())
            .serve_incoming_with_graceful_shutdown(incoming, shutdown)
            .await;
        release_managed_core_on_shutdown();
        Ok(())
    })
}

/// Connections are filtered by peer credential rather than by the socket mode
/// alone: a supplementary group membership is enough to reach a `0660` socket,
/// and only the installing user may drive a Core that runs as root.
struct AuthorizedIncoming {
    listener: UnixListener,
    owner: Owner,
    retry: Option<Pin<Box<Sleep>>>,
}

impl AuthorizedIncoming {
    fn bind(owner: Owner) -> Result<Self> {
        if Path::new(SOCKET_PATH).exists() {
            fs::remove_file(SOCKET_PATH).with_context(|| format!("remove stale {SOCKET_PATH}"))?;
        }
        let listener =
            UnixListener::bind(SOCKET_PATH).with_context(|| format!("bind {SOCKET_PATH}"))?;
        fs::set_permissions(SOCKET_PATH, fs::Permissions::from_mode(SOCKET_MODE))
            .with_context(|| format!("secure {SOCKET_PATH}"))?;
        Ok(Self {
            listener,
            owner,
            retry: None,
        })
    }
}

fn is_authorized_peer(stream: &UnixStream, owner: Owner) -> bool {
    matches!(stream.peer_cred(), Ok(credentials) if credentials.uid() == owner.uid)
}

impl Stream for AuthorizedIncoming {
    type Item = Result<UnixStream, Error>;

    /// hyper ends the whole server on the first accept error it is handed, so
    /// resource exhaustion is logged and retried after a pause instead.
    fn poll_next(
        mut self: Pin<&mut Self>,
        context: &mut TaskContext<'_>,
    ) -> Poll<Option<Self::Item>> {
        loop {
            if let Some(retry) = self.retry.as_mut() {
                match retry.as_mut().poll(context) {
                    Poll::Ready(()) => self.retry = None,
                    Poll::Pending => return Poll::Pending,
                }
            }
            match self.listener.poll_accept(context) {
                Poll::Ready(Ok((stream, _))) => {
                    if is_authorized_peer(&stream, self.owner) {
                        return Poll::Ready(Some(Ok(stream)));
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

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn parses_service_commands() {
        assert_eq!(service_command([]).unwrap(), ServiceCommand::Run);
        assert_eq!(
            service_command([OsString::from("install")]).unwrap(),
            ServiceCommand::Install
        );
        assert_eq!(
            service_command([OsString::from("uninstall")]).unwrap(),
            ServiceCommand::Uninstall
        );
    }

    #[test]
    fn rejects_unknown_or_extra_service_commands() {
        assert!(service_command([OsString::from("unknown")]).is_err());
        assert!(service_command([OsString::from("install"), OsString::from("extra")]).is_err());
    }

    #[test]
    fn rejects_owner_ids_that_cannot_own_a_core() {
        assert_eq!(parse_owner_id(" 1000\n").unwrap(), 1000);
        assert!(parse_owner_id("0").is_err());
        assert!(parse_owner_id("-1").is_err());
        assert!(parse_owner_id("nobody").is_err());
    }

    #[test]
    fn unit_names_the_owner_and_the_helper_it_starts() {
        let unit = unit_contents(
            Path::new("/opt/FlClash/FlClashHelperService"),
            Owner {
                uid: 1000,
                gid: 1001,
            },
        );

        assert!(unit.contains("ExecStart=\"/opt/FlClash/FlClashHelperService\"\n"));
        assert!(unit.contains("Group=1001\n"));
        assert!(unit.contains("Environment=FLCLASH_HELPER_OWNER_UID=1000\n"));
        assert!(unit.contains("Environment=FLCLASH_HELPER_OWNER_GID=1001\n"));
        assert!(unit.contains("RuntimeDirectory=flclash\n"));
        assert!(unit.contains("Restart=on-failure\n"));
        assert!(unit.contains("StartLimitBurst=5\n"));
    }

    #[test]
    fn unit_argument_survives_whitespace_and_specifiers() {
        assert_eq!(
            quoted_unit_argument(Path::new("/home/u/My Apps/100%/a\"b\\c")),
            r#""/home/u/My Apps/100%%/a\"b\\c""#
        );
    }

    #[test]
    fn reads_the_owner_back_out_of_an_installed_unit() {
        let unit = unit_contents(
            Path::new("/opt/FlClash/FlClashHelperService"),
            Owner {
                uid: 1000,
                gid: 1001,
            },
        );

        assert_eq!(installed_owner_uid(&unit), Some(1000));
        assert_eq!(installed_owner_uid("[Unit]\n"), None);
    }
}
