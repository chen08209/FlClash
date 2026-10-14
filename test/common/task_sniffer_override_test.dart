import 'dart:convert';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

Map<String, dynamic> _profileSniffer() => jsonDecode('''
{
  "enable": false,
  "override-destination": false,
  "skip-domain": ["keep.me"],
  "sniff": {"tls": {"ports": [443]}, "HTTP": {"ports": [80]}}
}
''');

const _overrides = ProfileOverrides(
  sniffer: Sniffer(
    enable: true,
    forceDomain: ['+.example.com'],
    sniff: {
      'TLS': SnifferConfig(ports: ['443', '8443']),
    },
  ),
  snifferOverrideKeys: {
    SnifferOverrideKey.enable,
    SnifferOverrideKey.forceDomain,
    SnifferOverrideKey.sniffTls,
  },
);

Future<YamlMap?> _snifferOf({
  required Map<String, dynamic> rawConfig,
  ProfileOverrides overrides = _overrides,
}) async {
  final result = await makeRealProfileTask(
    MakeRealProfileState(
      profilesPath: '/profiles',
      profileId: 1,
      rawConfig: rawConfig,
      realPatchConfig: const PatchClashConfig(),
      overrides: overrides,
      appendSystemDns: false,
      proxyGroups: const [],
      rules: const [],
      addedRules: const [],
      defaultUA: 'FlClash-Test',
    ),
  );
  final config = loadYaml(result.yaml) as YamlMap;
  return config['sniffer'] as YamlMap?;
}

void main() {
  test('overrides only the selected sniffer keys of a profile', () async {
    final sniffer = await _snifferOf(rawConfig: {'sniffer': _profileSniffer()});

    expect(sniffer!['enable'], true);
    expect(sniffer['force-domain'], ['+.example.com']);
    expect(sniffer['override-destination'], false);
    expect(sniffer['skip-domain'], ['keep.me']);
  });

  test(
    'an overridden protocol replaces the profile entry of any case',
    () async {
      final sniffer = await _snifferOf(
        rawConfig: {'sniffer': _profileSniffer()},
      );

      expect(sniffer!['sniff'], {
        'HTTP': {
          'ports': ['80'],
        },
        'TLS': {
          'ports': ['443', '8443'],
        },
      });
    },
  );

  test('keeps the protocols a profile lists in the deprecated form', () async {
    final sniffer = await _snifferOf(
      rawConfig: {
        'sniffer': jsonDecode('''
{"enable": true, "sniffing": ["tls", "http"], "port-whitelist": [443, "8000-9000"]}
'''),
      },
    );

    expect(sniffer!['sniff'], {
      'HTTP': {
        'ports': ['443', '8000-9000'],
      },
      'TLS': {
        'ports': ['443', '8443'],
      },
    });
  });

  test('leaves the profile alone without picked keys', () async {
    final sniffer = await _snifferOf(
      rawConfig: {'sniffer': _profileSniffer()},
      overrides: const ProfileOverrides(),
    );

    expect(sniffer!['enable'], false);
    expect(sniffer.containsKey('force-domain'), isFalse);
    expect((sniffer['sniff'] as YamlMap).keys, ['tls', 'HTTP']);
  });

  test('a profile without a sniffer gets only the selected keys', () async {
    final sniffer = await _snifferOf(rawConfig: {});

    expect(sniffer, {
      'enable': true,
      'force-domain': ['+.example.com'],
      'sniff': {
        'TLS': {
          'ports': ['443', '8443'],
        },
      },
    });
  });
}
