import 'package:fl_clash/common/utils.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:test/test.dart';

void main() {
  final utils = Utils();

  group('getDateStringLast2', () {
    test('pads single digit', () {
      expect(utils.getDateStringLast2(5), '05');
    });

    test('returns last 2 chars of double digit', () {
      expect(utils.getDateStringLast2(12), '12');
    });

    test('handles zero', () {
      expect(utils.getDateStringLast2(0), '00');
    });
  });

  group('uuidV4', () {
    test('produces valid UUID v4 format', () {
      final uuid = utils.uuidV4;
      expect(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ).hasMatch(uuid),
        isTrue,
      );
    });

    test('produces unique values', () {
      final uuid1 = utils.uuidV4;
      final uuid2 = utils.uuidV4;
      expect(uuid1, isNot(equals(uuid2)));
    });
  });

  group('getTimeText', () {
    test('returns 00:00:00 for null', () {
      expect(utils.getTimeText(null), '00:00:00');
    });

    test('formats zero milliseconds', () {
      expect(utils.getTimeText(0), '00:00:00');
    });

    test('formats seconds only', () {
      expect(utils.getTimeText(5000), '00:00:05');
    });

    test('formats minutes and seconds', () {
      expect(utils.getTimeText(125000), '00:02:05');
    });

    test('formats hours', () {
      expect(utils.getTimeText(3661000), '01:01:01');
    });

    test('formats three digit hours', () {
      expect(utils.getTimeText(100 * 3600 * 1000), '100:00:00');
    });

    test('caps at 999:59:59', () {
      expect(utils.getTimeText(1000 * 3600 * 1000), '999:59:59');
    });
  });

  group('sortByChar', () {
    test('equal strings return 0', () {
      expect(utils.sortByChar('abc', 'abc'), 0);
    });

    test('empty first returns -1', () {
      expect(utils.sortByChar('', 'a'), -1);
    });

    test('empty second returns 1', () {
      expect(utils.sortByChar('a', ''), 1);
    });

    test('both empty returns 0', () {
      expect(utils.sortByChar('', ''), 0);
    });

    test('case insensitive comparison', () {
      expect(utils.sortByChar('a', 'B'), lessThan(0));
      expect(utils.sortByChar('B', 'a'), greaterThan(0));
    });
  });

  group('getOverwriteLabel', () {
    test('appends (1) to label without number', () {
      expect(utils.getOverwriteLabel('foo'), 'foo(1)');
    });

    test('increments existing number', () {
      expect(utils.getOverwriteLabel('foo(1)'), 'foo(2)');
    });

    test('increments higher numbers', () {
      expect(utils.getOverwriteLabel('foo(9)'), 'foo(10)');
    });
  });

  group('compareVersions', () {
    test('equal versions', () {
      expect(utils.compareVersions('1.0.0', '1.0.0'), 0);
    });

    test('major version difference', () {
      expect(utils.compareVersions('2.0.0', '1.0.0'), greaterThan(0));
      expect(utils.compareVersions('1.0.0', '2.0.0'), lessThan(0));
    });

    test('minor version difference', () {
      expect(utils.compareVersions('1.2.0', '1.1.0'), greaterThan(0));
    });

    test('patch version difference', () {
      expect(utils.compareVersions('1.0.2', '1.0.1'), greaterThan(0));
    });

    test('handles build number', () {
      expect(utils.compareVersions('1.0.0+1', '1.0.0+2'), lessThan(0));
      expect(utils.compareVersions('1.0.0+2', '1.0.0+1'), greaterThan(0));
    });

    test('handles missing minor/patch', () {
      expect(utils.compareVersions('1', '1.0.0'), 0);
    });
  });

  group('getViewMode', () {
    test('mobile for small width', () {
      expect(utils.getViewMode(400).name, 'mobile');
    });

    test('laptop for medium width', () {
      expect(utils.getViewMode(700).name, 'laptop');
    });

    test('desktop for large width', () {
      expect(utils.getViewMode(1000).name, 'desktop');
    });
  });

  group('getProxiesColumns', () {
    test('minimum 2 columns', () {
      expect(utils.getProxiesColumns(100, ProxiesLayout.standard), 2);
    });

    test('scales with width', () {
      expect(utils.getProxiesColumns(500, ProxiesLayout.standard), 2);
      expect(utils.getProxiesColumns(800, ProxiesLayout.standard), 4);
    });

    test('tight layout adds column', () {
      final standard = utils.getProxiesColumns(500, ProxiesLayout.standard);
      final tight = utils.getProxiesColumns(500, ProxiesLayout.tight);
      expect(tight, standard + 1);
    });

    test('loose layout removes column', () {
      final standard = utils.getProxiesColumns(800, ProxiesLayout.standard);
      final loose = utils.getProxiesColumns(800, ProxiesLayout.loose);
      expect(loose, standard - 1);
    });
  });

  group('getProfilesColumns', () {
    test('minimum 1 column', () {
      expect(utils.getProfilesColumns(100), 1);
    });

    test('scales with width', () {
      expect(utils.getProfilesColumns(300), 1);
      expect(utils.getProfilesColumns(600), 2);
    });
  });

  group('parseReleaseBody', () {
    test('extracts bullet points', () {
      const body = '- Feature 1\n- Feature 2\n- Bug fix';
      final result = utils.parseReleaseBody(body);
      expect(result, ['Feature 1', 'Feature 2', 'Bug fix']);
    });

    test('returns empty for null', () {
      expect(utils.parseReleaseBody(null), isEmpty);
    });

    test('ignores non-bullet lines', () {
      const body = 'Header\n- Item 1\nFooter\n- Item 2';
      final result = utils.parseReleaseBody(body);
      expect(result, ['Item 1', 'Item 2']);
    });
  });

  group('fastHash', () {
    test('produces consistent hash', () {
      final hash1 = utils.fastHash('hello');
      final hash2 = utils.fastHash('hello');
      expect(hash1, hash2);
    });

    test('different input produces different hash', () {
      expect(utils.fastHash('hello'), isNot(equals(utils.fastHash('world'))));
    });

    test('returns an integer', () {
      final hash = utils.fastHash('test');
      expect(hash, isA<int>());
    });
  });
}
