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
  test('SnifferOverrideKey names every current key of the core sniffer', () {
    final source = File('core/Clash.Meta/config/config.go').readAsStringSync();
    final body = RegExp(
      'type RawSniffer struct {([^}]*)}',
    ).firstMatch(source)!.group(1)!;
    final protocols = RegExp(r'List = \[\]Type\{([^}]*)\}')
        .firstMatch(
          File(
            'core/Clash.Meta/constant/sniffer/sniffer.go',
          ).readAsStringSync(),
        )!
        .group(1)!
        .split(',')
        .map((name) => name.trim());
    const deprecated = {'sniffing', 'port-whitelist'};

    expect(SnifferOverrideKey.values.map((key) => key.path).toSet(), {
      for (final match in RegExp(r'yaml:"([^",]+)').allMatches(body))
        if (!deprecated.contains(match.group(1)) &&
            match.group(1) != SnifferOverrideKey.sniffSection)
          match.group(1)!,
      for (final protocol in protocols)
        '${SnifferOverrideKey.sniffSection}.$protocol',
    });
  });

  test('the model defaults match the ones the core parses', () {
    final source = File('core/Clash.Meta/config/config.go').readAsStringSync();
    final body = RegExp(
      r'Sniffer: RawSniffer\{([\s\S]*?)\n\s*\},',
    ).firstMatch(source)!.group(1)!;
    String valueOf(String field) =>
        RegExp('$field:\\s*(.+),').firstMatch(body)!.group(1)!.trim();

    expect(valueOf('Enable'), '${defaultSniffer.enable}');
    expect(valueOf('OverrideDest'), '${defaultSniffer.overrideDest}');
    expect(valueOf('ForceDnsMapping'), '${defaultSniffer.forceDnsMapping}');
    expect(valueOf('ParsePureIp'), '${defaultSniffer.parsePureIp}');
  });

  group('Sniffer.overrideJson', () {
    test('emits only the selected keys in model order', () {
      const sniffer = Sniffer(skipDomain: ['+.push.apple.com']);
      final json = sniffer.overrideJson({
        SnifferOverrideKey.skipDomain,
        SnifferOverrideKey.enable,
      });

      expect(json.keys.toList(), ['enable', 'skip-domain']);
      expect(json['skip-domain'], ['+.push.apple.com']);
    });

    test('groups the selected protocols under sniff as plain maps', () {
      const sniffer = Sniffer(
        sniff: {
          'TLS': SnifferConfig(ports: ['443']),
        },
      );
      final json = sniffer.overrideJson({
        SnifferOverrideKey.sniffTls,
        SnifferOverrideKey.sniffHttp,
      });

      expect(json, {
        'sniff': {
          'HTTP': {'ports': <String>[]},
          'TLS': {
            'ports': ['443'],
          },
        },
      });
    });

    test('is empty without keys', () {
      expect(defaultSniffer.overrideJson({}), isEmpty);
    });
  });

  group('ProfileOverrides.snifferOverrideKeys', () {
    test('round-trips as key paths', () {
      const config = ProfileOverrides(
        sniffer: Sniffer(
          sniff: {
            'QUIC': SnifferConfig(ports: ['443'], overrideDest: false),
          },
        ),
        snifferOverrideKeys: {
          SnifferOverrideKey.sniffQuic,
          SnifferOverrideKey.parsePureIp,
        },
      );
      final json = jsonDecode(jsonEncode(config)) as Map<String, Object?>;

      expect(json['sniffer-override-keys'], ['sniff.QUIC', 'parse-pure-ip']);
      expect(_decode(json), config);
    });

    test('a config saved before the section keeps the empty set', () {
      final json = const ProfileOverrides().toJson()
        ..remove('sniffer')
        ..remove('sniffer-override-keys');
      final config = _decode(json);

      expect(config.snifferOverrideKeys, isEmpty);
      expect(config.sniffer, defaultSniffer);
    });

    test('a key this build does not know is dropped, not the config', () {
      final json = const ProfileOverrides(
        sniffer: Sniffer(enable: true),
      ).toJson();
      json['sniffer-override-keys'] = ['enable', 'sniff.FTP'];
      final config = _decode(json);

      expect(config.snifferOverrideKeys, {SnifferOverrideKey.enable});
      expect(config.sniffer.enable, isTrue);
    });
  });

  group('Sniffer.applyOverrideYaml', () {
    const sniffer = Sniffer(
      enable: true,
      forceDomain: ['+.google.com'],
      sniff: {
        'TLS': SnifferConfig(ports: ['443', '8443']),
      },
    );
    const keys = {
      SnifferOverrideKey.enable,
      SnifferOverrideKey.forceDomain,
      SnifferOverrideKey.sniffTls,
    };

    test('round-trips the raw document', () {
      final result = sniffer.applyOverrideYaml(sniffer.overrideYaml(keys));

      expect(result.keys, keys);
      expect(result.sniffer.enable, isTrue);
      expect(result.sniffer.forceDomain, ['+.google.com']);
      expect(result.sniffer.sniffOf(SnifferOverrideKey.sniffTls).ports, [
        '443',
        '8443',
      ]);
    });

    test('reads protocols in any case and ports as strings', () {
      final result = sniffer.applyOverrideYaml('''
sniff:
  http:
    ports: [80, 8080-8880]
    override-destination: false
''');

      expect(result.keys, {SnifferOverrideKey.sniffHttp});
      expect(
        result.sniffer.sniffOf(SnifferOverrideKey.sniffHttp),
        const SnifferConfig(ports: ['80', '8080-8880'], overrideDest: false),
      );
      expect(result.sniffer.sniffOf(SnifferOverrideKey.sniffTls).ports, [
        '443',
        '8443',
      ]);
      expect(result.sniffer.forceDomain, ['+.google.com']);
    });

    test('an empty document clears the key set', () {
      final result = sniffer.applyOverrideYaml('');

      expect(result.keys, isEmpty);
      expect(result.sniffer, sniffer);
    });

    test('rejects unknown keys and values the model cannot hold', () {
      expect(
        () => sniffer.applyOverrideYaml('sniffing: [tls]'),
        throwsFormatException,
      );
      expect(
        () => sniffer.applyOverrideYaml('sniff: {FTP: {ports: [21]}}'),
        throwsFormatException,
      );
      expect(
        () => sniffer.applyOverrideYaml('sniff: [TLS]'),
        throwsFormatException,
      );
      expect(
        () => sniffer.applyOverrideYaml('enable: maybe'),
        throwsA(anything),
      );
      expect(
        () => sniffer.applyOverrideYaml('- enable'),
        throwsFormatException,
      );
    });
  });
}
