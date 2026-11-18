import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/api/mapping.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

import '../../tool/src/concord_schema.dart';
import 'api/schema_core.dart';

/// `tool/check_sent_config.dart` loads these with `concord -t`; rewrite them
/// with `flutter test --update-goldens` after checking the change.
const _fixtures = 'test/fixtures/sent_config';

const _platforms = ['android', 'macos', 'windows', 'linux'];

const _table = '.agents/sent-config-keys.md';

const _sections = {
  'dns',
  'dns.fallback-filter',
  'tun',
  'sniffer',
  'ntp',
  'geox-url',
  'profile',
};

/// Keys FlClash writes whatever the user sets.
const _fixed = {
  'external-controller',
  'secret',
  'external-controller-tls',
  'external-controller-unix',
  'external-controller-pipe',
  'external-ui',
  'external-ui-url',
  'profile.store-selected',
  'tun.auto-route',
  'tun.auto-detect-interface',
};

const _profile = <String, dynamic>{
  'proxies': [
    {'name': 'a', 'type': 'direct'},
  ],
  'proxy-groups': [
    {
      'name': 'g',
      'type': 'select',
      'proxies': ['a', 'DIRECT'],
    },
  ],
  'proxy-providers': {
    'p': {'type': 'http', 'url': 'https://a.test/p.yaml'},
  },
  'rule-providers': {
    'r': {'type': 'http', 'behavior': 'domain', 'url': 'https://a.test/r'},
  },
  'rules': ['DOMAIN,a.test,g', 'MATCH,DIRECT'],
};

const _tun = ProfileTun(
  mtu: 1400,
  congestionController: 'reno',
  strictRoute: true,
  routeAddress: ['10.0.0.0/8'],
  routeExcludeAddress: ['10.1.0.0/16'],
  dnsHijack: ['any:53', 'tcp://any:53'],
  udpTimeout: 60,
  disableIcmpForwarding: true,
  includeInterface: ['eth1'],
  excludeInterface: ['docker0'],
  includeUid: [1000],
  excludeUid: [1001],
  excludeSrcPort: [5000],
  excludeDstPort: [5001],
);

const _dns = Dns(
  enable: true,
  listen: '127.0.0.1:1053',
  ipv6: true,
  preferH3: true,
  respectRules: true,
  enhancedMode: DnsMode.redirHost,
  fakeIpFilter: ['+.lan'],
  defaultNameserver: ['9.9.9.9'],
  nameserver: ['https://1.1.1.1/dns-query'],
  fallback: ['8.8.4.4'],
  proxyServerNameserver: ['8.8.8.8'],
  directNameserver: ['223.5.5.5'],
);

final _patch = defaultClashConfig.copyWith(
  mixedPort: 7899,
  socksPort: 7891,
  port: 7892,
  redirPort: 7893,
  tproxyPort: 7894,
  mode: Mode.global,
  allowLan: true,
  logLevel: LogLevel.debug,
  ipv6: true,
  findProcessMode: FindProcessMode.always,
  interfaceNameMode: InterfaceNameMode.custom,
  interfaceName: 'en9',
  keepAliveInterval: 20,
  keepAliveIdle: 25,
  disableKeepAlive: true,
  routingMark: 6666,
  unifiedDelay: false,
  tcpConcurrent: false,
  tun: defaultClashConfig.tun.copyWith(enable: true, device: 'utun9'),
  geoXUrl: const {
    GeoResource.MMDB: 'https://a.test/geoip.metadb',
    GeoResource.ASN: 'https://a.test/asn.mmdb',
    GeoResource.GEOSITE: 'https://a.test/geosite.dat',
  },
  globalUa: 'sample/1.0',
  externalController: ExternalControllerStatus.open,
  secret: 'sample',
  externalControllerCors: false,
  hosts: const {'a.test': '10.0.0.1'},
  geoAutoUpdate: true,
  geoUpdateInterval: 48,
  testUrl: 'https://a.test/generate_204',
  generalOverrideKeys: GeneralOverrideKey.values.toSet(),
  mitm: const Mitm(enable: true, hostname: ['a.test'], h2: true),
);

const _overrides = ProfileOverrides(
  dns: _dns,
  dnsOverrideKeys: {...DnsOverrideKey.values},
  ntp: Ntp(enable: true, server: 'ntp.a.test', writeToSystem: true),
  ntpOverrideKeys: {...NtpOverrideKey.values},
  sniffer: Sniffer(enable: true, forceDomain: ['+.a.test']),
  snifferOverrideKeys: {...SnifferOverrideKey.values},
  tun: _tun,
  tunOverrideKeys: {...TunOverrideKey.values},
);

