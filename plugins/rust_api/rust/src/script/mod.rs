mod console;

use rquickjs::{CatchResultExt, Context, Function, Runtime, Value};
use std::time::{Duration, Instant};

const ENTRY: &str = "main";
// A profile script is a pure transform that finishes in milliseconds. Anything
// still running after this is a loop the user cannot otherwise escape, since
// the evaluation blocks the profile from being applied.
const TIMEOUT: Duration = Duration::from_secs(10);
// QuickJS grows its heap on demand; the ceiling only has to be out of reach of
// a config, which is megabytes at worst.
const MEMORY_LIMIT: usize = 256 * 1024 * 1024;

pub fn evaluate(script: &str, config: &str) -> Result<String, String> {
    evaluate_within(script, config, TIMEOUT)
}

fn evaluate_within(script: &str, config: &str, timeout: Duration) -> Result<String, String> {
    let runtime = Runtime::new().map_err(|e| format!("{e}"))?;
    runtime.set_memory_limit(MEMORY_LIMIT);
    let deadline = Instant::now() + timeout;
    runtime.set_interrupt_handler(Some(Box::new(move || Instant::now() >= deadline)));

    let context = Context::full(&runtime).map_err(|e| format!("{e}"))?;
    context.with(|ctx| {
        console::install(&ctx).catch(&ctx).map_err(describe)?;
        ctx.eval::<Value, _>(script.as_bytes())
            .catch(&ctx)
            .map_err(describe)?;
        // Evaluated as an expression rather than read off `globals()` because a
        // top-level `const main = ...` is a global lexical binding, not a
        // property of globalThis.
        let entry: Function = ctx
            .eval(ENTRY.as_bytes())
            .map_err(|_| format!("script does not define {ENTRY}()"))?;
        let parsed: Value = ctx
            .json_parse(config)
            .catch(&ctx)
            .map_err(|_| "profile is not valid JSON".to_owned())?;
        let result: Value = entry.call((parsed,)).catch(&ctx).map_err(describe)?;
        let result = match result.as_promise() {
            Some(promise) => promise.finish::<Value>().catch(&ctx).map_err(|error| {
                match error {
                    // `finish` drains the job queue and gives up once it is empty,
                    // which only happens for a promise waiting on a timer or I/O.
                    rquickjs::CaughtError::Error(rquickjs::Error::WouldBlock) => {
                        format!("{ENTRY}() returned a Promise that did not settle")
                    }
                    other => describe(other),
                }
            })?,
            None => result,
        };
        if result.is_undefined() || result.is_null() {
            return Ok(config.to_owned());
        }
        let json = ctx
            .json_stringify(result)
            .catch(&ctx)
            .map_err(describe)?
            .ok_or_else(|| format!("{ENTRY}() returned a value that is not JSON"))?;
        json.to_string().map_err(|e| format!("{e}"))
    })
}

