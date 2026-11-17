fn main() {
    println!("cargo:rerun-if-env-changed=CONCORD_LIB_DIR");
    if let Ok(dir) = std::env::var("CONCORD_LIB_DIR") {
        println!("cargo:rustc-link-search=native={dir}");
    }
}
