use rquickjs::function::Rest;
use rquickjs::{Ctx, Function, Object, Result, Value};

const LEVELS: [&str; 6] = ["log", "info", "warn", "error", "debug", "trace"];

/// Scripts written for other clients log while they work. Without a `console`
/// the first such call aborts the whole profile, so provide one.
pub fn install(ctx: &Ctx<'_>) -> Result<()> {
    let console = Object::new(ctx.clone())?;
    for level in LEVELS {
        let print = Function::new(ctx.clone(), move |ctx, args| write(level, ctx, args))?;
        console.set(level, print)?;
    }
    ctx.globals().set("console", console)
}

fn write<'js>(level: &str, ctx: Ctx<'js>, args: Rest<Value<'js>>) {
    let line = args
        .iter()
        .map(|value| format(&ctx, value))
        .collect::<Vec<_>>()
        .join(" ");
    eprintln!("[script:{level}] {line}");
}

fn format<'js>(ctx: &Ctx<'js>, value: &Value<'js>) -> String {
    if let Some(text) = value.as_string() {
        return text.to_string().unwrap_or_default();
    }
    match ctx.json_stringify(value.clone()) {
        Ok(Some(json)) => json.to_string().unwrap_or_default(),
        _ => format!("{value:?}"),
    }
}
