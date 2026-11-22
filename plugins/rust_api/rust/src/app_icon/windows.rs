use super::Owner;
use std::path::{Path, PathBuf};

const PACKAGE_ROOT: &str = "WindowsApps";
const MANIFEST: &str = "AppxManifest.xml";
const LOGO_DESIGN_SIZE: u32 = 44;

pub enum Source {
    Executable,
    PackageLogo,
}

/// A packaged app's processes run from under `WindowsApps`, where the shell
/// draws the tile logo its manifest names rather than the executable's icon.
pub fn owner(process_path: &Path, size: u32) -> Option<Owner<Source>> {
    if let Some((package, executable)) = split_package_path(process_path) {
        let file = package_logo(&package, &executable, size)?;
        return Some(Owner {
            stamp: file.clone(),
            key: file,
            source: Source::PackageLogo,
        });
    }
    process_path.is_file().then(|| Owner {
        key: process_path.to_path_buf(),
        stamp: process_path.to_path_buf(),
        source: Source::Executable,
    })
}

#[cfg(windows)]
pub fn render(owner: &Owner<Source>, size: u32) -> Result<Option<Vec<u8>>, String> {
    match owner.source {
        Source::PackageLogo => std::fs::read(&owner.key)
            .map(Some)
            .map_err(|error| format!("{}: {error}", owner.key.display())),
        Source::Executable => native::extract(&owner.key, 0, size),
    }
}

#[cfg(windows)]
pub fn render_default(size: u32) -> Result<Option<Vec<u8>>, String> {
    let (file, index) = native::stock_application_icon()?;
    native::extract(&file, index, size)
}

fn package_logo(package: &Path, executable: &str, size: u32) -> Option<PathBuf> {
    let manifest = std::fs::read_to_string(package.join(MANIFEST)).ok()?;
    best_logo(package, &application_logo(&manifest, executable)?, size)
}

fn split_package_path(process_path: &Path) -> Option<(PathBuf, String)> {
    let path = process_path.to_string_lossy();
    let parts: Vec<&str> = path.split(['\\', '/']).collect();
    let root = parts
        .iter()
        .position(|part| part.eq_ignore_ascii_case(PACKAGE_ROOT))?;
    let executable = parts.get(root + 2..).filter(|rest| !rest.is_empty())?;
    Some((
        PathBuf::from(parts[..root + 2].join("\\")),
        executable.join("\\"),
    ))
}

/// The `Square44x44Logo` of `executable`'s `<Application>`, else the package `<Logo>`.
fn application_logo(manifest: &str, executable: &str) -> Option<String> {
    let mut rest = manifest;
    while let Some(start) = find_tag(rest, "Application") {
        let element = &rest[start..];
        let end = element[1..]
            .find("Application>")
            .map_or(element.len(), |end| end + 1);
        let element = &element[..end];
        let matches = attribute(tag(element), "Executable")
            .is_some_and(|value| same_relative_path(&value, executable));
        if matches {
            if let Some(logo) = find_tag(element, "VisualElements")
                .and_then(|visual| attribute(tag(&element[visual..]), "Square44x44Logo"))
            {
                return Some(logo);
            }
            break;
        }
        rest = &rest[start + 1..];
    }
    let open = manifest.find("<Logo>")? + "<Logo>".len();
    let close = manifest[open..].find("</Logo>")?;
    Some(manifest[open..open + close].trim().to_owned())
}

fn find_tag(text: &str, name: &str) -> Option<usize> {
    let mut offset = 0;
    while let Some(found) = text[offset..].find('<') {
        let start = offset + found;
        let after = &text[start + 1..];
        let local = after
            .split(|c: char| c.is_whitespace() || c == '>' || c == '/')
            .next()
            .unwrap_or_default();
        if local.rsplit(':').next() == Some(name) {
            return Some(start);
        }
        offset = start + 1;
    }
    None
}

fn tag_end(element: &str) -> usize {
    element.find('>').map_or(element.len(), |end| end + 1)
}

fn tag(element: &str) -> &str {
    &element[..tag_end(element)]
}

fn attribute(tag: &str, name: &str) -> Option<String> {
    let mut offset = 0;
    while let Some(found) = tag[offset..].find(name) {
        let start = offset + found;
        let before = tag[..start].chars().next_back();
        let after = tag[start + name.len()..].trim_start();
        if before.is_some_and(char::is_whitespace) {
            if let Some(value) = after.strip_prefix('=') {
                let value = value.trim_start();
                let quote = value.chars().next()?;
                if quote == '"' || quote == '\'' {
                    let value = &value[1..];
                    return Some(value[..value.find(quote)?].to_owned());
                }
            }
        }
        offset = start + name.len();
    }
    None
}

