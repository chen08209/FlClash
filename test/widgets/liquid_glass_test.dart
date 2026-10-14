import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _window = Size(800, 600);
const _pane = Rect.fromLTWH(0, 0, 100, 40);

LiquidGlassPlacement _place(List<ContainerLayer> chain) {
  for (var index = 1; index < chain.length; index++) {
    chain[index - 1].append(chain[index]);
  }
  final pane = PictureLayer(_pane);
  chain.last.append(pane);
  addTearDown(chain.first.dispose);
  return LiquidGlassPlacement.of(pane, _pane, _window);
}

void main() {
  test('a pane lands where the transforms and offsets above it put it', () {
    final placement = _place([
      TransformLayer(transform: Matrix4.diagonal3Values(2, 2, 1)),
      OffsetLayer(offset: const Offset(10, 20)),
    ]);

    expect(placement.device, const Rect.fromLTWH(20, 40, 200, 80));
    expect(placement.clip, Offset.zero & _window);
    expect(placement.offscreen, isFalse);
  });

  test('a clip above a pane bounds it in window pixels', () {
    final placement = _place([
      TransformLayer(transform: Matrix4.diagonal3Values(2, 2, 1)),
      OffsetLayer(offset: const Offset(300, 0)),
      ClipRectLayer(clipRect: const Rect.fromLTWH(0, 0, 50, 400)),
    ]);

    expect(placement.clip, const Rect.fromLTWH(600, 0, 100, 600));
  });

  test('a rect clip bounds a pane where Impeller snaps it to pixels', () {
    Rect clipOf(Rect rect, Clip behavior) =>
        _place([ClipRectLayer(clipRect: rect, clipBehavior: behavior)]).clip;
    const fractional = Rect.fromLTRB(10.3, 20.7, 300.4, 400.6);

    expect(
      clipOf(fractional, Clip.hardEdge),
      const Rect.fromLTRB(10, 21, 300, 401),
    );
    expect(clipOf(fractional, Clip.antiAlias), fractional);
    expect(
      clipOf(const Rect.fromLTRB(10.1, 20, 300, 400.05), Clip.antiAlias),
      const Rect.fromLTRB(10, 20, 300, 400),
    );
  });

  test('only a layer drawing into a texture of its own takes it offscreen', () {
    expect(_place([OpacityLayer(alpha: 255)]).offscreen, isFalse);
    expect(_place([OpacityLayer(alpha: 128)]).offscreen, isTrue);
    expect(_place([ClipRectLayer(clipRect: Rect.largest)]).offscreen, isFalse);
    expect(
      _place([
        ClipRectLayer(
          clipRect: Rect.largest,
          clipBehavior: Clip.antiAliasWithSaveLayer,
        ),
      ]).offscreen,
      isTrue,
    );
    expect(
      _place([
        BackdropFilterLayer(filter: ui.ImageFilter.blur(sigmaX: 1, sigmaY: 1)),
      ]).offscreen,
      isTrue,
    );
  });

  test('a profile reads how far an outline reaches each way', () {
    final box = liquidGlassProfile(
      Path()..addRect(const Rect.fromLTWH(0, 0, 40, 20)),
      const Offset(20, 10),
    );
    expect(box[0], moreOrLessEquals(20, epsilon: 1e-6));
    expect(box[16], moreOrLessEquals(10, epsilon: 1e-6));
    expect(box[32], moreOrLessEquals(20, epsilon: 1e-6));
    expect(box[48], moreOrLessEquals(10, epsilon: 1e-6));
    expect(box[8], moreOrLessEquals(10 * math.sqrt2, epsilon: 1e-6));

    final round = liquidGlassProfile(
      Path()..addOval(Rect.fromCircle(center: Offset.zero, radius: 30)),
      Offset.zero,
    );
    expect(round, everyElement(moreOrLessEquals(30, epsilon: 0.05)));
  });

  testWidgets('a pane shaped by a clipper keeps to its path', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: RepaintBoundary(
            key: key,
            child: const SizedBox.square(
              dimension: 40,
              child: LiquidGlass(
                style: LiquidGlassStyle(tint: Colors.blue),
                clipper: _Diamond(),
              ),
            ),
          ),
        ),
      ),
    );
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final image = boundary.toImageSync();
    addTearDown(image.dispose);

    await tester.runAsync(() async {
      final bytes = (await image.toByteData())!;
      int alphaAt(int x, int y) =>
          bytes.getUint8((y * image.width + x) * 4 + 3);
      expect(alphaAt(5, 5), 0);
      expect(alphaAt(34, 34), 0);
      expect(alphaAt(20, 20), greaterThan(0));
      expect(alphaAt(20, 3), greaterThan(0));
    });
  });

  testWidgets('a snapshot taken without panes holds only what stands on them', (
    tester,
  ) async {
    final key = GlobalKey();
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: RepaintBoundary(
            key: key,
            child: const SizedBox.square(
              dimension: 40,
              child: LiquidGlass(style: LiquidGlassStyle(tint: Colors.blue)),
            ),
          ),
        ),
      ),
    );
    final boundary =
        key.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    final bare = LiquidGlass.withoutPanes(boundary.toImageSync);
    final glass = boundary.toImageSync();
    addTearDown(bare.dispose);
    addTearDown(glass.dispose);

    Future<int> centerAlpha(ui.Image image) async {
      final bytes = (await image.toByteData())!;
      return bytes.getUint8(
        ((image.height ~/ 2) * image.width + image.width ~/ 2) * 4 + 3,
      );
    }

    await tester.runAsync(() async {
      expect(await centerAlpha(bare), 0);
      expect(await centerAlpha(glass), greaterThan(0));
    });
  });
}

class _Diamond extends CustomClipper<Path> {
  const _Diamond();

  @override
  Path getClip(Size size) => Path()
    ..moveTo(size.width / 2, 0)
    ..lineTo(size.width, size.height / 2)
    ..lineTo(size.width / 2, size.height)
    ..lineTo(0, size.height / 2)
    ..close();

  @override
  bool shouldReclip(_Diamond oldClipper) => false;
}
