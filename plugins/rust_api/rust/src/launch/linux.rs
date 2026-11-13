use std::fs;
use std::path::{Path, PathBuf};

pub fn autostart_enabled(name: &str, _executable: &str) -> bool {
    home().is_some_and(|home| desktop_file(&home, name).exists())
}

pub fn set_autostart(name: &str, executable: &str, enabled: bool) -> bool {
    home().is_some_and(|home| write_autostart(&home, name, executable, enabled))
}

/// `$HOME/.config/autostart`, not `$XDG_CONFIG_HOME`: the path the
/// `launch_at_startup` builds wrote to, so their entry stays ours.
fn desktop_file(home: &Path, name: &str) -> PathBuf {
    home.join(".config/autostart")
        .join(format!("{name}.desktop"))
}

fn desktop_entry(name: &str, executable: &str) -> String {
    format!(
        "[Desktop Entry]\n\
         Type=Application\n\
         Name={name}\n\
         Comment={name} startup script\n\
         Exec={executable}\n\
         StartupNotify=false\n\
         Terminal=false\n"
    )
}

fn write_autostart(home: &Path, name: &str, executable: &str, enabled: bool) -> bool {
    let file = desktop_file(home, name);
    if enabled {
        file.parent()
            .is_some_and(|dir| fs::create_dir_all(dir).is_ok())
            && fs::write(&file, desktop_entry(name, executable)).is_ok()
    } else {
        match fs::remove_file(&file) {
            Ok(()) => true,
            Err(error) => error.kind() == std::io::ErrorKind::NotFound,
        }
    }
}

fn home() -> Option<PathBuf> {
    std::env::var_os("HOME")
        .filter(|home| !home.is_empty())
        .map(PathBuf::from)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn temp_home(name: &str) -> PathBuf {
        let dir =
            std::env::temp_dir().join(format!("rust_api_autostart_{name}_{}", std::process::id()));
        let _ = fs::remove_dir_all(&dir);
        dir
    }

    #[test]
    fn writes_the_entry_the_launch_at_startup_builds_wrote() {
        let home = temp_home("write");
        assert!(write_autostart(
            &home,
            "FlClash",
            "/opt/FlClash/FlClash",
            true
        ));

        let file = home.join(".config/autostart/FlClash.desktop");
        assert_eq!(
            fs::read_to_string(&file).unwrap(),
            "[Desktop Entry]\nType=Application\nName=FlClash\n\
             Comment=FlClash startup script\nExec=/opt/FlClash/FlClash\n\
             StartupNotify=false\nTerminal=false\n",
        );
        assert!(desktop_file(&home, "FlClash").exists());

        assert!(write_autostart(
            &home,
            "FlClash",
            "/opt/FlClash/FlClash",
            false
        ));
        assert!(!file.exists());
        assert!(write_autostart(
            &home,
            "FlClash",
            "/opt/FlClash/FlClash",
            false
        ));
        fs::remove_dir_all(home).unwrap();
    }
}