fn same_relative_path(a: &str, b: &str) -> bool {
    let normal = |path: &str| {
        path.replace('/', "\\")
            .trim_start_matches(".\\")
            .to_lowercase()
    };
    normal(a) == normal(b)
}

/// The variant of a manifest image the shell would load for `size` pixels:
/// the smallest `targetsize` at least that big, preferring the unplated
/// form, then the closest `scale`, then the file as named.
fn best_logo(package: &Path, logo: &str, size: u32) -> Option<PathBuf> {
    let named = package.join(logo.replace('\\', std::path::MAIN_SEPARATOR_STR));
    let dir = named.parent()?;
    let stem = named.file_stem()?.to_string_lossy().to_lowercase();
    let extension = named.extension()?.to_string_lossy().to_lowercase();
    let mut best: Option<(Variant, PathBuf)> = None;
    for entry in std::fs::read_dir(dir).ok()?.flatten() {
        let name = entry.file_name().to_string_lossy().to_lowercase();
        let Some(variant) = Variant::parse(&name, &stem, &extension) else {
            continue;
        };
        if best
            .as_ref()
            .is_none_or(|(current, _)| variant.better_than(current, size))
        {
            best = Some((variant, entry.path()));
        }
    }
    best.map(|(_, file)| file)
        .or_else(|| named.is_file().then_some(named))
}

#[derive(Debug, PartialEq)]
struct Variant {
    pixels: u32,
    target_size: bool,
    unplated: bool,
}

impl Variant {
    fn parse(name: &str, stem: &str, extension: &str) -> Option<Self> {
        let qualifiers = name
            .strip_prefix(stem)?
            .strip_prefix('.')?
            .strip_suffix(extension)?
            .strip_suffix('.')?;
        let mut variant = Variant {
            pixels: 0,
            target_size: false,
            unplated: false,
        };
        for qualifier in qualifiers.split('_') {
            if let Some(pixels) = qualifier.strip_prefix("targetsize-") {
                variant.pixels = pixels.parse().ok()?;
                variant.target_size = true;
            } else if let Some(scale) = qualifier.strip_prefix("scale-") {
                variant.pixels = LOGO_DESIGN_SIZE * scale.parse::<u32>().ok()? / 100;
            } else if qualifier == "altform-unplated" {
                variant.unplated = true;
            } else {
                return None;
            }
        }
        (variant.pixels > 0).then_some(variant)
    }

    fn better_than(&self, other: &Self, size: u32) -> bool {
        let rank = |variant: &Self| {
            let fits = variant.pixels >= size;
            let distance = variant.pixels.abs_diff(size);
            (
                variant.target_size,
                variant.unplated,
                fits,
                std::cmp::Reverse(distance),
            )
        };
        rank(self) > rank(other)
    }
}

#[cfg(windows)]
mod native {
    use super::super::png;
    use std::mem::{size_of, zeroed};
    use std::os::windows::ffi::OsStrExt;
    use std::path::{Path, PathBuf};
    use std::ptr::null_mut;
    use windows_sys::Win32::Graphics::Gdi::{
        CreateCompatibleDC, DeleteDC, DeleteObject, GetDIBits, GetObjectW, BITMAP, BITMAPINFO,
        BITMAPINFOHEADER, BI_RGB, DIB_RGB_COLORS, HBITMAP, HDC,
    };
    use windows_sys::Win32::UI::Shell::{
        SHDefExtractIconW, SHGetStockIconInfo, SHGSI_ICONLOCATION, SHSTOCKICONINFO,
        SIID_APPLICATION,
    };
    use windows_sys::Win32::UI::WindowsAndMessaging::{DestroyIcon, GetIconInfo, HICON, ICONINFO};

    const S_OK: i32 = 0;

    pub fn stock_application_icon() -> Result<(PathBuf, i32), String> {
        let mut info = SHSTOCKICONINFO {
            cbSize: size_of::<SHSTOCKICONINFO>() as u32,
            ..Default::default()
        };
        // SAFETY: `info` is sized and outlives the call.
        let hr = unsafe { SHGetStockIconInfo(SIID_APPLICATION, SHGSI_ICONLOCATION, &mut info) };
        if hr != S_OK {
            return Err(format!("SHGetStockIconInfo: {hr:#x}"));
        }
        let length = info
            .szPath
            .iter()
            .position(|&c| c == 0)
            .unwrap_or(info.szPath.len());
        Ok((
            PathBuf::from(String::from_utf16_lossy(&info.szPath[..length])),
            info.iIcon,
        ))
    }

