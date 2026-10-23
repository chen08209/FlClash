import 'dart:ui' as ui;

import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

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
}) => MaterialApp(
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
  const _HeldPane(this.rect, this.hold);

  final Rect rect;
  final Rect hold;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderHeldPane(rect, hold);

  @override
  void updateRenderObject(BuildContext context, _RenderHeldPane renderObject) {
    renderObject
      ..rect = rect
      ..hold = hold
      ..markNeedsPaint();
  }
}

class _RenderHeldPane extends RenderBox {
  _RenderHeldPane(this.rect, this.hold);

  Rect rect;
  Rect hold;
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
      style: _clear,
      hold: hold.shift(offset),
    );
  }
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
