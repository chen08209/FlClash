use anyhow::{anyhow, bail, Result};
use std::ffi::{OsStr, OsString};
use std::net::SocketAddrV4;

const OWNER_SID_FLAG: &str = "--owner-sid";
const OWNER_PID_FLAG: &str = "--owner-pid";
const MAX_SID_SUBAUTHORITIES: usize = 15;

#[derive(Debug, PartialEq, Eq)]
pub enum ServiceCommand {
    Run { owner_sid: String },
    Install { owner_pid: u32 },
    Uninstall,
}

/// The service is registered with its owner on the command line, which is how a
/// start by the service manager learns whom to answer. Starting without one
/// fails rather than serve anybody.
pub fn service_command(args: impl IntoIterator<Item = OsString>) -> Result<ServiceCommand> {
    let args: Vec<OsString> = args.into_iter().collect();
    let args: Vec<&OsStr> = args.iter().map(OsString::as_os_str).collect();
    match args.as_slice() {
        [] => bail!("the helper service was registered without an owner; reinstall it"),
        [flag, sid] if *flag == OsStr::new(OWNER_SID_FLAG) => {
            let sid = sid
                .to_str()
                .filter(|sid| is_sid_string(sid))
                .ok_or_else(|| anyhow!("{OWNER_SID_FLAG} is not a SID"))?;
            Ok(ServiceCommand::Run {
                owner_sid: sid.to_string(),
            })
        }
        [command] if *command == OsStr::new("uninstall") => Ok(ServiceCommand::Uninstall),
        [command, flag, pid]
            if *command == OsStr::new("install") && *flag == OsStr::new(OWNER_PID_FLAG) =>
        {
            let owner_pid = pid
                .to_str()
                .and_then(|pid| pid.parse::<u32>().ok())
                .filter(|pid| *pid != 0)
                .ok_or_else(|| anyhow!("{OWNER_PID_FLAG} is not a process ID"))?;
            Ok(ServiceCommand::Install { owner_pid })
        }
        [command, ..] if *command == OsStr::new("install") => {
            bail!("install takes exactly {OWNER_PID_FLAG} <pid>")
        }
        [value, ..] => bail!("unknown helper command: {}", value.to_string_lossy()),
    }
}

pub fn owner_sid_arguments(owner_sid: &str) -> Vec<OsString> {
    vec![OsString::from(OWNER_SID_FLAG), OsString::from(owner_sid)]
}

fn is_sid_string(value: &str) -> bool {
    let Some(rest) = value.strip_prefix("S-1-") else {
        return false;
    };
    let parts: Vec<&str> = rest.split('-').collect();
    parts.len() <= MAX_SID_SUBAUTHORITIES + 1
        && parts
            .iter()
            .all(|part| !part.is_empty() && part.bytes().all(|byte| byte.is_ascii_digit()))
}

pub fn same_sid(left: &str, right: &str) -> bool {
    left.eq_ignore_ascii_case(right)
}

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub struct TcpConnection {
    pub local: SocketAddrV4,
    pub remote: SocketAddrV4,
    pub pid: u32,
}

