use std::os::unix::fs::PermissionsExt;
use std::path::Path;

use super::command::{self, ProxyCommand};
use super::{without_wininet_local, Target, PROXY_HOST};

#[derive(Debug, Clone, Copy, PartialEq, Eq)]
enum Backend {
    Gnome,
    Mate,
    Kde,
}

const FALLBACK_BACKENDS: [Backend; 2] = [Backend::Gnome, Backend::Kde];
const KDE_CONFIG_WRITERS: [&str; 2] = ["kwriteconfig6", "kwriteconfig5"];
const PROXY_TYPES: [&str; 3] = ["http", "https", "socks"];

pub fn start(target: &Target) -> bool {
    let Some((home, backend, tool)) = environment() else {
        return false;
    };
    command::run_all(start_commands(target, &home, backend, tool), command::spawn)
}

pub fn stop() -> bool {
    let Some((home, backend, tool)) = environment() else {
        return false;
    };
    command::run_all(stop_commands(&home, backend, tool), command::spawn)
}

fn environment() -> Option<(String, Backend, &'static str)> {
    let home = std::env::var("HOME").ok().filter(|home| !home.is_empty())?;
    let desktop = std::env::var("XDG_CURRENT_DESKTOP").ok();
    let (backend, tool) = resolve(desktop.as_deref(), executable_on_path)?;
    Some((home, backend, tool))
}

fn preferred_backend(desktop: Option<&str>) -> Option<Backend> {
    let desktops: Vec<String> = desktop
        .unwrap_or_default()
        .split(':')
        .map(|value| value.trim().to_uppercase())
        .filter(|value| !value.is_empty())
        .collect();
    let has = |name: &str| desktops.iter().any(|desktop| desktop == name);
    if has("KDE") {
        Some(Backend::Kde)
    } else if has("MATE") {
        Some(Backend::Mate)
    } else if ["GNOME", "CINNAMON", "BUDGIE", "UNITY"]
        .into_iter()
        .any(has)
    {
        Some(Backend::Gnome)
    } else {
        None
    }
}

/// A known desktop only uses its own backend; an unknown one takes the first
/// backend whose tool is installed.
fn resolve(
    desktop: Option<&str>,
    mut available: impl FnMut(&str) -> bool,
) -> Option<(Backend, &'static str)> {
    let mut tool_for = |backend| match backend {
        Backend::Gnome | Backend::Mate => available("gsettings").then_some("gsettings"),
        Backend::Kde => KDE_CONFIG_WRITERS.into_iter().find(|tool| available(tool)),
    };
    match preferred_backend(desktop) {
        Some(backend) => tool_for(backend).map(|tool| (backend, tool)),
        None => FALLBACK_BACKENDS
            .into_iter()
            .find_map(|backend| tool_for(backend).map(|tool| (backend, tool))),
    }
}

fn executable_on_path(name: &str) -> bool {
    let Some(paths) = std::env::var_os("PATH") else {
        return false;
    };
    std::env::split_paths(&paths).any(|dir| {
        std::fs::metadata(dir.join(name))
            .is_ok_and(|meta| meta.is_file() && meta.permissions().mode() & 0o111 != 0)
    })
}

fn gsettings_schema(backend: Backend) -> &'static str {
    match backend {
        Backend::Mate => "org.mate.system.proxy",
        _ => "org.gnome.system.proxy",
    }
}

fn start_commands(target: &Target, home: &str, backend: Backend, tool: &str) -> Vec<ProxyCommand> {
    let gsettings = |schema| match target {
        Target::Pac { url } => gsettings_pac(url, schema),
        Target::Manual {
            port,
            bypass_domain,
        } => gsettings_start(*port, bypass_domain, schema),
    };
    if backend != Backend::Kde {
        return gsettings(gsettings_schema(backend));
    }
    let kde = match target {
        Target::Pac { url } => vec![
            kde_write(tool, home, "Proxy Config Script", url),
            kde_write(tool, home, "ProxyType", "2"),
            kde_reparse(),
        ],
        Target::Manual {
            port,
            bypass_domain,
        } => kde_start(*port, bypass_domain, home, tool),
    };
    with_gtk_settings(kde, gsettings(gsettings_schema(Backend::Gnome)))
}

