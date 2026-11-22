#[cfg(target_os = "linux")]
use super::Owner;
use std::path::{Path, PathBuf};

const GENERIC_ICON: &str = "application-x-executable";

/// What a desktop entry says about the program it launches.
#[derive(Debug, Clone, Default)]
pub struct Entry {
    pub id: String,
    pub file: PathBuf,
    pub executable: Option<PathBuf>,
    pub wm_class: Option<String>,
}

/// The entry that launches `process_path`, judged as a desktop shell matches
/// a window to its app: a snap or flatpak by its app id, then the entry's
/// `Exec` program, its `StartupWMClass`, and finally its id.
pub fn pick<'a>(
    entries: &'a [Entry],
    process_path: &Path,
    flatpak: Option<&str>,
) -> Option<&'a Entry> {
    if let Some(snap) = snap_name(process_path) {
        let prefix = format!("{snap}_");
        if let Some(entry) = entries.iter().find(|entry| entry.id.starts_with(&prefix)) {
            return Some(entry);
        }
    }
    if let Some(app) = flatpak {
        let id = format!("{app}.desktop");
        if let Some(entry) = entries.iter().find(|entry| entry.id == id) {
            return Some(entry);
        }
    }
    let name = process_path.file_name()?.to_string_lossy().to_lowercase();
    if runs_other_programs(&name) {
        return None;
    }
    if let Some(entry) = entries
        .iter()
        .find(|entry| entry.executable.as_deref() == Some(process_path))
    {
        return Some(entry);
    }
    let mut by_program = entries.iter().filter(|entry| {
        entry
            .executable
            .as_deref()
            .and_then(Path::file_name)
            .is_some_and(|program| program.to_string_lossy().to_lowercase() == name)
    });
    let only_by_program = match (by_program.next(), by_program.next()) {
        (Some(entry), None) => Some(entry),
        _ => None,
    };
    only_by_program
        .or_else(|| {
            entries.iter().find(|entry| {
                entry
                    .wm_class
                    .as_deref()
                    .is_some_and(|class| class.to_lowercase() == name)
            })
        })
        .or_else(|| {
            entries.iter().find(|entry| {
                let stem = entry.id.trim_end_matches(".desktop").to_lowercase();
                stem == name || stem.rsplit('.').next() == Some(name.as_str())
            })
        })
}

const LAUNCHERS: &[&str] = &[
    "env", "sh", "bash", "dash", "zsh", "fish", "ksh", "csh", "tcsh", "sudo", "pkexec", "flatpak",
    "snap", "bwrap", "xdg-open", "gjs", "electron", "mono", "dotnet", "javaw", "nodejs",
];
const INTERPRETERS: &[&str] = &[
    "python", "pypy", "node", "java", "perl", "ruby", "php", "lua", "wine",
];

fn runs_other_programs(name: &str) -> bool {
    LAUNCHERS.contains(&name)
        || INTERPRETERS.iter().any(|interpreter| {
            name.strip_prefix(interpreter)
                .is_some_and(|version| version.chars().all(|c| c.is_ascii_digit() || c == '.'))
        })
}

/// `firefox` for `/snap/firefox/5123/usr/lib/firefox/firefox`.
fn snap_name(process_path: &Path) -> Option<String> {
    let mut components = process_path.strip_prefix("/snap").ok()?.components();
    Some(
        components
            .next()?
            .as_os_str()
            .to_string_lossy()
            .into_owned(),
    )
}

/// The `name` of the `[Application]` group in a `.flatpak-info` file.
fn flatpak_app(info: &str) -> Option<String> {
    let mut in_application = false;
    for line in info.lines().map(str::trim) {
        if line.starts_with('[') {
            in_application = line == "[Application]";
        } else if in_application {
            if let Some(name) = line.strip_prefix("name=") {
                return Some(name.trim().to_owned());
            }
        }
    }
    None
}

