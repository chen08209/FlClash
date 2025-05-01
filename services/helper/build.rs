fn main() {
    let version = std::env::var("TOKEN").unwrap_or_default();
    println!("cargo:rustc-env=TOKEN={}", version);
    println!("cargo:rerun-if-env-changed=TOKEN");
}
