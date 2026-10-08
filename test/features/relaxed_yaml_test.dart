import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/editor/clash_schema.dart';
import 'package:fl_clash/features/editor/relaxed_yaml.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

void main() {
  Object? relaxed(String content, [EditorSchema schema = EditorSchema.dns]) =>
      loadYaml(relaxYaml(content, schema)!);

  group('relaxYaml', () {
    test('drops the section header a pasted fragment still carries', () {
      for (final (content, schema, expected) in [
        (
          'dns:\n  enable: true\n  ipv6: false\n',
          EditorSchema.dns,
          'enable: true\nipv6: false\n',
        ),
        (
          'DNS:\nenable: true\nipv6: false\n',
          EditorSchema.dns,
          'enable: true\nipv6: false\n',
        ),
        (
          'ntp:\n    enable: true\n    port: 123\n',
          EditorSchema.ntp,
          'enable: true\nport: 123\n',
        ),
      ]) {
        expect(relaxYaml(content, schema), expected, reason: content);
      }
    });

    test('nests each key the schema knows whatever its indentation', () {
      expect(
        relaxed('''
enable: true
  ipv6: false
  nameserver:
    - 1.1.1.1
    ipv6-timeout: 300
fallback-filter:
geoip: true
\tgeoip-code: CN
  respect-rules: true
'''),
        {
          'enable': true,
          'ipv6': false,
          'nameserver': ['1.1.1.1'],
          'ipv6-timeout': 300,
          'fallback-filter': {'geoip': true, 'geoip-code': 'CN'},
          'respect-rules': true,
        },
      );
    });

    test('nests a key the schema does not know by its indentation', () {
      expect(
        relaxed('''
nameserver:
  - 1.1.1.1
cache-max-size: 4096
nameserver-policy:
    localhost: 127.0.0.1
'''),
        {
          'nameserver': ['1.1.1.1'],
          'cache-max-size': 4096,
          'nameserver-policy': {
            'localhost': ['127.0.0.1'],
          },
        },
      );
    });

    test('reads a key with no space or a full-width colon after it', () {
      expect(relaxed('Enable:true\nipv6：false\nlisten: 0.0.0.0:53\n'), {
        'enable': true,
        'ipv6': false,
        'listen': '0.0.0.0:53',
      });
    });

    test('turns a list written on one line into entries', () {
      expect(
        relaxed('''
nameserver: 223.5.5.5, tls://1.1.1.1:853 # cn first
fake-ip-filter:
  *.lan，+.local
  -localhost
nameserver-policy:
  'geosite:cn': 223.5.5.5, 119.29.29.29
  geosite:private:
  - 192.168.1.1
proxy-server-nameserver: [8.8.8.8]
'''),
        {
          'nameserver': ['223.5.5.5', 'tls://1.1.1.1:853'],
          'fake-ip-filter': ['*.lan', '+.local', 'localhost'],
          'nameserver-policy': {
            'geosite:cn': ['223.5.5.5', '119.29.29.29'],
            'geosite:private': ['192.168.1.1'],
          },
          'proxy-server-nameserver': ['8.8.8.8'],
        },
      );
    });

    test('keeps a sniffer protocol apart from the keys around it', () {
      expect(
        relaxed('''
sniffer:
sniff:
http:
  ports: 80, 8080-8880
  override-destination: true
TLS:
ports: [443]
override-destination: false
''', EditorSchema.sniffer),
        {
          'sniff': {
            'HTTP': {
              'ports': [80, '8080-8880'],
              'override-destination': true,
            },
            'TLS': {
              'ports': [443],
              'override-destination': false,
            },
          },
        },
      );
    });

    test('takes the one group of a pasted proxy-groups list', () {
      expect(
        relaxed('''
proxy-groups:
  - name: Auto
    type: url-test
    proxies: HK 01, JP
''', EditorSchema.proxyGroup),
        {
          'name': 'Auto',
          'type': 'url-test',
          'proxies': ['HK 01', 'JP'],
        },
      );
    });

    test('leaves a document that is no map schema alone', () {
      expect(relaxYaml('- MATCH,DIRECT', EditorSchema.rules), isNull);
    });
  });

  group('readRelaxed', () {
    const dns = Dns();

    test('reads what parses as written without rewriting it', () {
      final contents = <String>[];
      readRelaxed('enable: true', EditorSchema.dns, contents.add);

      expect(contents, ['enable: true']);
    });

    test('a DNS quick edit takes a header and loose indentation', () {
      final result = readRelaxed(
        'dns:\nenable: true\n  nameserver: 1.1.1.1, 8.8.8.8\n',
        EditorSchema.dns,
        dns.applyOverrideYaml,
      );

      expect(result.dns.enable, isTrue);
      expect(result.dns.nameserver, ['1.1.1.1', '8.8.8.8']);
      expect(result.keys, {DnsOverrideKey.enable, DnsOverrideKey.nameserver});
    });

    test('reports the error of the text as written', () {
      expect(
        () => readRelaxed(
          'bogus-key: 1\nenable:true',
          EditorSchema.dns,
          dns.applyOverrideYaml,
        ),
        throwsA(isA<YamlException>()),
      );
    });
  });
}
