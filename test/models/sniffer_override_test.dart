import 'dart:convert';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:test/test.dart';

import '../helpers/concord_config.dart';

ProfileOverrides _decode(Map<String, Object?> json) {
  return ProfileOverrides.fromJson(
    jsonDecode(jsonEncode(json)) as Map<String, Object?>,
  );
}

void main() {
  test('SnifferOverrideKey names every current key of the core sniffer', () {
    const deprecated = {'sniffing', 'port-whitelist'};

    expect(
      {
        for (final key in SnifferOverrideKey.values)
          if (!key.path.startsWith('${SnifferOverrideKey.sniffSection}.'))
            key.path,
      },
      concordKeys(
        'sniffer',
      ).difference({...deprecated, SnifferOverrideKey.sniffSection}),
    );
  });

  test('the model defaults match the ones the core parses', () {
    final core = concordDefaults('sniffer');

    expect(core['enable'], defaultSniffer.enable);
    expect(core['override-destination'], defaultSniffer.overrideDest);
    expect(core['force-dns-mapping'], defaultSniffer.forceDnsMapping);
    expect(core['parse-pure-ip'], defaultSniffer.parsePureIp);
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
