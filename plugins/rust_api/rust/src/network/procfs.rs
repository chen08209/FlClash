/// The interface of the main table's preferred default route, IPv4 first, as
/// `/proc/net/route` and `/proc/net/ipv6_route` list them.
pub fn default_interface(route: &str, ipv6_route: &str) -> Option<String> {
    ipv4_default(route).or_else(|| ipv6_default(ipv6_route))
}

const RTF_UP: u32 = 0x1;
const RTF_REJECT: u32 = 0x200;

fn ipv4_default(table: &str) -> Option<String> {
    table
        .lines()
        .skip(1)
        .filter_map(|line| {
            let fields: Vec<&str> = line.split_whitespace().collect();
            let flags = u32::from_str_radix(fields.get(3)?, 16).ok()?;
            let metric: u32 = fields.get(6)?.parse().ok()?;
            let default = fields.get(1)? == &"00000000" && fields.get(7)? == &"00000000";
            (default && flags & RTF_UP != 0 && flags & RTF_REJECT == 0)
                .then(|| (metric, fields[0].to_owned()))
        })
        .min_by_key(|(metric, _)| *metric)
        .map(|(_, interface)| interface)
}

fn ipv6_default(table: &str) -> Option<String> {
    table
        .lines()
        .filter_map(|line| {
            let fields: Vec<&str> = line.split_whitespace().collect();
            if fields.len() < 10 {
                return None;
            }
            let default = fields[0].bytes().all(|byte| byte == b'0') && fields[1] == "00";
            let metric = u32::from_str_radix(fields[5], 16).ok()?;
            let flags = u32::from_str_radix(fields[8], 16).ok()?;
            let interface = fields[9];
            (default && flags & RTF_UP != 0 && flags & RTF_REJECT == 0 && interface != "lo")
                .then(|| (metric, interface.to_owned()))
        })
        .min_by_key(|(metric, _)| *metric)
        .map(|(_, interface)| interface)
}

#[cfg(test)]
mod tests {
    use super::*;

    const ROUTE: &str =
        "Iface\tDestination\tGateway \tFlags\tRefCnt\tUse\tMetric\tMask\t\tMTU\tWindow\tIRTT\n\
wlan0\t00000000\t0101A8C0\t0003\t0\t0\t600\t00000000\t0\t0\t0\n\
eth0\t00000000\t0100A8C0\t0003\t0\t0\t100\t00000000\t0\t0\t0\n\
eth0\t0000A8C0\t00000000\t0001\t0\t0\t100\t00FFFFFF\t0\t0\t0\n";

    const IPV6_ROUTE: &str = "\
00000000000000000000000000000000 00 00000000000000000000000000000000 00 fe800000000000000000000000000001 00000400 00000001 00000000 00000003 wlan0\n\
00000000000000000000000000000000 00 00000000000000000000000000000000 00 00000000000000000000000000000000 ffffffff 00000001 00000000 00200200 lo\n";

    #[test]
    fn picks_the_ipv4_default_with_the_lowest_metric() {
        assert_eq!(
            default_interface(ROUTE, IPV6_ROUTE).as_deref(),
            Some("eth0")
        );
    }

    #[test]
    fn falls_back_to_the_ipv6_default_and_skips_unreachable_ones() {
        let header_only = ROUTE.lines().next().unwrap();
        assert_eq!(
            default_interface(header_only, IPV6_ROUTE).as_deref(),
            Some("wlan0")
        );
        assert_eq!(default_interface(header_only, ""), None);
    }
}
