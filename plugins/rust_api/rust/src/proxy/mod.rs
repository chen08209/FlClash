#[cfg(any(target_os = "linux", target_os = "macos", test))]
mod command;
#[cfg(any(target_os = "linux", all(test, unix)))]
#[cfg_attr(not(target_os = "linux"), allow(dead_code))]
mod linux;
#[cfg(any(target_os = "macos", test))]
#[cfg_attr(not(target_os = "macos"), allow(dead_code))]
mod macos;
#[cfg(any(target_os = "linux", target_os = "macos", windows))]
mod pac;
#[cfg(windows)]
mod windows;
#[cfg(any(windows, test))]
mod wininet;

const PROXY_HOST: &str = "127.0.0.1";

/// WinINet's entry for hosts without a dot, kept in a list that may come from
/// Windows; networksetup and the Linux settings would take it for a host.
#[cfg(any(target_os = "linux", target_os = "macos", test))]
fn without_wininet_local(bypass_domain: &[String]) -> Vec<&str> {
    bypass_domain
        .iter()
        .map(String::as_str)
        .filter(|domain| domain.trim() != "<local>")
        .collect()
}
const PAC_PATH: &str = "/flclash.pac";
const PAC_PORT_PLACEHOLDER: &str = "%mixed-port%";

/// What the system proxy points at: the mixed port itself, or a PAC script
/// served from this process.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum Target<'a> {
    Manual {
        port: u16,
        bypass_domain: &'a [String],
    },
    Pac {
        url: String,
    },
}

pub fn start(port: u32, bypass_domain: &[String], pac_script: Option<&str>) -> bool {
    let port = match u16::try_from(port) {
        Ok(port) if port != 0 => port,
        _ => return false,
    };
    let target = match pac_script {
        None => Target::Manual {
            port,
            bypass_domain,
        },
        Some(script) => {
            let script = script.replace(PAC_PORT_PLACEHOLDER, &port.to_string());
            match platform::serve_pac(script) {
                Some(url) => Target::Pac { url },
                None => return false,
            }
        }
    };
    platform::start(&target)
}

pub fn stop() -> bool {
    platform::stop()
}

#[cfg(any(target_os = "linux", target_os = "macos", windows))]
mod platform {
    #[cfg(target_os = "linux")]
    pub use super::linux::{start, stop};
    #[cfg(target_os = "macos")]
    pub use super::macos::{start, stop};
    pub use super::pac::serve as serve_pac;
    #[cfg(windows)]
    pub use super::windows::{start, stop};
}

#[cfg(not(any(target_os = "linux", target_os = "macos", windows)))]
mod platform {
    pub fn serve_pac(_script: String) -> Option<String> {
        None
    }

    pub fn start(_target: &super::Target) -> bool {
        false
    }

    pub fn stop() -> bool {
        false
    }
}

#[cfg(test)]
mod tests {
    #[test]
    fn rejects_ports_outside_the_tcp_port_range() {
        assert!(!super::start(0, &[], None));
        assert!(!super::start(65536, &[], None));
        assert!(!super::start(0, &[], Some("")));
    }
}
