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
  test('NtpOverrideKey names every key of the core NTP section', () {
    final source = File('core/Clash.Meta/config/config.go').readAsStringSync();
    final body = RegExp(
      'type RawNTP struct {([^}]*)}',
    ).firstMatch(source)!.group(1)!;

    expect(NtpOverrideKey.values.map((key) => key.path).toSet(), {
      for (final match in RegExp(r'yaml:"([^",]+)').allMatches(body))
        match.group(1)!,
    });
  });

  test('the model defaults match the ones the core parses', () {
    final source = File('core/Clash.Meta/config/config.go').readAsStringSync();
    final body = RegExp(
      r'NTP: RawNTP\{([^}]*)\}',
    ).firstMatch(source)!.group(1)!;
    String valueOf(String field) =>
        RegExp('$field:\\s*(.+),').firstMatch(body)!.group(1)!.trim();

    expect(valueOf('Server'), '"${defaultNtp.server}"');
    expect(valueOf('Port'), '${defaultNtp.port}');
    expect(valueOf('Interval'), '${defaultNtp.interval}');
    expect(valueOf('Enable'), '${defaultNtp.enable}');
    expect(valueOf('WriteToSystem'), '${defaultNtp.writeToSystem}');
  });

  group('Ntp.overrideJson', () {
    test('emits only the selected keys in model order', () {
      const ntp = Ntp(server: 'time.cloudflare.com', port: 1230);
      final json = ntp.overrideJson({
        NtpOverrideKey.port,
        NtpOverrideKey.server,
      });

      expect(json.keys.toList(), ['server', 'port']);
      expect(json['server'], 'time.cloudflare.com');
      expect(json['port'], 1230);
    });

    test('is empty without keys', () {
      expect(const Ntp().overrideJson({}), isEmpty);
    });
  });

  group('PatchClashConfig.ntpOverrideKeys', () {
    test('round-trips as key paths', () {
      const config = PatchClashConfig(
        ntpOverrideKeys: {
          NtpOverrideKey.writeToSystem,
          NtpOverrideKey.dialerProxy,
        },
      );
      final json = config.toJson();

      expect(json['ntp-override-keys'], ['write-to-system', 'dialer-proxy']);
      expect(_decode(json).ntpOverrideKeys, config.ntpOverrideKeys);
    });

    test('a fresh config overrides nothing', () {
      expect(const PatchClashConfig().ntpOverrideKeys, isEmpty);
    });

    test('a config saved before the section keeps the empty set', () {
      final json = const PatchClashConfig().toJson()
        ..remove('ntp')
        ..remove('ntp-override-keys');
      final config = _decode(json);

      expect(config.ntpOverrideKeys, isEmpty);
      expect(config.ntp, defaultNtp);
    });

    test('a key this build does not know is dropped, not the config', () {
      final json = const PatchClashConfig(mixedPort: 7899).toJson();
      json['ntp-override-keys'] = ['server', 'key-from-a-newer-build'];
      final config = _decode(json);

      expect(config.ntpOverrideKeys, {NtpOverrideKey.server});
      expect(config.mixedPort, 7899);
    });
  });

  group('Ntp.applyOverrideYaml', () {
    const ntp = Ntp(enable: true, server: 'ntp.aliyun.com', interval: 60);
    const keys = {
      NtpOverrideKey.enable,
      NtpOverrideKey.server,
      NtpOverrideKey.interval,
    };

    test('round-trips the raw document', () {
      final result = ntp.applyOverrideYaml(ntp.overrideYaml(keys));

      expect(result.keys, keys);
      expect(result.ntp, ntp);
    });

    test('names the keys the document lists and keeps other values', () {
      final result = ntp.applyOverrideYaml('''
port: 1230
write-to-system: true
''');

      expect(result.keys, {NtpOverrideKey.port, NtpOverrideKey.writeToSystem});
      expect(result.ntp.port, 1230);
      expect(result.ntp.writeToSystem, isTrue);
      expect(result.ntp.server, 'ntp.aliyun.com');
      expect(result.ntp.interval, 60);
    });

    test('an empty document clears the key set', () {
      final result = ntp.applyOverrideYaml('');

      expect(result.keys, isEmpty);
      expect(result.ntp, ntp);
    });

    test('rejects unknown keys and values the model cannot hold', () {
      expect(
        () => ntp.applyOverrideYaml('bogus-key: 1'),
        throwsFormatException,
      );
      expect(() => ntp.applyOverrideYaml('port: many'), throwsA(anything));
      expect(() => ntp.applyOverrideYaml('- enable'), throwsFormatException);
    });
  });
}
