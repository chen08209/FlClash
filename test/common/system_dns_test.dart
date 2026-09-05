import 'package:fl_clash/common/system_dns.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePort implements SystemDnsPort {
  _FakePort({List<String>? servers}) : servers = servers ?? ['1.1.1.1'];

  String? service = 'Wi-Fi';
  List<String> servers;
  bool writeSucceeds = true;
  Duration delay = Duration.zero;

  int reads = 0;
  int inFlight = 0;
  int maxInFlight = 0;
  final List<List<String>> writes = [];
  final List<String> writtenServices = [];

  @override
  Future<String?> resolveDefaultService() => _guard(() async => service);

  @override
  Future<List<String>?> readDnsServers(String service) => _guard(() async {
    reads++;
    return List.of(servers);
  });

  @override
  Future<bool> writeDnsServers(String service, List<String> servers) =>
      _guard(() async {
        if (!writeSucceeds) {
          return false;
        }
        writtenServices.add(service);
        writes.add(List.of(servers));
        if (service == this.service) {
          this.servers = List.of(servers);
        }
        return true;
      });

  Future<T> _guard<T>(Future<T> Function() body) async {
    inFlight++;
    maxInFlight = inFlight > maxInFlight ? inFlight : maxInFlight;
    try {
      if (delay > Duration.zero) {
        await Future.delayed(delay);
      }
      return await body();
    } finally {
      inFlight--;
    }
  }
}

class _FakeStore implements SystemDnsStore {
  _FakeStore([this.record]);

  SystemDnsRecord? record;
  int writeCount = 0;
  int clearCount = 0;

  @override
  Future<SystemDnsRecord?> read() async => record;

  @override
  Future<void> write(SystemDnsRecord record) async {
    writeCount++;
    this.record = record;
  }

  @override
  Future<void> clear() async {
    clearCount++;
    record = null;
  }
}

SystemDnsCoordinator _coordinator(_FakePort port, _FakeStore store) =>
    SystemDnsCoordinator(port: port, store: store, fallbackDns: '223.5.5.5');