#[cfg(target_os = "linux")]
pub fn owner(process_path: &Path, _size: u32) -> Option<Owner<()>> {
    let process_path = &std::fs::canonicalize(process_path).unwrap_or_else(|_| process_path.into());
    let flatpak = process_path
        .starts_with("/app")
        .then(|| native::flatpak_of(process_path))
        .flatten();
    let entries = native::entries();
    let entry = pick(&entries, process_path, flatpak.as_deref())?;
    Some(Owner {
        key: entry.file.clone(),
        stamp: entry.file.clone(),
        source: (),
    })
}

#[cfg(target_os = "linux")]
pub fn render(owner: &Owner<()>, size: u32) -> Result<Option<Vec<u8>>, String> {
    native::render(native::Icon::Entry(owner.key.clone()), size)
}

#[cfg(target_os = "linux")]
pub fn render_default(size: u32) -> Result<Option<Vec<u8>>, String> {
    native::render(native::Icon::Named(GENERIC_ICON), size)
}

#[cfg(target_os = "linux")]
mod native {
    use super::{flatpak_app, Entry};
    use std::ffi::{c_char, c_void, CStr, CString};
    use std::os::unix::ffi::OsStrExt;
    use std::path::{Path, PathBuf};
    use std::ptr::null_mut;
    use std::sync::mpsc;
    use std::sync::Mutex;
    use std::time::{Duration, Instant};

    const ENTRIES_TTL: Duration = Duration::from_secs(30);
    const MAIN_THREAD_TIMEOUT: Duration = Duration::from_secs(5);

    static ENTRIES: Mutex<Option<(Instant, Vec<Entry>)>> = Mutex::new(None);

    /// Installed entries, listed again once they are older than
    /// [ENTRIES_TTL] so an app installed meanwhile is found.
    pub fn entries() -> Vec<Entry> {
        let mut cached = ENTRIES
            .lock()
            .unwrap_or_else(|poisoned| poisoned.into_inner());
        if let Some((listed, entries)) = cached.as_ref() {
            if listed.elapsed() < ENTRIES_TTL {
                return entries.clone();
            }
        }
        let entries = list();
        *cached = Some((Instant::now(), entries.clone()));
        entries
    }

    fn list() -> Vec<Entry> {
        let mut entries = Vec::new();
        // SAFETY: GIO's app info registry is thread-safe; each GAppInfo is a
        // GObject the list owns and g_list_free_full releases.
        unsafe {
            let all = gio_sys::g_app_info_get_all();
            let mut node = all;
            while !node.is_null() {
                let info = (*node).data.cast::<gio_sys::GAppInfo>();
                if let Some(entry) = entry(info) {
                    entries.push(entry);
                }
                node = (*node).next;
            }
            glib_sys::g_list_free_full(all, Some(unref));
        }
        entries
    }

    unsafe extern "C" fn unref(object: glib_sys::gpointer) {
        unsafe { gobject_sys::g_object_unref(object.cast()) };
    }

    unsafe fn entry(info: *mut gio_sys::GAppInfo) -> Option<Entry> {
        let desktop = unsafe {
            gobject_sys::g_type_check_instance_is_a(
                info.cast(),
                gio_sys::g_desktop_app_info_get_type(),
            )
        };
        if desktop == 0 {
            return None;
        }
        let desktop_info = info.cast::<gio_sys::GDesktopAppInfo>();
        let file = string(unsafe { gio_sys::g_desktop_app_info_get_filename(desktop_info) })?;
        Some(Entry {
            id: string(unsafe { gio_sys::g_app_info_get_id(info) }).unwrap_or_default(),
            file: PathBuf::from(file),
            executable: string(unsafe { gio_sys::g_app_info_get_executable(info) })
                .and_then(|program| resolve(&program)),
            wm_class: string(unsafe {
                gio_sys::g_desktop_app_info_get_startup_wm_class(desktop_info)
            }),
        })
    }

