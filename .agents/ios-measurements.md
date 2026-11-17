# iOS Measurements

Values in this file were measured on the Xcode 27 / iOS 27 simulator (iPhone 17, 402×874 pt unless stated). "Match iOS"
means match these measurements, not an impression of iOS. Items marked "Deliberate deviation" are product decisions,
not defects.

Sizes are pt on the iOS side and dp on the FlClash side. FlClash's current behaviour is documented in
`.agents/architecture.md` (App Bar Actions, Popup Motion, Bottom Sheet Motion, Liquid Glass including the banner glass)
and `.agents/surfaces.md` (Press); this file records the measured values and the differences those documents do not
cover. All symbols live under `plugins/prism_ui/lib/` (the components formerly in `lib/ui` moved there and lost the
`Common*` prefix).

## Alerts (UIAlertController)

- The frame is 320 wide with a continuous corner radius of 34. Title is 17 Semibold, body is 15 Regular
  (secondaryLabel), both left-aligned. Text margins are 30 left and right, 22 top; title to body 7.33, body to buttons
  20.33, buttons to bottom 16. With a text field, title to field is 16 and field to buttons is 20.
- Buttons are 48 high capsules with 16 side and bottom margins and 8 between them. The preferred button is a systemBlue
  solid fill with white Semibold text; the others are a tertiarySystemFill gray with 17 Medium text; destructive text is
  red (systemRed light FF383C, dark FF4245). Without a preferred button all are gray. Two buttons sit side by side
  (cancel on the left); three, or two that do not fit, stack, and cancel moves to the bottom. Text field: 48 high
  capsule, no stroke, 15 inset left and right.
- Animation: the whole block (glass and content) uses one critically damped spring (mass 1, stiffness 522.35, damping
  45.71, perceptual duration 0.275 s, duration 0.404 s) for opacity 0→1 and scale 1.2→1. Dismissal only fades out
  without scaling. The glass opacity stays 1 throughout; it does not "gradually appear".
- Scrim: about 20% in light and 48% in dark. Press: pressing anywhere on the alert grows the whole block by 4 pt over
  320 (about 1.25%), and dragging past the edge stretches it about 3 pt. The pressed button does not grow itself; its
  fill fades to about 40%.
