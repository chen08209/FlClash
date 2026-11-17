use interprocess::local_socket::tokio::{prelude::*, Stream};
use interprocess::local_socket::ListenerOptions;
use std::io;

/// Linux carries an `fchmod` on the unbound socket over to the file `bind`
/// creates; other Unixes reject it and get `restrict_socket` after `bind`.
pub fn owner_only(options: ListenerOptions<'_>) -> ListenerOptions<'_> {
    #[cfg(target_os = "linux")]
    {
        use interprocess::os::unix::local_socket::ListenerOptionsExt as _;

        options.mode(0o600)
    }
    #[cfg(not(target_os = "linux"))]
    {
        options
    }
}

pub fn restrict_socket(path: &str) -> io::Result<()> {
    #[cfg(unix)]
    {
        use std::os::unix::fs::PermissionsExt;

        std::fs::set_permissions(path, std::fs::Permissions::from_mode(0o600))?;
    }
    #[cfg(windows)]
    {
        let _ = path;
    }
    Ok(())
}

/// A directory another user can write into lets them swap the socket between bind and dial.
pub fn private_directory(socket: &str) -> io::Result<()> {
    #[cfg(unix)]
    {
        use std::os::unix::fs::{DirBuilderExt, MetadataExt};

        let Some(directory) = std::path::Path::new(socket)
            .parent()
            .filter(|parent| !parent.as_os_str().is_empty())
        else {
            return Err(denied("the socket path has no directory".into()));
        };
        match std::fs::DirBuilder::new().mode(0o700).create(directory) {
            Ok(()) => {}
            Err(error) if error.kind() == io::ErrorKind::AlreadyExists => {}
            Err(error) => return Err(error),
        }
        let metadata = std::fs::symlink_metadata(directory)?;
        // SAFETY: geteuid() takes no arguments and cannot fail.
        let own_uid = unsafe { libc::geteuid() };
        if !is_private_directory(metadata.is_dir(), metadata.uid(), metadata.mode(), own_uid) {
            return Err(denied(format!(
                "{} is not a directory only this user can enter",
                directory.display()
            )));
        }
    }
    #[cfg(windows)]
    {
        let _ = socket;
    }
    Ok(())
}

/// Reports the admitted peer's process ID where the platform knows it.
pub fn admit(stream: &Stream) -> io::Result<Option<u32>> {
    let credentials = stream.peer_creds()?;
    #[cfg(unix)]
    {
        let peer_uid = credentials
            .euid()
            .ok_or_else(|| denied("peer user ID is unavailable".into()))?;
        // SAFETY: geteuid() takes no arguments and cannot fail.
        let own_uid = unsafe { libc::geteuid() };
        if !is_permitted_uid(peer_uid, own_uid) {
            return Err(denied(format!(
                "peer uid {peer_uid} is neither {own_uid} nor root"
            )));
        }
    }
    #[allow(clippy::useless_conversion)]
    Ok(credentials.pid().and_then(|pid| u32::try_from(pid).ok()))
}

#[cfg(unix)]
fn denied(reason: String) -> io::Error {
    io::Error::new(io::ErrorKind::PermissionDenied, reason)
}

#[cfg(unix)]
fn is_permitted_uid(peer_uid: libc::uid_t, own_uid: libc::uid_t) -> bool {
    peer_uid == own_uid || peer_uid == 0
}

#[cfg(unix)]
fn is_private_directory(is_directory: bool, owner: u32, mode: u32, own_uid: u32) -> bool {
    is_directory && owner == own_uid && mode & 0o077 == 0
}

#[cfg(all(test, unix))]
mod tests {
    use super::{is_permitted_uid, is_private_directory};

    #[test]
    fn a_private_directory_is_ours_and_closed_to_group_and_others() {
        assert!(is_private_directory(true, 501, 0o040_700, 501));
        assert!(!is_private_directory(true, 501, 0o040_750, 501));
        assert!(!is_private_directory(true, 501, 0o041_777, 501));
        assert!(!is_private_directory(true, 0, 0o040_700, 501));
        assert!(!is_private_directory(false, 501, 0o120_700, 501));
    }

    #[test]
    fn admits_the_socket_owner() {
        assert!(is_permitted_uid(501, 501));
    }

    #[test]
    fn admits_root_because_the_core_runs_privileged_for_tun() {
        assert!(is_permitted_uid(0, 501));
    }

    #[test]
    fn rejects_every_other_user() {
        assert!(!is_permitted_uid(502, 501));
        assert!(!is_permitted_uid(501, 0));
    }
}
