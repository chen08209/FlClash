import 'package:fl_clash/common/yaml_writer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yaml/yaml.dart';

const _awkwardStrings = [
  '0123', '00', '1e3', '0x1F', '0o17', '0b101', '1_000', '+1', '-0', '.5', //
  '1.', '.inf', '-.Inf', '.nan', 'yes', 'No', 'on', 'OFF', 'y', 'n', 'true',
  'False', 'null', 'Null', '~', '', ' ', '2001-12-14', '12:30', '1:20:30',
  '=', '!a', '- a', '? a', ': a', 'a: b', 'a #b', '#a', '&a', '*a', '|', '>',
  '%a', '@a', '`a', '[a', '{a', ',a', "'a", '"a', ' lead', 'trail ', 'a\tb',
  'geosite:cn', '+.google.com', '*.lan', 'rule-set:cn,direct', 'HK 🇭🇰 香港',
  'p\x00w\x7f\r\u0085\u2028\ufeff\uffff "q" \\', 'G\x07', 'k\x1bey',
  'a\nb', 'multi\nline \x1b\n', 'tail\n', 'two\n\n', '\nlead break', ' a\nb',
  'a\n  \nb', 'a \nb ', 'a\n\tb', '\n', 'a\n#b\n- c\n---\n...',
];

void main() {
  test('keeps the layout the Core config has always had', () {
    final text = writeYaml({
      'mixed-port': 7890,
      'proxies': [
        {'name': 'HK', 'type': 'ss', 'port': 443, 'udp': true, 'plugin': null},
      ],
      'proxy-groups': [
        {
          'name': 'G',
          'proxies': ['HK', 'DIRECT'],
        },
      ],
      'dns': {
        'enable': true,
        'nameserver': <String>[],
        'fallback-filter': <String, Object?>{},
      },
      'nameserver-policy': {'geosite:cn': 'system', '+.lan': 'system'},
      'certificate': 'line 1\nline 2\n',
      'rules': ['MATCH,G'],
      'matrix': [
        [1, 2],
        [3],
      ],
    });

    expect(text, '''
mixed-port: 7890
proxies:
  - name: "HK"
    type: "ss"
    port: 443
    udp: true
    plugin: null
proxy-groups:
  - name: "G"
    proxies:
      - "HK"
      - "DIRECT"
dns:
  enable: true
  nameserver: []
  fallback-filter: {}
nameserver-policy:
  geosite:cn: "system"
  +.lan: "system"
certificate: |
  line 1
  line 2
rules:
  - "MATCH,G"
matrix:
  - - 1
    - 2
  - - 3
''');
  });

  test('reads back every string as the same string, as value or key', () {
    final data = {
      'values': _awkwardStrings,
      'keys': {
        for (final text in _awkwardStrings.where((text) => text.isNotEmpty))
          text: text,
      },
    };

    expect(loadYaml(writeYaml(data)), data);
  });

  test('reads back numbers, booleans, nulls and non-string keys', () {
    final data = {
      'numbers': [0, -1, 1 << 53, 1e21, 1e-7, 3.0, -0.5],
      'flags': [true, false, null],
      'keys': {1: 'one', 2.5: 'half', true: 'yes', null: 'none'},
    };

    expect(loadYaml(writeYaml(data)), data);
  });

  test('writes non-finite doubles as YAML floats', () {
    final read =
        loadYaml(
              writeYaml([double.nan, double.infinity, double.negativeInfinity]),
            )
            as List;

    expect((read[0] as double).isNaN, isTrue);
    expect(read.sublist(1), [double.infinity, double.negativeInfinity]);
  });

  test('replaces a lone surrogate, which UTF-8 cannot carry', () {
    expect(loadYaml(writeYaml({'name': 'a\ud800b\udc00c'})), {
      'name': 'a\ufffdb\ufffdc',
    });
    expect(writeYaml({'flag': '🇭🇰'}), 'flag: "🇭🇰"\n');
  });

  test('leaves a merge key plain, the way the profile wrote it', () {
    final text = writeYaml({
      'proxy': {
        '<<': {'type': 'ss'},
        'name': 'HK',
      },
    });

    expect(text, contains('  <<:\n    type: "ss"\n'));
  });

  test('encodes sets and objects through toJson', () {
    expect(
      loadYaml(
        writeYaml({
          'set': {'a', 'b'},
          'object': _Encodable(),
        }),
      ),
      {
        'set': ['a', 'b'],
        'object': {'kind': 'encodable'},
      },
    );
  });
}

class _Encodable {
  Map<String, Object?> toJson() => {'kind': 'encodable'};
}
