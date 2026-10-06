import 'dart:ui' as ui;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/liquid_glass.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _size = Size(200, 60);

Future<void> _pumpGlass(WidgetTester tester, Widget glass) async {
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: SizedBox(width: _size.width, height: _size.height, child: glass),
      ),
    ),
  );
}

RenderObject _painter(WidgetTester tester, Finder finder) {
  return tester.renderObject(
    find.descendant(of: finder, matching: find.byType(CustomPaint)).first,
  );
}

PaintPatternPredicate _blendsWith(BlendMode blendMode) {
  return (method, arguments) =>
      method != #drawRect || (arguments.last as Paint).blendMode == blendMode;
}

ContainerLayer _swollenLeaf() {
  final root = TransformLayer(
    transform: Matrix4.diagonal3Values(2.75, 2.75, 1),
  );
  final offset = OffsetLayer(offset: const Offset(10, 20));
  final swell = TransformLayer(transform: Matrix4.diagonal3Values(1.5, 1.5, 1));
  final leaf = ContainerLayer();
  root.append(offset);
  offset.append(swell);
  swell.append(leaf);
  addTearDown(root.dispose);
  return leaf;
}

void main() {
  group('backdropTransform', () {
    test('maps a layer through offsets and transforms to device pixels', () {
      final transform = backdropTransform(_swollenLeaf())!;

      expect(
        MatrixUtils.transformRect(transform, const Rect.fromLTWH(4, 2, 8, 6)),
        const Rect.fromLTWH(44, 63.25, 33, 24.75),
      );
    });

    test('places and scales the lens uniforms in backdrop pixels', () {
      final uniforms = lensUniforms(
        backdropTransform(_swollenLeaf())!,
        const Rect.fromLTWH(4, 2, 8, 6),
        refractionHeight: 24,
        refractionAmount: 24,
      );

      expect(uniforms, <double>[
        33, 24.75, -44, -63.25, //
        12.375, 12.375, 12.375, 12.375, //
        99, -99,
      ]);
    });

    test('gives up under a layer that reads the backdrop on its own', () {
      for (final (isolating, parent) in [
        (true, OpacityLayer(alpha: 128)),
        (false, OpacityLayer(alpha: 255)),
        (true, ImageFilterLayer(imageFilter: ui.ImageFilter.blur())),
        (true, ColorFilterLayer()),
        (true, BackdropFilterLayer()),
        (true, ShaderMaskLayer()),
        (false, ClipRectLayer(clipRect: Rect.largest)),
      ]) {
        final leaf = ContainerLayer();
        parent.append(leaf);
        expect(
          backdropTransform(leaf),
          isolating ? isNull : isNotNull,
          reason: '$parent',
        );
        parent.dispose();
      }
    });
  });

  testWidgets('without shader filters the glass keeps blur and vibrancy', (
    tester,
  ) async {
    await _pumpGlass(
      tester,
      const LiquidGlass(
        shaders: null,
        color: Color(0x66FFFFFF),
        blurRadius: 8,
        vibrancy: true,
        refractionHeight: 24,
        refractionAmount: 24,
      ),
    );

    final filter = tester.widget<BackdropFilter>(find.byType(BackdropFilter));
    final description = filter.filter.toString();
    expect(description, contains('blur(${8 * 0.57735 + 0.5 / 2}'));
    expect(description, contains('clamp'));
    expect(description, contains('matrix'));
    expect(
      find.descendant(
        of: find.byType(ClipRSuperellipse),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is ColoredBox && widget.color == const Color(0x66FFFFFF),
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('a lens with nothing to refract reads no backdrop', (
    tester,
  ) async {
    await _pumpGlass(
      tester,
      const LiquidGlass(
        shaders: null,
        color: Color(0x08000000),
        refractionHeight: 10,
        refractionAmount: 14,
        chromaticAberration: true,
      ),
    );

    expect(find.byType(BackdropFilter), findsNothing);
    expect(find.byType(ClipRSuperellipse), findsOneWidget);
  });

  testWidgets('the shadow falls outside the glass only', (tester) async {
    await _pumpGlass(
      tester,
      const LiquidGlass(
        shaders: null,
        color: Colors.transparent,
        shadowAlpha: 0.5,
      ),
    );

    final outline = AppRadius.full.toRSuperellipse(Offset.zero & _size);
    expect(
      _painter(tester, find.byType(LiquidGlass)),
      paints
        ..clipPath(
          pathMatcher: isPathThat(
            includes: const [Offset(-4, 30)],
            excludes: const [Offset(100, 30)],
          ),
        )
        ..rsuperellipse(
          rsuperellipse: outline.shift(const Offset(0, 4)),
          color: Colors.black.withValues(alpha: 0.05),
          hasMaskFilter: true,
        ),
    );
  });

  testWidgets('the rim carries the inner shadow and the highlight', (
    tester,
  ) async {
    await _pumpGlass(
      tester,
      const LiquidGlass(
        shaders: null,
        color: Colors.transparent,
        innerShadowRadius: 8,
        innerShadowAlpha: 1,
        highlightAlpha: 0.5,
      ),
    );

    expect(
      _painter(tester, find.byType(LiquidGlass)),
      paints
        ..clipRSuperellipse(
          rsuperellipse: AppRadius.full.toRSuperellipse(Offset.zero & _size),
        )
        ..path(
          color: Colors.black.withValues(alpha: 0.15),
          hasMaskFilter: true,
          includes: const [Offset(100, 2)],
          excludes: const [Offset(100, 30)],
        )
        ..rsuperellipse(
          color: Colors.white.withValues(alpha: 0.25),
          strokeWidth: 1,
          hasMaskFilter: true,
        ),
    );
  });

  testWidgets('the glow lights the glass around its center', (tester) async {
    await _pumpGlass(
      tester,
      const LiquidGlassGlow(center: Offset(40, 30), progress: 0.5),
    );

    final glow = _painter(tester, find.byType(LiquidGlassGlow));
    expect(
      glow,
      paints
        ..clipRSuperellipse()
        ..rect(
          rect: Offset.zero & _size,
          color: Colors.white.withValues(alpha: 0.04),
        )
        ..rect(rect: Offset.zero & _size),
    );
    expect(glow, paints..everything(_blendsWith(BlendMode.plus)));
  });

  testWidgets('the shaders load once and light the rim', (tester) async {
    final shaders = await tester.runAsync(LiquidGlassShaders.load);
    expect(shaders, isNotNull);
    expect(LiquidGlassShaders.loaded, same(shaders));
    expect(await tester.runAsync(LiquidGlassShaders.load), same(shaders));

    await _pumpGlass(
      tester,
      LiquidGlassHighlight(shaders: shaders, alpha: 0.5),
    );

    expect(
      _painter(tester, find.byType(LiquidGlassHighlight)),
      paints
        ..clipRSuperellipse()
        ..something((method, arguments) {
          final paint = arguments.last as Paint;
          return method == #drawRSuperellipse &&
              paint.shader == shaders!.highlight &&
              paint.blendMode == BlendMode.plus;
        }),
    );
  });
}