void main() {
  test(
    'appends the fallback resolver and records the untouched servers',
    () async {
      final port = _FakePort(servers: ['1.1.1.1']);
      final store = _FakeStore();
      final coordinator = _coordinator(port, store);

      await coordinator.sync(true);

      expect(port.writes, [
        ['1.1.1.1', '223.5.5.5'],
      ]);
      expect(
        store.record,
        const SystemDnsRecord(service: 'Wi-Fi', servers: ['1.1.1.1']),
      );
    },
  );

  test('restores the recorded servers and forgets them', () async {
    final port = _FakePort(servers: ['1.1.1.1']);
    final store = _FakeStore();
    final coordinator = _coordinator(port, store);

    await coordinator.sync(true);
    await coordinator.sync(false);

    expect(port.writes.last, ['1.1.1.1']);
    expect(store.record, isNull);
    expect(coordinator.appliedRecord, isNull);
  });

  test(
    'restores an empty server list so the service returns to DHCP',
    () async {
      final port = _FakePort(servers: []);
      final store = _FakeStore();
      final coordinator = _coordinator(port, store);

      await coordinator.sync(true);
      await coordinator.sync(false);

      expect(port.writes, [
        ['223.5.5.5'],
        <String>[],
      ]);
    },
  );

  test('re-applying the same service writes nothing more', () async {
    final port = _FakePort(servers: ['1.1.1.1']);
    final store = _FakeStore();
    final coordinator = _coordinator(port, store);

    await coordinator.sync(true);
    await coordinator.resync();
    await coordinator.sync(true);

    expect(port.writes.length, 1);
    expect(store.record?.servers, ['1.1.1.1']);
  });

  test(
    'resync reinstalls a fallback that was cleared outside the app',
    () async {
      final port = _FakePort(servers: ['1.1.1.1']);
      final store = _FakeStore();
      final coordinator = _coordinator(port, store);

      await coordinator.sync(true);
      port.servers = ['8.8.8.8'];
      await coordinator.resync();

      expect(port.writes, [
        ['1.1.1.1', '223.5.5.5'],
        ['8.8.8.8', '223.5.5.5'],
      ]);
      expect(store.record?.servers, ['8.8.8.8']);

      await coordinator.sync(false);

      expect(port.writes.last, ['8.8.8.8']);
      expect(store.record, isNull);
    },
  );

  test(
    'keeps the pre-existing servers when the fallback is already set',
    () async {
      final port = _FakePort(servers: ['223.5.5.5', '1.1.1.1']);
      final store = _FakeStore();
      final coordinator = _coordinator(port, store);

      await coordinator.sync(true);

      expect(port.writes, isEmpty);
      expect(store.record?.servers, ['223.5.5.5', '1.1.1.1']);

      await coordinator.sync(false);

      expect(port.writes, [
        ['223.5.5.5', '1.1.1.1'],
      ]);
    },
  );

  test('restores a record left behind by a previous run', () async {
    final port = _FakePort(servers: ['1.1.1.1', '223.5.5.5']);
    final store = _FakeStore(
      const SystemDnsRecord(service: 'Wi-Fi', servers: ['1.1.1.1']),
    );
    final coordinator = _coordinator(port, store);

    await coordinator.sync(false);

    expect(port.writes, [
      ['1.1.1.1'],
    ]);
    expect(store.record, isNull);
  });

  test('never adopts a patched service as its own backup', () async {
    final port = _FakePort(servers: ['1.1.1.1', '223.5.5.5']);
    final store = _FakeStore(
      const SystemDnsRecord(service: 'Wi-Fi', servers: ['1.1.1.1']),
    );
    final coordinator = _coordinator(port, store);

    await coordinator.sync(true);

    expect(store.record?.servers, ['1.1.1.1']);

    await coordinator.sync(false);

    expect(port.writes, [
      ['1.1.1.1'],
    ]);
  });

  test(
    'moves the patch to the service the default route switched to',
    () async {
      final port = _FakePort(servers: ['1.1.1.1']);
      final store = _FakeStore();
      final coordinator = _coordinator(port, store);

      await coordinator.sync(true);
      port.service = 'Ethernet';
      port.servers = ['8.8.8.8'];
      await coordinator.resync();

      expect(port.writtenServices, ['Wi-Fi', 'Wi-Fi', 'Ethernet']);
      expect(port.writes, [
        ['1.1.1.1', '223.5.5.5'],
        ['1.1.1.1'],
        ['8.8.8.8', '223.5.5.5'],
      ]);
      expect(store.record?.service, 'Ethernet');
    },
  );

  test('does not record a patch the system rejected', () async {
    final port = _FakePort(servers: ['1.1.1.1'])..writeSucceeds = false;
    final store = _FakeStore();
    final coordinator = _coordinator(port, store);

    await coordinator.sync(true);

    expect(store.record, isNull);
    expect(coordinator.appliedRecord, isNull);

    port.writeSucceeds = true;
    await coordinator.resync();

    expect(store.record?.servers, ['1.1.1.1']);
  });

  test(
    'keeps the record when the restore fails so it can be retried',
    () async {
      final port = _FakePort(servers: ['1.1.1.1']);
      final store = _FakeStore();
      final coordinator = _coordinator(port, store);

      await coordinator.sync(true);
      port.writeSucceeds = false;
      await coordinator.sync(false);

      expect(store.record, isNotNull);

      port.writeSucceeds = true;
      await coordinator.resync();

      expect(store.record, isNull);
      expect(port.writes.last, ['1.1.1.1']);
    },
  );

  test('leaves the service untouched when no default route exists', () async {
    final port = _FakePort()..service = null;
    final store = _FakeStore();
    final coordinator = _coordinator(port, store);

    await coordinator.sync(true);

    expect(port.writes, isEmpty);
    expect(store.record, isNull);
  });

  test('serializes overlapping requests onto the last intent', () async {
    final port = _FakePort(servers: ['1.1.1.1'])
      ..delay = const Duration(milliseconds: 5);
    final store = _FakeStore();
    final coordinator = _coordinator(port, store);

    final first = coordinator.sync(true);
    final second = coordinator.sync(false);
    final third = coordinator.sync(true);
    await Future.wait([first, second, third]);

    expect(port.maxInFlight, 1);
    expect(port.writes.last, ['1.1.1.1', '223.5.5.5']);
    expect(store.record?.servers, ['1.1.1.1']);
  });

  test('shutdown restores once and ignores later requests', () async {
    final port = _FakePort(servers: ['1.1.1.1']);
    final store = _FakeStore();
    final coordinator = _coordinator(port, store);

    await coordinator.sync(true);
    await coordinator.shutdown();
    await coordinator.sync(true);
    await coordinator.resync();

    expect(port.writes, [
      ['1.1.1.1', '223.5.5.5'],
      ['1.1.1.1'],
    ]);
    expect(store.record, isNull);
  });

  test('decodes only a well formed record', () {
    expect(
      SystemDnsRecord.fromJson({
        'service': 'Wi-Fi',
        'servers': ['1.1.1.1', 2],
      }),
      const SystemDnsRecord(service: 'Wi-Fi', servers: ['1.1.1.1']),
    );
    expect(SystemDnsRecord.fromJson({'service': '', 'servers': []}), isNull);
    expect(SystemDnsRecord.fromJson({'service': 'Wi-Fi'}), isNull);
    expect(SystemDnsRecord.fromJson('Wi-Fi'), isNull);
  });
}
