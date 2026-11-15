use std::process::{Command, Stdio};

use super::command::{self, ProxyCommand};
use super::{without_wininet_local, Target, PROXY_HOST};

const NETWORKSETUP: &str = "/usr/sbin/networksetup";

pub fn start(target: &Target) -> bool {
    let commands: Vec<_> = network_services()
        .iter()
        .flat_map(|service| start_commands(service, target))
        .collect();
    command::run_all(commands, command::spawn)
}

pub fn stop() -> bool {
    let commands: Vec<_> = network_services()
        .iter()
        .flat_map(|service| stop_commands(service))
        .collect();
    command::run_all(commands, command::spawn)
}

fn network_services() -> Vec<String> {
    let Ok(output) = Command::new(NETWORKSETUP)
        .arg("-listallnetworkservices")
        .stdin(Stdio::null())
        .stderr(Stdio::null())
        .output()
    else {
        return Vec::new();
    };
    if !output.status.success() {
        return Vec::new();
    }
    parse_network_services(&String::from_utf8_lossy(&output.stdout))
}

fn parse_network_services(stdout: &str) -> Vec<String> {
    stdout
        .lines()
        .map(str::trim)
        .filter(|line| !line.is_empty())
        .filter(|line| !line.starts_with('*'))
        .filter(|line| !line.starts_with("An asterisk "))
        .map(str::to_owned)
        .collect()
}

fn networksetup(args: &[&str]) -> ProxyCommand {
    ProxyCommand::new(NETWORKSETUP, args.iter().copied())
}

fn start_commands(service: &str, target: &Target) -> Vec<ProxyCommand> {
    match target {
        Target::Manual {
            port,
            bypass_domain,
        } => manual_commands(service, *port, bypass_domain),
        Target::Pac { url } => vec![
            networksetup(&["-setwebproxystate", service, "off"]),
            networksetup(&["-setsecurewebproxystate", service, "off"]),
            networksetup(&["-setsocksfirewallproxystate", service, "off"]),
            networksetup(&["-setautoproxyurl", service, url]),
            networksetup(&["-setautoproxystate", service, "on"]),
        ],
    }
}

fn manual_commands(service: &str, port: u16, bypass_domain: &[String]) -> Vec<ProxyCommand> {
    let port = port.to_string();
    vec![
        networksetup(&["-setautoproxystate", service, "off"]),
        networksetup(&["-setwebproxy", service, PROXY_HOST, &port]),
        networksetup(&["-setsecurewebproxy", service, PROXY_HOST, &port]),
        networksetup(&["-setsocksfirewallproxy", service, PROXY_HOST, &port]),
        bypass_command(service, bypass_domain),
        networksetup(&["-setwebproxystate", service, "on"]),
        networksetup(&["-setsecurewebproxystate", service, "on"]),
        networksetup(&["-setsocksfirewallproxystate", service, "on"]),
    ]
}

fn stop_commands(service: &str) -> Vec<ProxyCommand> {
    vec![
        networksetup(&["-setautoproxystate", service, "off"]),
        networksetup(&["-setwebproxystate", service, "off"]),
        networksetup(&["-setsecurewebproxystate", service, "off"]),
        networksetup(&["-setsocksfirewallproxystate", service, "off"]),
        bypass_command(service, &[]),
    ]
}

fn bypass_command(service: &str, bypass_domain: &[String]) -> ProxyCommand {
    let mut args = vec!["-setproxybypassdomains", service];
    let domains = without_wininet_local(bypass_domain);
    if domains.is_empty() {
        args.push("Empty");
    } else {
        args.extend(domains);
    }
    networksetup(&args)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn filters_the_service_list_header_disabled_services_and_blanks() {
        let services = parse_network_services(
            "An asterisk (*) denotes that a network service is disabled.\n\
             Wi-Fi\n\
             *Thunderbolt Bridge\n\
             USB 10/100/1000 LAN\n\n",
        );
        assert_eq!(services, ["Wi-Fi", "USB 10/100/1000 LAN"]);
    }

    #[test]
    fn passes_bypass_domains_as_separate_arguments() {
        let command = bypass_command("Wi-Fi", &["localhost".into(), "*.lan".into()]);
        assert_eq!(
            command.args,
            ["-setproxybypassdomains", "Wi-Fi", "localhost", "*.lan"]
        );
    }

    #[test]
    fn leaves_out_the_wininet_local_entry() {
        let command = bypass_command("Wi-Fi", &["<local>".into(), "*.lan".into()]);
        assert_eq!(command.args, ["-setproxybypassdomains", "Wi-Fi", "*.lan"]);
        assert_eq!(
            bypass_command("Wi-Fi", &["<local>".into()]).args,
            ["-setproxybypassdomains", "Wi-Fi", "Empty"]
        );
    }

    #[test]
    fn uses_empty_when_clearing_bypass_domains() {
        assert_eq!(
            bypass_command("Wi-Fi", &[]).args,
            ["-setproxybypassdomains", "Wi-Fi", "Empty"]
        );
    }

    #[test]
    fn configures_values_before_enabling_proxy_states() {
        let flags: Vec<_> = manual_commands("Wi-Fi", 7890, &[])
            .into_iter()
            .map(|command| command.args[0].clone())
            .collect();
        assert_eq!(
            flags,
            [
                "-setautoproxystate",
                "-setwebproxy",
                "-setsecurewebproxy",
                "-setsocksfirewallproxy",
                "-setproxybypassdomains",
                "-setwebproxystate",
                "-setsecurewebproxystate",
                "-setsocksfirewallproxystate",
            ]
        );
    }

    #[test]
    fn turns_the_manual_proxies_off_before_pointing_at_the_pac_url() {
        let target = Target::Pac {
            url: "http://127.0.0.1:5/flclash.pac?v=0".into(),
        };
        let args: Vec<Vec<String>> = start_commands("Wi-Fi", &target)
            .into_iter()
            .map(|command| command.args)
            .collect();
        assert_eq!(
            args,
            [
                vec!["-setwebproxystate", "Wi-Fi", "off"],
                vec!["-setsecurewebproxystate", "Wi-Fi", "off"],
                vec!["-setsocksfirewallproxystate", "Wi-Fi", "off"],
                vec![
                    "-setautoproxyurl",
                    "Wi-Fi",
                    "http://127.0.0.1:5/flclash.pac?v=0"
                ],
                vec!["-setautoproxystate", "Wi-Fi", "on"],
            ]
        );
    }
}