    fn string(pointer: *const c_char) -> Option<String> {
        // SAFETY: GIO returns NUL-terminated strings it keeps alive.
        (!pointer.is_null()).then(|| {
            unsafe { CStr::from_ptr(pointer) }
                .to_string_lossy()
                .into_owned()
        })
    }

    /// The real file `Exec` runs, found on `PATH` when it is a bare name.
    fn resolve(program: &str) -> Option<PathBuf> {
        let path = Path::new(program);
        let found = if path.is_absolute() {
            Some(path.to_path_buf())
        } else {
            std::env::var_os("PATH").and_then(|paths| {
                std::env::split_paths(&paths)
                    .map(|dir| dir.join(program))
                    .find(|candidate| candidate.is_file())
            })
        };
        found.map(|file| std::fs::canonicalize(&file).unwrap_or(file))
    }

    /// A flatpak process sees its app under `/app`; the app id is in the
    /// sandbox's `.flatpak-info`, reached through any process running that
    /// executable.
    pub fn flatpak_of(process_path: &Path) -> Option<String> {
        for process in std::fs::read_dir("/proc").ok()?.flatten() {
            let name = process.file_name();
            if !name.as_bytes().iter().all(u8::is_ascii_digit) {
                continue;
            }
            let dir = process.path();
            if std::fs::read_link(dir.join("exe")).ok().as_deref() != Some(process_path) {
                continue;
            }
            if let Ok(info) = std::fs::read_to_string(dir.join("root/.flatpak-info")) {
                return flatpak_app(&info);
            }
        }
        None
    }

    pub enum Icon {
        Entry(PathBuf),
        Named(&'static str),
    }

    enum Found {
        File(PathBuf),
        Pixbuf(Pixbuf),
    }

    struct Pixbuf(*mut gdk_pixbuf_sys::GdkPixbuf);

    // SAFETY: GObject reference counts are atomic and the pixels are only read.
    unsafe impl Send for Pixbuf {}

    impl Drop for Pixbuf {
        fn drop(&mut self) {
            unsafe { gobject_sys::g_object_unref(self.0.cast()) };
        }
    }

    struct Job {
        icon: Icon,
        size: i32,
        reply: mpsc::Sender<Result<Option<Found>, String>>,
    }

    /// Only the theme lookup, and loading an icon that has no file, run on
    /// the main loop, which the UI thread shares; the rest runs on this worker.
    pub fn render(icon: Icon, size: u32) -> Result<Option<Vec<u8>>, String> {
        let size = size as i32;
        match on_main_thread(icon, size)? {
            Some(Found::File(file)) => unsafe { from_file(&file, size) }.map(Some),
            Some(Found::Pixbuf(pixbuf)) => unsafe { encode(&pixbuf) }.map(Some),
            None => Ok(None),
        }
    }

    /// GTK's default icon theme belongs to the thread running the GLib main
    /// loop, so the lookup runs there and this worker waits for its answer.
    fn on_main_thread(icon: Icon, size: i32) -> Result<Option<Found>, String> {
        let (reply, answer) = mpsc::channel();
        let job = Box::new(Job { icon, size, reply });
        // SAFETY: `run` takes back the box it is handed exactly once.
        unsafe {
            glib_sys::g_main_context_invoke(null_mut(), Some(run), Box::into_raw(job).cast());
        }
        answer
            .recv_timeout(MAIN_THREAD_TIMEOUT)
            .map_err(|_| "the main loop did not answer".to_owned())?
    }

    unsafe extern "C" fn run(data: glib_sys::gpointer) -> glib_sys::gboolean {
        let job = unsafe { Box::from_raw(data.cast::<Job>()) };
        let _ = job.reply.send(unsafe { locate(&job.icon, job.size) });
        glib_sys::G_SOURCE_REMOVE
    }

