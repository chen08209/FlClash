import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:test/test.dart';

ProfileOverrides _decode(Map<String, Object?> json) {
  return ProfileOverrides.fromJson(
    jsonDecode(jsonEncode(json)) as Map<String, Object?>,
  );
}

void main() {
  test('every TunOverrideKey is a key of the core TUN section', () {
    final source = File('core/Clash.Meta/config/config.go').readAsStringSync();
    final body = RegExp(
      'type RawTun struct {([^}]*)}',
    ).firstMatch(source)!.group(1)!;
    final coreKeys = {
      for (final match in RegExp(r'yaml:"([^",]+)').allMatches(body))
        match.group(1)!,
    };

    expect(coreKeys, containsAll(TunOverrideKey.values.map((key) => key.path)));
  });

  test('no TunOverrideKey is one the network settings write', () {
    final networkKeys = defaultTun.toJson().keys.toSet();

    for (final key in TunOverrideKey.values) {
      expect(networkKeys, isNot(contains(key.path)));
    }
  });

  group('ProfileTun.overrideJson', () {
    test('emits only the selected keys', () {
      const tun = ProfileTun(
        disableIcmpForwarding: true,
        excludeInterface: ['docker0'],
      );

      expect(tun.overrideJson({TunOverrideKey.excludeInterface}), {
        'exclude-interface': ['docker0'],
      });
      expect(tun.overrideJson({}), isEmpty);
    });

    test('a list key without items writes nothing', () {
      expect(
        const ProfileTun().overrideJson({
          TunOverrideKey.disableIcmpForwarding,
          TunOverrideKey.excludeInterface,
        }),
        {'disable-icmp-forwarding': false},
      );
    });
  });

  group('ProfileOverrides.tunOverrideKeys', () {
    test('round-trips as key paths', () {
      const config = ProfileOverrides(
        tun: ProfileTun(excludeInterface: ['docker0']),
        tunOverrideKeys: {TunOverrideKey.excludeInterface},
      );
      final json = config.toJson();

      expect(json['tun-override-keys'], ['exclude-interface']);
      expect(_decode(json), config);
    });

    test('a config saved before the section overrides nothing', () {
      final json = const ProfileOverrides().toJson()
        ..remove('tun')
        ..remove('tun-override-keys');
      final config = _decode(json);

      expect(config.tunOverrideKeys, isEmpty);
      expect(config.tun, defaultProfileTun);
    });

    test('a key this build does not know is dropped, not the config', () {
      final json = const ProfileOverrides(
        tun: ProfileTun(disableIcmpForwarding: true),
      ).toJson();
      json['tun-override-keys'] = [
        'disable-icmp-forwarding',
        'key-from-a-newer-build',
      ];
      final config = _decode(json);

      expect(config.tunOverrideKeys, {TunOverrideKey.disableIcmpForwarding});
      expect(config.tun.disableIcmpForwarding, isTrue);
    });
  });
}