    pub fn extract(file: &Path, index: i32, size: u32) -> Result<Option<Vec<u8>>, String> {
        let wide: Vec<u16> = file.as_os_str().encode_wide().chain([0]).collect();
        let mut icon: HICON = null_mut();
        // SAFETY: `wide` is NUL-terminated and `icon` receives one handle.
        let hr = unsafe { SHDefExtractIconW(wide.as_ptr(), index, 0, &mut icon, null_mut(), size) };
        if hr != S_OK || icon.is_null() {
            return Ok(None);
        }
        let rgba = rgba(icon);
        // SAFETY: the handle came from SHDefExtractIconW and is used no more.
        unsafe { DestroyIcon(icon) };
        Ok(rgba.map(|(width, height, pixels)| png::encode(width, height, &pixels)))
    }

    /// Straight-alpha RGBA of the icon's color bitmap; an icon drawn before
    /// alpha channels existed takes its transparency from the mask.
    fn rgba(icon: HICON) -> Option<(u32, u32, Vec<u8>)> {
        // SAFETY: ICONINFO is plain data that GetIconInfo fills.
        let mut info: ICONINFO = unsafe { zeroed() };
        // SAFETY: `icon` is a live handle.
        if unsafe { GetIconInfo(icon, &mut info) } == 0 {
            return None;
        }
        // SAFETY: a memory DC compatible with the screen.
        let dc = unsafe { CreateCompatibleDC(null_mut()) };
        let pixels = (!info.hbmColor.is_null())
            .then(|| bits(dc, info.hbmColor))
            .flatten()
            .and_then(|(width, height, mut color)| {
                if color.as_chunks::<4>().0.iter().all(|pixel| pixel[3] == 0) {
                    let (_, _, mask) = bits(dc, info.hbmMask)?;
                    let masks = mask.as_chunks::<4>().0;
                    for (pixel, mask) in color.as_chunks_mut::<4>().0.iter_mut().zip(masks) {
                        pixel[3] = if mask[0] == 0 { 0xff } else { 0 };
                    }
                }
                for pixel in color.as_chunks_mut::<4>().0 {
                    pixel.swap(0, 2);
                }
                Some((width, height, color))
            });
        // SAFETY: GetIconInfo hands the caller both bitmaps to delete.
        unsafe {
            DeleteDC(dc);
            DeleteObject(info.hbmColor);
            DeleteObject(info.hbmMask);
        }
        pixels
    }

