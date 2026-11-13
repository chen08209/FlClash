import 'package:fl_clash/common/system_dns.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePort implements SystemDnsPort {
  bool writeSucceeds = true;
  final List<String> writes = [];

  @override
  Future<bool> writeDnsServers(String service, List<String> servers) async {
    writes.add('$service ${servers.join(',')}');
    return writeSucceeds;
  }
}

class _FakeStore implements SystemDnsStore {
  _FakeStore(this.record);

  SystemDnsRecord? record;

  @override
  Future<SystemDnsRecord?> read() async => record;

  @override
  Future<void> clear() async {
    record = null;
  }
}

void main() {
  test('puts back the servers an older build left and forgets them', () async {
    final port = _FakePort();
    final store = _FakeStore(
      const SystemDnsRecord(service: 'Wi-Fi', servers: ['192.168.1.1']),
    );

    await restoreLegacySystemDns(port: port, store: store);

    expect(port.writes, ['Wi-Fi 192.168.1.1']);
    expect(store.record, isNull);
  });

  test('leaves the system alone without a record', () async {
    final port = _FakePort();

    await restoreLegacySystemDns(port: port, store: _FakeStore(null));

    expect(port.writes, isEmpty);
  });

  test('tries a rejected restore only once', () async {
    final port = _FakePort()..writeSucceeds = false;
    final store = _FakeStore(
      const SystemDnsRecord(service: 'Wi-Fi', servers: []),
    );

    await restoreLegacySystemDns(port: port, store: store);
    await restoreLegacySystemDns(port: port, store: store);

    expect(port.writes, hasLength(1));
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
