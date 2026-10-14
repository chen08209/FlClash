import 'dart:io';

import 'package:fl_clash/common/system_fonts.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('sorts families without case and drops duplicates and hidden ones', () {
    expect(
      sortFontFamilies([
        'Segoe UI',
        ' arial ',
        '.AppleSystemUIFont',
        '',
        'segoe ui',
        'Arial',
        'Microsoft YaHei',
      ]),
      ['arial', 'Microsoft YaHei', 'Segoe UI'],
    );
  });

  test('lists the named families of an Android fonts.xml', () {
    const fontsXml = '''
<familyset version="23">
  <family name="sans-serif" varied="true">
    <font weight="400" style="normal">Roboto-Regular.ttf</font>
  </family>
  <alias name="arial" to="sans-serif" />
  <family lang="zh-Hans">
    <font weight="400" style="normal" index="2">NotoSansCJK-Regular.ttc</font>
  </family>
  <family
      name="serif-monospace">
    <font weight="400" style="normal">CutiveMono.ttf</font>
  </family>
</familyset>
''';

    expect(androidFontFamilies(fontsXml), ['sans-serif', 'serif-monospace']);
  });

  test('reads the host fonts sorted and unique, or nothing', () async {
    final families = await loadSystemFontFamilies();

    expect(families, sortFontFamilies(families));
  });

  test('reports a failed read as no fonts', () async {
    final reader = systemFontFamiliesReader;
    addTearDown(() => systemFontFamiliesReader = reader);
    systemFontFamiliesReader = () async => throw const OSError('dwrite', -1);

    expect(await loadSystemFontFamilies(), isEmpty);
  });
}