    fn bits(dc: HDC, bitmap: HBITMAP) -> Option<(u32, u32, Vec<u8>)> {
        // SAFETY: BITMAP is plain data that GetObjectW fills.
        let mut header: BITMAP = unsafe { zeroed() };
        let read =
            unsafe { GetObjectW(bitmap, size_of::<BITMAP>() as i32, (&raw mut header).cast()) };
        if read == 0 || header.bmWidth <= 0 || header.bmHeight <= 0 {
            return None;
        }
        let (width, height) = (header.bmWidth as u32, header.bmHeight as u32);
        let mut info = BITMAPINFO {
            bmiHeader: BITMAPINFOHEADER {
                biSize: size_of::<BITMAPINFOHEADER>() as u32,
                biWidth: header.bmWidth,
                biHeight: -header.bmHeight,
                biPlanes: 1,
                biBitCount: 32,
                biCompression: BI_RGB,
                // SAFETY: the remaining fields are plain integers.
                ..unsafe { zeroed() }
            },
            // SAFETY: an RGBQUAD of zeros.
            bmiColors: unsafe { zeroed() },
        };
        let mut pixels = vec![0u8; (width * height * 4) as usize];
        // SAFETY: `pixels` holds `height` rows of `width` 32-bit pixels.
        let lines = unsafe {
            GetDIBits(
                dc,
                bitmap,
                0,
                height,
                pixels.as_mut_ptr().cast(),
                &mut info,
                DIB_RGB_COLORS,
            )
        };
        (lines == height as i32).then_some((width, height, pixels))
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    const MANIFEST: &str = r#"<?xml version="1.0" encoding="utf-8"?>
<Package xmlns:uap="http://schemas.microsoft.com/appx/manifest/uap/windows10">
  <Properties><Logo>Assets\StoreLogo.png</Logo></Properties>
  <Applications>
    <Application Id="Other" Executable="other.exe">
      <uap:VisualElements Square44x44Logo="Assets\Other.png" />
    </Application>
    <Application Id="App" Executable="App\Terminal.exe" EntryPoint="Windows.FullTrustApplication">
      <uap:VisualElements DisplayName="Terminal" Square150x150Logo="Assets\Square150.png"
        Square44x44Logo='Assets\Square44x44Logo.png' />
    </Application>
  </Applications>
</Package>"#;

    #[test]
    fn splits_a_packaged_executable_from_its_package() {
        let (package, executable) = split_package_path(Path::new(
            r"C:\Program Files\WindowsApps\Microsoft.WindowsTerminal_1.21_x64__8wekyb3d8bbwe\App\Terminal.exe",
        ))
        .unwrap();
        assert_eq!(
            package,
            PathBuf::from(
                r"C:\Program Files\WindowsApps\Microsoft.WindowsTerminal_1.21_x64__8wekyb3d8bbwe"
            ),
        );
        assert_eq!(executable, r"App\Terminal.exe");
        assert_eq!(
            split_package_path(Path::new(r"C:\Windows\explorer.exe")),
            None
        );
    }

    #[test]
    fn takes_the_logo_of_the_application_that_runs_the_executable() {
        assert_eq!(
            application_logo(MANIFEST, r"app\terminal.exe").as_deref(),
            Some(r"Assets\Square44x44Logo.png"),
        );
        assert_eq!(
            application_logo(MANIFEST, "other.exe").as_deref(),
            Some(r"Assets\Other.png")
        );
        assert_eq!(
            application_logo(MANIFEST, "missing.exe").as_deref(),
            Some(r"Assets\StoreLogo.png")
        );
    }

    #[test]
    fn prefers_an_unplated_target_size_that_covers_the_request() {
        let dir = std::env::temp_dir().join(format!("app_icon_appx_{}", std::process::id()));
        let assets = dir.join("Assets");
        std::fs::create_dir_all(&assets).unwrap();
        for name in [
            "Square44x44Logo.scale-200.png",
            "Square44x44Logo.targetsize-32.png",
            "Square44x44Logo.targetsize-48.png",
            "Square44x44Logo.targetsize-48_altform-unplated.png",
            "Square44x44Logo.targetsize-256_altform-unplated.png",
            "Square44x44Logo.targetsize-48_contrast-black.png",
        ] {
            std::fs::write(assets.join(name), b"").unwrap();
        }
        let best = best_logo(&dir, r"Assets\Square44x44Logo.png", 40).unwrap();
        assert_eq!(
            best.file_name().unwrap(),
            "Square44x44Logo.targetsize-48_altform-unplated.png"
        );
        std::fs::remove_dir_all(dir).unwrap();
    }

    #[test]
    fn a_packaged_app_logo_is_the_variant_for_the_size_asked_for() {
        let dir = std::env::temp_dir().join(format!("app_icon_appx_size_{}", std::process::id()));
        let assets = dir.join("Assets");
        std::fs::create_dir_all(&assets).unwrap();
        std::fs::write(dir.join(super::MANIFEST), MANIFEST).unwrap();
        for pixels in [32, 48, 64, 96] {
            let name = format!("Square44x44Logo.targetsize-{pixels}_altform-unplated.png");
            std::fs::write(assets.join(name), b"").unwrap();
        }
        let logo = |size| {
            package_logo(&dir, r"App\Terminal.exe", size)
                .unwrap()
                .file_name()
                .unwrap()
                .to_string_lossy()
                .into_owned()
        };
        assert_eq!(
            logo(52),
            "Square44x44Logo.targetsize-64_altform-unplated.png"
        );
        assert_eq!(
            logo(104),
            "Square44x44Logo.targetsize-96_altform-unplated.png"
        );
        std::fs::remove_dir_all(dir).unwrap();
    }

    #[test]
    fn scales_rank_by_the_pixels_they_give() {
        let at = |name: &str| Variant::parse(name, "logo", "png").unwrap();
        assert_eq!(at("logo.scale-200.png").pixels, 88);
        assert!(at("logo.scale-100.png").better_than(&at("logo.scale-200.png"), 40));
        assert!(at("logo.scale-200.png").better_than(&at("logo.scale-100.png"), 64));
        assert_eq!(Variant::parse("logo.png", "logo", "png"), None);
    }
}
