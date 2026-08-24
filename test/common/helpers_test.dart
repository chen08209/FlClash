import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/widgets.dart';
import 'package:test/test.dart';

void main() {
  group('getDateStringLast2', () {
    test('pads single digit', () {
      expect(getDateStringLast2(5), '05');
    });

    test('returns last 2 chars of double digit', () {
      expect(getDateStringLast2(12), '12');
    });

    test('handles zero', () {
      expect(getDateStringLast2(0), '00');
    });
  });

  group('uuidV4', () {
    test('produces valid UUID v4 format', () {
      final uuid = uuidV4;
      expect(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ).hasMatch(uuid),
        isTrue,
      );
    });

    test('produces unique values', () {
      final uuid1 = uuidV4;
      final uuid2 = uuidV4;
      expect(uuid1, isNot(equals(uuid2)));
    });
  });

  group('getTimeText', () {
    test('returns 00:00:00 for null', () {
      expect(getTimeText(null), '00:00:00');
    });

    test('formats zero milliseconds', () {
      expect(getTimeText(0), '00:00:00');
    });

    test('formats seconds only', () {
      expect(getTimeText(5000), '00:00:05');
    });

    test('formats minutes and seconds', () {
      expect(getTimeText(125000), '00:02:05');
    });

    test('formats hours', () {
      expect(getTimeText(3661000), '01:01:01');
    });

    test('formats three digit hours', () {
      expect(getTimeText(100 * 3600 * 1000), '100:00:00');
    });

    test('caps at 999:59:59', () {
      expect(getTimeText(1000 * 3600 * 1000), '999:59:59');
    });
  });

  group('getOverwriteLabel', () {
    test('appends (1) to label without number', () {
      expect(getOverwriteLabel('foo'), 'foo(1)');
    });

    test('increments existing number', () {
      expect(getOverwriteLabel('foo(1)'), 'foo(2)');
    });

    test('increments higher numbers', () {
      expect(getOverwriteLabel('foo(9)'), 'foo(10)');
    });
  });

  group('compareVersions', () {
    test('equal versions', () {
      expect(compareVersions('1.0.0', '1.0.0'), 0);
    });

    test('major version difference', () {
      expect(compareVersions('2.0.0', '1.0.0'), greaterThan(0));
      expect(compareVersions('1.0.0', '2.0.0'), lessThan(0));
    });

    test('minor version difference', () {
      expect(compareVersions('1.2.0', '1.1.0'), greaterThan(0));
    });

    test('patch version difference', () {
      expect(compareVersions('1.0.2', '1.0.1'), greaterThan(0));
    });

    test('handles build number', () {
      expect(compareVersions('1.0.0+1', '1.0.0+2'), lessThan(0));
      expect(compareVersions('1.0.0+2', '1.0.0+1'), greaterThan(0));
    });

    test('handles missing minor/patch', () {
      expect(compareVersions('1', '1.0.0'), 0);
    });
  });

  group('getViewMode', () {
    test('mobile for small width', () {
      expect(getViewMode(400).name, 'mobile');
    });

    test('laptop for medium width', () {
      expect(getViewMode(700).name, 'laptop');
    });

    test('desktop for large width', () {
      expect(getViewMode(1000).name, 'desktop');
    });
  });

  group('getProxiesColumns', () {
    test('minimum 2 columns', () {
      expect(getProxiesColumns(100, ProxiesLayout.standard), 2);
    });

    test('scales with width', () {
      expect(getProxiesColumns(500, ProxiesLayout.standard), 2);
      expect(getProxiesColumns(800, ProxiesLayout.standard), 4);
    });

    test('tight layout adds column', () {
      final standard = getProxiesColumns(500, ProxiesLayout.standard);
      final tight = getProxiesColumns(500, ProxiesLayout.tight);
      expect(tight, standard + 1);
    });

    test('loose layout removes column', () {
      final standard = getProxiesColumns(800, ProxiesLayout.standard);
      final loose = getProxiesColumns(800, ProxiesLayout.loose);
      expect(loose, standard - 1);
    });
  });

  group('getProfilesColumns', () {
    test('minimum 1 column', () {
      expect(getProfilesColumns(100), 1);
    });

    test('scales with width', () {
      expect(getProfilesColumns(300), 1);
      expect(getProfilesColumns(600), 2);
    });
  });

  group('parseReleaseBody', () {
    test('extracts bullet points', () {
      const body = '- Feature 1\n- Feature 2\n- Bug fix';
      final result = parseReleaseBody(body);
      expect(result, ['Feature 1', 'Feature 2', 'Bug fix']);
    });

    test('returns empty for null', () {
      expect(parseReleaseBody(null), isEmpty);
    });

    test('ignores non-bullet lines', () {
      const body = 'Header\n- Item 1\nFooter\n- Item 2';
      final result = parseReleaseBody(body);
      expect(result, ['Item 1', 'Item 2']);
    });

    test('stops at the changelog markers', () {
      const body =
          '$releaseNotesBeginMarker\n'
          '### Features\n'
          '- Item 1\n'
          '$releaseNotesEndMarker\n'
          '<a href="FlClash-0.8.96-android-arm64-v8a.apk">APK</a>\n'
          '- Not part of the notes\n';

      expect(parseReleaseBody(body), ['Item 1']);
    });

    test('ignores inline dashes in the download template', () {
      const body =
          '- Item 1\n'
          '<img src="https://img.shields.io/badge/APK-ARMv8-168039.svg">\n'
          '<td>Windows</td>\n';

      expect(parseReleaseBody(body), ['Item 1']);
    });
  });

  group('generateRandomString', () {
    test('respects the requested length bounds', () {
      for (var attempt = 0; attempt < 20; attempt++) {
        final value = generateRandomString(minLength: 5, maxLength: 9);
        expect(value.length, inInclusiveRange(5, 9));
      }
    });

    test('can produce a fixed length', () {
      expect(generateRandomString(minLength: 7, maxLength: 7).length, 7);
    });

    test('produces different values across calls', () {
      final values = List.generate(
        8,
        (_) => generateRandomString(minLength: 30, maxLength: 30),
      ).toSet();
      expect(values.length, greaterThan(1));
    });
  });

  group('getLocaleForString', () {
    test('returns null for null input', () {
      expect(getLocaleForString(null), isNull);
    });

    test('parses a bare language code', () {
      expect(getLocaleForString('en'), const Locale('en'));
    });

    test('parses language and country', () {
      expect(getLocaleForString('zh_CN'), const Locale('zh', 'CN'));
    });

    test('parses language, script and country', () {
      expect(
        getLocaleForString('zh_Hans_CN'),
        const Locale.fromSubtags(
          languageCode: 'zh',
          scriptCode: 'Hans',
          countryCode: 'CN',
        ),
      );
    });

    test('returns null for more subtags than it understands', () {
      expect(getLocaleForString('a_b_c_d'), isNull);
    });
  });

  group('getFileNameForDisposition', () {
    test('returns null for null input', () {
      expect(getFileNameForDisposition(null), isNull);
    });

    test('reads a plain filename parameter', () {
      expect(
        getFileNameForDisposition('attachment; filename="profile.yaml"'),
        'profile.yaml',
      );
    });

    test('prefers the encoded filename* parameter', () {
      expect(
        getFileNameForDisposition(
          "attachment; filename=\"fallback.yaml\"; filename*=UTF-8''%E9%85%8D%E7%BD%AE.yaml",
        ),
        '配置.yaml',
      );
    });

    test('falls back to filename when filename* is malformed', () {
      expect(
        getFileNameForDisposition(
          'attachment; filename*=broken; filename="fallback.yaml"',
        ),
        'fallback.yaml',
      );
    });

    test('returns null when no filename parameter is present', () {
      expect(getFileNameForDisposition('attachment'), isNull);
    });
  });
}