fn describe(error: rquickjs::CaughtError<'_>) -> String {
    match error {
        rquickjs::CaughtError::Exception(exception) => {
            let message = exception.message().unwrap_or_else(|| exception.to_string());
            match exception.stack() {
                Some(stack) if !stack.trim().is_empty() => format!("{message}\n{}", stack.trim()),
                _ => message,
            }
        }
        other => other.to_string(),
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use serde_json::{json, Value as Json};

    fn run(script: &str, config: Json) -> Result<Json, String> {
        evaluate(script, &config.to_string()).map(|out| serde_json::from_str(&out).unwrap())
    }

    #[test]
    fn returns_the_object_main_produced() {
        let result = run(
            "function main(config) { config.mode = 'global'; return config }",
            json!({ "mode": "rule" }),
        )
        .unwrap();

        assert_eq!(result, json!({ "mode": "global" }));
    }

    #[test]
    fn accepts_a_lexically_declared_arrow_function_entry() {
        let result = run(
            "const main = (config) => { return config; }",
            json!({ "mode": "rule" }),
        )
        .unwrap();

        assert_eq!(result, json!({ "mode": "rule" }));
    }

    #[test]
    fn keeps_the_profile_when_main_returns_nothing() {
        let result = run("function main(config) {}", json!({ "mode": "rule" })).unwrap();

        assert_eq!(result, json!({ "mode": "rule" }));
    }

    #[test]
    fn resolves_a_promise_main_returns() {
        let result = run(
            "async function main(config) { config.mode = 'global'; return config }",
            json!({ "mode": "rule" }),
        )
        .unwrap();

        assert_eq!(result, json!({ "mode": "global" }));
    }

    #[test]
    fn reports_the_rejection_of_a_promise_main_returns() {
        let error = run(
            "async function main() { throw new Error('bad profile') }",
            json!({}),
        )
        .unwrap_err();

        assert!(error.contains("bad profile"), "{error}");
    }

    #[test]
    fn reports_a_promise_that_never_settles() {
        let error = run(
            "function main() { return new Promise(() => {}) }",
            json!({}),
        )
        .unwrap_err();

        assert!(error.contains("did not settle"), "{error}");
    }

    #[test]
    fn reports_a_missing_entry_point() {
        let error = run("const value = 1", json!({})).unwrap_err();

        assert!(error.contains("main()"), "{error}");
    }

    #[test]
    fn reports_the_message_and_stack_of_a_thrown_error() {
        let error = run(
            "function main() { throw new Error('bad profile') }",
            json!({}),
        )
        .unwrap_err();

        assert!(error.contains("bad profile"), "{error}");
        assert!(error.contains("main"), "{error}");
    }

    #[test]
    fn reports_a_syntax_error_with_its_location() {
        let error = run("function main( {", json!({})).unwrap_err();

        assert!(error.contains(":1:"), "{error}");
    }

    #[test]
    fn stops_a_script_that_never_finishes() {
        let started = Instant::now();
        let error = evaluate_within(
            "function main() { while (true) {} }",
            "{}",
            Duration::from_millis(100),
        )
        .unwrap_err();

        assert!(!error.is_empty());
        assert!(started.elapsed() < Duration::from_secs(5));
    }

    #[test]
    fn console_calls_do_not_stop_a_script() {
        let result = run(
            "function main(config) { console.log('a', 1); console.error({}); return config }",
            json!({ "mode": "rule" }),
        )
        .unwrap();

        assert_eq!(result, json!({ "mode": "rule" }));
    }

    #[test]
    fn supports_the_language_features_profile_scripts_use() {
        let script = r#"
            const regions = new Map([['HK', '🇭🇰']]);
            function main(config) {
              const names = [...new Set(config.proxies.map((proxy) => proxy.name))];
              const flag = regions.get('HK') ?? '';
              return {
                ...config,
                names: names.map((name) => `${flag} ${name}`.trim()),
                first: config.proxies?.[0]?.name ?? null,
                entries: Object.fromEntries(names.map((name, index) => [name, index])),
              };
            }
        "#;

        let result = run(
            script,
            json!({ "proxies": [{ "name": "a" }, { "name": "b" }, { "name": "a" }] }),
        )
        .unwrap();

        assert_eq!(result["names"], json!(["🇭🇰 a", "🇭🇰 b"]));
        assert_eq!(result["first"], json!("a"));
        assert_eq!(result["entries"], json!({ "a": 0, "b": 1 }));
    }

    fn overwrite_fixture() -> Json {
        let script = include_str!("../../tests/fixtures/profile_script.js");
        let config = include_str!("../../tests/fixtures/profile_config.json");

        serde_json::from_str(&evaluate(script, config).unwrap()).unwrap()
    }

    #[test]
    fn runs_a_profile_overwrite_end_to_end() {
        let result = overwrite_fixture();
        let proxies = result["proxies"].as_array().unwrap();
        let groups = result["proxy-groups"].as_array().unwrap();
        let rules = result["rules"].as_array().unwrap();

        assert_eq!(proxies.len(), 10);
        assert_eq!(groups.len(), 17);
        assert_eq!(rules.len(), 12);
        assert_eq!(rules.last().unwrap(), &json!("MATCH,手动选择"));
    }

    #[test]
    fn the_overwrite_renames_nodes_and_rewrites_the_chains_through_them() {
        let result = overwrite_fixture();
        let proxies = result["proxies"].as_array().unwrap();
        let named = |name: &str| {
            proxies
                .iter()
                .find(|proxy| proxy["name"] == json!(name))
                .unwrap_or_else(|| panic!("{name} is missing"))
        };

        assert!(proxies
            .iter()
            .all(|proxy| proxy["name"] != json!("官网 https://example.com")));
        assert_eq!(named("🇬🇧 英国 01")["dialer-proxy"], json!("🇭🇰 香港 01"));
        assert_eq!(named("🏳️ 其他 02")["dialer-proxy"], json!(null));
        assert_eq!(named("🇭🇰 香港 02 | 2x")["server"], json!("hk2.example.com"));
    }

    #[test]
    fn the_overwrite_merges_dns_instead_of_replacing_it() {
        let dns = overwrite_fixture()["dns"].clone();

        assert_eq!(dns["enhanced-mode"], json!("fake-ip"));
        assert_eq!(dns["nameserver"], json!(["223.5.5.5", "119.29.29.29"]));
        assert_eq!(
            dns["nameserver-policy"]["+.example.com"],
            json!("223.5.5.5")
        );
        assert_eq!(dns["nameserver-policy"]["+.internal"], json!("system://"));
    }
}