    unsafe fn locate(icon: &Icon, size: i32) -> Result<Option<Found>, String> {
        let gicon: *mut gio_sys::GIcon = match icon {
            Icon::Entry(file) => {
                let file = CString::new(file.as_os_str().as_bytes()).map_err(|e| e.to_string())?;
                let info = unsafe { gio_sys::g_desktop_app_info_new_from_filename(file.as_ptr()) };
                if info.is_null() {
                    return Ok(None);
                }
                let icon = unsafe { gio_sys::g_app_info_get_icon(info.cast()) };
                if !icon.is_null() {
                    unsafe { gobject_sys::g_object_ref(icon.cast()) };
                }
                unsafe { gobject_sys::g_object_unref(info.cast()) };
                icon
            }
            Icon::Named(name) => {
                let name = CString::new(*name).map_err(|e| e.to_string())?;
                unsafe { gio_sys::g_themed_icon_new(name.as_ptr()).cast() }
            }
        };
        if gicon.is_null() {
            return Ok(None);
        }
        let result = unsafe { lookup(gicon, size) };
        unsafe { gobject_sys::g_object_unref(gicon.cast()) };
        result
    }

    unsafe fn lookup(icon: *mut gio_sys::GIcon, size: i32) -> Result<Option<Found>, String> {
        // Asking for the default theme without a screen is itself a GTK critical.
        if unsafe { gdk_sys::gdk_screen_get_default() }.is_null() {
            return Ok(None);
        }
        let theme = unsafe { gtk_sys::gtk_icon_theme_get_default() };
        let info = unsafe {
            gtk_sys::gtk_icon_theme_lookup_by_gicon(
                theme,
                icon,
                size,
                gtk_sys::GTK_ICON_LOOKUP_FORCE_SIZE,
            )
        };
        if info.is_null() {
            return Ok(None);
        }
        // A theme compiled into a GResource names its icons by resource path,
        // which no file has.
        let file = string(unsafe { gtk_sys::gtk_icon_info_get_filename(info) })
            .map(PathBuf::from)
            .filter(|file| file.is_file());
        let found = match file {
            Some(file) => Ok(Found::File(file)),
            None => {
                let mut error = null_mut();
                let pixbuf = unsafe { gtk_sys::gtk_icon_info_load_icon(info, &mut error) };
                if pixbuf.is_null() {
                    Err(unsafe { take_error(error) })
                } else {
                    Ok(Found::Pixbuf(Pixbuf(pixbuf)))
                }
            }
        };
        unsafe { gobject_sys::g_object_unref(info.cast()) };
        found.map(Some)
    }

    unsafe fn from_file(file: &Path, size: i32) -> Result<Vec<u8>, String> {
        let file = CString::new(file.as_os_str().as_bytes()).map_err(|e| e.to_string())?;
        let mut error = null_mut();
        let pixbuf = unsafe {
            gdk_pixbuf_sys::gdk_pixbuf_new_from_file_at_size(file.as_ptr(), size, size, &mut error)
        };
        if pixbuf.is_null() {
            return Err(unsafe { take_error(error) });
        }
        unsafe { encode(&Pixbuf(pixbuf)) }
    }

    unsafe fn encode(pixbuf: &Pixbuf) -> Result<Vec<u8>, String> {
        debug_assert!(
            unsafe { glib_sys::g_main_context_is_owner(glib_sys::g_main_context_default()) } == 0,
            "an icon is encoded off the main loop",
        );
        let mut error = null_mut();
        let mut buffer: *mut u8 = null_mut();
        let mut length = 0;
        let saved = unsafe {
            gdk_pixbuf_sys::gdk_pixbuf_save_to_bufferv(
                pixbuf.0,
                &mut buffer,
                &mut length,
                c"png".as_ptr(),
                null_mut(),
                null_mut(),
                &mut error,
            )
        };
        if saved == 0 {
            return Err(unsafe { take_error(error) });
        }
        let bytes = unsafe { std::slice::from_raw_parts(buffer, length) }.to_vec();
        unsafe { glib_sys::g_free(buffer.cast::<c_void>()) };
        Ok(bytes)
    }

