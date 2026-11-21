import 'dart:async';
import 'dart:ui' as ui;

import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_ui/prism_ui.dart';
import '../helpers/test_app.dart';

const _red = Color(0xFFFF0000);
const _green = Color(0xFF00FF00);
const _blue = Color(0xFF0000FF);
const _clear = LiquidGlassStyle(tint: Colors.transparent, blur: 0);

typedef _Pane = ({
  Rect pane,
  Rect slot,
  Rect place,
  double scale,
  int level,
  ui.Image atlas,
});

Widget _app(
  Widget child, {
  bool enabled = true,
  LiquidGlassQuality quality = LiquidGlassQuality.ultra,
}) => HostApp(
  home: LiquidGlassScope(
    enabled: true,
    quality: quality,
    child: LiquidGlassHost(enabled: enabled, child: child),
  ),
);

Widget _pane(Rect rect, {LiquidGlassStyle style = _clear, Widget? child}) =>
    Positioned.fromRect(
      rect: rect,
      child: LiquidGlass(style: style, child: child),
    );

LiquidGlassCapture _capture() => LiquidGlassHost.debugLastCapture!;

class _HeldPane extends LeafRenderObjectWidget {
  const _HeldPane(
    this.rect,
    this.hold, {
    this.style = _clear,
    this.steadyFrost = false,
  });

  final Rect rect;
  final Rect hold;
  final LiquidGlassStyle style;
  final bool steadyFrost;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderHeldPane(rect, hold, style, steadyFrost);

  @override
  void updateRenderObject(BuildContext context, _RenderHeldPane renderObject) {
    renderObject
      ..rect = rect
      ..hold = hold
      ..style = style
      ..steadyFrost = steadyFrost
      ..markNeedsPaint();
  }
}

class _RenderHeldPane extends RenderBox {
  _RenderHeldPane(this.rect, this.hold, this.style, this.steadyFrost);

  Rect rect;
  Rect hold;
  LiquidGlassStyle style;
  bool steadyFrost;
  late final _pane = LiquidGlassPane(markNeedsPaint);

  @override
  bool get sizedByParent => true;

  @override
  bool get alwaysNeedsCompositing => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void dispose() {
    _pane.dispose();
    super.dispose();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _pane.paint(
      context,
      rect.shift(offset),
      shape: LiquidGlassCorners.circular(0),
      style: style,
      hold: hold.shift(offset),
      steadyFrost: steadyFrost,
    );
  }
}

List<Widget> _stripes() => [
  const Positioned.fill(child: ColoredBox(color: Colors.white)),
  for (var stripe = 0; stripe < 56; stripe++)
    Positioned(
      left: stripe * 14.3,
      top: stripe.isEven ? 0 : 40,
      width: 5 + stripe % 4 * 2.5,
      bottom: 0,
      child: ColoredBox(color: [_red, _green, _blue][stripe % 3]),
    ),
  for (var stripe = 0; stripe < 40; stripe++)
    Positioned(
      left: 0,
      top: stripe * 15.7,
      right: stripe.isEven ? 0 : 90,
      height: 4,
      child: const ColoredBox(color: Color(0xB3000000)),
    ),
];

// The first panes of a run ask for the shaders, which come after their frame.
Future<void> _shadersLoaded(WidgetTester tester) => tester.pump();

int _furthest(List<int> one, List<int> other) {
  expect(one.length, other.length);
  var furthest = 0;
  for (var index = 0; index < one.length; index++) {
    final apart = (one[index] - other[index]).abs();
    if (apart > furthest) {
      furthest = apart;
    }
  }
  return furthest;
}

/// The frame as the view shows it, a channel at a time.
Future<List<int>> _frame(WidgetTester tester) async {
  final layer = tester.binding.renderViews.first.debugLayer! as OffsetLayer;
  final image = (await tester.runAsync(
    () => layer.toImage(Offset.zero & tester.view.physicalSize),
  ))!;
  final bytes = (await tester.runAsync(image.toByteData))!;
  image.dispose();
  return bytes.buffer.asUint8List();
}

Future<Color> _behind(WidgetTester tester, _Pane pane, Offset point) async {
  final texel = pane.place.topLeft + (point - pane.slot.topLeft) * pane.scale;
  final bytes = (await tester.runAsync(pane.atlas.toByteData))!;
  final offset = (texel.dy.floor() * pane.atlas.width + texel.dx.floor()) * 4;
  return Color.fromARGB(
    bytes.getUint8(offset + 3),
    bytes.getUint8(offset),
    bytes.getUint8(offset + 1),
    bytes.getUint8(offset + 2),
  );
}

