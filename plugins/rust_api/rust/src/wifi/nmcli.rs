pub fn active_ssid(output: &str) -> Option<String> {
    output
        .lines()
        .find_map(|line| line.strip_prefix("yes:"))
        .map(unescape)
}

fn unescape(value: &str) -> String {
    let mut output = String::with_capacity(value.len());
    let mut chars = value.chars();
    while let Some(c) = chars.next() {
        if c == '\\' {
            if let Some(escaped) = chars.next() {
                output.push(escaped);
                continue;
            }
        }
        output.push(c);
    }
    output
}

#[cfg(test)]
mod tests {
    use super::active_ssid;

    #[test]
    fn reads_the_active_line() {
        let output = "no:Neighbour\nyes:Office\nno:Cafe\n";
        assert_eq!(active_ssid(output).as_deref(), Some("Office"));
    }

    #[test]
    fn unescapes_colons_and_backslashes() {
        assert_eq!(
            active_ssid("yes:Home\\:5G\\\\x\n").as_deref(),
            Some("Home:5G\\x")
        );
    }

    #[test]
    fn keeps_a_trailing_backslash() {
        assert_eq!(active_ssid("yes:odd\\").as_deref(), Some("odd\\"));
    }

    #[test]
    fn no_active_network_reads_none() {
        assert_eq!(active_ssid("no:Neighbour\n"), None);
        assert_eq!(active_ssid(""), None);
    }
}
