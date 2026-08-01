import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:test/test.dart';

void main() {
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
    test('builds destination description and process text', () {
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

      expect(trackerInfo.desc, 'tcp://example.com/1.1.1.1:443');
      expect(trackerInfo.progressText, 'Browser(501)');
    });

    test('calculates speeds from consecutive snapshots', () {
      final start = DateTime(2026);
      final previous = TrackerInfo(
        id: '1',
        upload: 100,
        download: 200,
        start: start,
        metadata: const Metadata(process: 'Browser'),
        chains: const [],
        rule: 'MATCH',
        rulePayload: '',
      );
      final current = previous.copyWith(upload: 400, download: 800);

      final result = current.withSpeedFrom(
        previous,
        const Duration(milliseconds: 1500),
      );

      expect(result.uploadSpeed, 200);
      expect(result.downloadSpeed, 400);
      expect(current.withSpeedFrom(null, Duration.zero).uploadSpeed, 0);
    });

    test('sorts connections by speed and process', () {
      final start = DateTime(2026);
      TrackerInfo connection(
        String id,
        String process,
        int uploadSpeed,
        int downloadSpeed,
      ) {
        return TrackerInfo(
          id: id,
          start: start.add(Duration(seconds: int.parse(id))),
          metadata: Metadata(process: process),
          chains: const [],
          rule: 'MATCH',
          rulePayload: '',
          uploadSpeed: uploadSpeed,
          downloadSpeed: downloadSpeed,
        );
      }

      final connections = [
        connection('1', 'Zulu', 10, 30),
        connection('2', 'alpha', 30, 20),
        connection('3', 'Bravo', 20, 10),
      ];

      expect(
        connections
            .sortedBy(ConnectionSortType.downloadDesc)
            .map((item) => item.id),
        ['1', '2', '3'],
      );
      expect(
        connections
            .sortedBy(ConnectionSortType.uploadAsc)
            .map((item) => item.id),
        ['1', '3', '2'],
      );
      expect(
        connections
            .sortedBy(ConnectionSortType.processAsc)
            .map((item) => item.id),
        ['2', '3', '1'],
      );
      expect(connections.sortedBy(ConnectionSortType.none), same(connections));
    });
  });

  group('TrafficExt', () {
    test('formats speed, description, tray title, and total speed', () {
      const traffic = Traffic(up: 1024, down: 2048);

      expect(traffic.speedText, '↑ 1KB/s   ↓ 2KB/s');
      expect(traffic.desc, '1KB ↑ 2KB ↓');
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

  group('IpInfo parsers', () {
    test('parse supported response shapes', () {
      expect(
        IpInfo.fromIpInfoIoJson({'ip': '1.1.1.1', 'country': 'US'}),
        const IpInfo(ip: '1.1.1.1', countryCode: 'US'),
      );
      expect(
        IpInfo.fromMyIpJson({'ip': '2.2.2.2', 'cc': 'JP'}),
        const IpInfo(ip: '2.2.2.2', countryCode: 'JP'),
      );
      expect(
        IpInfo.fromIpAPIJson({'query': '3.3.3.3', 'countryCode': 'CN'}),
        const IpInfo(ip: '3.3.3.3', countryCode: 'CN'),
      );
    });

    test('throw FormatException for unsupported response shapes', () {
      expect(
        () => IpInfo.fromIpInfoIoJson({'ip': '1.1.1.1'}),
        throwsFormatException,
      );
      expect(
        () => IpInfo.fromIpApiCoJson({'ip': '1.1.1.1'}),
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