    unsafe fn take_error(error: *mut glib_sys::GError) -> String {
        if error.is_null() {
            return "the icon could not be loaded".to_owned();
        }
        let message = string(unsafe { (*error).message }).unwrap_or_default();
        unsafe { glib_sys::g_error_free(error) };
        message
    }

    #[cfg(test)]
    mod tests {
        use super::*;
        use std::sync::atomic::{AtomicUsize, Ordering};

        #[test]
        fn without_a_display_there_is_no_icon_and_no_misuse_of_gtk() {
            static CRITICALS: AtomicUsize = AtomicUsize::new(0);
            unsafe extern "C" fn count(
                _: *const c_char,
                _: glib_sys::GLogLevelFlags,
                _: *const c_char,
                _: glib_sys::gpointer,
            ) {
                CRITICALS.fetch_add(1, Ordering::SeqCst);
            }
            let handler = unsafe {
                glib_sys::g_log_set_handler(
                    c"Gtk".as_ptr(),
                    glib_sys::G_LOG_LEVEL_CRITICAL,
                    Some(count),
                    null_mut(),
                )
            };
            let rendered = render(Icon::Named(super::super::GENERIC_ICON), 32);
            unsafe { glib_sys::g_log_remove_handler(c"Gtk".as_ptr(), handler) };
            assert!(rendered.is_ok());
            assert_eq!(CRITICALS.load(Ordering::SeqCst), 0);
        }

