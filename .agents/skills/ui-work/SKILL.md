---
name: ui-work
description: Use when changing FlClash Flutter UI, widgets, screens, color and surface styling, icons or glyphs, shapes and corner radii, navigation surfaces, async feedback, or user-facing interactions.
---

# UI Work

## When To Use

Use this for user-facing Flutter UI changes in `lib/`, including widgets, screens, navigation surfaces, settings rows,
dialogs, and interaction behavior.

## Conventions

- Reuse the patterns of nearby widgets, providers, notifiers, and helpers before adding an abstraction, and keep to the
  look the rest of the app has: its own seeded color system, with Apple's interaction conventions (continuous corners,
  sheets that snap between detents, a floating tab bar), all drawn by `prism_ui`. `Card`, `PressSurface`, and `ListRow`
  press with `PressLook.ink`, a state layer plus, on Android, a sparkle drawn by `PressSparkles`, and a desktop hover is
  faint (Press in `.agents/surfaces.md`). Do not introduce a visual system for one screen or rewrite a layout the
  request does not need.
- Widgets come from `package:flutter/widgets.dart` and components from `prism_ui`; no design library is imported. The
  Generated Code section of `.agents/rules.md` has the rule.
- `.agents/rules.md` is binding here: the lint set (`child:` last, `const`, final locals), the superellipse corner API,
  and the widget-test facts under Testing Rules (`pumpAndSettle` never returns on `EditorView`, `dispose()` must not
  await, auto-dispose providers need a container-level hold, platform decisions are passed in as parameters).
- A component that knows nothing of FlClash goes in the `prism_ui` package, the submodule `plugins/prism_ui`; what FlClash adds to it without reading app
  state (its glyphs, fonts, page illustrations) goes in `lib/ui/`; one built for an app feature goes in
  `lib/widgets/`. The UI Layer section of `.agents/architecture.md` draws the boundary and says how a `prism_ui`
  component gets app state.
- Settings screens are built from the `ConfigToggleItem` family in `lib/widgets/config_item.dart`; the Settings Rows
  section of `.agents/architecture.md` says when a file-local helper or a named widget is warranted.
- Every icon is a glyph, never an icon font: reuse or add one in `AppGlyphs` (`Glyphs` when a
  `prism_ui` component draws it) and show it
  with `GlyphIcon`, or with `AnimatedGlyph` where it fills on selection. Glyphs are outlined, except inside a filled
  button, where they take `fill: 1`. The Icons section of `.agents/architecture.md` covers shape roles, the stroke, the
  fill animation, and when to fill.
- Text sizes and weights come from `AppTextStyle` in `prism_ui/lib/typography.dart`, Apple's iOS Dynamic Type scale, never a
  bare `fontSize`, or a `fontWeight`; the Typography section of `.agents/rules.md` has the
  rule.
- Modals dim what they cover and never blur it: sheets with the Material 3 scrim (`ColorScheme.modalScrim`, `scrim` at
  32%), alerts with `ColorScheme.alertScrim`, the lighter dim iOS 27 puts behind an alert. Every modal brings its own
  scrim, including one opened from inside another, so do not make a barrier transparent to keep scrims from stacking.
- A sheet's size belongs to its route, never to its content or call site: a bottom sheet rests at
  `SheetProps.detents`, a side sheet is as tall as the window and as wide as `ModalSideSheetRoute` makes it from
  the window width (`prism_ui/lib/side_sheet.dart`, pinned by `test/widgets/side_sheet_width_test.dart`), and a form sheet
  is a card `FormSheetRoute` caps in width and height (`prism_ui/lib/form_sheet.dart`). Do not wrap a sheet's content in a
  fixed width or height to resize one sheet.
- A form with more than one value opens with `showFormSheet` and lays its values out in `FormRow`s, never as labeled
  fields in an `AlertDialog`; a prompt for one value stays an alert. Forms in `.agents/architecture.md` has the rule.
- A modal scrolls only once the window and keyboard leave it no room, and then through one scroll view: `AlertDialog`
  caps its body at nothing but the space it is given, and a multi-line field in a dialog or sheet grows with its text
  (`maxLines: null`) rather than scrolling inside a line count. With the keyboard up, a bottom sheet keeps what it
  shows above the keyboard, rising past its tallest detent as far as a peek below the top (`_top` in
  `prism_ui/lib/snap_sheet.dart`).
- The keyboard animates `MediaQuery.viewInsets` every frame. Read MediaQuery by aspect (`paddingOf`, `viewInsetsOf`)
  rather than `MediaQuery.of`, and wrap the page of a new route type in `KeyboardInsetHold`; Keyboard Insets in
  `.agents/architecture.md` has the reasons.
- A page loads what it shows as it mounts, never once its route has settled; what waits out a transition is work
  that repeats, such as a live feed's refreshes (`RouteMotionHoldMixin`), and the rows past the viewport
  (`ArrivalCacheExtentMixin`). Page Arrival in `.agents/architecture.md` has the rule.
- A page that waits on its data shows nothing until all of it is ready (`NullStatusSwitcher.isLoading`), and a load
  that can run long adds its illustration or a page spinner as `loadingStatus`, never a skeleton screen; Page Arrival in
  `.agents/architecture.md` has the rule.
- App bar buttons reach `Scaffold` as data (`primaryAction`, `iconActions`, `menuItems`) so it can fold them into
  its overflow menu; App Bar Actions in `.agents/architecture.md` has the rule.
- A row's secondary actions open from a context menu, never a trailing more button; a list whose rows have one
  reorders in a sort mode, any other from the row itself, a mouse dragging it and a finger long pressing first. Row
  Actions And Sort Mode in `.agents/architecture.md` has the rule.
