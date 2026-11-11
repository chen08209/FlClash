import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';

String _androidAttribute(String source, String element, String attribute) {
  final elementTag = RegExp('<$element\\b[^>]*>').firstMatch(source)!.group(0)!;
  return RegExp(
    'android:$attribute="([^"]+)"',
  ).firstMatch(elementTag)!.group(1)!;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('TV launcher icons meet density-specific minimum sizes', () async {
    const expectedSizes = {
      'mdpi': 80,
      'hdpi': 120,
      'xhdpi': 160,
      'xxhdpi': 240,
      'xxxhdpi': 320,
    };

    for (final MapEntry(key: density, value: size) in expectedSizes.entries) {
      final file = File(
        'android/app/src/main/res/'
        'mipmap-television-$density/ic_launcher.webp',
      );
      expect(file.existsSync(), isTrue, reason: 'missing ${file.path}');

      final codec = await ui.instantiateImageCodec(await file.readAsBytes());
      final frame = await codec.getNextFrame();
      expect(
        (frame.image.width, frame.image.height),
        (size, size),
        reason: file.path,
      );
      frame.image.dispose();
      codec.dispose();
    }
  });

  test('TV adaptive launcher icon stays centered in the safe zone', () async {
    final adaptiveIcon = File(
      'android/app/src/main/res/'
      'mipmap-television-anydpi-v26/ic_launcher.xml',
    ).readAsStringSync();
    expect(
      _androidAttribute(adaptiveIcon, 'foreground', 'drawable'),
      '@drawable/ic_launcher_foreground_tv',
    );
    expect(
      _androidAttribute(adaptiveIcon, 'background', 'drawable'),
      '@drawable/ic_launcher_plate',
    );

    final bounds = await _foregroundGlyphBounds('ic_launcher_foreground_tv');
    const safeZone = ui.Rect.fromLTWH(18, 18, 72, 72);

    expect(bounds.left, greaterThanOrEqualTo(safeZone.left));
    expect(bounds.top, greaterThanOrEqualTo(safeZone.top));
    expect(bounds.right, lessThanOrEqualTo(safeZone.right));
    expect(bounds.bottom, lessThanOrEqualTo(safeZone.bottom));
    expect(bounds.center.dx, closeTo(safeZone.center.dx, 0.5));
    expect(bounds.center.dy, closeTo(safeZone.center.dy, 0.5));
    expect(bounds.height, closeTo(70.12, 0.5));
  });

  test('phone adaptive launcher glyph stays centered at its size', () async {
    final bounds = await _foregroundGlyphBounds('ic_launcher_foreground');
    expect(bounds.center.dx, closeTo(54, 0.5));
    expect(bounds.center.dy, closeTo(54, 0.5));
    expect(bounds.height, closeTo(45.69, 0.5));
  });
}

Future<ui.Rect> _foregroundGlyphBounds(String drawable) async {
  final foreground = File(
    'android/app/src/main/res/drawable/$drawable.xml',
  ).readAsStringSync();
  final art = _androidAttribute(foreground, 'inset', 'drawable');
  expect(art, startsWith('@drawable/'));
  final inset = _androidAttribute(foreground, 'inset', 'inset');
  expect(inset, endsWith('%'));
  final padding = double.parse(inset.substring(0, inset.length - 1)) / 100;
  final imageFile = File(
    'android/app/src/main/res/drawable-xxxhdpi/'
    '${art.substring('@drawable/'.length)}.webp',
  );
  final codec = await ui.instantiateImageCodec(await imageFile.readAsBytes());
  addTearDown(codec.dispose);
  final image = (await codec.getNextFrame()).image;
  addTearDown(image.dispose);
  final pixels = (await image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
  var left = image.width;
  var top = image.height;
  var right = 0;
  var bottom = 0;
  for (var y = 0; y < image.height; y++) {
    for (var x = 0; x < image.width; x++) {
      if (pixels.getUint8((y * image.width + x) * 4 + 3) < 128) continue;
      if (x < left) left = x;
      if (y < top) top = y;
      if (x + 1 > right) right = x + 1;
      if (y + 1 > bottom) bottom = y + 1;
    }
  }
  expect(right, greaterThan(left));
  expect(bottom, greaterThan(top));
  final offset = 108 * padding;
  final size = 108 - 2 * offset;
  return ui.Rect.fromLTRB(
    offset + size * left / image.width,
    offset + size * top / image.height,
    offset + size * right / image.width,
    offset + size * bottom / image.height,
  );
}
