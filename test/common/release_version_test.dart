import 'package:fl_clash/common/app_update.dart';
import 'package:fl_clash/common/release_asset.dart';
import 'package:fl_clash/common/release_version.dart';
import 'package:flutter_test/flutter_test.dart';

ReleaseVersion _v(String tag) => ReleaseVersion.tryParse(tag)!;

void main() {
  group('ReleaseVersion', () {
    test('orders prereleases numerically and below their release', () {
      final ordered = [
        'v1.1.9',
        'v1.2.0-pre.1',
        'v1.2.0-pre.2',
        'v1.2.0-pre.10',
        'v1.2.0',
        'v1.2.1-pre.1',
        'v1.10.0',
      ];
      final shuffled = [...ordered.reversed]..shuffle();
      expect((shuffled..sort((a, b) => _v(a).compareTo(_v(b)))), ordered);
    });

    test('ranks a rebuild above its prerelease and below the next one', () {
      expect(_v('v1.2.0-pre.2+1'), greaterThan(_v('v1.2.0-pre.2')));
      expect(_v('v1.2.0-pre.2+2'), greaterThan(_v('v1.2.0-pre.2+1')));
      expect(_v('v1.2.0-pre.2+9'), lessThan(_v('v1.2.0-pre.3')));
      expect(_v('v1.2.0-pre.2+9'), lessThan(_v('v1.2.0')));
      expect(_v('v1.2.0-pre.2+1').comparePrecedence(_v('v1.2.0-pre.2')), 0);
    });

    test('orders rs prereleases the same way', () {
      expect(_v('v1.2.0-rs.2'), lessThan(_v('v1.2.0-rs.10')));
      expect(_v('v1.2.0-rs.2+1'), greaterThan(_v('v1.2.0-rs.2')));
      expect(_v('v1.2.0-rs.10'), lessThan(_v('v1.2.1-rs.1')));
    });

    test('follows semver for identifiers of mixed kinds', () {
      expect(_v('v1.0.0-alpha'), lessThan(_v('v1.0.0-alpha.1')));
      expect(_v('v1.0.0-1'), lessThan(_v('v1.0.0-alpha')));
      expect(_v('v1.0.0-alpha.beta'), lessThan(_v('v1.0.0-beta')));
    });

    test('ranks an identifier of more than digits as alphanumeric', () {
      expect(_v('v1.0.0-pre.20'), lessThan(_v('v1.0.0-pre.0x10')));
      expect(_v('v1.0.0-pre.1'), lessThan(_v('v1.0.0-pre.-1')));
      expect(
        _v('v1.0.0-pre.9223372036854775807'),
        lessThan(_v('v1.0.0-pre.99999999999999999999')),
      );
    });

    test('reads the line from the first prerelease identifier', () {
      expect(_v('v1.2.0').line, ReleaseLine.dev);
      expect(_v('v1.2.0-pre.1').line, ReleaseLine.dev);
      expect(_v('v1.2.0-rs.1+2').line, ReleaseLine.rs);
      expect(_v('v1.2.0-pre.1').isPrerelease, isTrue);
      expect(_v('v1.2.0').isPrerelease, isFalse);
    });

    test('accepts a version without the v and rejects what is no tag', () {
      expect(_v('1.2.3').compareTo(_v('v1.2.3')), 0);
      expect(ReleaseVersion.tryParse('latest'), isNull);
      expect(ReleaseVersion.tryParse('v1.2'), isNull);
      expect(ReleaseVersion.tryParse('v1.2.3+build.1'), isNull);
      expect(ReleaseVersion.tryParse(''), isNull);
    });

    test('prints back the tag it was read from', () {
      for (final tag in ['v1.2.3', 'v1.2.3-pre.4', 'v1.2.3-rs.1+2']) {
        expect(_v(tag).toString(), tag);
      }
    });
  });

  group('releaseTagsNewestFirst', () {
    const tags = [
      'v1.2.0',
      'v1.2.1-rs.3',
      'v1.2.1-pre.2',
      'v1.2.1-pre.10',
      'nightly',
      'v1.2.1-pre.2+4',
    ];

    test('orders by version, not by listing', () {
      expect(releaseTagsNewestFirst(tags, ReleaseLine.dev), [
        'v1.2.1-pre.10',
        'v1.2.1-pre.2+4',
        'v1.2.1-pre.2',
        'v1.2.0',
      ]);
    });

    test('keeps to its own line', () {
      expect(releaseTagsNewestFirst(tags, ReleaseLine.rs), ['v1.2.1-rs.3']);
      expect(releaseTagsNewestFirst(['v1.2.0-rs.1'], ReleaseLine.dev), isEmpty);
    });
  });

  group('installedReleaseVersion', () {
    test('prefers the tag the build was made from', () {
      expect(
        installedReleaseVersion('1.2.0', builtTag: 'v1.2.0-pre.3+1').toString(),
        'v1.2.0-pre.3+1',
      );
    });

    test('falls back to the version name of an untagged build', () {
      expect(
        installedReleaseVersion('1.2.0', builtTag: '').toString(),
        'v1.2.0',
      );
    });

    test('a prerelease install is offered its release and a rebuild', () {
      final installed = installedReleaseVersion(
        '1.2.0',
        builtTag: 'v1.2.0-pre.3',
      );
      expect(_v('v1.2.0'), greaterThan(installed));
      expect(_v('v1.2.0-pre.3+1'), greaterThan(installed));
      expect(_v('v1.2.0-pre.2'), lessThan(installed));
    });
  });

  group('installedVersionLabel', () {
    test('names a prerelease by the tag it was built from', () {
      expect(
        installedVersionLabel('1.2.0', builtTag: 'v1.2.0-pre.3+1'),
        'v1.2.0-pre.3+1',
      );
    });

    test('names an untagged build by its version name', () {
      expect(installedVersionLabel('1.2.0', builtTag: ''), 'v1.2.0');
    });
  });

  test('the update card names a prerelease by its tag, as About does', () {
    expect(
      installedVersionName('0.9.4', builtTag: 'v0.9.4-rs.2'),
      '0.9.4-rs.2',
    );
    expect(installedVersionName('0.9.4', builtTag: ''), '0.9.4');
  });
}
