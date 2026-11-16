pub fn os_major_version() -> u32 {
    #[cfg(target_os = "macos")]
    {
        let version = objc2_foundation::NSProcessInfo::processInfo().operatingSystemVersion();
        u32::try_from(version.majorVersion).unwrap_or(0)
    }
    #[cfg(windows)]
    {
        windows_version().map_or(0, |info| info.dwMajorVersion)
    }
    #[cfg(not(any(target_os = "macos", windows)))]
    0
}

#[cfg(windows)]
pub fn windows_build() -> u32 {
    windows_version().map_or(0, |info| info.dwBuildNumber)
}

#[cfg(windows)]
fn windows_version() -> Option<windows_sys::Win32::System::SystemInformation::OSVERSIONINFOW> {
    use windows_sys::Wdk::System::SystemServices::RtlGetVersion;
    use windows_sys::Win32::System::SystemInformation::OSVERSIONINFOW;

    // GetVersionExW answers with what the manifest declares.
    let mut info: OSVERSIONINFOW = unsafe { std::mem::zeroed() };
    info.dwOSVersionInfoSize = std::mem::size_of::<OSVERSIONINFOW>() as u32;
    (unsafe { RtlGetVersion(&mut info) } >= 0).then_some(info)
}