- FlClash: `AlertDialog` (`prism_ui/lib/dialog.dart`) makes the last action the default, filled with the primary color,
  and puts the first action at the bottom when stacked. `AppCorner.alert = 34` (`shape.dart`). `_AlertRoute` uses the
  spring at 275 ms / 0.404 s. Text margin is 30 and width is 348. In `hasFields`, the input has the same width and fill
  as the buttons, a placeholder replaces the label, and there is no character counter (a 0/32 counter looked bad). A
  `hasFields` alert without a body centers its title in regular 17; with a trailing widget it uses `_CenteredTitle`
  rather than an invisible twin button, because `find.byTooltip` would find two. The scrim is `ColorScheme.alertScrim`
  (light 0.2, dark 0.48, `showFloatingDialog` only; the sheet `modalScrim` now has the same values). The destructive
  button uses `ColorScheme.destructive` (a menu's danger item still uses error). The whole dialog is wrapped in
  `ElasticPress(maxGrowth 4, maxPull 3, pullPastEdges)` and a pressed button's fill gets lighter. Fading the whole
  glass group uses `LiquidGlassFade`.
- Remaining differences (not changed): iOS's dark default button is brighter (about 1BACFF) where FlClash uses primary;
  `EntryDialog` with a key (two inputs) still uses outlined floating labels.

## Alert and menu material and edge

- The light alert and the menu share one material. Shader-field fit: light tint alpha 0.55, saturation 2.0, brightness
  1.1, contrast 0 (rmse 2). In dark, iOS keeps hue and chroma, pushes white down to 131 and lifts black to 32; the fit
  is surfaceContainerHighest alpha .63, saturation 1.75, brightness 1.8, contrast -.53 (on pure black 18→32 against
  iOS 32, rmse 4.1). FlClash computes contrast from the average brightness of the whole panel, not per pixel.
- Frosting: the alert is a single Gaussian with sigma about 13 (FlClash blur 16 matches a measured 14); the menu is
  sigma 10-13.5, with no sharp component like the dock's.
- Shadow: menu and alert share one wide shadow, alpha 0.118, blur 29, offset down 8, times 1.5 in dark (shared
  `menuShadows`).
- Button and input fill: a non-default button is glass shifted by a constant 30/255 toward black or white, about 13%
  black or white (`glassFillOf`).
- Edge (pixels taken along the normal from 3x screenshots): in dark, a thin line sits outside the glass by about 0.67
  pt, darkest on the sides and faintest top and bottom. The highlight is added light, not an overlay of white: on
  black, dark gray and light gray backgrounds the same material adds a roughly constant amount (about +55/255 dark,
  +42/255 light). It is strongest at the midpoints of the top and bottom edges and decays along the perimeter (.65 at
  the start of the corner, .38 at 45 degrees, .17 on the side at y=R, .07 at 1.5R, about 0 further down). In depth it
  is 1/.70/.47 within the first 1 pt, then a tail of about 4 pt.
- FlClash: `LiquidGlassRim.paint` follows the true superellipse path, using a SweepGradient times 9 depth bands with
  `BlendMode.plus`; shine is .22 in dark and .16 in light. The depth bands must be drawn as even-odd ring fills:
  Impeller draws a stroke thinner than 1 physical pixel as 1 px wide with alpha times min(1, 2w), which carries 73% /
  20% too much energy at 1x / 2x, and accumulated strokes show +-6 level banding, so that approach was dropped. The
  shader rounds corners as circular arcs while the panel is clipped to a continuous curvature; the two differ by a few
  tenths of a dp at the ends of the corners, which is why the stroke is drawn on the true path.
- Deliberate deviation: dialog and menu edges are kept calmer than a single-point measurement suggests. Edge
  brightness follows the current `LiquidGlassRim`; do not strengthen it from a single measurement.

## Bar button menu open and return (droplet)

FlClash's current opening behaviour is in architecture.md, "Popup Motion"; this section adds the measurements and
tuning.

- Opening: the main spring is k400, zeta 0.754 (omega 20), reaching 1 at about 200 ms, peaking at 1.028 and settling at
  about 0.45 s. The base plate P scales as a whole from an 18 pt circle (0.41 x the button) at the button center, with
  height W→H. Its center travels toward the menu center, with an extra y sink of about (23 + 0.124 x center distance) x
  riseAndFall(98 ms, 3.3). Corner radius r = min(H/2, R(t)), where R(t) = final + 0.48W x spring(k324, zeta 0.75,
  delayed about 70 ms); it starts as a capsule and squares up, undershooting about 3%. The button droplet B shrinks
  from 44 to 11 (25%), its center travels 1/4 of the way to the menu center, and it joins P in a smooth union. Content
  uses o = p and blur 4(1-p); the whole menu also gets a gaussianBlur bulge 0→1.89 (about 69 ms)→0.
- Return: in a single CASDFLayer the plate P and the droplet B are always a smooth union (pear-shaped) and never
  separate. The main spring is zeta 0.80, omega 12.83 (k about 165), starting about 1 frame after release; content
  blurs out over 80-100 ms and the visible motion lasts about 0.55 s. P shrinks to a circle whose longest side is about
  18 pt (height H→W, corner radius 32→W/2); its center follows the main spring toward the button while y first sinks
  away from the button (peak at about 72 ms, magnitude about 0.42 x center distance, capped near 45). B starts at
  "button→1/4 of the way to the menu center, 25% size" and floats above its home position in y (peak at about 176 ms,
  about 0.25 x center distance, capped at 19). Returning from a fully open menu differs from iOS by under 10 ms at every
  point (iOS starts about 50 ms after the finger lifts; FlClash does not copy that).
- Deliberate deviation: the iOS menu covers its button, while the FlClash menu opens beside the button (bottom edge
  overlap 8). Copying the sink would separate P from B, so the sink is halved and the merge radius is 28 (ramped from 0
  over the first 50 ms to avoid a bulge on the first frame). The return lasts 500 ms and a selection takes effect only
  after the return settles. The glyph is drawn only on B and fades out by p = 0.25; the enlarged glyph copy iOS draws is
  not drawn (it is not visible in recordings either). The opening lasts 450 ms rather than waiting for the spring to
  settle fully: an early handoff would make the card scale rise again on the last undershoot, and held screenshots
  would be retaken every frame.
- Implementation: `_openingOf` and `_paintReturn` in `popup.dart`; the outline is `gooPairOutline` (`goo.dart`), which
  finds the first exit of the smooth field along rays (reducing to 64 rays leaves a polyline at the neck, so only the
  standard tier `coarse` uses 64); the glass is `LiquidGlassGoo(firstRadius:)`. `_dropletAbsorbed` drops the merge
  radius to 0 and returns the blur to the button's value inside Interval(0.6, 0.9), otherwise the handoff jumps. The
  return uses `LiquidGlassPane.paint(holdFrost:)`, with the frosting supplied by the shader, cutting screenshots from 12
  to 2 (Skia still retakes per tier). A return that began within 750 ms of opening used to be compressed; `didPop` now
  scales `reverseDuration` by progress. Retaking a bar glass screenshot on every frame while search collapses is an
  existing cost; the bar must not get a hold.
- Unexplained: recordings of the content look blurrier than the layer values and only clear at about 270 ms.

## Menu state display (UIMenu)

- `UIAction.state=.on`: the check mark is at the start of the row, left of the icon. When any item is checked, all rows
  indent to leave the check column; with none checked there is no column (rows shift left and right). `subtitle` is
  small gray text under the label. `.displayInline` groups add a divider and spacing between groups, and a group can
  carry a small gray title. A single-selection submenu (`.singleSelection`) shows only the icon, title and arrow on its
  parent row, not the current value. `preferredElementSize=.medium` gives a top row of compact icon-plus-small-text
  buttons; `.on` is a gray plate, with no check mark.
- Submenu: the iOS parent menu scales to about 0.97 (anchored top right) with content about 50% opaque and sharp, and
  the child card has the same width as the parent. Closing with a submenu open shrinks only the submenu back to the
  button and the parent menu disappears at once (FlClash does this already).
- FlClash: `PopupMenuItem.section` (divider plus small title) and `subtitle` are supported. Deliberate deviation: the
  check mark stays at the end of the row, because leaving a column empty for rows with icons looked unattractive. The
  parent menu still uses a 20% scrim / 0.95 / 1.12 x rather than 50% / 0.97 / same width; not changed.

## Glass button (UIButton .glass()) edge and dock at rest

- The top bar back button (44 circle) and the right-hand button pair measure the same as a standalone glass UIButton.
  The highlight depth profile matches the alert (1/.69/.38, then a tail of about 4 pt). In dark the top peak is +42/255
  (FlClash +51); in light on an 808080 background it is +29. On a straight edge the top edge is uniform (unlike the
  alert's decay along the perimeter), and it decays faster at the round ends, relative to the top: .85 at 80 degrees,
  .40 at 60, .15 at 45, .10 at 30, about 0 at 20. The dark line lies outside the boundary; in dark there is none on the
  top and bottom and the sides are 36 lower than the bottom; in light the top is -12 and the sides -50. The Prominent
  (tinted) highlight is about half (dark +18, light +27).
- FlClash matches `regular` and `tinted`: `LiquidGlassStyle` fields `rimTail` (.17), `rimFocus` (1, direction taken as
  1/2 (n.y^3 + n.y^19)), `rimAdded` (.38) and `hairlineSide` (the line goes from top to side with |n.x|^3). In styles
  with a line, the bare background shows inside the line band (otherwise the highlight would be twice as wide).
- Dock at rest (measured): the shadow is only below, -3/255 at 1-4 pt, -2 to 7, -1 to 10; fitted BoxShadow 1.3% / blur
  3.8 / (0, 6.5). Frosting is a mix of about 28% sharp (sigma <= 0.5) and 72% at sigma about 15.6. Bar color in light:
  white tint alpha 0.524, saturation 1.97, contrast 0; in dark (with the theme tint) alpha 0.604, saturation 1.63,
  brightness 2.0, contrast -0.31. The selected platter is a colorMatrix of the bar.
- Adopted: the shadow, the dark top and bottom lines off, and two-part frosting (`LiquidGlassStyle.haze` / `hazeBlur`;
  pill blur 0, haze 0.72 at 15.6). For the border only "highlight proportional to n.y^2" was adopted (not on the lens
  path). Rejected (do not propose again without new reasons): bar tint, unselected icon color, the iOS platter (the
  theme platter stays), selected icon vibrancy (primary stays), dark rim 0.25, the |n.x|^3 line, and a line outside the
  boundary.

## Dock long-press lens

- Displacement is outward along the normal and uniform around the ring: 0 at the edge, about 4.3 pt at 5.5 pt, flat to
  about 7.5 pt, then falling, 0 at the center. Dispersion R-B is about 6 pt at the top and bottom edges, dropping to
  about 3.8 pt at 6 pt, about 3.7 pt at the two ends, and fading out over 7-10 pt. The direction is (n.y, n.x), the
  opposite sign to the old shader's tangent (-n.y, n.x).
- In dark, the lens interior and the selected content are both multiplied by about 1.33 (bar 45→60; icon (6,151,255)
  →(39,184,255)); light is unchanged. The shadow is only below and at the sides: below it peaks at -14/255 about 6 pt
  under the edge and ends at 14 pt, and at the sides it ends within 5 pt; approximated by BoxShadow 0.055 / blur 5 /
  (0, 8), times 3 in dark. A resting tab bar on a white page has almost no shadow (1-3/255); FlClash's `dockShadows` is
  5-7%. That is a difference in the resting state and is kept.

## Top bar button symbols and bar button reveal

- Symbols: a bar button is `textStyle=body, weight=Medium, scale=Large`. Line widths: plus/xmark about 1.95 pt,
  magnifier ring about 1.85, filter and share about 1.65-1.7, trash outline 1.6 with inner line 1.2. The plus is about
  16.5 pt long. The ellipsis dots are 4.0 in diameter with centers 7.8 apart (total width about 19.7).
- FlClash: fill-1 top bar buttons use a 2.2 dp line (slightly heavier), so "too thin" only shows on solid dots.
  `GlyphPainter` scales the line shape of a solid glyph by 2.2/1.8, and `AppGlyphs.more` is r 1.65 with centers 7.8
  apart. Deliberate deviation: the vertical three dots are kept (iOS is horizontal); changing direction was not
  requested.
- Reveal (second measurement round): the p spring is 0.416 s / bounce 0.25, starting 0.03 s after the first frame of
  the transition. The whole button has opacity p, scale 1.2-0.2p around its center and blur 10(1-p); on exit use 1-p.
  A shared slot (both pages have a button at the same position) is the same glass container with no frame or corner
  morph: the icons swap in with opacity q, scale 0.2+0.8q and blur 10(1-q), and the container pulses with scale =
  1 + 0.2 x (up(t) - down(t - lag)) (up 0.292 s / bounce 0.5, down 0.416 s lagging about 0.13 s; peak about 1.22,
  trough about 0.965). Identical icons do not pulse. The back button stays across pages 1→2→3; only root↔page 1 reveals
  or hides the whole button.
- Title: on an ordinary push or pop the title moves with the card (parallax -0.3W on exit), is clipped by the card edge,
  and neither fades nor blurs; on zoom the two titles stay at their end positions and cross-fade (about 0.33 s). Layer
  order: page < bar background < title < glass buttons. During an interactive drag back the buttons of both pages stay
  put and only reveal or hide after the gesture commits.
- Deliberate deviation: when a push is popped midway iOS resets the buttons and title abruptly; FlClash redirects
  smoothly. The pill width change (a 2↔1 grouping, where one persistent pill widens on the 0.416 / 0.25 spring with
  its right edge fixed) is not implemented in FlClash.
- FlClash implementation, `bar_item_presence.dart`: `BarItemPresence` has three modes (default: the leading button and
  every trailing action; `.held`: the home dock, which only moves a snapshot; `.title`: the scaffold title, a pure
  opacity cross-fade on zoom only). The route signal is `CardRouteMixin.barItems = (lifted, moving, shown, tracking)`
  with `shown = hasCome(animation) && !hasCome(secondary)`. Buttons of a covered page move into the root overlay
  (`Overlay.wrap` in `application.dart`; text selection and context menus are mounted on this layer for the same
  reason). Pairing rule: on the same navigator one is entering (p <= 0.1) and one leaving (p >= 0.9), their resting
  rects are equal, and each has exactly one `BarItemGlyph`. Test: `test/widgets/bar_item_presence_test.dart` (pump one
  extra frame when timing is involved).
- Pitfalls: a ticker of an off-screen page muted by TickerMode freezes the fade-out near 0, so with TickerMode off the
  animation completes directly and p <= 0 does not expose semantics. `OverlayPortalController.hide/show` cannot be
  called during build. An `IgnorePointer` in the overlay must rebuild with the motion via `ListenableBuilder`. For the
  side covered by a zoom, `shown` must use `!hasCome(secondary)` rather than status (a deferred push makes status go
  forward while the value is still 0, and the two buttons would each cross-fade). A kept-alive off-screen tab page has
  an all-zero matrix, so lifting must skip non-finite or empty rects, otherwise the glass `_place` throws NaN every
  frame. "Born in the overlay" is not achievable (OverlayPortal lays out the slot before the overlay child); the only
  thing done is to skip `retakeSnapshot()` on lifting when the slot paints transparent.
- Push inside a sheet: iOS is identical to a full-screen push (same spring, lower page -0.301W, dim 0.1), with the card
  corner equal to the sheet's own corner (about 38 pt for both large and medium top corners); the small grabber belongs
  to the sheet and does not move with the page. Deliberate deviation: pinned lifted buttons were reported as very
  unstable while a sheet changes height, so `PagedSheetRoute.computeBarItems` returns lifted:false (buttons move with
  the page) and the grabber is drawn once by the sheet. Do not pin buttons in a sheet again. Wrapping a PagedSheet in
  `LookupBoundary` plus `Overlay.wrap` blocks `Material.of` / `View.of` and was abandoned.

## Top bar scroll edge

- Default (automatic) and `.hard` are pixel-identical, and the Settings app is the same: from the top of the screen to
  the bottom of the bar (116 pt = status bar 62 + bar 54) is a uniform frosted band with sigma about 9-10 pt (black to
  white edge 10%→90% spans about 24 pt). Its color is 85% page background plus 15% blurred content (linear mix, error
  <= 1/255, no saturation boost; light is white, dark is black, and Settings uses grouped gray 243,243,247). At the
  bottom of the band is a 0.67 pt hairline (light about -12/255, dark about +25/255), with content sharp immediately
  below it. `.soft` (must be set explicitly) has no hard edge, with the blur and fade transitioning from the top of the
  screen to about 110 pt.
- Deliberate deviation: after reviewing the iOS look, the direction of matching it was rejected; FlClash does not draw
  the blurred band.

## Sheet (UISheetPresentationController)

FlClash's current behaviour is in architecture.md, "Bottom Sheet Motion"; this section adds the measurements.

- Detents: medium top at 415 (459 from the bottom, about 56.5% of the 812 usable height, about FlClash's 9/16); large
  top at 62. From iOS 26, medium is a floating card inset 8 pt on the left, right and bottom; large is edge to edge, and
  the page behind no longer scales.
- Spring: nominal mass 3 / stiffness 1000 / damping 500, but the measured trajectory is critically damped with omega
  about 18.25, the same for programmatic detent changes and release settle-back. When thrown toward a target, velocity
  is inherited and zeta is about 0.8 (overshoot about 1.7%); away from the target, velocity is zeroed. Keyboard: medium
  rises to the large geometry with the keyboard spring (stiffness 555, critical); a custom 300 pt detent lifts as a
  whole by the keyboard height.
- Release projection uses `DecelerationRate.fast`; at zero velocity the sheet dismisses only when past half of medium.
  A 1000 pt/s downward drag of 85 pt springs back, and a 1500 pt/s drag of 96 pt dismisses. Content handoff: dragging
  up on medium grows the sheet 1:1, and after large the same gesture scrolls content; when the content is already
  scrolled, dragging down only scrolls it back to the top and then springs back.
- Above the top detent: a full-height (.large) sheet does not move. For a non-full-height top detent, dragging up
  stretches the layout height with the UIScrollView rubber band r = (1 - 1/(0.55x/D + 1)) x D, with D = min(100, 778 -
  top detent value) (c90→77.8, c95→38.9, c98→15.56). On release it uses the same critical spring k = 333.33, initial
  velocity 0, with the bottom edge fixed. On a scroll view, dragging up only scrolls the content. FlClash:
  `_rubberBand` in `snap_sheet.dart`.
- Dim: black, light 0.2 and dark 0.48, the same for all detents; a sheet over a sheet adds a 0.6x layer. The medium
  floating card is visually 386×451 with scale 0.9602, top corners about 52, bottom corners 36.5, glass material. Large
  has top corners 62 (pre-scale) and an opaque bottom color (white in light, #1C1C1E in dark). During a medium↔large
  change, H, scale, the inset 8(1-p), the top corner 54+8p and the background alpha = p all follow one linear progress.
  Presenting has no scale and no fade-in.
- Sheet over sheet: the lower sheet shrinks only when both are large (scale 0.9204, top fixed, the upper sheet 10 pt
  lower); medium over medium shrinks the lower to coincide with the upper; other combinations leave the lower one
  still. FlClash: `stackedSheetScale` 0.9204, `stackedSheetPeek` 10 (for large/large the whole stack is 10 higher than
  iOS); the scale amount = the upper sheet's presented progress x the upper sheet's reach x the lower sheet's own
  reach, where on each layout the upper sheet writes its reach into the lower sheet's `_coverReach` (cleared to 0 for a
  non-sheet route); the upper barrier is 0.6x.
- Growing from a bar button: only an explicit `preferredTransition = .zoom(sourceBarButtonItem:)` morphs from the button
  glass (zeta 0.8, omega about 15.9); a popover sourceItem has no effect, and this is not the default.
- Corners (FlClash): `bottomSheetRadiusOf` top = min(screen corner, 38), bottom = min(38, screen bottom corner); the
  floating card `floatingSheetRadius` keeps a constant top corner and its bottom corner transitions to 38 with float.
- Deliberate deviation: iOS's "Liquid Glass deformation" (growing on press, deforming when stretched) is not copied.

## Search

FlClash's current behaviour is in architecture.md, "App Bar Actions". Measurements:

- On an iPhone with a tab bar (UIKit `.integratedButton`; SwiftUI `.searchable` takes the same form once active), the
  top bar button group turns in place into a search field spanning the top bar; the back button, small title and other
  buttons hide and the large title row stays below. The field is at x=16, 44 high, a capsule; on the right is a 44×44
  glass round ✕ with 12 spacing and a 16 right margin; inside the field the magnifier is 20 at x+12, text is 17 body,
  and the clear button is 20. Without a tab bar search is at the bottom: once active the whole navigation bar hides and
  the field rises above the keyboard with a ✕. `Tab(role: .search)` sits in the tab bar by default; the split-off round
  button is the prominent search tab, which must be chosen explicitly. iPad: the button expands in place into a 280×44
  field with a 10 right margin, neighbouring buttons stay on the left if they fit (spacing 16), and there is no ✕.
- Press and stickiness: pressing the field makes the whole field swell about 4.5%, the gap to the ✕ shrinks to about 5
  pt and a sticky neck forms between them (thinnest about 14 pt). Pressing the ✕ swells it to about 1.38x and sticks to
  the field; releasing it more than 50 pt away still triggers cancel. On expansion the ✕ grows from the right end of the
  field; on collapse it retracts into the field. The clear button's solid circle is about 17.3 pt in diameter, with its
  center 24.5 pt from the right end of the field; the magnifier is also label black, and only the placeholder text is
  gray.
- Expand and collapse timeline (from the tap, +-30 ms): on expansion the magnifier and back button vanish on that frame,
  the title fades out over about 80 ms, the button group first collapses the search slot, and about 90 ms later the
  field grows out of the remaining group; the geometry peaks 0.245 s after that, overshooting about 3%, and the field
  content fades in from blur starting at about 110 ms. On collapse the content clears within about 30 ms, pauses about
  80 ms, the field shrinks into the narrowed group (about 0.15 s), the group grows back to its original width over 0.25-
  0.34 s, the magnifier fades back in only at 0.54-0.71 s, the whole group swells about +16 dp by the ElasticPress
  formula, and it is still at about 0.74 s. On a pushed page the left segment of the field shrinks back into the back
  button and the ✕ turns back into the button group on collapse.
- Collapse of a standalone search button (not in a group): on an iPhone root page the ✕ vanishes on that frame, the
  field slides right and fades out within 0.12 s, and the button reassembles from a droplet at "button→1/4 of the way to
  the field center, 25% size" (x follows the main spring k165 zeta 0.8, overshooting its home position by about 0.71 of
  the travel, still at about 0.6 s). On a pushed page the field retracts into the back button and the droplet is
  "pinched out" from the right end. On iPad the field deforms into the button (k241 zeta 0.77), bulges +20% at the
  center at 0.51 s, and is still at about 0.68 s.
- Slowing down does not work: neither `-UIAnimationDragCoefficient` nor the window `layer.speed` slows the navigation
  bar glass morph; for finer timing, record more takes.
- FlClash implementation: `_SearchMotion` (`lib/ui/scaffold/scaffold_search.dart`) drives a segmented `_SearchMove`
  timeline from one clock (an interruption resumes from the current value), with an expand spring of k390 and a
  collapse spring of k600 (zeta 0.75). `_SearchLead` really narrows and expands, `_SearchSwell` uses
  `ElasticPress.growthOf`, and `_SearchReturn` has four variants: group, morph, droplet and pinch (a single button uses
  the real bar button for the droplet, starting at the field center measured when collapsing). `GooSurface` / `GooPane`
  (`goo.dart`) with `gooGeometry` use a smooth minimum, with a resting blend of 8 dp and +8 while pressed. The clear
  button is onSurface (28) and matches; the magnifier is still the InputDecorator default onSurfaceVariant (71; iOS
  measures gray level 3).
- Deliberate deviations: (1) segments join while the previous one is still decelerating and do not pause as iOS does
  (about 0.55 s to rest on collapse, about 0.22 s on expand), because following iOS's segments felt stop-and-go; (2) the
  field also stretches with a drag (in iOS a 40 pt vertical drag does not move the field); (3) on phone pushed pages
  without a tab bar (requests, logs, connections, DNS, access control and others) search is uniformly a persistent
  bottom control and the navigation bar does not hide (iOS hides the whole bar when active); access control already has
  a status strip at the bottom, so its search returns to a top bar button (`Scaffold.searchInBar`), leaving only one
  floating item at the bottom; (4) on collapse the field first shrinks to the size of the button group before the
  spring has 0.2 left, then fades out within the same capsule (so that a field wider than the group does not leave a
  ghost outline when fading).

## Pointer hover (iPad, button group)

- A capsule highlight appears under the pointed button: 36 pt high (group height 44, 4 above and below), as wide as the
  button itself; about 8% black in light and about 8% white in dark. The glyph does not change, the group does not
  swell, and the pointer does not morph.
- The highlight does not follow the pointer within a button; on crossing into the next button it slides there (the width
  transitions at the same time) with a spring of k about 2350 and zeta about 0.95, in place in about 120 ms. Entering
  fades in in place and leaving fades out in place, with no scaling, perceived at about 365-400 ms.
- FlClash: `TonalButtonGroup` (`_HoverMark` / `_HoverSlot` in `prism_ui/lib/button.dart`) insets 2×4 dp, slides with
  k2350
  zeta0.95 and fades in and out over 380 ms; buttons in the group no longer use `ElasticHover` to swell the group. The
  highlight reads the buttons' live positions at paint time and applies the intermediate clipping (the search slot that
  `_SearchLead` narrows), interpolating only from the previous spot to the current button. It used to snapshot the
  coordinates at entry; when the group origin moved while search collapsed, the highlight ended up on the search slot
  and hover looked wrong while the search animation was still running, so it now follows live.
- List cells, grid cells and gray/filled UIButton show no visible change under an iPadOS 27 pointer.

## List/grid cell and UIButton press

FlClash's current behaviour is in `.agents/surfaces.md`, Press (Ink 10% state layer, Tint button 75% / dark mixes 20%
white, 150 ms scroll view delay, no scaling, hover 4%). Measurements:

