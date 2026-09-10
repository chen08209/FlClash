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

## Corner Radii

All corner radii come from `lib/common/shape.dart`. Never write a radius literal in a widget.

The scale is picked by the component's **shortest side**, not by what looks good in isolation. A radius that reads as
a soft card at 64 logical pixels tall reads as a pill at 24 and as a square at 400, so a single radius everywhere is
the wrong kind of consistency.

| Token | Value | Shortest side | Use |
| --- | --- | --- | --- |
| `none` | 0 | - | square edges, and the flat side of a grouped run |
| `xs` | 4 | inset blocks | tiles clipped inside an already rounded surface |
| `sm` | 8 | up to 48 | chips, thumbs, swatches, small square tiles |
| `md` | 16 | up to 64 | interactive chrome: inputs, menus, buttons, popups, FAB |
| `lg` | 20 | 64 to 180 | mid-size cards: dashboard tiles, proxy node cards |
| `xl` | 24 | full-bleed | anything spanning the whole width: list rows, grouped runs, group headers |
| `xxl` | 28 | over 200 | sheets, dialogs, full-screen containers |
| `full` | 1000 | - | pills and circles: tracks, indicators, progress, avatars |

`AppCorner.fit(shortestSide)` applies that table at runtime and is the right call whenever the size comes from a
`LayoutBuilder` or scales with text size. It snaps to the largest token that stays at or under one third of the
shortest side, which is the rule the table encodes.

- `AppCorner` holds the scale as `double`, for `radius:` on `CommonCard` and for arithmetic.
- `AppRadius` mirrors it as `BorderRadius`, plus `all`, `top`, and `vertical` builders.
- `AppShape` mirrors it as `RoundedSuperellipseBorder`, plus `full` (stadium), `circle`, `input`, and the
  `all`/`top`/`vertical`/`of` builders.
- `ThemeData.withAppShapes` in `lib/application.dart` applies the scale to card, dialog, bottom sheet, snack bar,
  chip, menu, input, FAB, navigation indicator, and progress themes. Do not restate those shapes at call sites; in
  particular, leave `InputDecoration.border` unset so inputs inherit `AppShape.input`.

The three tiers between `md` and `xxl` each answer to a different size class, and the split is what keeps one radius
from being wrong for two of them.

`xl` is for a surface that spans the full width. A wide, short strip needs a larger corner than its height alone
suggests, or it stops reading as a card. Everything full-bleed shares this token and must stay on it:
`CommonSelectedListItem`, the profiles card, the outer corners of a grouped run in `DecorationListItem`
(`generateSectionV3`), and the proxy group header in `lib/views/proxies/list.dart`. The value is deliberately under
half the height of a standard row, so nothing gets clamped and every one of them renders at the identical radius no
matter which is taller. This is the one place the one-third rule is knowingly overshot; the width is what carries
it, and `fit()` is not used here.

`lg` is for the mid-size card that is not full-bleed: dashboard tiles and proxy node cards. It exists because `xl`
does not fit all of them. A proxy node card's height follows the user's `ProxyCardType` setting, and at `min` it is
only about 64 tall, which caps its radius at 21 — so `xl` would break on a setting the user can change at any time,
while `lg` clears every one of the three heights. The same value has room to spare on the smallest dashboard tile,
about 177x80, so both surfaces can hold one token instead of branching per size.

Outlined inputs use `AppInputBorder`, not `ShapedInputBorder` from `package:material_ui`. That one subtracts the
floating label's notch from the outline as a two-pixel band along the top edge, which assumes the label sits over a
flat run of border. Any radius from 8 up puts the corner curve under the notch instead, the subtraction takes the
corner with it, and the top edge is left drawn a pixel low. `AppInputBorder` clips the notch region away and paints
the full superellipse through it, so the corner arc is truncated exactly where the notch begins. That is what
Flutter's own `OutlineInputBorder` does by shortening the corner arc's sweep, which is why the framework border
survives large radii and the package one does not. The border needs no `contentPadding` compensation; leave Material's
defaults alone.

Nested radii are derived, never tokens. Concentric corners need `outer = inner + inset`, so name the inset and
compute the outer value: `_cardRadius` in `lib/widgets/popup.dart`, `_kCornerRadius` in `lib/widgets/tab.dart`, and
the selection ring in `lib/widgets/palette.dart` all do this. Adding an intermediate token to spell one of these out
is what makes a scale grow without bound.

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
