pub const RUN_KEY: &str = r"Software\Microsoft\Windows\CurrentVersion\Run";
pub const STARTUP_APPROVED_KEY: &str =
    r"Software\Microsoft\Windows\CurrentVersion\Explorer\StartupApproved\Run";

pub const STARTUP_APPROVED_ENABLED: [u8; 12] = [2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

pub fn run_value(executable: &str) -> &str {
    executable
}

/// Task Manager disables a Run entry with an odd first byte.
pub fn startup_approved(value: Option<&[u8]>) -> bool {
    value
        .and_then(|bytes| bytes.first())
        .is_none_or(|first| first % 2 == 0)
}

pub fn url_protocol_key(scheme: &str) -> String {
    format!(r"Software\Classes\{scheme}")
}

pub const URL_COMMAND_KEY: &str = r"shell\open\command";
pub const URL_PROTOCOL_VALUE: &str = "URL Protocol";

pub fn url_command(executable: &str) -> String {
    format!(r#""{executable}" "%1""#)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn an_untouched_or_even_entry_is_approved() {
        assert!(startup_approved(None));
        assert!(startup_approved(Some(&[])));
        assert!(startup_approved(Some(&STARTUP_APPROVED_ENABLED)));
        assert!(startup_approved(Some(&[6, 1])));
    }

    #[test]
    fn an_odd_first_byte_is_disabled_in_task_manager() {
        assert!(!startup_approved(Some(&[3, 0, 0, 0])));
    }

    #[test]
    fn writes_the_url_protocol_keys_the_older_builds_wrote() {
        assert_eq!(url_protocol_key("flclash"), r"Software\Classes\flclash");
        assert_eq!(
            url_command(r"C:\Program Files\FlClash\FlClash.exe"),
            r#""C:\Program Files\FlClash\FlClash.exe" "%1""#,
        );
    }

    #[test]
    fn the_run_value_is_the_unquoted_path() {
        assert_eq!(
            run_value(r"C:\Program Files\FlClash\FlClash.exe"),
            r"C:\Program Files\FlClash\FlClash.exe",
        );
    }
}
