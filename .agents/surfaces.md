# Surfaces

FlClash draws structure with fills and keeps color for state. A surface stands out from what it sits on by a step in
lightness, never by a border. Color appears where something is selected, on, failing, or the one action a screen is
for. The dashboard set this direction; every other screen follows it, and Material components keep their behavior
but give up their tonal container fills.

## Levels

`SurfaceLevel` in `lib/ui/surface.dart` names four depths. Each surface takes the level one deeper than the one
it sits on, which `SurfaceScope` passes down the tree.

| Level   | Light                     | Dark                      | Holds                                                   |
|---------|---------------------------|---------------------------|---------------------------------------------------------|
| `page`  | `surfaceContainer`        | `surface`                 | scaffold body, sheets                                   |
| `card`  | `surfaceBright`           | `surfaceContainer`        | cards, grouped runs of rows, light-mode floats          |
| `block` | `surfaceContainer`        | `surfaceContainerHigh`    | unselected segments, tiles and wells in a card          |
| `inset` | `surfaceContainerHighest` | `surfaceContainerHighest` | small marks inside a block: glyph wells, badges, tracks |

Light mode alternates gray and paper: a near-white card on a gray page, a gray block in the card. The card is tone 98,
not pure white, and the page tone 94: pure white beside a tinted gray made the white glare and the gray look soiled. Dark mode only
lightens, because a darker step inside a lighter surface reads as a hole rather than a layer, and it steps further:
tones 6, 15, 21, 27 where light steps by 4, as iOS 27 sets its dark grouped card about 2.3 times as far off the page
as its light one. At Material's dark tones a card stood barely clear of the page, and on pure black hardly at all.
`inset` is the floor;
nothing nests below it, so a design that needs a fifth level needs fewer containers instead.

- A widget never picks its level at the call site. `CommonCard` and the other shared surfaces read
  `context.raisedSurfaceLevel` and wrap their child in `SurfaceScope`, so the same row is white on a page and gray
  inside a card. A branch on `isInBottomSheet` or on where a widget is placed to choose its fill is the bug this
  replaces.
- Sheets are `page` level, like a page, so a section looks the same in a sheet and in a page. In dark mode a sheet
  presents a level up, as iOS presents a sheet on its elevated backgrounds: `ColorScheme.elevated` moves every level
  up one, so the sheet's page takes the tone of the cards it covers, its cards the tone of a block, and its blocks
  the tone of an inset, under pure black too. `ElevatedColorScheme` carries the result and the sheet
  routes apply it through `ElevatedSurfaceTheme`; a sheet opened from a sheet keeps the same lift. A scrim barely
  darkens a dark page, so a dark sheet at the page's own tone read as more of the page rather than a layer over it,
  a covered sheet's peek vanished, and on black the edge and corners went with it. Light mode keeps its levels,
  because the scrim already sets a light sheet apart.
- What floats over content, dialogs, menus, popups, the mobile dock, toasts, takes `SurfaceLevel.floatingOf`: `card`
  in light, `block` in dark. A shadow does not show on a dark page, so a float has to come out lighter than the cards
  it covers, and its content scopes to that level so a block inside still steps away from it.
- Shadows mark what floats, plus the dashboard cards. Cards in a scrolling list have none; a grid of proxies with a
  blurred shadow each costs raster time for no extra layering. A render object that paints a shadow itself draws it
  with `drawRSuperellipse`, as `ShapeDecoration` does: Impeller blurs a superellipse in one analytic pass, but a path
  through an offscreen Gaussian blur on every frame, which made the shadows the largest raster cost of an opening menu.
  A shadow is black at an opacity, so one measured on iOS darkens FlClash's surfaces as it darkens iOS's own: the
  surfaces differ from iOS's too little to call for retuning, and over the dark page, which is not black, a shadow
  shows where iOS's would not.

## The Seeded Scheme

