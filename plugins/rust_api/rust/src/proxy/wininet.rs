use std::net::Ipv6Addr;

use super::{PAC_PATH, PROXY_HOST};

/// WinINet rejects the whole list over one bare IPv6 literal or one entry
/// ending in `/`, so the system proxy is not set at all. Loopback needs no
/// entry: WinINet never proxies it.
pub fn bypass_list(bypass_domain: &[String]) -> String {
    let mut entries: Vec<String> = Vec::new();
    for domain in bypass_domain {
        let entry = domain.trim().trim_end_matches('/');
        if entry.is_empty() {
            continue;
        }
        let entry = if is_bare_ipv6(entry) {
            format!("[{entry}]")
        } else {
            entry.to_owned()
        };
        if !entries.contains(&entry) {
            entries.push(entry);
        }
    }
    entries.join(";")
}

fn is_bare_ipv6(entry: &str) -> bool {
    let address = entry.split_once('%').map_or(entry, |(address, _)| address);
    address.parse::<Ipv6Addr>().is_ok()
}

pub fn local_proxy_port(server: &str) -> Option<u16> {
    parse_port(server.strip_prefix(PROXY_HOST)?.strip_prefix(':')?)
}

pub fn local_pac_port(url: &str) -> Option<u16> {
    let rest = url
        .strip_prefix("http://")?
        .strip_prefix(PROXY_HOST)?
        .strip_prefix(':')?;
    let (port, path) = rest.split_at(rest.find('/')?);
    let path = path.split_once('?').map_or(path, |(path, _)| path);
    (path == PAC_PATH).then(|| parse_port(port)).flatten()
}

fn parse_port(digits: &str) -> Option<u16> {
    if digits.is_empty() || digits.len() > 5 || !digits.bytes().all(|b| b.is_ascii_digit()) {
        return None;
    }
    digits.parse::<u16>().ok().filter(|port| *port != 0)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn list(values: &[&str]) -> String {
        let values: Vec<String> = values.iter().map(|v| v.to_string()).collect();
        bypass_list(&values)
    }

    #[test]
    fn keeps_the_intranet_token_only_where_listed() {
        assert_eq!(
            list(&["localhost", "<local>", "127.*", "<local>"]),
            "localhost;<local>;127.*"
        );
        assert_eq!(list(&["localhost"]), "localhost");
    }

    #[test]
    fn brackets_bare_ipv6_literals_and_drops_blank_entries() {
        assert_eq!(
            list(&[" ::1 ", "fe80::1", "", "[fd00::1]", "*.lan", "fe80::1%eth0"]),
            "[::1];[fe80::1];[fd00::1];*.lan;[fe80::1%eth0]"
        );
    }

    #[test]
    fn drops_trailing_slashes_that_fail_the_whole_list() {
        assert_eq!(
            list(&["example.test/", "example.test", "nas//", "/"]),
            "example.test;nas"
        );
    }

    #[test]
    fn reads_only_the_proxy_servers_this_app_writes() {
        assert_eq!(local_proxy_port("127.0.0.1:7890"), Some(7890));
        assert_eq!(local_proxy_port("127.0.0.1:65535"), Some(65535));
        assert_eq!(local_proxy_port("127.0.0.1:0"), None);
        assert_eq!(local_proxy_port("127.0.0.1:65536"), None);
        assert_eq!(local_proxy_port("127.0.0.1:"), None);
        assert_eq!(local_proxy_port("127.0.0.1:+80"), None);
        assert_eq!(local_proxy_port("http=127.0.0.1:7890"), None);
        assert_eq!(local_proxy_port("10.0.0.1:7890"), None);
    }

    #[test]
    fn reads_only_the_pac_urls_this_app_serves() {
        assert_eq!(
            local_pac_port("http://127.0.0.1:51234/flclash.pac?v=3"),
            Some(51234)
        );
        assert_eq!(
            local_pac_port("http://127.0.0.1:51234/flclash.pac"),
            Some(51234)
        );
        assert_eq!(local_pac_port("http://127.0.0.1:51234/proxy.pac"), None);
        assert_eq!(local_pac_port("http://127.0.0.1:51234"), None);
        assert_eq!(local_pac_port("http://10.0.0.1:51234/flclash.pac"), None);
        assert_eq!(local_pac_port("https://127.0.0.1:51234/flclash.pac"), None);
    }
}
