import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

Future<void> _pump(WidgetTester tester, Widget icon) {
  return tester.pumpWidget(
    TestApp(
      child: Center(
        child: IconTheme(data: const IconThemeData(size: 32), child: icon),
      ),
    ),
  );
}

void main() {
  testWidgets('a group without an icon shows the first letter of its name, '
      'past a leading emoji', (tester) async {
    for (final (name, mark) in [
      ('🚀 节点选择', '节'),
      ('proxy', 'P'),
      ('♻️ 9 Auto', '9'),
      ('🇭🇰', '🇭🇰'),
    ]) {
      await _pump(
        tester,
        CommonTargetIcon(src: '', fallback: GroupMonogram(name)),
      );

      expect(find.text(mark), findsOne, reason: name);
    }
  });

  testWidgets('a missing image shows a placeholder, as does an empty name', (
    tester,
  ) async {
    await _pump(tester, const CommonTargetIcon(src: ''));

    expect(find.byGlyph(AppGlyphs.photos), findsOne);

    await _pump(tester, const GroupMonogram(''));

    expect(find.byGlyph(AppGlyphs.photos), findsOne);
  });

  testWidgets('the placeholder glyph is opaque, so a grid of icons that '
      'cannot load paints no offscreen layer per tile', (tester) async {
    await _pump(tester, const CommonTargetIcon(src: ''));

    final glyph = tester.widget<GlyphIcon>(find.byGlyph(AppGlyphs.photos));
    expect(glyph.color!.a, 1);
  });

  group('a remote icon', () {
    late List<String> reads;

    setUp(() {
      reads = [];
      readRemoteIcon = (src) {
        reads.add(src);
        return Stream.value(_onePixelPng);
      };
    });

    tearDown(() => readRemoteIcon = null);

    testWidgets('loads at once on a page that sits still', (tester) async {
      const src = 'https://example.com/still.png';
      await _pump(tester, const CommonTargetIcon(src: src));
      await tester.pump();

      expect(reads, [src]);
      expect(find.byType(Image), findsOne);
    });

    testWidgets('waits for the route bringing it in to settle', (tester) async {
      const src = 'https://example.com/pushed.png';
      await tester.pumpWidget(
        TestApp(
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const Center(
                    child: IconTheme(
                      data: IconThemeData(size: 32),
                      child: CommonTargetIcon(src: src),
                    ),
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(reads, isEmpty);
      expect(find.byGlyph(AppGlyphs.photos), findsNothing);
      expect(find.byType(Image), findsNothing);

      await tester.pumpAndSettle();

      expect(reads, [src]);
      expect(find.byGlyph(AppGlyphs.photos), findsNothing);
      expect(find.byType(Image), findsOne);
    });

    testWidgets('a page pushed again shows a whole set it loaded before '
        'through its transition', (tester) async {
      readRemoteIcon = (src) {
        reads.add(src);
        return Stream.value(Uint8List.fromList(_onePixelPng));
      };
      final icons = Wrap(
        children: [
          for (var i = 0; i < 340; i++)
            CommonTargetIcon(src: 'https://example.com/set/$i.png'),
        ],
      );
      await _pump(tester, icons);
      await tester.pump();
      await tester.pumpWidget(
        TestApp(
          child: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => IconTheme(
                    data: const IconThemeData(size: 32),
                    child: icons,
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      reads.clear();
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(reads, isEmpty);
      expect(find.byType(Image), findsNWidgets(340));
    });

    testWidgets('an oversized icon decodes at icon size, into the one cache '
        'entry its precache filled', (tester) async {
      final png = (await tester.runAsync(() => _squarePng(512)))!;
      readRemoteIcon = (_) => Stream.value(png);
      const src = 'https://example.com/large.png';
      imageCache.clear();
      await tester.runAsync(() => precacheTargetIcons([src]));

      expect(imageCache.currentSize, 1);

      await _pump(tester, const CommonTargetIcon(src: src));
      await tester.pump();

      expect(tester.widget<RawImage>(find.byType(RawImage)).image!.width, 192);
      expect(imageCache.currentSize, 1);
    });

    testWidgets('shows the fallback once a load ends without an image', (
      tester,
    ) async {
      readRemoteIcon = (_) => const Stream.empty();
      await _pump(
        tester,
        const CommonTargetIcon(
          src: 'https://example.com/missing.png',
          fallback: GroupMonogram('proxy'),
        ),
      );

      expect(find.text('P'), findsNothing);

      await tester.pump();

      expect(find.text('P'), findsOne);
    });
  });
}

Future<Uint8List> _squarePng(int size) async {
  final recorder = ui.PictureRecorder();
  Canvas(recorder).drawRect(
    Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
    Paint()..color = const Color(0xFF2196F3),
  );
  final image = await recorder.endRecording().toImage(size, size);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

final _onePixelPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg==',
);
