---
name: ui-work
description: Use when changing FlClash Flutter UI, widgets, screens, Material You styling, navigation surfaces, async feedback, or user-facing interactions.
---

# UI Work

## When To Use

Use this for user-facing Flutter UI changes in `lib/`, including widgets, screens, navigation surfaces, settings rows,
dialogs, and interaction behavior.

## Conventions

- Reuse the patterns of nearby widgets, providers, notifiers, and helpers before adding an abstraction, and keep to the
  Material You, Surfboard-like look the rest of the app has. Do not introduce a visual system for one screen or rewrite
  a layout the request does not need.
- `.agents/rules.md` is binding here: the lint set (`child:` last, `const`, final locals), the superellipse corner API,
  and the widget-test facts under Testing Rules (`pumpAndSettle` never returns on `EditorView`, `dispose()` must not
  await, auto-dispose providers need a container-level hold, platform decisions are passed in as parameters).
- Settings screens are built from the `ConfigToggleItem` family in `lib/widgets/config_item.dart`; the Settings Rows
  section of `.agents/architecture.md` says when a file-local helper or a named widget is warranted.
- Every icon lives in `lib/icons/`, never the Material `Icons` font: reuse or add a glyph in `AppGlyphs` and show it
  with `GlyphIcon`, or with `AnimatedGlyph` where it fills on selection. Glyphs are outlined, except inside a filled
  button, where they take `fill: 1`. The Icons section of `.agents/architecture.md` covers shape roles, the stroke, the
  fill animation, and when to fill.
- Modals dim what they cover with the Material 3 scrim (`ColorScheme.modalScrim`, `scrim` at 32%) and never blur it.
  Every modal brings its own scrim, including one opened from inside another, so do not make a barrier transparent to
  keep scrims from stacking.
- App bar buttons reach `CommonScaffold` as data (`primaryAction`, `iconActions`, `menuItems`) so it can fold them into
  its overflow menu; App Bar Actions in `.agents/architecture.md` has the rule.
- User-facing text goes through ARB; use `localization` when text changes are non-trivial.
- An asynchronous control keeps four things apart: authoritative provider/domain state; display-only state such as a
  minimum progress duration; tap policy while work or a display hold is active; and failure/disposal cleanup, in
  `finally` for animations and timers. `CoreStatusButton` and the proxies delay test action are the reference implementations,
  described under User-Facing Core And Delay Feedback in `.agents/architecture.md`.

## Corner Radii

All corner radii come from `lib/common/shape.dart`: a token, a derived value, or a named off-scale value passed to its
builders. Never write a bare radius literal at a call site.

The scale is picked by the component's **shortest side**. A radius that reads as a soft card at 64 logical pixels tall
reads as a pill at 24 and as a square at 400, so one radius everywhere is the wrong kind of consistency.

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

- `AppCorner` holds the scale as `double`; `AppRadius` mirrors it as `BorderRadius` with `all`, `top`, and `vertical`
  builders; `AppShape` mirrors it as `RoundedSuperellipseBorder` with `full`, `circle`, `input`, and the
  `all`/`top`/`vertical`/`of` builders.
- `AppCorner.fit(shortestSide)` snaps to the largest token at or under one third of the shortest side. Use it whenever
  the size comes from a `LayoutBuilder` or scales with text.
- `ThemeData.withAppShapes` in `lib/application.dart` already applies the scale to card, dialog, bottom sheet, snack
  bar, chip, menu, input, FAB, navigation indicator, and progress themes. Do not restate those shapes at call sites, and
  leave `InputDecoration.border` unset so inputs inherit `AppShape.input`.

`xl` and `lg` exist because one token cannot serve both size classes. A full-bleed surface is wide and short, so its
corner must be larger than its height alone suggests or it stops reading as a card; everything full-bleed shares `xl`
(`CommonSelectedListItem`, the profiles card, the outer corners of a grouped run in `DecorationListItem`, the proxy
group header in `lib/views/proxies/list.dart`) and does not use `fit()`. This is the one deliberate overshoot of the
one-third rule; the value stays under half a standard row so nothing clamps and every full-bleed surface renders the
same radius. `lg` is for mid-size cards that are not full-bleed: a proxy node card at `ProxyCardType.min` is only about
64 tall, which caps its radius at 21, so `xl` would break on a setting the user can change at any time while `lg`
clears all three heights and the smallest dashboard tile.

Outlined inputs use `AppInputBorder`, not `ShapedInputBorder` from `package:material_ui`. The package border subtracts
the floating label's notch as a flat band along the top edge, which takes the corner curve with it at any radius from 8
up. `AppInputBorder` clips the notch region and paints the full superellipse through it, as Flutter's own
`OutlineInputBorder` does by shortening the arc. It needs no `contentPadding` compensation.

Nested radii are derived, never tokens: concentric corners need `outer = inner + inset`, so name the inset and compute
the outer value, as `_cardRadius` in `lib/widgets/popup.dart`, `_kCornerRadius` in `lib/widgets/tab.dart`, and the
selection ring in `lib/widgets/palette.dart` do. Adding a token for one of these is how a scale grows without bound.

A component the scale does not fit keeps its own value instead of growing the scale: name it once in the file and pass
it to the `all`/`top`/`vertical` builders, as `_itemShape` in `lib/widgets/sidebar.dart` does with 10, between the
chip-sized `sm` and the near-pill `md` on a 40 tall row. Reach for this only once the table and `fit()` are ruled out.

## Verification

- A behavior change gets a focused widget test covering rendering states, taps, scrolling, and empty/error states,
  including the exception path of any async action. Run `flutter analyze` and `flutter test test/widgets/` plus the
  tests of the touched view.
- The scans in `test/lint/` fail on the common UI mistakes and run as part of `flutter test`: an `IconButton` whose
  icon is an icon needs a `tooltip`; a field that constructs its own controller, notifier, or focus node is released in
  the same file; a public declaration nothing references is dead. `.agents/rules.md` explains each rule and its
  allowlist.

## Pitfalls

- Do not mutate provider/domain state merely to smooth a transition. Keep presentation holds local and let real errors
  bypass them immediately.
- Do not leave loading animations active when callbacks throw.
- Do not manually edit generated localization or provider files.