void main() {
  setUp(() => LiquidGlassHost.debugLastCapture = null);

  testWidgets('a pane reads what lies behind it and not what it holds', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: _red)),
            _pane(
              const Rect.fromLTWH(100, 100, 200, 100),
              child: const ColoredBox(color: _blue),
            ),
          ],
        ),
      ),
    );

    final pane = _capture().panes.single;
    expect(pane.pane, const Rect.fromLTWH(100, 100, 200, 100));
    expect(pane.level, 0);
    expect(await _behind(tester, pane, const Offset(200, 150)), _red);
  });

  testWidgets('a host within a snapshot takes the panes the snapshot holds', (
    tester,
  ) async {
    final controller = SnapshotController(allowSnapshotting: true);
    addTearDown(controller.dispose);
    Widget scene({required bool inner}) => _app(
      SnapshotWidget(
        controller: controller,
        mode: SnapshotMode.permissive,
        child: LiquidGlassHost(
          enabled: inner,
          child: Stack(
            children: [
              const Positioned.fill(child: ColoredBox(color: _red)),
              _pane(const Rect.fromLTWH(100, 100, 200, 100)),
            ],
          ),
        ),
      ),
    );

    await tester.pumpWidget(scene(inner: false));
    expect(LiquidGlassHost.debugHeldCaptures, 0);

    controller.clear();
    await tester.pumpWidget(scene(inner: true));
    expect(LiquidGlassHost.debugHeldCaptures, 1);
  });

  testWidgets('a host within another leaves its panes to the outer one', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        LiquidGlassHost(
          enabled: true,
          child: Stack(
            children: [
              const Positioned.fill(child: ColoredBox(color: _red)),
              _pane(const Rect.fromLTWH(100, 100, 200, 100)),
            ],
          ),
        ),
      ),
    );

    final before = LiquidGlassHost.debugCaptures;
    tester.binding.scheduleFrame();
    await tester.pump();
    expect(LiquidGlassHost.debugCaptures - before, 1);
    expect(_capture().panes, hasLength(1));
  });

  testWidgets('a frame that leaves the backdrop as it was keeps the capture', (
    tester,
  ) async {
    Widget scene(Color behind) => _app(
      Stack(
        children: [
          Positioned.fill(child: ColoredBox(color: behind)),
          _pane(const Rect.fromLTWH(100, 100, 200, 100)),
        ],
      ),
    );

    await tester.pumpWidget(scene(_red));
    final first = _capture().panes.single.atlas;
    expect(_capture().snapshots, 1);

    tester.binding.scheduleFrame();
    await tester.pump();
    expect(_capture().snapshots, 0);
    expect(_capture().panes.single.atlas, same(first));

    await tester.pumpWidget(scene(_green));
    expect(_capture().snapshots, 1);
    final pane = _capture().panes.single;
    expect(await _behind(tester, pane, const Offset(200, 150)), _green);
  });

  testWidgets('a pane moving within its hold keeps one capture', (
    tester,
  ) async {
    const hold = Rect.fromLTWH(50, 50, 400, 300);
    Widget scene(Rect rect) => _app(
      Stack(
        children: [
          const Positioned.fill(
            child: RepaintBoundary(child: ColoredBox(color: _red)),
          ),
          Positioned.fill(child: _HeldPane(rect, hold)),
        ],
      ),
    );

    await tester.pumpWidget(scene(const Rect.fromLTWH(100, 100, 50, 50)));
    expect(_capture().snapshots, 1);
    final first = _capture().panes.single;
    expect(first.slot.contains(hold.bottomRight - const Offset(1, 1)), isTrue);

    await tester.pumpWidget(scene(const Rect.fromLTWH(200, 150, 200, 150)));
    expect(_capture().snapshots, 0);
    expect(_capture().panes.single.slot, first.slot);
    expect(_capture().panes.single.atlas, same(first.atlas));

    await tester.pumpWidget(scene(const Rect.fromLTWH(500, 500, 50, 50)));
    expect(_capture().snapshots, 1);
  });

  testWidgets('a steady pane shrinking within its hold keeps one capture', (
    tester,
  ) async {
    const rect = Rect.fromLTWH(100, 100, 200, 100);
    const frost = LiquidGlassStyle(tint: Colors.transparent, blur: 12);
    Widget scene(double scale) => _app(
      Stack(
        children: [
          const Positioned.fill(
            child: RepaintBoundary(child: ColoredBox(color: _red)),
          ),
          Positioned.fill(
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.topLeft,
              origin: rect.center,
              child: const _HeldPane(
                rect,
                rect,
                style: frost,
                steadyFrost: true,
              ),
            ),
          ),
        ],
      ),
    );

    await tester.pumpWidget(scene(1.2));
    expect(_capture().snapshots, 1);
    final first = _capture().panes.single;

    for (final scale in [1.1, 1.0]) {
      await tester.pumpWidget(scene(scale));
      expect(_capture().snapshots, 0);
      expect(_capture().panes.single.atlas, same(first.atlas));
    }
  });

  testWidgets('a pane reads past a veil, which fades without a capture', (
    tester,
  ) async {
    Widget scene(Color veil) => _app(
      Stack(
        children: [
          const Positioned.fill(
            child: RepaintBoundary(child: ColoredBox(color: _red)),
          ),
          Positioned.fill(
            child: LiquidGlassVeil(color: AlwaysStoppedAnimation(veil)),
          ),
          _pane(const Rect.fromLTWH(100, 100, 200, 100)),
        ],
      ),
    );

    await tester.pumpWidget(scene(const Color(0x40000000)));
    final first = _capture().panes.single;
    expect(await _behind(tester, first, const Offset(200, 150)), _red);

    await tester.pumpWidget(scene(const Color(0x80000000)));
    expect(_capture().snapshots, 0);
    expect(_capture().panes.single.atlas, same(first.atlas));
  });

  testWidgets('a veil with content drawn over it lies in the capture', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: _red)),
            const Positioned.fill(
              child: LiquidGlassVeil(
                color: AlwaysStoppedAnimation(Color(0x80000000)),
              ),
            ),
            const Positioned(
              left: 100,
              top: 100,
              width: 100,
              height: 100,
              child: ColoredBox(color: _green),
            ),
            _pane(const Rect.fromLTWH(100, 100, 200, 100)),
          ],
        ),
      ),
    );

    final pane = _capture().panes.single;
    expect(await _behind(tester, pane, const Offset(150, 150)), _green);
    final veiled = await _behind(tester, pane, const Offset(250, 150));
    expect(veiled.r, inExclusiveRange(0.4, 0.6));
    expect(veiled.a, 1);
  });

  testWidgets('content moving by part of a capture pixel captures alike', (
    tester,
  ) async {
    Widget scene(double top) => _app(
      Stack(
        children: [
          Positioned(
            left: 120,
            top: top,
            width: 160,
            height: 13,
            child: const RepaintBoundary(child: ColoredBox(color: _red)),
          ),
          _pane(
            const Rect.fromLTWH(100, 100, 200, 40),
            style: const LiquidGlassStyle(tint: Colors.transparent, blur: 8),
          ),
        ],
      ),
    );
    Future<List<int>> slot() async {
      final pane = _capture().panes.single;
      expect(pane.scale, lessThan(1));
      final bytes = (await tester.runAsync(pane.atlas.toByteData))!;
      final place = pane.place;
      return [
        for (var y = place.top.toInt(); y < place.bottom; y++)
          ...bytes.buffer.asUint8List(
            (y * pane.atlas.width + place.left.toInt()) * 4,
            place.width.toInt() * 4,
          ),
      ];
    }

    await tester.pumpWidget(scene(104));
    final still = await slot();
    await tester.pumpWidget(scene(104.5));
    expect(_capture().snapshots, 1);
    expect(await slot(), still);
  });

  testWidgets('a pane over another reads a capture with that one drawn in', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: _red)),
            _pane(
              const Rect.fromLTWH(100, 100, 200, 100),
              style: const LiquidGlassStyle(tint: _blue, blur: 0),
            ),
            _pane(const Rect.fromLTWH(250, 150, 100, 100)),
            _pane(const Rect.fromLTWH(500, 400, 100, 100)),
          ],
        ),
      ),
    );

    final [lower, upper, apart] = _capture().panes;
    expect([lower.level, upper.level, apart.level], [0, 1, 0]);
    expect(upper.atlas, isNot(same(lower.atlas)));
    expect(apart.atlas, same(lower.atlas));
    final over = await _behind(tester, upper, const Offset(275, 175));
    expect(over.b, greaterThan(over.r));
    expect(await _behind(tester, upper, const Offset(325, 225)), _red);
  });

  testWidgets('panes in one group share a level and read past each other', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        LiquidGlassGroup(
          child: Stack(
            children: [
              const Positioned.fill(child: ColoredBox(color: _red)),
              _pane(
                const Rect.fromLTWH(100, 100, 200, 100),
                style: const LiquidGlassStyle(tint: _blue, blur: 0),
              ),
              _pane(const Rect.fromLTWH(250, 150, 100, 100)),
            ],
          ),
        ),
      ),
    );

    final capture = _capture();
    final [lower, upper] = capture.panes;
    expect([lower.level, upper.level], [0, 0]);
    expect(upper.atlas, same(lower.atlas));
    expect(capture.snapshots, 1);
    expect(await _behind(tester, upper, const Offset(275, 175)), _red);
  });

  testWidgets('a pane stays on its level beside one past its frost', (
    tester,
  ) async {
    const frosted = LiquidGlassStyle(tint: Colors.transparent);
    Future<int> levelBeside(double gap) async {
      await tester.pumpWidget(
        _app(
          Stack(
            children: [
              const Positioned.fill(child: ColoredBox(color: _red)),
              _pane(const Rect.fromLTWH(100, 100, 200, 100), style: frosted),
              _pane(Rect.fromLTWH(300 + gap, 100, 100, 100), style: frosted),
            ],
          ),
        ),
      );
      return _capture().panes.last.level;
    }

    expect(await levelBeside(8), 0);
    expect(await levelBeside(4), 1);
  });

  Widget bandsScene(Color changing) => _app(
    Stack(
      children: [
        Positioned(
          left: 0,
          top: 0,
          width: 400,
          height: 300,
          child: RepaintBoundary(child: ColoredBox(color: changing)),
        ),
        const Positioned(
          left: 0,
          top: 300,
          width: 400,
          height: 300,
          child: RepaintBoundary(child: ColoredBox(color: _blue)),
        ),
        _pane(const Rect.fromLTWH(100, 100, 200, 100)),
        _pane(
          const Rect.fromLTWH(100, 420, 200, 100),
          style: const LiquidGlassStyle(tint: Colors.transparent, blur: 12),
        ),
      ],
    ),
  );

  testWidgets('a level redraws only the bands whose backdrop changed', (
    tester,
  ) async {
    LiquidGlassHost.debugCarryBandsOverride = true;
    addTearDown(() => LiquidGlassHost.debugCarryBandsOverride = null);

    await tester.pumpWidget(bandsScene(_red));
    expect(_capture().snapshots, 1);
    expect(_capture().keptBands, 0);

    await tester.pumpWidget(bandsScene(_green));
    expect(_capture().snapshots, 1);
    expect(_capture().keptBands, 1);
    final [changed, kept] = _capture().panes;
    expect(await _behind(tester, changed, const Offset(200, 150)), _green);
    expect(await _behind(tester, kept, const Offset(200, 470)), _blue);
  });

  testWidgets(
    'without Impeller a level redraws every band, copying from no capture',
    (tester) async {
      await tester.pumpWidget(bandsScene(_red));
      await tester.pumpWidget(bandsScene(_green));
      expect(_capture().snapshots, 1);
      expect(_capture().keptBands, 0);
      final [changed, kept] = _capture().panes;
      expect(await _behind(tester, changed, const Offset(200, 150)), _green);
      expect(await _behind(tester, kept, const Offset(200, 470)), _blue);
    },
    skip: ui.ImageFilter.isShaderFilterSupported,
  );

  testWidgets('the standard tier frosts a hazed pane through its haze alone', (
    tester,
  ) async {
    const hazed = LiquidGlassStyle(
      tint: Colors.transparent,
      blur: 0,
      haze: 0.72,
      hazeBlur: 15.6,
    );
    Future<double> scaleAt(LiquidGlassQuality quality) async {
      await tester.pumpWidget(
        _app(
          Stack(
            children: [
              const Positioned.fill(child: ColoredBox(color: _red)),
              _pane(const Rect.fromLTWH(100, 100, 200, 100), style: hazed),
            ],
          ),
          quality: quality,
        ),
      );
      return _capture().panes.single.scale;
    }

    expect(
      await scaleAt(LiquidGlassQuality.ultra),
      tester.view.devicePixelRatio,
    );
    expect(await scaleAt(LiquidGlassQuality.standard), lessThan(1));
  });

  testWidgets('a pane under a layer of its own reads only that layer', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: _red)),
            Positioned.fill(
              child: Opacity(
                opacity: 0.5,
                child: Stack(
                  children: [
                    const Positioned(
                      left: 100,
                      top: 100,
                      width: 100,
                      height: 100,
                      child: ColoredBox(color: _green),
                    ),
                    _pane(const Rect.fromLTWH(100, 100, 200, 100)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final pane = _capture().panes.single;
    expect(await _behind(tester, pane, const Offset(150, 150)), _green);
    expect((await _behind(tester, pane, const Offset(250, 150))).a, 0);
  });

  testWidgets('a pane under a glass fade reads through it', (tester) async {
    await tester.pumpWidget(
      _app(
        Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: _red)),
            Positioned.fill(
              child: LiquidGlassFade(
                opacity: const AlwaysStoppedAnimation(0.5),
                child: Stack(
                  children: [
                    const Positioned(
                      left: 100,
                      top: 100,
                      width: 100,
                      height: 100,
                      child: ColoredBox(color: _green),
                    ),
                    _pane(const Rect.fromLTWH(100, 100, 200, 100)),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    final pane = _capture().panes.single;
    final faded = await _behind(tester, pane, const Offset(150, 150));
    expect(faded.r, inExclusiveRange(0, 1));
    expect(faded.g, inExclusiveRange(0, 1));
    expect(await _behind(tester, pane, const Offset(250, 150)), _red);
  });

  testWidgets('an edit menu reads the page behind it as it fades in', (
    tester,
  ) async {
    final navigator = GlobalKey<NavigatorState>();
    final selection = ValueNotifier(const Rect.fromLTWH(180, 80, 40, 20));
    addTearDown(selection.dispose);
    await tester.pumpWidget(
      HostApp(
        navigatorKey: navigator,
        builder: (context, child) => LiquidGlassScope(
          enabled: true,
          quality: LiquidGlassQuality.standard,
          child: LiquidGlassHost(enabled: true, child: child!),
        ),
        home: const ColoredBox(color: _red, child: SizedBox.expand()),
      ),
    );
    unawaited(
      navigator.currentState!.push(
        EditMenuRoute(
          barrierLabel: 'close',
          selection: selection,
          items: ValueNotifier([
            PopupMenuItem(label: 'Copy', onPressed: () {}),
          ]),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    final pane = _capture().panes.single;
    expect(await _behind(tester, pane, pane.pane.center), _red);

    await tester.pumpAndSettle();
  });

  for (final quality in LiquidGlassQuality.values) {
    testWidgets('an edit menu opens and closes on one capture ($quality)', (
      tester,
    ) async {
      final navigator = GlobalKey<NavigatorState>();
      final selection = ValueNotifier(const Rect.fromLTWH(180, 80, 40, 20));
      addTearDown(selection.dispose);
      await tester.pumpWidget(
        HostApp(
          navigatorKey: navigator,
          builder: (context, child) => LiquidGlassScope(
            enabled: true,
            quality: quality,
            child: LiquidGlassHost(enabled: true, child: child!),
          ),
          home: const ColoredBox(color: _red, child: SizedBox.expand()),
        ),
      );
      unawaited(
        navigator.currentState!.push(
          EditMenuRoute(
            barrierLabel: 'close',
            selection: selection,
            items: ValueNotifier([
              PopupMenuItem(label: 'Copy', onPressed: () {}),
            ]),
          ),
        ),
      );
      await tester.pump();
      var snapshots = _capture().snapshots;
      for (var frame = 0; frame < 30; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        snapshots += _capture().snapshots;
      }
      expect(snapshots, lessThanOrEqualTo(1));

      navigator.currentState!.pop();
      await tester.pump();
      snapshots = _capture().snapshots;
      for (var frame = 0; frame < 9; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        snapshots += _capture().snapshots;
      }
      expect(snapshots, 0);

      await tester.pumpAndSettle();
    });
  }

  testWidgets('a frosted pane reads a capture that holds its blur', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: _red)),
            const Positioned(
              left: 200,
              top: 0,
              right: 0,
              bottom: 0,
              child: ColoredBox(color: _blue),
            ),
            _pane(
              const Rect.fromLTWH(100, 100, 200, 100),
              style: const LiquidGlassStyle(tint: Colors.transparent, blur: 12),
            ),
          ],
        ),
      ),
    );

    final pane = _capture().panes.single;
    expect(pane.scale, lessThan(1));
    final near = await _behind(tester, pane, const Offset(194, 150));
    expect(near.b, inExclusiveRange(0.15, 0.5));
    expect(await _behind(tester, pane, const Offset(120, 150)), _red);
  });

  testWidgets('a pane that skips the rim in its middle draws alike', (
    tester,
  ) async {
    addTearDown(() => LiquidGlassHost.debugSkipRimOverride = null);
    final colorScheme = ColorScheme.fromSeed(seedColor: _blue);
    await tester.pumpWidget(
      _app(
        Stack(
          children: [
            ..._stripes(),
            _pane(
              const Rect.fromLTWH(60, 40, 300, 180),
              style: LiquidGlassStyle.regular(colorScheme),
            ),
            _pane(
              const Rect.fromLTWH(380, 260, 320, 200),
              style: LiquidGlassStyle.menu(colorScheme),
            ),
            _pane(
              const Rect.fromLTWH(60, 300, 280, 120),
              style: LiquidGlassStyle.pill(colorScheme),
            ),
          ],
        ),
      ),
    );
    await _shadersLoaded(tester);

    Future<List<int>> drawn({required bool skipping}) {
      LiquidGlassHost.debugSkipRimOverride = skipping ? null : false;
      tester.binding.scheduleFrame();
      return tester.pump().then((_) => _frame(tester));
    }

    final throughout = await drawn(skipping: false);
    final skipped = await drawn(skipping: true);

    expect(throughout.toSet().length, greaterThan(64));
    expect(_furthest(throughout, skipped), 0);
  }, skip: !ui.ImageFilter.isShaderFilterSupported);

  test('a pane has a middle only past all its rim reaches', () {
    final colorScheme = ColorScheme.fromSeed(seedColor: _blue);
    final menu = LiquidGlassStyle.menu(colorScheme);
    const card = Rect.fromLTWH(0, 0, 270, 170);

    // Its bevel of 20 dp, then what a corner of 34 dp cuts off a rectangle.
    final inner = liquidGlassInner(card, 34, card.size, menu, shine: true);
    expect(inner.left, closeTo(24.11, 0.01));
    expect(inner.top, closeTo(24.11, 0.01));
    expect(inner.right, closeTo(245.89, 0.01));
    expect(inner.bottom, closeTo(145.89, 0.01));

    const small = Rect.fromLTWH(0, 0, 20, 20);
    expect(
      liquidGlassInner(small, 10, small.size, menu, shine: false),
      Rect.zero,
    );
    expect(
      liquidGlassInner(
        card,
        34,
        card.size,
        LiquidGlassStyle.lens(colorScheme),
        shine: false,
      ),
      Rect.zero,
    );
  });

  testWidgets('a host turned off captures nothing', (tester) async {
    await tester.pumpWidget(
      _app(
        Stack(
          children: [
            const Positioned.fill(child: ColoredBox(color: _red)),
            _pane(const Rect.fromLTWH(100, 100, 200, 100)),
          ],
        ),
        enabled: false,
      ),
    );

    expect(LiquidGlassHost.debugLastCapture, isNull);
  });

  testWidgets('a pane that leaves the tree lets go of its capture', (
    tester,
  ) async {
    final held = LiquidGlassHost.debugHeldCaptures;
    Widget scene({required bool offstage, bool enabled = true}) => _app(
      Stack(
        children: [
          const Positioned.fill(child: ColoredBox(color: _red)),
          _pane(const Rect.fromLTWH(100, 100, 200, 100)),
          Positioned.fill(
            child: Offstage(
              offstage: offstage,
              child: Stack(
                children: [_pane(const Rect.fromLTWH(100, 300, 200, 100))],
              ),
            ),
          ),
        ],
      ),
      enabled: enabled,
    );

    await tester.pumpWidget(scene(offstage: false));
    expect(LiquidGlassHost.debugHeldCaptures, held + 2);

    await tester.pumpWidget(scene(offstage: true));
    expect(_capture().panes, hasLength(1));
    expect(LiquidGlassHost.debugHeldCaptures, held + 1);

    await tester.pumpWidget(scene(offstage: false));
    expect(LiquidGlassHost.debugHeldCaptures, held + 2);

    await tester.pumpWidget(scene(offstage: false, enabled: false));
    expect(LiquidGlassHost.debugHeldCaptures, held);
  });
}