- An insetGrouped list cell and a grid cell using the listGroupedCell background: pressing replaces the fill with
  systemGray4 (light 255→209,209,214; dark 28,28,30→58,58,60), appearing instantly. In a scroll view the highlight shows
  only about 160-200 ms after press (delaysContentTouches 150 ms); a quick 60 ms tap never lights, pressing then
  dragging at once does not light, and starting to scroll after holding extinguishes it at once. Release fades out over
  0.30 s on the CA default curve (0.25, 0.1, 0.25, 1) = `Curves.ease`; shouldHighlight without selection goes out at
  once.
- UIButton (not in a scroll view): a quick tap lights immediately, release takes about 0.25 s easeInOut, no scaling. In
  light, opacity x 0.75; in dark it gets brighter instead: filled 0,145,255→51,167,255 (about 20% toward white), gray
  fill alpha .32→.354. A UIButton in a scroll view follows the cell rule (lights after about 165 ms).
- Deliberate deviation: the measured cell behaviour is a systemGray4 replacement, while FlClash uses an onSurface 10%
  state layer ("press = 10% state layer"), plus a 4% hover on desktop pointers.

## Navigation push/pop and zoom transitions

Read from the UIKit settings objects `_UIFluidNavigationTransitionsDomain` and `UIKit._UIZoomTransitionSettingsDomain`,
sampled per frame with `UIUpdateLink`, matching the settings values within 1e-5. Page geometry does not use a
CAAnimation; it is a spring inside the UIKit process, with initial velocity = retargetImpulse x stiffness.

