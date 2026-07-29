# Rules

These are repository coding and testing conventions. Codex command permission rules belong in `.codex/rules/*.rules`; see `.agents/agent-config.md` before adding those.

## Dart and Flutter Style

`analysis_options.yaml` enforces these non-default rules:

- `prefer_single_quotes: true`: always use single quotes.
- `require_trailing_commas: true`: use trailing commas in multi-line argument lists.
- `sort_child_properties_last: true`: `child:` must be the last named parameter.
- `avoid_print: true`: do not use `print()` calls.
- `prefer_const_constructors: true` and `prefer_const_declarations: true`.
- `prefer_final_locals: true` and `prefer_final_in_for_each: true`.
- `always_declare_return_types: true`.

Generated directories are excluded from analysis:

- `build/**`
- `lib/l10n/intl/**`
- `lib/**/generated/**`
- `plugins/**`

## Testing Rules

Use `CoreController.test(mock)` to inject a mocked `CoreHandlerInterface`. Call `CoreController.resetInstance()` in `tearDown` to clean up the singleton between tests.

Register fallback values for freezed params used with `any()` matchers.

Use `ProviderContainer` directly for simple Riverpod provider tests. The generated Riverpod `update()` method takes a callback:

```dart
notifier.update((state) => newValue);
```

When testing freezed models with nested objects, always round-trip through `jsonEncode` and `jsonDecode`. Direct `fromJson(toJson())` fails for nested freezed types because `toJson()` stores child objects directly instead of maps.

## Generated Code

Do not manually edit generated files under:

- `lib/models/generated/`
- `lib/providers/generated/`
- `lib/database/generated/`
- `lib/l10n/intl/`

After schema, model, or provider changes, run build generation and include focused tests when behavior changes.
