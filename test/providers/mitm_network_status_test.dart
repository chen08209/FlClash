import 'package:fl_clash/common/mitm_network.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/mitm.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const overrides = ProfileOverrides(
    dns: Dns(nameserverPolicy: {'a.test': '8.8.8.8'}),
    dnsOverrideKeys: {
      DnsOverrideKey.nameserver,
      DnsOverrideKey.nameserverPolicy,
    },
  );

  bool overridesUser(MitmNetworkChange change) => mitmChangeOverridesUser(
    change,
    overrides: overrides,
    hosts: const {'own.test': '127.0.0.1'},
  );

  test('a module goes over a setting the user made only in full', () {
    final changes = const MitmNetwork(
      nameserver: MitmListEdit(replace: true, before: ['9.9.9.9']),
      defaultNameserver: MitmListEdit(replace: true, before: ['1.1.1.1']),
      fakeIpFilter: MitmListEdit(after: ['*.lan']),
      nameserverPolicy: {
        'a.test': ['system://'],
        'b.test': ['system://'],
      },
      hosts: {
        'own.test': ['0.0.0.0'],
        'ad.test': ['0.0.0.0'],
      },
      routeAddress: ['10.0.0.0/8'],
      bypassDomain: MitmListEdit(after: ['captive.test']),
    ).changes;
    expect(
      {
        for (final change in changes)
          change.entry ?? change.key.path: overridesUser(change),
      },
      {
        'nameserver': true,
        'default-nameserver': false,
        'fake-ip-filter': false,
        'a.test': true,
        'b.test': false,
        'own.test': true,
        'ad.test': false,
        'route-address': false,
        'bypass-domain': false,
      },
    );
    expect(
      overridesUser(
        const MitmNetworkChange(
          MitmNetworkKey.nameserver,
          edit: MitmListEdit(after: ['9.9.9.9']),
        ),
      ),
      isFalse,
    );
  });
}
