use std::fs;
use std::path::{Path, PathBuf};

pub fn autostart_enabled(id: &str, _executable: &str) -> bool {
    home().is_some_and(|home| desktop_file(&home, id).exists())
}

pub fn set_autostart(id: &str, display_name: &str, executable: &str, enabled: bool) -> bool {
    home().is_some_and(|home| write_autostart(&home, id, display_name, executable, enabled))
}

/// `$HOME/.config/autostart`, not `$XDG_CONFIG_HOME`: the path the
/// `launch_at_startup` builds wrote to, so their entry stays ours.
fn desktop_file(home: &Path, id: &str) -> PathBuf {
    home.join(".config/autostart").join(format!("{id}.desktop"))
}

fn desktop_entry(display_name: &str, executable: &str) -> String {
    format!(
        "[Desktop Entry]\n\
         Type=Application\n\
         Name={display_name}\n\
         Comment={display_name} startup script\n\
         Exec={executable}\n\
         StartupNotify=false\n\
         Terminal=false\n"
    )
}

fn write_autostart(
    home: &Path,
    id: &str,
    display_name: &str,
    executable: &str,
    enabled: bool,
) -> bool {
    let file = desktop_file(home, id);
    if enabled {
        file.parent()
            .is_some_and(|dir| fs::create_dir_all(dir).is_ok())
            && fs::write(&file, desktop_entry(display_name, executable)).is_ok()
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
        let write =
            |enabled| write_autostart(&home, "FlClash", "FlClash", "/opt/FlClash/FlClash", enabled);
        assert!(write(true));

        let file = home.join(".config/autostart/FlClash.desktop");
        assert_eq!(
            fs::read_to_string(&file).unwrap(),
            "[Desktop Entry]\nType=Application\nName=FlClash\n\
             Comment=FlClash startup script\nExec=/opt/FlClash/FlClash\n\
             StartupNotify=false\nTerminal=false\n",
        );
        assert!(desktop_file(&home, "FlClash").exists());

        assert!(write(false));
        assert!(!file.exists());
        assert!(write(false));
        fs::remove_dir_all(home).unwrap();
    }

    #[test]
    fn names_the_file_by_id_and_the_entry_by_display_name() {
        let home = temp_home("display");
        assert!(write_autostart(
            &home, "App id", "App Name", "/opt/app", true
        ));

        let file = home.join(".config/autostart/App id.desktop");
        let entry = fs::read_to_string(&file).unwrap();
        assert!(entry.contains("\nName=App Name\nComment=App Name startup script\n"));
        assert!(!home.join(".config/autostart/App Name.desktop").exists());

        assert!(write_autostart(
            &home, "App id", "App Name", "/opt/app", false
        ));
        assert!(!file.exists());
        fs::remove_dir_all(home).unwrap();
    }
}
