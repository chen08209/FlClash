/// The cached PNG of the app behind a desktop process, `size` pixels square,
/// kept under `cache_dir`; an empty path asks for the generic application
/// icon, and `None` means the process has no icon of its own.
pub fn app_icon_file(
    process_path: String,
    size: u32,
    cache_dir: String,
) -> Result<Option<String>, String> {
    crate::app_icon::icon_file(&process_path, size, std::path::Path::new(&cache_dir))
        .map(|file| file.map(|file| file.to_string_lossy().into_owned()))
}