        #[test]
        #[ignore = "needs a display"]
        fn an_icon_with_no_file_is_encoded_off_the_main_loop() {
            assert_ne!(
                unsafe { gtk_sys::gtk_init_check(null_mut(), null_mut()) },
                0
            );
            let dir =
                std::env::temp_dir().join(format!("app_icon_resource_{}", std::process::id()));
            std::fs::create_dir_all(&dir).unwrap();
            let image = unsafe {
                gdk_pixbuf_sys::gdk_pixbuf_new(gdk_pixbuf_sys::GDK_COLORSPACE_RGB, 1, 8, 48, 48)
            };
            unsafe { gdk_pixbuf_sys::gdk_pixbuf_fill(image, 0x3366_ccff) };
            let png = unsafe { encode(&Pixbuf(image)) }.unwrap();
            std::fs::write(dir.join("flclash-probe.png"), png).unwrap();
            std::fs::write(
                dir.join("icons.xml"),
                r#"<gresources><gresource prefix="/org/flclash/probe/icons/48x48/apps">
                <file>flclash-probe.png</file></gresource></gresources>"#,
            )
            .unwrap();
            let bundle = dir.join("icons.gresource");
            let compiled = std::process::Command::new("glib-compile-resources")
                .arg("--sourcedir")
                .arg(&dir)
                .arg("--target")
                .arg(&bundle)
                .arg(dir.join("icons.xml"))
                .status()
                .unwrap();
            assert!(compiled.success());
            let bundle = CString::new(bundle.as_os_str().as_bytes()).unwrap();
            unsafe {
                let resource = gio_sys::g_resource_load(bundle.as_ptr(), null_mut());
                assert!(!resource.is_null());
                gio_sys::g_resources_register(resource);
                gtk_sys::gtk_icon_theme_add_resource_path(
                    gtk_sys::gtk_icon_theme_get_default(),
                    c"/org/flclash/probe/icons".as_ptr(),
                );
            }

            let png = render(Icon::Named("flclash-probe"), 32).unwrap().unwrap();

            assert!(png.starts_with(b"\x89PNG"));
            std::fs::remove_dir_all(dir).unwrap();
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    fn entry(id: &str, executable: Option<&str>, wm_class: Option<&str>) -> Entry {
        Entry {
            id: id.into(),
            file: PathBuf::from(format!("/usr/share/applications/{id}")),
            executable: executable.map(PathBuf::from),
            wm_class: wm_class.map(Into::into),
        }
    }

    fn picked(entries: &[Entry], path: &str, flatpak: Option<&str>) -> Option<String> {
        pick(entries, Path::new(path), flatpak).map(|entry| entry.id.clone())
    }

    #[test]
    fn matches_the_exec_program_before_names() {
        let entries = [
            entry(
                "code-url-handler.desktop",
                Some("/usr/share/code/bin/code"),
                None,
            ),
            entry("code.desktop", Some("/usr/share/code/code"), None),
        ];
        assert_eq!(
            picked(&entries, "/usr/share/code/code", None).as_deref(),
            Some("code.desktop")
        );
    }

    #[test]
    fn falls_back_to_the_program_name_wm_class_and_id() {
        let entries = [
            entry("firefox.desktop", Some("/usr/bin/firefox"), None),
            entry(
                "google-chrome.desktop",
                Some("/usr/bin/google-chrome-stable"),
                Some("Google-chrome"),
            ),
            entry(
                "org.gnome.Nautilus.desktop",
                Some("/usr/bin/nautilus-launcher"),
                None,
            ),
        ];
        assert_eq!(
            picked(&entries, "/usr/lib/firefox/firefox", None).as_deref(),
            Some("firefox.desktop")
        );
        assert_eq!(
            picked(&entries, "/opt/google/chrome/google-chrome", None).as_deref(),
            Some("google-chrome.desktop"),
        );
        assert_eq!(
            picked(&entries, "/usr/bin/nautilus", None).as_deref(),
            Some("org.gnome.Nautilus.desktop"),
        );
        assert_eq!(picked(&entries, "/usr/bin/curl", None), None);
    }

    #[test]
    fn a_program_name_shared_by_two_entries_picks_neither() {
        let entries = [
            entry("tool-a.desktop", Some("/opt/a/bin/tool"), None),
            entry("tool-b.desktop", Some("/opt/b/bin/tool"), None),
        ];
        assert_eq!(picked(&entries, "/usr/local/bin/tool", None), None);
        assert_eq!(
            picked(&entries, "/opt/b/bin/tool", None).as_deref(),
            Some("tool-b.desktop")
        );
    }

    #[test]
    fn interpreters_and_launchers_pick_nothing() {
        let entries = [
            entry("lutris.desktop", Some("/usr/bin/python3"), Some("python3")),
            entry("app.desktop", Some("/usr/bin/env"), None),
            entry("node.desktop", Some("/usr/bin/node"), None),
            entry("rubymine.desktop", Some("/opt/rubymine/bin/rubymine"), None),
        ];
        for interpreter in [
            "/usr/bin/python3",
            "/usr/bin/python3.12",
            "/usr/bin/env",
            "/usr/bin/node",
        ] {
            assert_eq!(picked(&entries, interpreter, None), None, "{interpreter}");
        }
        assert_eq!(
            picked(&entries, "/usr/local/bin/rubymine", None).as_deref(),
            Some("rubymine.desktop")
        );
    }

    #[test]
    fn finds_snaps_and_flatpaks_by_app_id() {
        let entries = [
            entry("firefox.desktop", Some("/usr/bin/firefox"), None),
            entry("firefox_firefox.desktop", Some("/snap/bin/firefox"), None),
            entry(
                "org.mozilla.firefox.desktop",
                Some("/usr/bin/flatpak"),
                None,
            ),
        ];
        assert_eq!(
            picked(&entries, "/snap/firefox/5123/usr/lib/firefox/firefox", None).as_deref(),
            Some("firefox_firefox.desktop"),
        );
        assert_eq!(
            picked(
                &entries,
                "/app/lib/firefox/firefox",
                Some("org.mozilla.firefox")
            )
            .as_deref(),
            Some("org.mozilla.firefox.desktop"),
        );
    }

    #[test]
    fn reads_the_app_id_of_a_flatpak_sandbox() {
        let info =
            "[Instance]\nname=ignored\n\n[Application]\nname=org.mozilla.firefox\nruntime=x\n";
        assert_eq!(flatpak_app(info).as_deref(), Some("org.mozilla.firefox"));
        assert_eq!(flatpak_app("[Instance]\nname=x\n"), None);
    }
}
