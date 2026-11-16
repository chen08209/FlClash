pub fn start_system_proxy(
    port: u32,
    bypass_domain: Vec<String>,
    pac_script: Option<String>,
) -> bool {
    crate::proxy::start(port, &bypass_domain, pac_script.as_deref())
}

pub fn stop_system_proxy() -> bool {
    crate::proxy::stop()
}
