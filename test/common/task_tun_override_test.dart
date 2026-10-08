import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

const _overrides = ProfileOverrides(
  tun: ProfileTun(disableIcmpForwarding: true, excludeInterface: ['docker0']),
  tunOverrideKeys: {
    TunOverrideKey.disableIcmpForwarding,
    TunOverrideKey.excludeInterface,
  },
);

Future<YamlMap> _tunOf({
  required Map<String, dynamic> rawConfig,
  ProfileOverrides overrides = _overrides,
}) async {
  final result = await makeRealProfileTask(
    MakeRealProfileState(
      profilesPath: '/profiles',
      profileId: 1,
      rawConfig: rawConfig,
      realPatchConfig: const PatchClashConfig(tun: Tun(mtu: 1400)),
      overrides: overrides,
      appendSystemDns: false,
      proxyGroups: const [],
      rules: const [],
      addedRules: const [],
      defaultUA: 'FlClash-Test',
    ),
  );
  final config = loadYaml(result.yaml) as YamlMap;
  return config['tun'] as YamlMap;
}

void main() {
  test('writes the selected keys beside the network settings', () async {
    final tun = await _tunOf(rawConfig: {});

    expect(tun['disable-icmp-forwarding'], true);
    expect(tun['exclude-interface'], ['docker0']);
    expect(tun['mtu'], 1400);
  });

  test('replaces the same keys of the profile and keeps the rest', () async {
    final tun = await _tunOf(
      rawConfig: {
        'tun': {
          'exclude-interface': ['eth1'],
          'include-uid': [1000],
        },
      },
    );

    expect(tun['exclude-interface'], ['docker0']);
    expect(tun['include-uid'], [1000]);
  });

  test('leaves the profile alone without picked keys', () async {
    final tun = await _tunOf(
      rawConfig: {
        'tun': {
          'exclude-interface': ['eth1'],
        },
      },
      overrides: const ProfileOverrides(
        tun: ProfileTun(disableIcmpForwarding: true),
      ),
    );

    expect(tun['exclude-interface'], ['eth1']);
    expect(tun.containsKey('disable-icmp-forwarding'), isFalse);
  });
}
