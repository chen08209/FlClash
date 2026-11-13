import 'dart:io';

import 'package:fl_clash/common/system_fonts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('passes the families through as read', () async {
    final reader = systemFontFamiliesReader;
    addTearDown(() => systemFontFamiliesReader = reader);
    systemFontFamiliesReader = () async => ['Arial', 'Segoe UI'];

    expect(await loadSystemFontFamilies(), ['Arial', 'Segoe UI']);
  });

  test('reports a failed read as no fonts', () async {
    final reader = systemFontFamiliesReader;
    addTearDown(() => systemFontFamiliesReader = reader);
    systemFontFamiliesReader = () async => throw const OSError('dwrite', -1);

    expect(await loadSystemFontFamilies(), isEmpty);
  });
}
