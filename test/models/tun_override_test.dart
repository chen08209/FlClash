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
    final networkKeys = defaultTun.coreJson.keys.toSet();

    for (final key in TunOverrideKey.values) {
      expect(networkKeys, isNot(contains(key.path)));
    }
  });

  group('PatchClashConfig from before the TUN override', () {
    PatchClashConfig decode(Map<String, Object?> json) =>
        PatchClashConfig.fromJson(
          jsonDecode(jsonEncode(json)) as Map<String, Object?>,
        );

    test('picks each network value changed from its default', () {
      final config = decode({
        'tun': {
          'mtu': 1400,
          'congestion-controller': 'cubic',
          'strict-route': true,
          'route-address': <String>[],
          'route-exclude-address': ['10.0.0.0/8'],
        },
      });

      expect(config.tunOverrideKeys, {
        TunOverrideKey.mtu,
        TunOverrideKey.strictRoute,
        TunOverrideKey.routeExcludeAddress,
      });
      expect(config.tunOverride.mtu, 1400);
      expect(config.tunOverride.strictRoute, isTrue);
      expect(config.tunOverride.routeExcludeAddress, ['10.0.0.0/8']);
      expect(config.tun.mtu, 1400);
    });

    test('a config saved with override keys is read as it is', () {
      final json = const PatchClashConfig(tun: Tun(mtu: 1400)).toJson();

      expect(decode(json).tunOverrideKeys, isEmpty);
    });
  });

  test('a custom profile picks its own TUN keys over the app-wide ones', () {
    const custom = ProfileOverrides(
      tun: ProfileTun(mtu: 1400, gso: true),
      tunOverrideKeys: {TunOverrideKey.mtu},
    );
    final merged = custom.overAppTun(
      const ProfileTun(mtu: 1500, strictRoute: true),
      {TunOverrideKey.mtu, TunOverrideKey.strictRoute},
    );

    expect(merged.tunOverrideKeys, {
      TunOverrideKey.mtu,
      TunOverrideKey.strictRoute,
    });
    expect(merged.tun.overrideJson(merged.tunOverrideKeys), {
      'mtu': 1400,
      'strict-route': true,
    });
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

    test('writes user IDs and ports as the numbers the core parses', () {
      const tun = ProfileTun(includeUid: [1000], excludeSrcPort: [22]);

      expect(
        tun.overrideJson({
          TunOverrideKey.includeUid,
          TunOverrideKey.excludeSrcPort,
        }),
        {
          'include-uid': [1000],
          'exclude-src-port': [22],
        },
      );
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
