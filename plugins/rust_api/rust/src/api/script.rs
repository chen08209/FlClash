use flutter_rust_bridge::frb;

/// Runs `main(config)` from a profile override script and returns the JSON the
/// script produced. `config` is the profile as JSON; the result replaces it.
#[frb]
pub fn evaluate_script(script: String, config: String) -> Result<String, String> {
    crate::script::evaluate(&script, &config)
}