- Push/pop: critically damped, response 0.30, impulse 0.02 → v0 8.773 (FlClash uses 9, a difference of at most 0.4%).
  The lower page moves -0.301W; dimming is black 0.1 x coverage; the shadow is black 0.04 constant, sigma 12, offset (0,
  -3). Deliberate deviation: FlClash does not draw the push shadow in dark, because iOS dark pages are black and the
  shadow is invisible.
- Interactive back (push): starts only at >= 30 pt from the press point; the follow spring is zeta 0.85 / 0.08; the
  overscroll rubber band is rb(d) = (1 - 1/(0.55d/D + 1)) x D with D = 0.5W; the release decision is T/W + 0.35 x v >=
  0.4665 (v is the last-sample velocity in W/s; at rest about 47% is needed to go back); toward the end at > 1.5 W/s the
  velocity is multiplied by 4.25 and only used for the release spring; the release spring is 0.85/0.30.
- Zoom interactive dismiss: starts after 10 pt, only toward the end or downward with an off-axis angle of at most about
  22 degrees (anything with an upward component never starts); the drag uses L = 0.6 x the axis length, scale = 1 - 0.4
  x prog around the start point and follows the finger, with 1.0/0.2 on the first update and 0.85/0.08 afterward; the
  decision is d + 0.1 x v >= 150 pt; the dismiss morph p is 1.0/0.40, chasing the current tile position with 0.42/0.80
  and 0.45/0.82; cancel is 1/0.25. During a zoom drag the bar buttons cross-fade by progress (upper page max(0, 1 -
  prog/0.6), lower page max(0, (prog - 0.4)/0.6)).