/// GTK programs on Plasma, Firefox among them, read the GNOME proxy settings
/// rather than kioslaverc. A Plasma without gsettings or the GNOME schema has
/// no such program to reach, so these never fail the KDE setup.
fn with_gtk_settings(
    mut commands: Vec<ProxyCommand>,
    gsettings: Vec<ProxyCommand>,
) -> Vec<ProxyCommand> {
    commands.extend(gsettings.into_iter().map(|command| ProxyCommand {
        optional: true,
        ..command
    }));
    commands
}

fn gsettings_pac(url: &str, schema: &str) -> Vec<ProxyCommand> {
    vec![
        ProxyCommand::new("gsettings", ["set", schema, "autoconfig-url", url]),
        ProxyCommand::new("gsettings", ["set", schema, "mode", "auto"]),
    ]
}

fn gsettings_start(port: u16, bypass_domain: &[String], schema: &str) -> Vec<ProxyCommand> {
    let port = port.to_string();
    let mut commands = vec![ProxyCommand::new(
        "gsettings",
        [
            "set",
            schema,
            "ignore-hosts",
            &gsettings_string_list(&without_wininet_local(bypass_domain)),
        ],
    )];
    for proxy_type in PROXY_TYPES {
        let section = format!("{schema}.{proxy_type}");
        commands.push(ProxyCommand::new(
            "gsettings",
            ["set", &section, "host", PROXY_HOST],
        ));
        commands.push(ProxyCommand::new(
            "gsettings",
            ["set", &section, "port", &port],
        ));
    }
    commands.push(ProxyCommand::new(
        "gsettings",
        ["set", schema, "mode", "manual"],
    ));
    commands
}

fn stop_commands(home: &str, backend: Backend, tool: &str) -> Vec<ProxyCommand> {
    let gsettings = |schema| {
        vec![ProxyCommand::new(
            "gsettings",
            ["set", schema, "mode", "none"],
        )]
    };
    if backend != Backend::Kde {
        return gsettings(gsettings_schema(backend));
    }
    with_gtk_settings(
        vec![kde_write(tool, home, "ProxyType", "0"), kde_reparse()],
        gsettings(gsettings_schema(Backend::Gnome)),
    )
}

fn kde_start(port: u16, bypass_domain: &[String], home: &str, tool: &str) -> Vec<ProxyCommand> {
    let mut commands = vec![kde_write(
        tool,
        home,
        "NoProxyFor",
        &without_wininet_local(bypass_domain).join(","),
    )];
    for proxy_type in PROXY_TYPES {
        let scheme = if proxy_type == "socks" {
            "socks"
        } else {
            "http"
        };
        commands.push(kde_write(
            tool,
            home,
            &format!("{proxy_type}Proxy"),
            &format!("{scheme}://{PROXY_HOST}:{port}"),
        ));
    }
    commands.push(kde_write(tool, home, "ProxyType", "1"));
    commands.push(kde_reparse());
    commands
}

fn kde_write(tool: &str, home: &str, key: &str, value: &str) -> ProxyCommand {
    let file = Path::new(home).join(".config").join("kioslaverc");
    ProxyCommand::new(
        tool,
        [
            "--file",
            &file.to_string_lossy(),
            "--group",
            "Proxy Settings",
            "--key",
            key,
            value,
        ],
    )
}

/// Running KIO programs keep the settings they read at startup until this
/// signal, which is what the KDE proxy settings page sends after saving.
fn kde_reparse() -> ProxyCommand {
    ProxyCommand {
        optional: true,
        ..ProxyCommand::new(
            "dbus-send",
            [
                "--session",
                "--type=signal",
                "/KIO/Scheduler",
                "org.kde.KIO.Scheduler.reparseSlaveConfiguration",
                "string:",
            ],
        )
    }
}

fn gsettings_string_list(values: &[&str]) -> String {
    let items: Vec<String> = values
        .iter()
        .map(|value| format!("'{}'", value.replace('\\', "\\\\").replace('\'', "\\'")))
        .collect();
    format!("[{}]", items.join(", "))
}

#[cfg(test)]
mod tests {
    use super::*;