- Quick edit belongs only on a page that edits a whole list or section, or one isolated item; never on one that edits a
  part of something other settings also write. Quick Edit in `.agents/architecture.md` has the rule.
- A page or sheet opens on the navigator of the context it comes from, never on the root navigator unless Where A
  Route Opens in `.agents/architecture.md` allows it.
- User-facing text goes through ARB; use `localization` when text changes are non-trivial.
- An asynchronous control keeps four things apart: authoritative provider/domain state; display-only state such as a
  minimum progress duration; tap policy while work or a display hold is active; and failure/disposal cleanup, in
  `finally` for animations and timers. `CoreStatusButton` and the proxies delay test action are the reference implementations,
  described under User-Facing Core And Delay Feedback in `.agents/architecture.md`.

## Corner Radii

All corner radii come from `prism_ui/lib/shape.dart`: a token, a derived value, or a named off-scale value passed to its
builders. Never write a bare radius literal at a call site.

The scale is picked by the component's **shortest side**. A radius that reads as a soft card at 64 dp tall
reads as a pill at 24 and as a square at 400, so one radius everywhere is the wrong kind of consistency.

| Token | Value | Shortest side | Use |
| --- | --- | --- | --- |
| `none` | 0 | - | square edges, and the flat side of a grouped run |
| `xs` | 4 | inset blocks | tiles clipped inside an already rounded surface |
| `sm` | 8 | up to 48 | chips, thumbs, swatches, small square tiles |
| `md` | 16 | up to 64 | interactive chrome: inputs, menus, buttons, popups |
| `lg` | 20 | 64 to 180 | mid-size cards: dashboard tiles, proxy node cards |
| `xl` | 24 | full-bleed | anything spanning the whole width: list rows, grouped runs, group headers |
| `xxl` | 28 | over 200 | sheets, full-screen containers |
| `alert` | 34 | - | alerts, the corner of iOS 27's UIAlertController; on `AppCorner` only, passed to the builders |
| `full` | 1000 | - | pills and circles: buttons, tracks, indicators, progress, avatars |

- `AppCorner` holds the scale as `double`; `AppRadius` mirrors it as `BorderRadius` with `all`, `top`, and `vertical`
  builders; `AppShape` mirrors it as `RoundedSuperellipseBorder`, `full` included, plus `circle`, `input`, and the
  `all`/`top`/`vertical`/`of` builders. Use `AppShape.full` for pills, never `StadiumBorder`; the Corner Radius
  section of `.agents/rules.md` explains why and lists the superellipse API per layer.
- `AppCorner.fit(shortestSide)` snaps to the largest token at or under one third of the shortest side. Use it whenever
  the size comes from a `LayoutBuilder` or scales with text.
- The components of `prism_ui` already take their shapes from the scale. Do not restate them at call sites, and leave
  a field's `border` unset so it keeps `AppShape.input`.
- Colors of surfaces follow `.agents/surfaces.md`: fills by `SurfaceLevel`, no structural borders, and a selected
  item keeping its fill under a `SelectionCheck` or `SelectionBadge`, with no container role on a card or row.

`xl` and `lg` exist because one token cannot serve both size classes. A full-bleed surface is wide and short, so its
corner must be larger than its height alone suggests or it stops reading as a card; everything full-bleed shares `xl`
(the profiles card, the outer corners of a grouped run in `DecorationListItem`, the proxy
group card in `lib/views/proxies/list.dart`) and does not use `fit()`. This is the one deliberate overshoot of the
one-third rule; the value stays under half a standard row so nothing clamps and every full-bleed surface renders the
same radius. `lg` is for mid-size cards that are not full-bleed: a proxy node card in the tab view at
`ProxyCardType.compact` is only about 64 tall, which caps its radius at 21, so `xl` would break on a setting the user
can change at any time while `lg` clears both heights and the smallest dashboard tile.

Outlined inputs use `AppInputBorder`, which paints the full superellipse through the floating label's notch.

Nested radii are derived, never tokens: concentric corners need `outer = inner + inset`, so name the inset and compute
the outer value, as `_cardRadius` in `prism_ui/lib/popup.dart` does. Adding a token for one of these is how a scale grows without
bound. A card that also stands on its own elsewhere keeps its token when nested: the proxy node cards inside a proxies
list group stay `lg` like those in the tab view, since deriving them from the group card's `xl` left them at 14, smaller
than every other card in the app.

A component the scale does not fit keeps its own value instead of growing the scale: name it once in the file and pass
it to the `all`/`top`/`vertical` builders, as `_itemShape` in `prism_ui/lib/sidebar.dart` does with 10, between the
chip-sized `sm` and the near-pill `md` on a 40 tall row. Reach for this only once the table and `fit()` are ruled out.

## Verification

- A behavior change gets a focused widget test covering rendering states, taps, scrolling, and empty/error states,
  including the exception path of any async action. Run `flutter analyze` and `flutter test test/widgets/` plus the
  tests of the touched view.
- The scans in `test/lint/` fail on the common UI mistakes and run as part of `flutter test`: an `IconButton`
  whose icon is an icon needs a `tooltip`; a field that constructs its own controller, notifier, or focus node is released in
  the same file; a public declaration nothing references is dead. `.agents/rules.md` explains each rule and its
  allowlist.

## Pitfalls

- A list, row, or animation whose cost grows with the user's data follows UI Frame Budget in `.agents/rules.md`; use
  the `ui-performance` skill to measure it.
- Do not mutate provider/domain state merely to smooth a transition. Keep presentation holds local and let real errors
  bypass them immediately.
- Do not leave loading animations active when callbacks throw.
- Do not manually edit generated localization or provider files.