- Zoom curves: opening zoomIn is critically damped 0.34, impulse 0.016 → v0 5.464; closing zoomOut is zeta 0.92 (bounce
  0.08) 0.34, starting from rest.
- Zoom composition: the card background interpolates from the source background to the target background by q; target
  page opacity min(1, q/0.65); the source snapshot is top-aligned and fills the width, and for a cell source its opacity
  is min(1, (1-q)/0.65); the shadow is black 0.4q, sigma 3→40, dy -3→10, and does not show through the inside of a
  translucent card; the lower page content scales 8.624% x q and darkens 0.15q; width is lerped, and corner and height
  are in page space when opening and in screen space when closing.
- FlClash: the screen corner exists only on Android 12+; a zoom route must be a ModalRoute (HeroController is offstage
  on
  the first frame). `OpenContainer` (`prism_ui/lib/open_container.dart`) has the curves, the background by q, and both
  the page and the source row drawn as snapshots with opacity added (Impeller folds opacity into a single image draw, so
  the transition costs 1 render pass per frame, where the old version used 2 in the first 160 ms); the shadow is clipped
  with evenOdd to exclude the card interior, and dark draws no shadow. In `drag_back.dart` the follow spring is
  `_DragFollower` with a resident ticker (do not use animateWith, whose per-frame reset stays at t=0). The left rubber
  band of a push records the overshoot share via `dragBackOverdrag`, and `_CardTransition` adds it to this page's offset
  and to the lower page's parallax, with the lower dimming capped at 0.1; releasing in overscroll has the follower start
  the release spring from the stretched position. The "page space vs screen space" reversal of opening height and corner
  is not reproduced (reversing would jump).
