import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:test/test.dart';

PatchClashConfig _decode(Map<String, Object?> json) {
  return PatchClashConfig.fromJson(
    jsonDecode(jsonEncode(json)) as Map<String, Object?>,
  );
}

void main() {
  test('DnsOverrideKey names every key of the core DNS section', () {
    final source = File('core/Clash.Meta/config/config.go').readAsStringSync();
    Iterable<String> yamlKeysOf(String struct) {
      final body = RegExp(
        'type $struct struct {([^}]*)}',
      ).firstMatch(source)!.group(1)!;
      return RegExp(
        r'yaml:"([^",]+)',
      ).allMatches(body).map((match) => match.group(1)!);
    }

    expect(DnsOverrideKey.values.map((key) => key.path).toSet(), {
      for (final key in yamlKeysOf('RawDNS'))
        if (key != DnsOverrideKey.fallbackFilterSection) key,
      for (final key in yamlKeysOf('RawFallbackFilter'))
        '${DnsOverrideKey.fallbackFilterSection}.$key',
    });
  });

  test('the model defaults match the core\'s but leave its presets unset', () {
    final source = File('core/Clash.Meta/config/config.go').readAsStringSync();
    final body = RegExp(
      r'DNS: RawDNS\{([\s\S]*?)\n\t\t\},',
    ).firstMatch(source)!.group(1)!;
    String valueOf(String field) =>
        RegExp('\\b$field:\\s*(.+),').firstMatch(body)!.group(1)!.trim();

    expect(valueOf('Enable'), '${defaultDns.enable}');
    expect(valueOf('IPv6'), '${defaultDns.ipv6}');
    expect(valueOf('UseHosts'), '${defaultDns.useHosts}');
    expect(valueOf('UseSystemHosts'), '${defaultDns.useSystemHosts}');
    expect(valueOf('IPv6Timeout'), '${defaultDns.ipv6Timeout}');
    expect(valueOf('FakeIPTTL'), '${defaultDns.fakeIpTtl}');
    expect(valueOf('GeoIP'), '${defaultDns.fallbackFilter.geoip}');
    expect(valueOf('EnhancedMode'), 'C.DNSMapping');
    expect(defaultDns.enhancedMode, DnsMode.redirHost);
    expect(valueOf('FakeIPFilterMode'), 'C.FilterBlackList');
    expect(defaultDns.fakeIpFilterMode, FakeIpFilterMode.blacklist);
    expect(
      defaultDns.overrideJson({
        DnsOverrideKey.listen,
        DnsOverrideKey.fakeIpRange,
        DnsOverrideKey.fakeIpRange6,
        DnsOverrideKey.fakeIpFilter,
        DnsOverrideKey.defaultNameserver,
        DnsOverrideKey.nameserver,
        DnsOverrideKey.fallbackFilterGeoipCode,
      }),
      isEmpty,
    );
  });

  group('Dns.overrideJson', () {
    test('emits only the selected keys in model order', () {
      const dns = Dns(listen: ':53', nameserver: ['1.1.1.1']);
      final json = dns.overrideJson({
        DnsOverrideKey.nameserver,
        DnsOverrideKey.listen,
      });

      expect(json.keys.toList(), ['listen', 'nameserver']);
      expect(json['nameserver'], ['1.1.1.1']);
      expect(json['listen'], ':53');
    });

    test('nests fallback filter keys and splits policy servers', () {
      const dns = Dns(
        nameserverPolicy: {'geosite:cn': 'a, b', 'x.com': '1.1.1.1'},
        fallbackFilter: FallbackFilter(geoipCode: 'US'),
      );
      final json = dns.overrideJson({
        DnsOverrideKey.nameserverPolicy,
        DnsOverrideKey.fallbackFilterGeoipCode,
      });

      expect(json['fallback-filter'], {'geoip-code': 'US'});
      expect(json['nameserver-policy'], {
        'geosite:cn': ['a', 'b'],
        'x.com': '1.1.1.1',
      });
    });

    test('is empty without keys', () {
      expect(const Dns().overrideJson({}), isEmpty);
    });
  });

  group('mergeDnsOverride', () {
    test('keeps the fallback filter keys the override does not name', () {
      final merged = mergeDnsOverride(
        {
          'enable': true,
          'fallback-filter': {
            'geoip': false,
            'domain': ['keep.me'],
          },
        },
        {
          'fallback-filter': {'geoip': true},
        },
      );

      expect(merged['enable'], true);
      expect(merged['fallback-filter'], {
        'geoip': true,
        'domain': ['keep.me'],
      });
    });

    test('replaces policy maps whole', () {
      final merged = mergeDnsOverride(
        {
          'nameserver-policy': {'a.com': '9.9.9.9', 'b.com': '8.8.8.8'},
        },
        {
          'nameserver-policy': {'a.com': '1.1.1.1'},
        },
      );

      expect(merged['nameserver-policy'], {'a.com': '1.1.1.1'});
    });

    test('replaces lists whole', () {
      final merged = mergeDnsOverride(
        {
          'nameserver': ['9.9.9.9', '8.8.8.8'],
        },
        {
          'nameserver': ['1.1.1.1'],
        },
      );

      expect(merged['nameserver'], ['1.1.1.1']);
    });
  });

  group('PatchClashConfig.dnsOverrideKeys', () {
    test('round-trips as key paths', () {
      const config = PatchClashConfig(
        dnsOverrideKeys: {
          DnsOverrideKey.fallbackFilterGeoip,
          DnsOverrideKey.nameserver,
        },
      );
      final json = config.toJson();

      expect(json['dns-override-keys'], [
        'fallback-filter.geoip',
        'nameserver',
      ]);
      expect(_decode(json).dnsOverrideKeys, config.dnsOverrideKeys);
    });

    test('a fresh config overrides nothing', () {
      expect(const PatchClashConfig().dnsOverrideKeys, isEmpty);
    });

    test('the baseline a profile without DNS is given stays minimal', () {
      expect(baselineDns.overrideJson(baselineDnsOverrideKeys), {
        'enable': true,
        'enhanced-mode': 'fake-ip',
        'nameserver': baselineDns.nameserver,
      });
    });

    test('a config saved before the key set keeps the keys it overrode', () {
      final json = const PatchClashConfig().toJson()
        ..remove('dns-override-keys');
      final keys = _decode(json).dnsOverrideKeys;

      expect(keys, hasLength(20));
      expect(keys, contains(DnsOverrideKey.fallbackFilterDomain));
      expect(keys, isNot(contains(DnsOverrideKey.directNameserver)));
    });

    test('a saved empty key set wins over edited values', () {
      final json = const PatchClashConfig(dns: Dns(ipv6: true)).toJson();
      json['dns-override-keys'] = <String>[];

      expect(_decode(json).dnsOverrideKeys, isEmpty);
    });

    test('a key this build does not know is dropped, not the config', () {
      final json = const PatchClashConfig(mixedPort: 7899).toJson();
      json['dns-override-keys'] = ['nameserver', 'key-from-a-newer-build'];
      final config = _decode(json);

      expect(config.dnsOverrideKeys, {DnsOverrideKey.nameserver});
      expect(config.mixedPort, 7899);
    });
  });

  group('Dns.applyOverrideYaml', () {
    const dns = Dns(
      ipv6: true,
      nameserverPolicy: {'geosite:cn': 'a, b'},
      fallbackFilter: FallbackFilter(geoipCode: 'US'),
    );
    const keys = {
      DnsOverrideKey.ipv6,
      DnsOverrideKey.nameserverPolicy,
      DnsOverrideKey.fallbackFilterGeoipCode,
    };

    test('round-trips the raw document', () {
      final result = dns.applyOverrideYaml(dns.overrideYaml(keys));

      expect(result.keys, keys);
      expect(result.dns, dns);
    });

    test('names the keys the document lists and keeps other values', () {
      final result = dns.applyOverrideYaml('''
nameserver:
  - 1.1.1.1
fallback-filter:
  geoip: false
''');

      expect(result.keys, {
        DnsOverrideKey.nameserver,
        DnsOverrideKey.fallbackFilterGeoip,
      });
      expect(result.dns.nameserver, ['1.1.1.1']);
      expect(result.dns.fallbackFilter.geoip, isFalse);
      expect(result.dns.fallbackFilter.geoipCode, 'US');
      expect(result.dns.ipv6, isTrue);
    });

    test('an empty document clears the key set', () {
      final result = dns.applyOverrideYaml('');

      expect(result.keys, isEmpty);
      expect(result.dns, dns);
    });

    test('reads the keys the core added and their enums', () {
      final result = dns.applyOverrideYaml('''
ipv6-timeout: 300
cache-algorithm: arc
fake-ip-filter-mode: whitelist
direct-nameserver-follow-policy: true
proxy-server-nameserver-policy:
  node.example: [1.1.1.1, 8.8.8.8]
''');

      expect(result.dns.ipv6Timeout, 300);
      expect(result.dns.cacheAlgorithm, DnsCacheAlgorithm.arc);
      expect(result.dns.fakeIpFilterMode, FakeIpFilterMode.whitelist);
      expect(result.dns.directNameserverFollowPolicy, isTrue);
      expect(result.dns.proxyServerNameserverPolicy, {
        'node.example': '1.1.1.1, 8.8.8.8',
      });
      expect(
        result.dns.overrideJson({DnsOverrideKey.proxyServerNameserverPolicy}),
        {
          'proxy-server-nameserver-policy': {
            'node.example': ['1.1.1.1', '8.8.8.8'],
          },
        },
      );
    });

    test('rejects unknown keys and values the model cannot hold', () {
      expect(
        () => dns.applyOverrideYaml('bogus-key: 1'),
        throwsFormatException,
      );
      expect(
        () => dns.applyOverrideYaml('fake-ip-filter-mode: sometimes'),
        throwsA(anything),
      );
      expect(
        () => dns.applyOverrideYaml('fallback-filter:\n  geo: true'),
        throwsFormatException,
      );
      expect(() => dns.applyOverrideYaml('ipv6: maybe'), throwsA(anything));
      expect(() => dns.applyOverrideYaml('- ipv6'), throwsFormatException);
    });
  });

  test('ProfileOverrides names the rule sets its picked policies match', () {
    const overrides = ProfileOverrides(
      dns: Dns(
        nameserverPolicy: {
          'rule-set:cn,private': '223.5.5.5',
          'geosite:gfw': '8.8.8.8',
        },
        proxyServerNameserverPolicy: {'RULE-SET:proxy': '1.1.1.1'},
      ),
      dnsOverrideKeys: {DnsOverrideKey.nameserverPolicy},
    );

    expect(overrides.ruleSets, {'cn', 'private'});
    expect(
      overrides
          .copyWith(
            dnsOverrideKeys: {
              DnsOverrideKey.nameserverPolicy,
              DnsOverrideKey.proxyServerNameserverPolicy,
            },
          )
          .ruleSets,
      {'cn', 'private', 'proxy'},
    );
    expect(overrides.copyWith(dnsOverrideKeys: {}).ruleSets, isEmpty);
  });

  test('a custom profile resolves unless it turns DNS off, and runs NTP and '
      'sniffing only once it turns them on', () {
    const fresh = ProfileOverrides();
    expect(fresh.customDnsEnabled, isTrue);
    expect(fresh.customNtpEnabled, isFalse);
    expect(fresh.customSnifferEnabled, isFalse);

    final picked = fresh.copyWith(
      dns: const Dns(enable: false),
      ntp: const Ntp(enable: true),
      sniffer: const Sniffer(enable: true),
    );
    expect(picked.customDnsEnabled, isTrue);
    expect(picked.customNtpEnabled, isFalse);
    expect(picked.customSnifferEnabled, isFalse);

    final on = picked.copyWith(
      dnsOverrideKeys: {DnsOverrideKey.enable},
      ntpOverrideKeys: {NtpOverrideKey.enable},
      snifferOverrideKeys: {SnifferOverrideKey.enable},
    );
    expect(on.customDnsEnabled, isFalse);
    expect(on.customNtpEnabled, isTrue);
    expect(on.customSnifferEnabled, isTrue);
  });

  group('ProxyProviderOptions', () {
    test('writes nothing until an option is set', () {
      expect(const ProxyProviderOptions().definition, isEmpty);
      expect(const ProxyProviderOptions(filter: 'HK').definition, {
        'filter': 'HK',
      });
    });

    test('a health check always names a url, so the core runs it', () {
      const options = ProxyProviderOptions(
        healthCheck: ProviderHealthCheck(timeout: 3000, lazy: false),
      );

      expect(options.definition, {
        'health-check': {
          'enable': true,
          'url': 'https://www.gstatic.com/generate_204',
          'timeout': 3000,
          'lazy': false,
        },
      });
    });

    test('writes only the overrides that are set, as the core names them', () {
      const options = ProxyProviderOptions(
        proxyOverride: ProviderOverride(
          additionalPrefix: 'HK-',
          udp: false,
          ipVersion: IpVersion.ipv4Prefer,
        ),
      );

      expect(options.definition, {
        'override': {
          'additional-prefix': 'HK-',
          'udp': false,
          'ip-version': 'ipv4-prefer',
        },
      });
    });

    test('survives a round trip through the profile overrides', () {
      const overrides = ProfileOverrides(
        proxyProviders: {
          'sub': ProxyProviderOptions(
            healthCheck: ProviderHealthCheck(url: 'https://example.com'),
            proxyOverride: ProviderOverride(
              skipCertVerify: true,
              ipVersion: IpVersion.ipv6Prefer,
            ),
          ),
        },
      );

      final decoded = ProfileOverrides.fromJson(
        jsonDecode(jsonEncode(overrides.toJson())) as Map<String, Object?>,
      );

      expect(decoded, overrides);
    });
  });
}
