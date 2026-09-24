import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockFile extends Mock implements File {}

void main() {
  group('FileInfo', () {
    late MockFile file;

    setUp(() {
      file = MockFile();
    });

    test('reads size and valid last modified time', () async {
      final lastModified = DateTime(2026, 7, 29);
      when(() => file.exists()).thenAnswer((_) async => true);
      when(() => file.length()).thenAnswer((_) async => 2048);
      when(() => file.lastModified()).thenAnswer((_) async => lastModified);

      final fileInfo = await file.getFileInfo();

      expect(fileInfo, FileInfo(size: 2048, lastModified: lastModified));
    });

    test(
      'treats positive timestamps within the epoch year as unknown',
      () async {
        when(() => file.exists()).thenAnswer((_) async => true);
        when(() => file.length()).thenAnswer((_) async => 1024);
        when(
          () => file.lastModified(),
        ).thenAnswer((_) async => DateTime(1970, 12, 31, 23, 59, 59));

        final fileInfo = await file.getFileInfo();

        expect(fileInfo, const FileInfo(size: 1024));
      },
    );

    test('keeps size when last modified time cannot be read', () async {
      when(() => file.exists()).thenAnswer((_) async => true);
      when(() => file.length()).thenAnswer((_) async => 1024);
      when(
        () => file.lastModified(),
      ).thenThrow(const FileSystemException('last modified unavailable'));

      final fileInfo = await file.getFileInfo();

      expect(fileInfo, const FileInfo(size: 1024));
    });

    test('returns null when file does not exist', () async {
      when(() => file.exists()).thenAnswer((_) async => false);

      expect(await file.getFileInfo(), isNull);
      verifyNever(() => file.length());
      verifyNever(() => file.lastModified());
    });
  });

  group('PackagesExt', () {
    const packages = [
      Package(
        packageName: 'system.app',
        label: 'System',
        system: true,
        internet: true,
        lastUpdateTime: 1,
      ),
      Package(
        packageName: 'user.old',
        label: 'Alpha',
        system: false,
        internet: false,
        lastUpdateTime: 2,
      ),
      Package(
        packageName: 'user.new',
        label: 'Beta',
        system: false,
        internet: true,
        lastUpdateTime: 3,
      ),
    ];

    test('filters system and non-internet apps', () {
      final result = packages.getViewList(
        pinedList: [],
        sortType: AccessSortType.none,
        isFilterSystemApp: true,
        isFilterNonInternetApp: true,
      );

      expect(result.map((item) => item.packageName), ['user.new']);
    });

    test('pins selected packages before sorted packages', () {
      final result = packages.getViewList(
        pinedList: ['user.old'],
        sortType: AccessSortType.name,
        isFilterSystemApp: false,
        isFilterNonInternetApp: false,
      );

      expect(result.map((item) => item.packageName), [
        'user.old',
        'user.new',
        'system.app',
      ]);
    });
  });

  group('TrackerInfoExt', () {
    test('builds destination title and process text', () {
      final trackerInfo = TrackerInfo(
        id: '1',
        start: DateTime(2026),
        metadata: const Metadata(
          network: 'tcp',
          host: 'example.com',
          destinationIP: '1.1.1.1',
          destinationPort: '443',
          process: 'Browser',
          uid: 501,
        ),
        chains: const ['Proxy'],
        rule: 'MATCH',
        rulePayload: '',
      );

      expect(trackerInfo.title, 'example.com');
      expect(trackerInfo.progressText, 'Browser(501)');
    });
  });

  group('TrafficExt', () {
    test('formats speed, tray title, and total speed', () {
      const traffic = Traffic(up: 1024, down: 2048);

      expect(traffic.speedText, '↑ 1KB/s   ↓ 2KB/s');
      expect(traffic.trayTitle, '1 KB/s\n2 KB/s');
      expect(traffic.speed, 3072);
    });
  });

  group('GroupsExt', () {
    test('finds group by name and resolves current selection', () {
      const groups = [
        Group(name: 'Auto', type: GroupType.URLTest, now: 'Proxy A'),
        Group(name: 'Manual', type: GroupType.Selector, now: 'Proxy B'),
      ];

      expect(
        groups.getGroup('Auto')?.getCurrentSelectedName('Proxy C'),
        'Proxy A',
      );
      expect(
        groups.getGroup('Manual')?.getCurrentSelectedName('Proxy C'),
        'Proxy C',
      );
      expect(groups.getGroup('Missing'), isNull);
    });
  });

  group('ScriptsExt naming', () {
    Script script(int id, String label) =>
        Script(id: id, label: label, lastUpdateTime: DateTime(2026));

    test('hasLabel ignores the script being renamed', () {
      final scripts = [script(1, 'a'), script(2, 'b')];
      expect(scripts.hasLabel('a'), isTrue);
      expect(scripts.hasLabel('a', except: scripts[0]), isFalse);
      expect(scripts.hasLabel('a', except: scripts[1]), isTrue);
      expect(scripts.hasLabel('c'), isFalse);
    });

    test('uniqueLabel trims, falls back and numbers duplicates', () {
      final scripts = [script(1, 'remote'), script(2, 'remote(1)')];
      expect(scripts.uniqueLabel(' local ', fallback: 'Script'), 'local');
      expect(scripts.uniqueLabel('remote', fallback: 'Script'), 'remote(2)');
      expect(scripts.uniqueLabel('   ', fallback: 'Script'), 'Script');
      expect(
        [script(3, 'Script')].uniqueLabel('', fallback: 'Script'),
        'Script(1)',
      );
    });

    test('uniqueLabel keeps the numbered label within the name limit', () {
      final long = 'x' * 100;
      final scripts = [script(1, 'x' * TextInputLimits.name)];
      final label = scripts.uniqueLabel(long, fallback: 'Script');
      expect(label.length, lessThanOrEqualTo(TextInputLimits.name));
      expect(label, endsWith('(1)'));
      expect(scripts.hasLabel(label), isFalse);
    });
  });

  group('IpInfo parsers', () {
    test('parse supported response shapes', () {
      expect(
        IpInfo.fromIpInfoIoJson({'ip': '1.1.1.1', 'country': 'US'}),
        const IpInfo(ip: '1.1.1.1', countryCode: 'US'),
      );
      expect(
        IpInfo.fromIdentMeJson({'ip': '2.2.2.2', 'cc': 'JP'}),
        const IpInfo(ip: '2.2.2.2', countryCode: 'JP'),
      );
      expect(
        IpInfo.fromIpAPIJson({'query': '3.3.3.3', 'countryCode': 'CN'}),
        const IpInfo(ip: '3.3.3.3', countryCode: 'CN'),
      );
      expect(
        IpInfo.fromGeoJsJson({'ip': '4.4.4.4', 'country_code': 'DE'}),
        const IpInfo(ip: '4.4.4.4', countryCode: 'DE'),
      );
      expect(
        IpInfo.fromCountryIsJson({'ip': '5.5.5.5', 'country': 'FR'}),
        const IpInfo(ip: '5.5.5.5', countryCode: 'FR'),
      );
    });

    test('parse the ipquery.io country from its location object', () {
      expect(
        IpInfo.fromIpQueryJson({
          'ip': '203.0.113.9',
          'isp': {'asn': 'AS64500', 'org': '', 'isp': 'Example'},
          'location': {'country': 'United Kingdom', 'country_code': 'GB'},
          'risk': {'is_datacenter': false},
        }),
        const IpInfo(ip: '203.0.113.9', countryCode: 'GB'),
      );
    });

    test('parse the Cloudflare trace key-value text', () {
      expect(
        IpInfo.fromCloudflareTrace(
          'fl=0f0\nh=www.cloudflare.com\nip=203.0.113.9\nts=1757800000.1\n'
          'visit_scheme=https\ncolo=LHR\nhttp=http/2\nloc=GB\ntls=TLSv1.3\n',
        ),
        const IpInfo(ip: '203.0.113.9', countryCode: 'GB'),
      );
    });

    test('throw FormatException for unsupported response shapes', () {
      expect(
        () => IpInfo.fromIpInfoIoJson({'ip': '1.1.1.1'}),
        throwsFormatException,
      );
      expect(
        () => IpInfo.fromGeoJsJson({'ip': '1.1.1.1'}),
        throwsFormatException,
      );
      expect(
        () => IpInfo.fromIpQueryJson({
          'ip': '1.1.1.1',
          'location': <String, dynamic>{},
        }),
        throwsFormatException,
      );
      expect(
        () => IpInfo.fromCloudflareTrace('ip=1.1.1.1\ncolo=LHR\n'),
        throwsFormatException,
      );
    });
  });

  group('ResultExt', () {
    test('identifies success and error results', () {
      final success = Result.success('ok');
      final error = Result<Object>.error('failed');

      expect(success.isSuccess, isTrue);
      expect(success.isError, isFalse);
      expect(error.isSuccess, isFalse);
      expect(error.isError, isTrue);
    });
  });
}
