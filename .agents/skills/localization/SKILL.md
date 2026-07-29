---
name: localization
description: Use when changing FlClash UI text, scanning for hardcoded Chinese strings, updating ARB localization, or fixing generated locale output in this repository.
---

# Localization

## When To Use

Use this for localization work inside `/Users/Shared/follow/FlClash`, especially hardcoded UI text in `lib/`, ARB updates, missing translations, or generated `lib/l10n/` output that does not match source ARB values.

Do not use this for README translation sync or manual edits to generated localization Dart.

## Workflow

1. Confirm `pubspec.yaml` still uses `flutter_intl`, source ARBs under `arb/`, and generated output under `lib/l10n/`.
2. Scan user-facing Dart text before opening many files:

   ```bash
   rg -n "[\\p{Han}]" lib -g '!lib/l10n/intl/**' -g '!lib/**/generated/**'
   ```

3. Inspect the smallest relevant call sites and nearby ARB keys.
4. Add or update every source ARB:
   - `arb/intl_en.arb`
   - `arb/intl_zh_CN.arb`
   - `arb/intl_ja.arb`
   - `arb/intl_ru.arb`
5. Replace inline strings with existing project accessors:
   - Widgets with `BuildContext`: `context.appLocalizations.key` from `common.dart`.
   - Controllers/providers/non-widget code: `currentAppLocalizations.key` from `app_localizations.dart`.
6. Regenerate:

   ```bash
   dart run intl_utils:generate
   ```

7. Verify changed Dart files with `flutter analyze` when practical.
8. Re-run the Han-text scan for targeted strings.

## Pitfalls

- If ja/ru still show English, fix ja/ru source ARB values and regenerate. Do not edit generated Dart.
- Ignore `lib/l10n/intl/**` and `lib/**/generated/**` during text scans.
- If generator or analyzer hits local cache permission friction, rerun serially before treating it as a code issue.
