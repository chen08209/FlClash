---
name: ui-work
description: Use when changing FlClash Flutter UI, widgets, screens, Material You styling, navigation surfaces, async feedback, or user-facing interactions.
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
8. For asynchronous controls, define separately:
   - authoritative provider/domain state;
   - display-only state such as a minimum progress duration;
   - tap policy while work or display holds are active;
   - failure/disposal cleanup, normally in `finally` for animations and timers.
9. Run targeted verification:

   ```bash
   flutter analyze
   flutter test test/widgets/
   ```

## Pitfalls

- Do not introduce a new visual system for one screen.
- Do not manually edit generated localization or provider files.
- Avoid broad layout rewrites unless the requested change requires them.
- Do not mutate provider/domain state merely to smooth a transition. Keep presentation holds local and let real errors
  bypass them immediately.
- Do not leave loading animations active when callbacks throw. Test the exception path, not only the successful tap.

## Current Interaction Examples

- `CoreStatusButton` watches `coreStatusProvider` but keeps its 600-millisecond connecting hold locally. Taps are ignored
  during the hold or genuine connecting state; disconnected cancels the hold immediately.
- Proxy delay testing writes `0` while pending, the measured delay on success, and `-1` on failure. `DelayTestButton` resets
  its animation in `finally`.
