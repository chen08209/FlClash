#[cfg(any(target_os = "android", test))]
#[cfg_attr(not(target_os = "android"), allow(dead_code))]
mod android;
#[cfg(target_os = "linux")]
mod linux;
#[cfg(target_os = "macos")]
mod macos;
#[cfg(windows)]
mod windows;

use std::collections::HashSet;

/// The font families the engine resolves by name on this host, each listed
/// through the API the engine itself matches names against.
pub fn system_families() -> Result<Vec<String>, String> {
    #[cfg(target_os = "android")]
    let families = android::families()?;
    #[cfg(target_os = "linux")]
    let families = linux::families()?;
    #[cfg(target_os = "macos")]
    let families = macos::families();
    #[cfg(windows)]
    let families = windows::families()?;
    #[cfg(not(any(
        target_os = "android",
        target_os = "linux",
        target_os = "macos",
        windows
    )))]
    let families = Vec::<String>::new();
    Ok(sort_families(families))
}

/// Case-insensitive and in UTF-16 order, as Dart sorts the picker's names;
/// hidden system families start with a dot.
fn sort_families(families: impl IntoIterator<Item = String>) -> Vec<String> {
    let mut seen = HashSet::new();
    let mut unique: Vec<(String, String)> = families
        .into_iter()
        .filter_map(|family| {
            let name = family.trim();
            if name.is_empty() || name.starts_with('.') {
                return None;
            }
            let key = name.to_lowercase();
            seen.insert(key.clone()).then(|| (key, name.to_owned()))
        })
        .collect();
    unique.sort_by(|(a, _), (b, _)| a.encode_utf16().cmp(b.encode_utf16()));
    unique.into_iter().map(|(_, name)| name).collect()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn sorts_without_case_and_drops_duplicates_and_hidden_ones() {
        let families = [
            "Segoe UI",
            " arial ",
            ".AppleSystemUIFont",
            "",
            "segoe ui",
            "Arial",
            "Microsoft YaHei",
        ]
        .map(String::from);
        assert_eq!(
            sort_families(families),
            ["arial", "Microsoft YaHei", "Segoe UI"],
        );
    }

    #[test]
    fn orders_by_utf16_code_units() {
        let families = ["\u{ff21}", "\u{1d400}"].map(String::from);
        assert_eq!(sort_families(families), ["\u{1d400}", "\u{ff21}"]);
    }

    #[test]
    fn reads_the_host_fonts_sorted_and_unique() {
        let families = system_families().unwrap_or_default();
        assert_eq!(sort_families(families.clone()), families);
    }
}
