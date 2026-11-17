fn main() {
    println!("cargo:rerun-if-env-changed=CONCORD_LIB_DIR");
    if let Ok(dir) = std::env::var("CONCORD_LIB_DIR") {
        println!("cargo:rustc-link-search=native={dir}");
    }
    // The root helper runs from the app's native library directory, next to libconcord.so.
    println!("cargo:rustc-link-arg-bins=-Wl,-rpath,$ORIGIN");
}