`seededColorScheme` in `lib/ui/color.dart` builds every app scheme: Material's scheme for the seed and the
`ColorStyle` picked in the theme settings, with four groups of roles replaced. Everything else stays Material,
including `toPureBlack` applied after it.

The four styles each change something a reader sees at once. Material's nine variants mostly moved secondary and
tertiary, which the app barely shows, so most of them looked alike once surfaces stayed gray.

| Style        | Material variant | Primary           | Surfaces                        |
|--------------|------------------|-------------------|---------------------------------|
| `vivid`      | content          | the seed          | near gray                       |
| `tinted`     | content          | the seed          | the seed's hue, up to chroma 10 |
| `soft`       | tonal spot       | Material's, muted | near gray                       |
| `monochrome` | monochrome       | black or white    | gray                            |


- **Surfaces stay near gray.** Each `surface*` role keeps Material's tone but its chroma is capped at 3, the light
  `surface` and `surfaceBright` at 1.5, and `outlineVariant` at 4. Material tints neutrals by the seed (content
  divides the seed's chroma by 8), so a yellow, green, or rose seed tinted the whole page. `tinted` is that wash
  chosen on purpose and made even: every surface takes the seed's hue at a sixth of its chroma, capped at 10, so a
  gray seed stays gray and any vivid one tints about as much.
- **`primaryContainer` comes from the primary palette.** It is primary's hue at tone 90 in light and 30 in dark,
  with `onPrimaryContainer` at 30 and 90, and the pair's chroma is capped at 48. Content and fidelity otherwise put it
  at the seed's own tone: a yellow seed filled it with pure yellow, a red seed with something that read as an error,
  and dark mode with a light block under light text. The cap matters for light, chromatic hues: yellow at tone 90 is
  still close to full strength.
- **`vivid` and `tinted` keep the seed as `primary`**, as an Apple accent color does: the color picked in the theme
  settings is the color of every check, switch, and filled button. Light holds the seed's tone between 35 and 60, so
  white text on it keeps about 3:1 and a near-black seed still reads as a color; dark lifts it 3 tones, as iOS lifts
  its system colors, within 50 to 75, and puts dark text on it above 60. Material sets primary at tone 40 and 80 for
  any seed, which turned iOS blue into navy in light and a pastel in dark. `soft` and `monochrome` keep Material's
  primary, since moving away from the seed is what they are for.
- **Dark spreads its levels and lifts its titles.** `surfaceContainer`, `surfaceContainerHigh`, and
  `surfaceContainerHighest` sit at tones 15, 21, and 27, not Material's 12, 17, and 22, for the steps under Levels.
  `onSurface` sits at 97, not 90, which left a dark title about an eighth weaker than a light one; iOS 27 gives `label`
  the same contrast in both modes. Dark `onSurfaceVariant`, `outline`, and the accent already fall off from light about
  as iOS 27's `secondaryLabel`, `tertiaryLabel`, and `systemBlue` do. Weigh text across the modes with APCA: WCAG's
  ratio overrates light text on a dark surface and points the other way. Dark Liquid Glass keeps the tint it was
  fitted to iOS 27 with, Material's old `surfaceContainerHighest`, seven tones over the card (`_darkGlassTint`).

## State

Color marks the one item that differs, never the structure around it.

- **Selected**, one of several rows, cards, or tiles: the item keeps its level's fill and a primary mark says which,
  as iOS checks the option picked from a list. A row in a grouped run takes `SelectionCheck` at its edge; a card that
  stands on its own, a profile or a proxy, and a tile take the filled `SelectionBadge`, which holds its own beside a
  40 dp icon well where the bare check read as small and thin (`lib/ui/selection_mark.dart`). `CommonCard.isSelected` only reports the state to
  accessibility. Fills were tried and rejected: a wash of primary landed on a gray that did not read as a choice, and
  `primaryContainer` read as a warning under rose seeds in light and as a heavy slab in dark, muddied the translucent
  marks on it, and cut a grouped run in two.
- **Multi-select** in edit mode: the circle checkbox is the mark; the row stays at its level.
- **Proxy groups** have two states in URLTest and Fallback: the check badge marks the proxy traffic goes through, in
  every group type, and a pin badge (`SelectionBadge.preferred`) marks the preferred proxy (mihomo's `fixed`): filled
  like the check while the group uses it, tonal while the group has fallen back to another proxy, which carries the
  check.
- **Chosen segment** in a connected button group, a mode switch, or a run of compact choice chips
  (`CommonCard.fillsSelection`): solid `primary` with `onPrimary`, as the dashboard outbound mode does. Only one
  segment per group.
- **Error** on a row or card: `errorContainer` with `onErrorContainer`, no border.
- **Status** values (delay, availability, success, warning): the color goes on text, a glyph, or a small chip, never
  on a whole card. `success` and `warning` come from fixed green and orange palettes that ignore the seed, like
  Material's `error`; harmonizing pulled orange toward red under rose seeds until warning and error matched. Text takes
  tone 40 in light and 80 in dark, a chip takes `successContainer`/`warningContainer` (90/30) with the `on` role
  (30/90). A delay under 600 ms is success, above it warning, a failure error: `ColorScheme.delayColor`.
- **Destructive** action in an alert: `ColorScheme.destructive`, iOS 27's systemRed in both modes, not `error`. A
  menu's `danger` item still takes `error`.
- **Data series** on one chart: the first is primary, the second primary at 45% over the card
  (`DashboardColors.series2`), so they differ by lightness under any seed. Tertiary is not a series color.
- **Text**: titles and values `onSurface`, labels and secondary lines `onSurfaceVariant`. `outline` is not a text
  color, and a value is never tinted primary.
- **Marks** that only identify, a country badge, a group or service icon, a source avatar, sit on a neutral well with
  `onSurfaceVariant`.
- `primaryContainer`, `secondaryContainer`, and `tertiaryContainer` are neither surface nor selection fills. Keep
  them out of cards, rows, marks, and navigation indicators. The code editor's completion popup is the one exception:
  it fills the highlighted suggestion with `primaryContainer` (`lib/features/editor/completion_popup.dart`).

## Borders That Stay

- **Focus**: a 2 dp primary stroke while a surface has keyboard or remote focus. TV navigation depends on it, and a
  fill change alone is too faint to follow from a couch. A card, a grouped row above all, rings only focus a key moved
  there (`FocusMovedByKey`), or any focus while a remote drives the app: a tap or a click puts focus where the reader
  is already looking, a field's caret already marks it, and the ring then read as a selection box around the row.
- **Inputs**: a form's field is a bare `FormRowTextField` at the end of a grouped `FormRow` whose title labels it, as
  iOS and macOS set one, with no stroke or fill of its own. A field among filled controls takes their fill, one level
  above its surface, through `FilledInputTheme`. An alert's fields, because they sit over its pill buttons, as
  UIAlertController sets them: as wide as the buttons, in their fill, with their text in line with the title and the
  label as the placeholder (`CommonDialog.hasFields`); a field under a filled block of text in an alert takes the
  block's width and corner instead. The custom color's hex field, because its card holds only fills, the color
  previews, where an outline was the one stroked thing. All of these stroke only while focused. Search fields are filled
  pills on the `GooSurface` they share with the buttons beside them, and ring only focus a key or a remote moved there,
  as cards do: a tap leaves focus to the caret, as on iOS. A docked search, a sheet's or a pushed phone page's, because
  the list scrolls under it: it floats like the dock, with the floating fill and the dock's shadow, or the dock's glass.
  The editor's find bar, because its fields sit in a row of filled pill buttons: they take the buttons' fill, one level
  above the bar. Any other field, one standing alone on a page, is outlined, with the floating label notched into the
  stroke: `ThemeData.withAppShapes` gives every input `AppShape.input`, so call sites leave `border` unset. A lone field
  is never filled: here a fill means structure, so one read as one more card or row, and in light mode the hover overlay
  brought it down to the page's own tone. No field counts its characters, as none does on iOS or macOS; a length limit
  holds through its formatter. Material strokes a filled field's whole outline in `onSurfaceVariant`, which ringed the
  pill brighter than anything else in a dark sheet.
- **Window chrome**: the desktop sidebar's inner edge and the title bar's bottom edge draw a divider where they meet
  the content. The chrome fill alone left the edge to a four-tone step, which read as a smudge rather than a boundary.

Nothing else draws an outline. Rows in a grouped run are separated by the hairline from `lib/ui/list_row_separator.dart`, which divides
one surface and does not outline it. Record lists, requests, connections, logs, and DNS queries, are not grouped: they
run to thousands of tall rows, and one card that long reads as a slab rather than a group. A stacked row of three or
four lines is already its own block, so each is a card of its own, `RecordListItem`: the raised fill at `xl`, 16 dp
from the edges and 8 dp from the next, as the profile cards sit. Every card takes the same fill, so the warning and
error tints on a label still stand out, where a fill on every other row competed with them; rows on the page split by
a full-width divider were the one structural line left on screens otherwise drawn with fills. Laid out as a table,
where a row is one line read across many columns, they drop the gap and give every other row the raised fill, inset
and rounded like the column header, so the eye keeps its row; the dashboard's table does the same.

Every divider takes its color from `ThemeData.withAppSurfaces`: `onSurface` at 14%, never `outlineVariant`. A
translucent line keeps the same contrast on the page, a card, or the chrome, in both modes; `outlineVariant` stood out
twice as much on the dark page as on the light one and carried the seed's tint.

## Navigation

- The desktop sidebar and title bar are window chrome, `ColorScheme.chromeSurface`: `surfaceContainerHighest` in
  light and `surfaceContainerLow` in dark, four tones from the page either way, with a divider along the edge that
  meets the content. At `page` level the sidebar merged with the content. In dark the chrome stays below `card`, so
  cards still stand out from it. The pane the sidebar opens over the content takes the same fill and edge, plus a
  shadow.
  The selected destination keeps its neutral fill and primary bar, which already marks it with color.
- The mobile dock and the docked navigation bar are floats; their indicator is a neutral platter one level above
  them, and the selected destination's content takes primary, as iOS's tab bar marks its selection.
- With Liquid Glass on (Theme settings), the dock, the buttons of a page's bar, a docked search, popup
  menus, and alerts are glass from `lib/ui/liquid_glass.dart` instead of a fill, and the dock's platter takes the
  secondary hue and chroma at tone 90, or at tone 4 in dark, which sinks it below the bar as iOS 27 does.
- The proxies page's group tabs are compact choice chips, the current group in the chosen segment's solid `primary`.
  Once they overflow, a tonal button at their end opens every group as a popup menu, the current one checked and
  scrolled into view. A profile can carry dozens of groups, so the menu stops at seven rows and half of the next.

## Where It Lives

- `lib/ui/surface.dart`: `SurfaceLevel`, `SurfaceScope`, `context.surfaceLevel`, `context.raisedSurfaceLevel`,
  `ColorScheme.chromeSurface`, and `ThemeData.withAppSurfaces`, applied next to `withAppShapes` wherever the app
  builds its theme.
- `lib/ui/color.dart`: `seededColorScheme`, the status palettes, and `delayColor`.
- `lib/views/dashboard/style.dart`: `DashboardColors` maps `page`, `card`, `tone`, and `tone2` onto the levels and
  adds the dashboard's switch, series, and status colors.

## Checking A Change

Render the touched screens in light and dark, on a phone width and a desktop width, before and after. A throwaway
widget test does it: pump `HomePage` or the view inside a `RepaintBoundary`, load Roboto with `FontLoader` so text
gets real glyphs, and write `RenderRepaintBoundary.toImage` to a PNG outside the repository. Look for a surface that
matches the one it sits on, which means it skipped `SurfaceScope`, and for a tonal container fill that survived on a
card or row.
