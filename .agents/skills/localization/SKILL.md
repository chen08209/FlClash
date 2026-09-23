---
name: localization
description: Use when changing FlClash UI text, scanning for hardcoded Chinese strings, updating ARB localization, or fixing generated locale output in this repository.
---

# Localization

## When To Use

Use this for localization work in this repository, especially hardcoded UI text in `lib/`, ARB updates, missing translations, or generated `lib/l10n/` output that does not match source ARB values.

Do not use this for README translation sync or manual edits to generated localization Dart.

## Workflow

1. Scan user-facing Dart text before opening many files. `flutter_intl` reads `arb/` and writes `lib/l10n/`:

   ```bash
   rg -n "[\\p{Han}]" lib -g '!lib/l10n/intl/**' -g '!lib/**/generated/**'
   ```

2. Inspect the smallest relevant call sites and nearby ARB keys.
3. Add or update every source ARB:
   - `arb/intl_en.arb`
   - `arb/intl_zh_CN.arb`
   - `arb/intl_ja.arb`
   - `arb/intl_ru.arb`
4. Replace inline strings with existing project accessors:
   - Widgets with `BuildContext`: `context.appLocalizations.key` from `lib/common/context.dart`.
   - Controllers/providers/non-widget code: `currentAppLocalizations.key` from `lib/common/app_localizations.dart`.
5. Regenerate:

   ```bash
   dart run intl_utils:generate
   ```

6. Run `flutter analyze` on the changed Dart files.
7. Re-run the Han-text scan for targeted strings.

## Pitfalls

- If ja/ru still show English, fix ja/ru source ARB values and regenerate. Do not edit generated Dart.
- Ignore `lib/l10n/intl/**` and `lib/**/generated/**` during text scans.
