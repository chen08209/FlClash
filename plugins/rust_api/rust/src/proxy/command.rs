use std::process::{Command, Stdio};

#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ProxyCommand {
    pub program: String,
    pub args: Vec<String>,
    pub optional: bool,
}

impl ProxyCommand {
    pub fn new<I, S>(program: &str, args: I) -> Self
    where
        I: IntoIterator<Item = S>,
        S: Into<String>,
    {
        Self {
            program: program.to_owned(),
            args: args.into_iter().map(Into::into).collect(),
            optional: false,
        }
    }
}

/// Runs `commands` in order until a required one fails. A list with nothing in
/// it configured nothing, so it fails too.
pub fn run_all(
    commands: impl IntoIterator<Item = ProxyCommand>,
    mut succeeds: impl FnMut(&ProxyCommand) -> bool,
) -> bool {
    let mut executed = false;
    for command in commands {
        executed = true;
        if !succeeds(&command) && !command.optional {
            return false;
        }
    }
    executed
}

pub fn spawn(command: &ProxyCommand) -> bool {
    Command::new(&command.program)
        .args(&command.args)
        .stdin(Stdio::null())
        .stdout(Stdio::null())
        .stderr(Stdio::null())
        .status()
        .is_ok_and(|status| status.success())
}

#[cfg(test)]
mod tests {
    use super::{run_all, ProxyCommand};

    #[test]
    fn treats_an_empty_command_set_as_failure() {
        assert!(!run_all([], |_| panic!("nothing to run")));
    }

    #[test]
    fn stops_after_the_first_failed_command() {
        let mut ran = Vec::new();
        let commands = [
            ProxyCommand::new("a", ["1"]),
            ProxyCommand::new("b", ["2"]),
            ProxyCommand::new("c", ["3"]),
        ];
        let result = run_all(commands, |command| {
            ran.push(command.program.clone());
            command.program != "b"
        });
        assert!(!result);
        assert_eq!(ran, ["a", "b"]);
    }

    #[test]
    fn carries_on_past_an_optional_command_that_fails() {
        let mut ran = Vec::new();
        let commands = [
            ProxyCommand {
                optional: true,
                ..ProxyCommand::new("a", ["1"])
            },
            ProxyCommand::new("b", ["2"]),
        ];
        let result = run_all(commands, |command| {
            ran.push(command.program.clone());
            command.program != "a"
        });
        assert!(result);
        assert_eq!(ran, ["a", "b"]);
    }

    #[test]
    fn a_program_that_cannot_launch_fails() {
        assert!(!super::spawn(&ProxyCommand::new(
            "/nonexistent/flclash-proxy-probe",
            [""; 0],
        )));
    }
}
