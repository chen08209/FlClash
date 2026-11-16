---
name: localization
description: Use when changing FlClash UI text, scanning for hardcoded Chinese strings, updating ARB localization, or fixing generated locale output in this repository.
---

# Localization

## When To Use

Use this for localization work in this repository, especially hardcoded UI text in `lib/`, ARB updates, missing translations, or generated `lib/l10n/` output that does not match source ARB values.

Do not use this for README translation sync or manual edits to generated localization Dart.

## Workflow

1. Scan user-facing Dart text before opening many files. Flutter's `gen-l10n` reads `arb/` and writes `lib/l10n/`
   with the options in `l10n.yaml`:

   ```bash
   rg -n "[\\p{Han}]" lib -g '!lib/l10n/**' -g '!lib/**/generated/**'
   ```

2. Inspect the smallest relevant call sites and nearby ARB keys.
3. Add or update every source ARB:
   - `arb/intl_en.arb`
   - `arb/intl_zh.arb`
   - `arb/intl_ja.arb`
   - `arb/intl_ru.arb`
   - `arb/intl_fr.arb`
   - `arb/intl_es.arb`
   - `arb/intl_ko.arb`
4. Replace inline strings with existing project accessors:
   - Widgets with `BuildContext`: `context.appLocalizations.key` from `lib/common/context.dart`.
   - Controllers/providers/non-widget code: `currentAppLocalizations.key` from `lib/common/app_localizations.dart`.
5. Regenerate (`flutter pub get` also does, since `pubspec.yaml` sets `generate: true`):

   ```bash
   flutter gen-l10n
   ```

   A message with more than one placeholder also needs `"@key": {"placeholders": {...}}` in `arb/intl_en.arb`, naming
   them in the order the text first uses them; without it `gen-l10n` orders the parameters alphabetically.

6. Run `flutter analyze --no-fatal-infos` and `flutter test test/l10n test/lint/dynamic_message_key_test.dart`. The
   lint test checks that every locale carries the same keys, that every message with several placeholders declares
   their order, and that no `Intl.message` builds a key at runtime; labels for enum values go through the switches in
   `lib/common/l10n_labels.dart`, as the ARB section of `.agents/rules.md` explains.
7. Re-run the Han-text scan for targeted strings.

## Pitfalls

- A locale that still shows English lacks the key or carries an English value in its source ARB; fix that ARB and
  regenerate. Do not edit generated Dart.
- `gen-l10n` prints the untranslated messages of each locale; a non-zero count is a key some ARB lacks.
- Ignore `lib/l10n/**` and `lib/**/generated/**` during text scans.
