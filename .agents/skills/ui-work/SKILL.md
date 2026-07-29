---
name: ui-work
description: Use when changing FlClash Flutter UI, widgets, screens, Material You styling, navigation surfaces, or user-facing interactions.
---

# UI Work

## When To Use

Use this for user-facing Flutter UI changes in `lib/`, including widgets, screens, navigation surfaces, settings rows, dialogs, and interaction behavior.

## Workflow

1. Locate existing nearby widgets and reuse their patterns before adding new abstractions.
2. Follow current Material You and Surfboard-like visual conventions.
3. Use existing providers, notifiers, and helpers where possible.
4. Keep `child:` last in widget constructors.
5. Prefer `const` constructors and final locals.
6. Localize user-facing text through ARB; use `localization` when text changes are non-trivial.
7. Add focused widget tests when behavior changes, especially for rendering states, taps, scrolling, and empty/error states.
8. Run targeted verification:

   ```bash
   flutter analyze
   flutter test test/widgets/
   ```

## Pitfalls

- Do not introduce a new visual system for one screen.
- Do not manually edit generated localization or provider files.
- Avoid broad layout rewrites unless the requested change requires them.
