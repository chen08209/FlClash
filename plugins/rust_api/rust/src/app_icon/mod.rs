#[cfg(any(target_os = "linux", test))]
#[cfg_attr(not(target_os = "linux"), allow(dead_code))]
mod linux;
#[cfg(any(target_os = "macos", test))]
#[cfg_attr(not(target_os = "macos"), allow(dead_code))]
mod macos;
#[cfg(any(windows, test))]
#[cfg_attr(not(windows), allow(dead_code))]
mod png;
#[cfg(any(windows, test))]
#[cfg_attr(not(windows), allow(dead_code))]
mod windows;

use std::fs;
use std::path::{Path, PathBuf};
use std::sync::atomic::{AtomicU64, Ordering};
use std::time::UNIX_EPOCH;

const MIN_SIZE: u32 = 16;
const MAX_SIZE: u32 = 256;

/// `key` names the cached icon; the modification time of `stamp` dates it.
pub(crate) struct Owner<T> {
    pub key: PathBuf,
    pub stamp: PathBuf,
    #[cfg_attr(not(windows), allow(dead_code))]
    pub source: T,
}

/// The PNG of the app that `process_path` belongs to, `size` pixels square,
/// from the cache in `cache_dir` or rendered into it. An empty path asks for
/// the platform's generic application icon; `None` means the process has no
/// icon of its own.
pub fn icon_file(
    process_path: &str,
    size: u32,
    cache_dir: &Path,
) -> Result<Option<PathBuf>, String> {
    let size = size.clamp(MIN_SIZE, MAX_SIZE);
    if process_path.is_empty() {
        return cached(cache_dir, "default", 0, size, || {
            platform::render_default(size)
        });
    }
    let Some(owner) = platform::owner(Path::new(process_path), size) else {
        return Ok(None);
    };
    let modified = fs::metadata(&owner.stamp)
        .and_then(|metadata| metadata.modified())
        .ok()
        .and_then(|time| time.duration_since(UNIX_EPOCH).ok())
        .map_or(0, |elapsed| elapsed.as_secs());
    cached(cache_dir, &stem(&owner.key), modified, size, || {
        platform::render(&owner, size)
    })
}

fn cached(
    dir: &Path,
    stem: &str,
    modified: u64,
    size: u32,
    render: impl FnOnce() -> Result<Option<Vec<u8>>, String>,
) -> Result<Option<PathBuf>, String> {
    let version = format!("{stem}_{modified}_");
    let file = dir.join(format!("{version}{size}.png"));
    if file.is_file() {
        return Ok(Some(file));
    }
    let Some(png) = render()? else {
        return Ok(None);
    };
    fs::create_dir_all(dir).map_err(|error| format!("{}: {error}", dir.display()))?;
    remove_older_versions(dir, stem, &version);
    write_atomically(&file, &png)?;
    Ok(Some(file))
}

fn remove_older_versions(dir: &Path, stem: &str, version: &str) {
    let Ok(entries) = fs::read_dir(dir) else {
        return;
    };
    let prefix = format!("{stem}_");
    let own_temporary = format!(".{}-", std::process::id());
    for entry in entries.flatten() {
        let name = entry.file_name();
        let name = name.to_string_lossy();
        let left_by_another_writer = name.ends_with(".tmp") && !name.contains(&own_temporary);
        if name.starts_with(&prefix) && (!name.starts_with(version) || left_by_another_writer) {
            let _ = fs::remove_file(entry.path());
        }
    }
}

fn write_atomically(file: &Path, bytes: &[u8]) -> Result<(), String> {
    static NEXT: AtomicU64 = AtomicU64::new(0);
    let temporary = file.with_extension(format!(
        "{}-{}.tmp",
        std::process::id(),
        NEXT.fetch_add(1, Ordering::Relaxed),
    ));
    let result = fs::write(&temporary, bytes).and_then(|()| fs::rename(&temporary, file));
    if result.is_err() {
        let _ = fs::remove_file(&temporary);
    }
    match result {
        // Windows will not replace a file that is open, as Flutter may hold it.
        Err(_) if file.is_file() => Ok(()),
        Err(error) => Err(format!("{}: {error}", file.display())),
        Ok(()) => Ok(()),
    }
}

/// FNV-1a of the path, which stays the same across builds as a cache name
/// must; std's hasher makes no such promise.
fn stem(path: &Path) -> String {
    let hash = path
        .as_os_str()
        .as_encoded_bytes()
        .iter()
        .fold(0xcbf2_9ce4_8422_2325_u64, |hash, byte| {
            (hash ^ u64::from(*byte)).wrapping_mul(0x0000_0100_0000_01b3)
        });
    format!("{hash:016x}")
}

#[cfg(target_os = "linux")]
use linux as platform;
#[cfg(target_os = "macos")]
use macos as platform;
#[cfg(windows)]
use windows as platform;

