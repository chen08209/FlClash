import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

const _profileNtp = <String, dynamic>{
  'enable': true,
  'server': 'ntp.aliyun.com',
  'port': 123,
  'write-to-system': true,
};

const _patchConfig = PatchClashConfig(
  ntp: Ntp(server: 'time.cloudflare.com', interval: 60),
  ntpOverrideKeys: {NtpOverrideKey.server, NtpOverrideKey.interval},
);

Future<YamlMap?> _ntpOf({
  required Map<String, dynamic> rawConfig,
  required bool overrideNtp,
}) async {
  final result = await makeRealProfileTask(
    MakeRealProfileState(
      profilesPath: '/profiles',
      profileId: 1,
      rawConfig: rawConfig,
      realPatchConfig: _patchConfig,
      overrideDns: false,
      overrideNtp: overrideNtp,
      appendSystemDns: false,
      proxyGroups: const [],
      rules: const [],
      addedRules: const [],
      defaultUA: 'FlClash-Test',
    ),
  );
  final config = loadYaml(result.yaml) as YamlMap;
  return config['ntp'] as YamlMap?;
}

void main() {
  test('overrides only the selected NTP keys of a profile', () async {
    final ntp = await _ntpOf(
      rawConfig: {'ntp': _profileNtp},
      overrideNtp: true,
    );

    expect(ntp!['server'], 'time.cloudflare.com');
    expect(ntp['interval'], 60);
    expect(ntp['enable'], true);
    expect(ntp['port'], 123);
    expect(ntp['write-to-system'], true);
  });

  test('leaves the profile alone while the override is off', () async {
    final ntp = await _ntpOf(
      rawConfig: {'ntp': _profileNtp},
      overrideNtp: false,
    );

    expect(ntp!['server'], 'ntp.aliyun.com');
    expect(ntp.containsKey('interval'), isFalse);
  });

  test('writes nothing for a profile without NTP', () async {
    expect(await _ntpOf(rawConfig: {}, overrideNtp: false), isNull);
  });

  test('a profile without NTP gets only the selected keys', () async {
    final ntp = await _ntpOf(rawConfig: {}, overrideNtp: true);

    expect(ntp, {'server': 'time.cloudflare.com', 'interval': 60});
  });
}