- Known gaps (not fixed): the drag-back Listener wraps the whole page, so a horizontal scroll inside the content (the
  editor's TwoDimensionalScrollable) wins first, whereas in iOS a screen-edge drag takes priority over content; the
  editor line-number gutter selects the whole line on press. In tests a single-frame `pump(duration)` does not advance a
  ticker; call `pump()` first.

## Text selection and edit menu (iOS 27.0 24A5380i, iPhone 17 Pro)

- Edit menu `_UIEditMenuListView` (Liquid Glass): a capsule 44 high with corner radius 22 and no arrow; width = 4 + the
  cells, and on overflow a 36 dp trailing chevron is added (a 36×36 circle filled (116,116,128,.08) with 4 dp inner
  padding). Cells: SF 15 Regular, text padded 16 left and right (cell = text + 32), the first cell 4 from the capsule
  edge; text only, no icons; the divider is 1×18 (y 13..31, (60,60,67,.12)), with none next to the chevron. Only items
  that fit completely are placed, with a limit of 370 (screen width - 32) minus the chevron. Tapping the chevron does
  not page: the capsule morphs into a context menu card (250×350 / 6 rows, top-aligned with the capsule), reaching full
  size in about 0.2 s and settling at 0.45 s; rows are 42 dp, 17 Regular, with a leading icon.
- Animation: opening is scale 0.2→1 + opacity 0→1 with a spring k522.9 c38.87 (zeta .85), settling at 0.405 s, with the
  pivot on the side near the text; closing is k372.9 c32.83, visually gone in 0.12-0.15 s. Dragging a handle hides the
  menu for 0.25 s from when it starts moving, and it springs back at the new position 0.1 s after the finger lifts. A
  pressed item is a capsule of about 71×38 inside the cell, filled (241,241,247) in light, with no scaling. Position:
  the menu top = row bottom + 15, or its bottom = row top - 15; if the row center is in the upper half of the safe area
  the menu goes below (boundary about 451); horizontally it is centered on the selection and clamped to a 16 margin.
- Glass: the UIKit layer parameters (light blur 5, white x 1.03 ...) cannot be filled directly into our fields. FlClash
  fit: `LiquidGlassStyle.editMenu` blur 0, haze .71 / hazeBlur 15.6; light tint white .52, saturation 1.97, brightness
  .98; dark tint gray .27 at .52, contrast -.33, saturation 1.8, brightness 1.55, with a body error of at most 5/255.
  Not matched: the elliptical refraction iOS has at the two ends of the capsule.
- Selection is rgba(0, 84.2, 165.8, alpha), light alpha .20, dark .35, with square corners. The caret is 2 wide with no
  rounding and line-height tall, (66.3, 107.1, 242.2), blinking with a 1.0 s period (500 ms solid, 150 ms fade-out, 200
  ms off, 150 ms fade-in), restarting on typing. During a long-press drag a blue floating cursor follows the finger
  and a gray ghost snaps to the insertion point.
- Handles: the bar is 2 wide and line-height tall; the ball is 16.5 in diameter, color (20, 111, 225) in both light and
  dark, appearing without animation; hit area: 34 below the ball center and 25 left and right.
- Magnifier: 115×85, corner radius 42.5 (continuous), 1.25x; its center is 75 dp above the row center and does not
  follow the finger's y; horizontally it follows the finger with a spring k about 506 c about 37.8, with left >= 8 and
  right <= 386. It appears after a 0.5 s long press, morphing from the 2×22 cursor rect, reaching 115 at 0.35 s, a peak
  of 123.5 at 0.5 s, and back to 115 at 0.9 s (zeta about .6); closing starts 45 ms after lifting and is gone in .23 s.
- Gestures: a single tap places the cursor without a menu; tapping an existing cursor toggles the menu; tapping
  elsewhere
  moves the cursor and closes the menu; a double tap selects a word with handles and the menu; a triple tap selects a
  paragraph; tapping inside the selection toggles the menu; a long press shows the magnifier and the floating cursor,
  and releasing places the cursor without a menu. Long press on an empty field: iOS shows the magnifier even for an
  empty UITextField, Android does not for an empty EditText (Flutter shows it on long press, still different).
- Deliberate deviation: the capsule keeps 4 dp at each end (width = 8 + the cells; the pressed capsule is 32 high with 6
  from each end, with the same color as a pressed PopupMenu row); the expanded card has 8 inner padding, 16 row
  corners and a 24 card corner; on phones the menu stays after select-all (iOS measures that it does not appear, which
  was judged a problem), while desktop select-all still closes the menu. Editor menu anchor: the cursor rect, a
  single-line selected segment, or the whole row for multiple lines.
- Menu ownership: `EditMenuRoute` (`edit_menu.dart`) only runs an item when tapped and does not close itself; the
  selection owner decides whether to close it or to update `items` / `selection` (a ValueListenable), like Flutter's
  toolbar model. Do not go back to the "close then reopen" patch. `SelectableRegion` re-shows by itself on select-all,
  which is still a new route.

## Foreground notification banner

- Geometry: on iPhone, inset 8 left and right, 386 wide, top 62.7 (about 12 below the Dynamic Island), and 66 high for a
  single-line title plus a single-line body; on iPad a fixed 556 wide, centered, top y=8. The corner is a superellipse
  fit of r about 27.5, n about 2.5 (FlClash uses `AppRadius.xl`).
- Material: 10 pt stripes are about 28% sharp, the same structure as the dock's pill, so `LiquidGlassStyle.banner` uses
  the pill's haze with contrast 0; the top and bottom edges each have a bright edge of about 1.7 pt.
- Entry: it widens from the Dynamic Island and drops; the width spring is zeta 0.74 omega 7.5 and the vertical spring
  zeta 0.62 omega 11, settling in about 1.1 s; exit takes about 0.15 s.
- Dwell and queue: each stays 7.3 s, one at a time; when others are queued the current one shows only about 3.3 s before
  hiding and the next enters about 0.05 s later; this is independent of threadIdentifier.
- Deliberate deviation: FlClash's dwell and queueing differ from iOS by product decision; the glass details are in
  architecture.md, Liquid Glass, banner section.