#[cfg(not(any(target_os = "linux", target_os = "macos", windows)))]
mod platform {
    use super::Owner;
    use std::path::Path;

    pub fn owner(_process_path: &Path, _size: u32) -> Option<Owner<()>> {
        None
    }

    pub fn render(_owner: &Owner<()>, _size: u32) -> Result<Option<Vec<u8>>, String> {
        Ok(None)
    }

    pub fn render_default(_size: u32) -> Result<Option<Vec<u8>>, String> {
        Ok(None)
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use std::cell::Cell;

    fn scratch(name: &str) -> PathBuf {
        let dir = std::env::temp_dir().join(format!("app_icon_{name}_{}", std::process::id()));
        let _ = fs::remove_dir_all(&dir);
        dir
    }

    #[cfg(target_os = "macos")]
    #[test]
    fn draws_an_installed_app_at_the_size_asked() {
        let dir = scratch("installed");
        let file = icon_file(
            "/System/Applications/Calculator.app/Contents/MacOS/Calculator",
            48,
            &dir,
        )
        .unwrap()
        .unwrap();
        let png = fs::read(&file).unwrap();
        assert_eq!(&png[..8], b"\x89PNG\r\n\x1a\n");
        assert_eq!(png[16..24], [0, 0, 0, 48, 0, 0, 0, 48]);
        assert!(icon_file("", 48, &dir).unwrap().is_some());
        fs::remove_dir_all(dir).unwrap();
    }

    #[test]
    fn renders_once_then_reads_the_cache() {
        let dir = scratch("once");
        let renders = Cell::new(0);
        let render = || {
            renders.set(renders.get() + 1);
            Ok(Some(vec![1, 2, 3]))
        };
        let first = cached(&dir, "abc", 7, 48, render).unwrap().unwrap();
        let second = cached(&dir, "abc", 7, 48, render).unwrap().unwrap();
        assert_eq!(first, second);
        assert_eq!(renders.get(), 1);
        assert_eq!(fs::read(&first).unwrap(), [1, 2, 3]);
        fs::remove_dir_all(dir).unwrap();
    }

    #[test]
    fn a_new_modification_time_replaces_every_size_of_the_old_one() {
        let dir = scratch("replace");
        let png = || Ok(Some(vec![0]));
        let old_small = cached(&dir, "abc", 1, 32, png).unwrap().unwrap();
        let old_large = cached(&dir, "abc", 1, 64, png).unwrap().unwrap();
        let other = cached(&dir, "abd", 1, 32, png).unwrap().unwrap();
        let new = cached(&dir, "abc", 2, 32, png).unwrap().unwrap();
        assert!(!old_small.exists());
        assert!(!old_large.exists());
        assert!(other.exists());
        assert!(new.exists());
        fs::remove_dir_all(dir).unwrap();
    }

    #[test]
    fn a_new_icon_clears_what_a_dead_writer_left() {
        let dir = scratch("partial");
        fs::create_dir_all(&dir).unwrap();
        let partial = dir.join("abc_7_48.1-0.tmp");
        fs::write(&partial, [0]).unwrap();
        cached(&dir, "abc", 7, 32, || Ok(Some(vec![0]))).unwrap();
        assert!(!partial.exists());
        fs::remove_dir_all(dir).unwrap();
    }

    #[cfg(unix)]
    #[test]
    fn a_failed_write_over_a_finished_icon_still_succeeds() {
        use std::os::unix::fs::PermissionsExt;
        let dir = scratch("taken");
        fs::create_dir_all(&dir).unwrap();
        let file = dir.join("abc_7_48.png");
        let attempt = |bytes: &[u8]| {
            fs::set_permissions(&dir, fs::Permissions::from_mode(0o555)).unwrap();
            let result = write_atomically(&file, bytes);
            fs::set_permissions(&dir, fs::Permissions::from_mode(0o755)).unwrap();
            result
        };
        assert!(attempt(&[2]).is_err());
        fs::write(&file, [1]).unwrap();
        assert_eq!(attempt(&[2]), Ok(()));
        assert_eq!(fs::read(&file).unwrap(), [1]);
        assert_eq!(fs::read_dir(&dir).unwrap().count(), 1);
        fs::remove_dir_all(dir).unwrap();
    }

    #[test]
    fn no_icon_writes_nothing() {
        let dir = scratch("none");
        assert_eq!(cached(&dir, "abc", 1, 32, || Ok(None)).unwrap(), None);
        assert!(!dir.exists());
    }

    #[test]
    fn stems_are_stable_and_distinct() {
        assert_eq!(stem(Path::new("")), "cbf29ce484222325");
        assert_ne!(stem(Path::new("/a")), stem(Path::new("/b")));
    }
}