/// Both ends of a loopback connection are in the table, each owned by its own
/// process; the client's end is the one whose local address is the peer address
/// the Helper accepted.
pub fn client_pid(
    connections: &[TcpConnection],
    client: SocketAddrV4,
    server: SocketAddrV4,
) -> Option<u32> {
    connections
        .iter()
        .find(|connection| connection.local == client && connection.remote == server)
        .map(|connection| connection.pid)
        .filter(|pid| *pid != 0)
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::net::Ipv4Addr;

    const SID: &str = "S-1-5-21-1004336348-1177238915-682003330-1001";

    fn os(values: &[&str]) -> Vec<OsString> {
        values.iter().map(OsString::from).collect()
    }

    fn address(port: u16) -> SocketAddrV4 {
        SocketAddrV4::new(Ipv4Addr::LOCALHOST, port)
    }

    #[test]
    fn parses_the_service_commands() {
        assert_eq!(
            service_command(os(&["--owner-sid", SID])).unwrap(),
            ServiceCommand::Run {
                owner_sid: SID.to_string()
            }
        );
        assert_eq!(
            service_command(os(&["install", "--owner-pid", "4242"])).unwrap(),
            ServiceCommand::Install { owner_pid: 4242 }
        );
        assert_eq!(
            service_command(os(&["uninstall"])).unwrap(),
            ServiceCommand::Uninstall
        );
    }

    #[test]
    fn refuses_to_run_without_an_owner() {
        assert!(service_command(os(&[])).is_err());
        assert!(service_command(os(&["--owner-sid"])).is_err());
        assert!(service_command(os(&["--owner-sid", "S-1-5-18", "extra"])).is_err());
    }

    #[test]
    fn rejects_an_owner_that_is_not_a_sid() {
        for value in [
            "",
            "alice",
            "S-1-",
            "S-1-5-",
            "S-1-5-x",
            "S-2-5-18",
            "S-1-5-18 ",
        ] {
            assert!(
                service_command(os(&["--owner-sid", value])).is_err(),
                "{value:?}"
            );
        }
        let long = format!("S-1-{}", vec!["5"; 17].join("-"));
        assert!(service_command(os(&["--owner-sid", &long])).is_err());
    }

    #[test]
    fn install_needs_a_real_owner_process() {
        assert!(service_command(os(&["install"])).is_err());
        assert!(service_command(os(&["install", "--owner-pid"])).is_err());
        assert!(service_command(os(&["install", "--owner-pid", "0"])).is_err());
        assert!(service_command(os(&["install", "--owner-pid", "-1"])).is_err());
        assert!(service_command(os(&["install", "--owner-pid", "abc"])).is_err());
        assert!(service_command(os(&["install", "--owner-pid", "7", "extra"])).is_err());
        assert!(service_command(os(&["install", "7"])).is_err());
    }

    #[test]
    fn rejects_unknown_or_extra_commands() {
        assert!(service_command(os(&["unknown"])).is_err());
        assert!(service_command(os(&["uninstall", "extra"])).is_err());
    }

    #[test]
    fn registration_arguments_read_back_as_the_same_owner() {
        let arguments = owner_sid_arguments(SID);

        assert_eq!(
            service_command(arguments).unwrap(),
            ServiceCommand::Run {
                owner_sid: SID.to_string()
            }
        );
    }

    #[test]
    fn compares_sids_regardless_of_case() {
        assert!(same_sid("S-1-5-21-1-2-3-1001", "s-1-5-21-1-2-3-1001"));
        assert!(!same_sid("S-1-5-21-1-2-3-1001", "S-1-5-21-1-2-3-1002"));
    }

    #[test]
    fn finds_the_process_on_the_client_end_of_the_connection() {
        let server = address(47890);
        let client = address(50123);
        let connections = [
            TcpConnection {
                local: server,
                remote: client,
                pid: 700,
            },
            TcpConnection {
                local: client,
                remote: server,
                pid: 4242,
            },
            TcpConnection {
                local: address(50124),
                remote: server,
                pid: 9999,
            },
        ];

        assert_eq!(client_pid(&connections, client, server), Some(4242));
    }

    #[test]
    fn finds_nobody_when_the_connection_is_gone_or_unowned() {
        let server = address(47890);
        let client = address(50123);
        let helper_end_only = [TcpConnection {
            local: server,
            remote: client,
            pid: 700,
        }];
        let unowned = [TcpConnection {
            local: client,
            remote: server,
            pid: 0,
        }];

        assert_eq!(client_pid(&helper_end_only, client, server), None);
        assert_eq!(client_pid(&unowned, client, server), None);
        assert_eq!(client_pid(&[], client, server), None);
    }
}
