import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

const _profileDns = <String, dynamic>{
  'enable': true,
  'listen': '0.0.0.0:53',
  'nameserver': ['9.9.9.9'],
  'fallback-filter': {
    'geoip': false,
    'domain': ['keep.me'],
  },
};

const _dns = Dns(
  listen: ':1053',
  ipv6: true,
  nameserver: ['1.1.1.1'],
  fallbackFilter: FallbackFilter(geoip: true),
);

const _keys = {
  DnsOverrideKey.nameserver,
  DnsOverrideKey.fallbackFilterGeoip,
  DnsOverrideKey.ipv6,
};

Future<YamlMap> _dnsOf({
  required Map<String, dynamic> rawConfig,
  Dns dns = _dns,
  Set<DnsOverrideKey> keys = _keys,
  bool keepEmpty = false,
}) async {
  final result = await makeRealProfileTask(
    MakeRealProfileState(
      profilesPath: '/profiles',
      profileId: 1,
      rawConfig: rawConfig,
      realPatchConfig: const PatchClashConfig(),
      overrides: ProfileOverrides(dns: dns, dnsOverrideKeys: keys),
      keepEmptyDnsOverrides: keepEmpty,
      appendSystemDns: false,
      proxyGroups: const [],
      rules: const [],
      addedRules: const [],
      defaultUA: 'FlClash-Test',
    ),
  );
  final config = loadYaml(result.yaml) as YamlMap;
  return config['dns'] as YamlMap;
}

void main() {
  test('overrides only the selected DNS keys of an enabled profile', () async {
    final dns = await _dnsOf(rawConfig: {'dns': _profileDns});

    expect(dns['nameserver'], ['1.1.1.1']);
    expect(dns['ipv6'], true);
    expect(dns['listen'], '0.0.0.0:53');
    expect(dns['fallback-filter'], {
      'geoip': true,
      'domain': ['keep.me'],
    });
  });

  test('leaves an enabled profile alone without picked keys', () async {
    final dns = await _dnsOf(rawConfig: {'dns': _profileDns}, keys: {});

    expect(dns['nameserver'], ['9.9.9.9']);
    expect(dns.containsKey('ipv6'), isFalse);
    expect(dns['fallback-filter'], {
      'geoip': false,
      'domain': ['keep.me'],
    });
  });

  test(
    'fills the minimal defaults plus overrides for a profile without DNS',
    () async {
      final dns = await _dnsOf(rawConfig: {});

      expect(dns, {
        'enable': true,
        'enhanced-mode': 'fake-ip',
        'nameserver': ['1.1.1.1'],
        'ipv6': true,
        'fallback-filter': {'geoip': true},
      });
    },
  );

  test('a key picked without a value writes nothing', () async {
    final dns = await _dnsOf(
      rawConfig: {'dns': _profileDns},
      dns: const Dns(nameserver: [], listen: ''),
      keys: {DnsOverrideKey.nameserver, DnsOverrideKey.listen},
    );

    expect(dns['nameserver'], ['9.9.9.9']);
    expect(dns['listen'], '0.0.0.0:53');
  });

  test(
    'keeps the profile proxy nameserver when respect-rules stays on',
    () async {
      final dns = await _dnsOf(
        rawConfig: {
          'dns': {
            ..._profileDns,
            'respect-rules': true,
            'proxy-server-nameserver': ['9.9.9.9'],
          },
        },
        dns: const Dns(),
        keys: {DnsOverrideKey.proxyServerNameserver},
        keepEmpty: true,
      );

      expect(dns['respect-rules'], true);
      expect(dns['proxy-server-nameserver'], ['9.9.9.9']);
    },
  );

  test('keeps the profile proxy nameserver when an override enables '
      'respect-rules', () async {
    final dns = await _dnsOf(
      rawConfig: {
        'dns': {
          ..._profileDns,
          'respect-rules': false,
          'proxy-server-nameserver': ['9.9.9.9'],
        },
      },
      dns: const Dns(respectRules: true),
      keys: {DnsOverrideKey.respectRules, DnsOverrideKey.proxyServerNameserver},
      keepEmpty: true,
    );

    expect(dns['respect-rules'], true);
    expect(dns['proxy-server-nameserver'], ['9.9.9.9']);
  });

  test('clears the profile proxy nameserver when an override disables '
      'respect-rules', () async {
    final dns = await _dnsOf(
      rawConfig: {
        'dns': {
          ..._profileDns,
          'respect-rules': true,
          'proxy-server-nameserver': ['9.9.9.9'],
        },
      },
      dns: const Dns(respectRules: false),
      keys: {DnsOverrideKey.respectRules, DnsOverrideKey.proxyServerNameserver},
      keepEmpty: true,
    );

    expect(dns['respect-rules'], false);
    expect(dns['proxy-server-nameserver'], isEmpty);
  });

  test(
    'replaces the profile proxy nameserver with a non-empty override',
    () async {
      final dns = await _dnsOf(
        rawConfig: {
          'dns': {
            ..._profileDns,
            'respect-rules': true,
            'proxy-server-nameserver': ['9.9.9.9'],
          },
        },
        dns: const Dns(proxyServerNameserver: ['1.1.1.1']),
        keys: {DnsOverrideKey.proxyServerNameserver},
        keepEmpty: true,
      );

      expect(dns['proxy-server-nameserver'], ['1.1.1.1']);
    },
  );

  test('an app entry emptied over a subscription replaces its value, save '
      'nameserver', () async {
    final dns = await _dnsOf(
      rawConfig: {'dns': _profileDns},
      dns: const Dns(
        nameserver: [],
        listen: '',
        fallbackFilter: FallbackFilter(domain: []),
      ),
      keys: {
        DnsOverrideKey.nameserver,
        DnsOverrideKey.listen,
        DnsOverrideKey.fallbackFilterDomain,
      },
      keepEmpty: true,
    );

    expect(dns['nameserver'], ['9.9.9.9']);
    expect(dns['listen'], '');
    expect(dns['fallback-filter'], {'geoip': false, 'domain': []});
  });
}