    fn manual(bypass_domain: &[String]) -> Target<'_> {
        Target::Manual {
            port: 7890,
            bypass_domain,
        }
    }

    fn pac() -> Target<'static> {
        Target::Pac {
            url: "http://127.0.0.1:5/flclash.pac?v=0".into(),
        }
    }

    fn programs(commands: &[ProxyCommand]) -> Vec<&str> {
        let mut programs: Vec<&str> = commands.iter().map(|c| c.program.as_str()).collect();
        programs.dedup();
        programs
    }

    #[test]
    fn checks_each_fallback_tool_once_for_unknown_desktops() {
        let mut checked = Vec::new();
        let resolved = resolve(Some("UNKNOWN"), |tool| {
            checked.push(tool.to_owned());
            tool == "kwriteconfig5"
        });
        assert_eq!(resolved, Some((Backend::Kde, "kwriteconfig5")));
        assert_eq!(checked, ["gsettings", "kwriteconfig6", "kwriteconfig5"]);
    }

    #[test]
    fn prefers_kwriteconfig6_for_kde() {
        let resolved = resolve(Some("KDE"), |_| true);
        assert_eq!(resolved, Some((Backend::Kde, "kwriteconfig6")));
    }

    #[test]
    fn falls_back_to_gsettings_for_xfce_when_available() {
        let resolved = resolve(Some("XFCE"), |tool| tool == "gsettings");
        assert_eq!(resolved, Some((Backend::Gnome, "gsettings")));
    }

    #[test]
    fn does_not_use_an_unrelated_backend_for_a_known_desktop() {
        assert_eq!(resolve(Some("KDE"), |tool| tool == "gsettings"), None);
    }

    #[test]
    fn reads_colon_separated_desktops_case_insensitively() {
        assert_eq!(
            preferred_backend(Some("ubuntu:gnome")),
            Some(Backend::Gnome)
        );
        assert_eq!(
            preferred_backend(Some("X-Cinnamon:MATE")),
            Some(Backend::Mate)
        );
        assert_eq!(preferred_backend(Some("")), None);
    }

    #[test]
    fn builds_gnome_commands_without_duplicate_port_writes() {
        let commands = start_commands(
            &manual(&["localhost".into()]),
            "/home/user",
            Backend::Gnome,
            "gsettings",
        );
        let args: Vec<Vec<&str>> = commands
            .iter()
            .map(|c| c.args.iter().map(String::as_str).collect())
            .collect();
        assert_eq!(
            args,
            [
                vec![
                    "set",
                    "org.gnome.system.proxy",
                    "ignore-hosts",
                    "['localhost']"
                ],
                vec!["set", "org.gnome.system.proxy.http", "host", "127.0.0.1"],
                vec!["set", "org.gnome.system.proxy.http", "port", "7890"],
                vec!["set", "org.gnome.system.proxy.https", "host", "127.0.0.1"],
                vec!["set", "org.gnome.system.proxy.https", "port", "7890"],
                vec!["set", "org.gnome.system.proxy.socks", "host", "127.0.0.1"],
                vec!["set", "org.gnome.system.proxy.socks", "port", "7890"],
                vec!["set", "org.gnome.system.proxy", "mode", "manual"],
            ]
        );
    }

    #[test]
    fn leaves_out_the_wininet_local_entry() {
        let bypass = ["<local>".to_owned(), "*.lan".to_owned()];
        let gnome = start_commands(&manual(&bypass), "/home/user", Backend::Gnome, "gsettings");
        assert_eq!(gnome[0].args[3], "['*.lan']");
        let kde = start_commands(
            &manual(&bypass),
            "/home/user",
            Backend::Kde,
            "kwriteconfig6",
        );
        assert_eq!(kde[0].args[5..], ["NoProxyFor", "*.lan"]);
    }

    #[test]
    fn builds_mate_commands_with_the_mate_schema() {
        let start = start_commands(&manual(&[]), "/home/user", Backend::Mate, "gsettings");
        assert!(start
            .iter()
            .all(|c| c.args[1].starts_with("org.mate.system.proxy")));
        let stop = stop_commands("/home/user", Backend::Mate, "gsettings");
        assert_eq!(
            stop[0].args,
            ["set", "org.mate.system.proxy", "mode", "none"]
        );
    }

    #[test]
    fn formats_gsettings_string_lists() {
        assert_eq!(gsettings_string_list(&[]), "[]");
        assert_eq!(
            gsettings_string_list(&[r"a\b", "it's"]),
            r"['a\\b', 'it\'s']"
        );
    }

    #[test]
    fn points_every_kde_proxy_at_the_listener_and_tells_kio_to_reload() {
        for commands in [
            start_commands(
                &manual(&["localhost".into()]),
                "/home/user",
                Backend::Kde,
                "kwriteconfig6",
            ),
            stop_commands("/home/user", Backend::Kde, "kwriteconfig6"),
        ] {
            let reload = commands.iter().find(|c| c.program == "dbus-send").unwrap();
            assert!(reload.optional);
            assert_eq!(
                programs(&commands),
                ["kwriteconfig6", "dbus-send", "gsettings"]
            );
            assert!(commands[0]
                .args
                .contains(&"/home/user/.config/kioslaverc".to_owned()));
        }
        let start = start_commands(&manual(&[]), "/home/user", Backend::Kde, "kwriteconfig6");
        let proxies: Vec<(&str, &str)> = start
            .iter()
            .filter(|c| c.program == "kwriteconfig6" && c.args[5].ends_with("Proxy"))
            .map(|c| (c.args[5].as_str(), c.args[6].as_str()))
            .collect();
        assert_eq!(
            proxies,
            [
                ("httpProxy", "http://127.0.0.1:7890"),
                ("httpsProxy", "http://127.0.0.1:7890"),
                ("socksProxy", "socks://127.0.0.1:7890"),
            ]
        );
    }

    #[test]
    fn points_gsettings_at_the_pac_url_in_auto_mode() {
        for (backend, schema) in [
            (Backend::Gnome, "org.gnome.system.proxy"),
            (Backend::Mate, "org.mate.system.proxy"),
        ] {
            let args: Vec<Vec<String>> = start_commands(&pac(), "/home/user", backend, "gsettings")
                .into_iter()
                .map(|command| command.args)
                .collect();
            assert_eq!(
                args,
                [
                    vec![
                        "set",
                        schema,
                        "autoconfig-url",
                        "http://127.0.0.1:5/flclash.pac?v=0"
                    ],
                    vec!["set", schema, "mode", "auto"],
                ]
            );
        }
    }

    #[test]
    fn points_kde_at_the_pac_url_and_tells_kio_to_reload() {
        let commands = start_commands(&pac(), "/home/user", Backend::Kde, "kwriteconfig6");
        let keys: Vec<(&str, &str)> = commands
            .iter()
            .filter(|c| c.program == "kwriteconfig6")
            .map(|c| (c.args[5].as_str(), c.args[6].as_str()))
            .collect();
        assert_eq!(
            keys,
            [
                ("Proxy Config Script", "http://127.0.0.1:5/flclash.pac?v=0"),
                ("ProxyType", "2"),
            ]
        );
        assert_eq!(
            programs(&commands),
            ["kwriteconfig6", "dbus-send", "gsettings"]
        );
    }

    #[test]
    fn mirrors_kde_into_the_gnome_settings_gtk_programs_read() {
        let gnome = |commands: Vec<ProxyCommand>| -> Vec<(Vec<String>, bool)> {
            commands
                .into_iter()
                .filter(|c| c.program == "gsettings")
                .map(|c| (c.args, c.optional))
                .collect()
        };
        let bypass = ["localhost".to_owned()];
        for (kde, expected) in [
            (
                start_commands(
                    &manual(&bypass),
                    "/home/user",
                    Backend::Kde,
                    "kwriteconfig6",
                ),
                start_commands(&manual(&bypass), "/home/user", Backend::Gnome, "gsettings"),
            ),
            (
                start_commands(&pac(), "/home/user", Backend::Kde, "kwriteconfig6"),
                start_commands(&pac(), "/home/user", Backend::Gnome, "gsettings"),
            ),
            (
                stop_commands("/home/user", Backend::Kde, "kwriteconfig6"),
                stop_commands("/home/user", Backend::Gnome, "gsettings"),
            ),
        ] {
            let mirrored = gnome(kde);
            assert!(mirrored.iter().all(|(_, optional)| *optional));
            let expected: Vec<Vec<String>> = expected.into_iter().map(|c| c.args).collect();
            let mirrored: Vec<Vec<String>> = mirrored.into_iter().map(|(args, _)| args).collect();
            assert_eq!(mirrored, expected);
        }
    }

    #[test]
    fn a_missing_gsettings_does_not_fail_the_kde_setup() {
        let commands = start_commands(&pac(), "/home/user", Backend::Kde, "kwriteconfig6");
        assert!(command::run_all(commands, |c| c.program != "gsettings"));
    }
}
