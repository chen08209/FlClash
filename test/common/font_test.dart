import 'package:fl_clash/common/font.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  List<String> fallback(
    TargetPlatform platform,
    List<Locale> locales, {
    String? fontFamily,
  }) => appFontFamilyFallback(
    platform: platform,
    locales: locales,
    fontFamily: fontFamily,
  );

  group('Han variant', () {
    test('follows a Chinese, Japanese or Korean UI language', () {
      expect(fallback(TargetPlatform.windows, const [Locale('zh', 'CN')]), [
        'Microsoft YaHei UI',
      ]);
      expect(fallback(TargetPlatform.windows, const [Locale('ja')]), [
        'Yu Gothic UI',
        'Meiryo UI',
      ]);
      expect(fallback(TargetPlatform.macOS, const [Locale('ko', 'KR')]), [
        'Apple SD Gothic Neo',
      ]);
    });

    test('falls through a Latin UI language to the system ones', () {
      expect(
        fallback(TargetPlatform.windows, const [Locale('en'), Locale('ja')]),
        ['Yu Gothic UI', 'Meiryo UI'],
      );
      expect(
        fallback(TargetPlatform.macOS, const [Locale('ru'), Locale('en')]),
        ['PingFang SC'],
      );
    });

    test('reads Traditional Chinese from the script, then the region', () {
      expect(
        fallback(TargetPlatform.windows, const [
          Locale.fromSubtags(languageCode: 'zh', scriptCode: 'Hant'),
        ]),
        ['Microsoft JhengHei UI'],
      );
      expect(fallback(TargetPlatform.macOS, const [Locale('zh', 'HK')]), [
        'PingFang TC',
      ]);
      expect(
        fallback(TargetPlatform.macOS, const [
          Locale.fromSubtags(
            languageCode: 'zh',
            scriptCode: 'Hans',
            countryCode: 'TW',
          ),
        ]),
        ['PingFang SC'],
      );
    });
  });

  test('keeps the Linux Latin fallbacks ahead of the Han families', () {
    final families = fallback(TargetPlatform.linux, const [Locale('zh')]);

    expect(families.first, 'Ubuntu');
    expect(families.sublist(families.indexOf('Noto Sans CJK SC')), [
      'Noto Sans CJK SC',
      'Noto Sans SC',
      'Source Han Sans SC',
      'WenQuanYi Micro Hei',
    ]);
  });

  test('puts the platform family behind a chosen one', () {
    expect(
      fallback(TargetPlatform.windows, const [
        Locale('zh'),
      ], fontFamily: 'LXGW WenKai'),
      ['Segoe UI', 'Microsoft YaHei UI'],
    );
    expect(
      fallback(TargetPlatform.macOS, const [Locale('en')], fontFamily: 'Menlo'),
      ['.AppleSystemUIFont', 'PingFang SC'],
    );
  });

  test('leaves Android to its own locale-aware fallback', () {
    expect(fallback(TargetPlatform.android, const [Locale('en')]), isEmpty);
    expect(
      fallback(TargetPlatform.android, const [
        Locale('en'),
      ], fontFamily: 'serif'),
      ['Roboto'],
    );
  });
}