Future<String> _sent(String os) async {
  final result = await makeRealProfileTask(
    MakeRealProfileState(
      profilesPath: '/profiles',
      profileId: 1,
      rawConfig: jsonDecode(jsonEncode(_profile)) as Map<String, dynamic>,
      realPatchConfig: _patch,
      overrides: _overrides,
      bypassPrivateRoute: true,
      appendSystemDns: true,
      os: os,
      proxyGroups: const [],
      rules: const [],
      addedRules: const [],
      defaultUA: 'FlClash-Test',
      authentication: const ['user:pass'],
    ),
  );
  return result.yaml;
}

void _expectFile(String path, String actual) {
  final file = File(path);
  if (autoUpdateGoldenFiles) {
    file
      ..createSync(recursive: true)
      ..writeAsStringSync(actual);
    return;
  }
  expect(
    file.existsSync(),
    isTrue,
    reason: '$path is missing; run flutter test --update-goldens',
  );
  expect(
    actual,
    file.readAsStringSync(),
    reason: '$path differs; run flutter test --update-goldens',
  );
}

Iterable<String> _paths(Map map, [String prefix = '']) sync* {
  for (final MapEntry(:key, :value) in map.entries) {
    final path = prefix.isEmpty ? '$key' : '$prefix.$key';
    if (_sections.contains(path) && value is Map) {
      yield* _paths(value, path);
    } else {
      yield path;
    }
  }
}

(String, String) _split(String path) {
  final dot = path.lastIndexOf('.');
  return dot < 0
      ? ('keys', path)
      : (path.substring(0, dot), path.substring(dot + 1));
}

String _setting(String path) {
  final (section, key) = _split(path);
  final relative = path.substring(path.indexOf('.') + 1);
  bool picks(List<OverrideKey> keys) => keys.any(
    (override) =>
        override.path == relative || override.path.split('.').first == relative,
  );
  if (_fixed.contains(path)) {
    return 'fixed';
  }
  return switch (section) {
    'keys' when _profile.containsKey(key) => 'profile',
    'keys' when key == 'mitm' => 'MITM',
    'keys' when defaultClashConfig.toJson().containsKey(key) => 'general',
    'keys' when key == 'authentication' => 'network',
    'dns' ||
    'dns.fallback-filter' when picks(DnsOverrideKey.values) => 'DNS override',
    'tun' when picks(TunOverrideKey.values) => 'TUN override',
    'tun' => 'TUN',
    'sniffer' when picks(SnifferOverrideKey.values) => 'sniffer override',
    'ntp' => 'NTP override',
    'geox-url' => 'general',
    _ => 'fixed',
  };
}

String _tier(ConcordSchema schema, String path) {
  final (section, key) = _split(path);
  return schema.tierOf(section, key)?.toUpperCase() ?? 'unknown';
}

String _default(ConcordSchema schema, String path) {
  final (section, key) = _split(path);
  final defaults = schema.defaults[section];
  if (defaults == null || !defaults.containsKey(key)) {
    return '';
  }
  return '`${jsonEncode(defaults[key])}`'.replaceAll('|', r'\|');
}

Future<String> _render() async {
  final schema = ConcordSchema.load();
  final sentOn = <String, List<String>>{};
  for (final os in _platforms) {
    for (final path in _paths(loadYaml(await _sent(os)) as Map)) {
      (sentOn[path] ??= []).add(os);
    }
  }
  final rows = [
    for (final path in sentOn.keys.toList()..sort())
      '| ${['`$path`', _setting(path), sentOn[path]!.join(', '), _tier(schema, path), _default(schema, path)].join(' | ')} |',
  ];
  return '''
# Keys Sent To The Core

Generated by `test/core/sent_config_golden_test.dart` from the config each
platform sends with every setting changed, and from the Core's
`concord/schema/config-schema.json`. Rewrite it with
`flutter test --update-goldens test/core/sent_config_golden_test.dart`.
Whether a key takes effect is what `make core-sent-config`
reports through `concord -t`, not this table.

| Key | FlClash setting | Sent on | Concord tier | mihomo default |
| --- | --- | --- | --- | --- |
${rows.join('\n')}
''';
}

void main() {
  for (final os in _platforms) {
    test('the config sent on $os matches its golden', () async {
      _expectFile('$_fixtures/$os.yaml', await _sent(os));
    });
  }

  test('the table of sent keys matches the goldens', () async {
    _expectFile(_table, await _render());
  });

  test('the live patch matches its golden and the Core declares it', () {
    final patch = configPatchOf(
      _patch,
      authentication: const ['user:pass'],
      hostCredential: 'host:secret',
      options: const CoreOptions(
        testUrl: 'https://a.test/generate_204',
        skipCertVerify: true,
        delayTestTimeout: 3000,
        mitmCapture: true,
      ),
    );
    _expectFile(
      '$_fixtures/patch.json',
      '${const JsonEncoder.withIndent('  ').convert(patch.toJson())}\n',
    );
    expect(
      ApiSchema.load().validate(patch.toJson(), {
        r'$ref': r'#/$defs/ConfigPatchParams',
      }),
      isEmpty,
      reason: 'the Core drops a patch key it does not declare',
    );
  });
}
