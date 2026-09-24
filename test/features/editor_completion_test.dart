import 'package:code_forge/code_forge.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/features/editor/editor.dart';
import 'package:flutter_test/flutter_test.dart';

CodeForgeCompletion? _complete(
  String document, {
  Language language = Language.yaml,
  EditorSchema schema = EditorSchema.config,
  Set<String> words = const {},
}) {
  final caret = document.indexOf('|');
  final text = document.replaceFirst('|', '');
  final lines = text.substring(0, caret).split('\n');
  final line = lines.length - 1;
  return editorCompletionSource(language, schema)!(
    CodeForgeCompletionRequest(
      lines: text.split('\n'),
      version: 1,
      line: line,
      lineText: text.split('\n')[line],
      column: lines.last.length,
      documentWords: words,
    ),
  );
}

List<String> _labels(CodeForgeCompletion? completion) => [
  for (final suggestion in completion?.suggestions ?? const [])
    suggestion.label,
];

String? _inserted(CodeForgeCompletion? completion, String label) => completion!
    .suggestions
    .firstWhere((suggestion) => suggestion.label == label)
    .snippet
    ?.body;

const _profile = '''
proxies:
  - name: node-a
    type: vmess
  - {name: node-b, type: trojan}
proxy-groups:
  - name: Proxy
    type: select
    proxies:
      - node-a
rule-providers:
  ads:
    type: http
''';

void main() {
  group('Clash YAML', () {
    test('completes top-level keys and inserts the separator', () {
      final completion = _complete('mode: rule\nmix|');
      expect(_labels(completion).first, 'mixed-port');
      expect(_inserted(completion, 'mixed-port'), 'mixed-port: ');
    });

    test('keeps dashes in the prefix and opens a sequence', () {
      final completion = _complete('proxy-g|');
      expect(completion!.prefix, 'proxy-g');
      expect(_labels(completion), ['proxy-groups']);
      expect(_inserted(completion, 'proxy-groups'), 'proxy-groups:\n\t- ');
    });

    test('offers the keys of the enclosing map it does not have yet', () {
      final labels = _labels(_complete('dns:\n  enable: true\n  en|'));
      expect(labels, contains('enhanced-mode'));
      expect(labels, isNot(contains('enable')));
    });

    test('reads through a comment after a parent key', () {
      final labels = _labels(
        _complete('dns: # resolver\n  enable: true\n  en|'),
      );
      expect(labels, contains('enhanced-mode'));
    });

    test('completes a value from its key', () {
      expect(_labels(_complete('mode: g|')), ['global']);
      expect(_labels(_complete('dns:\n  enhanced-mode: fa|')), ['fake-ip']);
    });

    test('offers the fields of the proxy type', () {
      const vmess = 'proxies:\n  - name: a\n    type: vmess\n    alt|';
      expect(_labels(_complete(vmess)), contains('alterId'));
      const ss = 'proxies:\n  - name: a\n    type: ss\n    alt|';
      expect(_labels(_complete(ss)), isNot(contains('alterId')));
      expect(
        _labels(_complete('proxies:\n  - name: a\n    type: ss\n    ci|')),
        contains('cipher'),
      );
    });

    test('completes the keys of an item the caret line opens', () {
      final completion = _complete('proxies:\n  - na|');
      expect(_labels(completion).first, 'name');
      const nested = 'proxy-groups:\n  - name: G\n    type: select\n  - pro|';
      expect(_inserted(_complete(nested), 'proxies'), 'proxies:\n  \t- ');
    });

    test('completes rule types, matching segments and abbreviations', () {
      expect(
        _labels(_complete('rules:\n  - DOMAIN-S|')).first,
        'DOMAIN-SUFFIX',
      );
      expect(
        _labels(_complete('rules:\n  - suffix|')),
        contains('DOMAIN-SUFFIX'),
      );
      final completion = _complete('rules:\n- dsuf|');
      expect(_labels(completion).first, 'DOMAIN-SUFFIX');
      expect(_inserted(completion, 'DOMAIN-SUFFIX'), 'DOMAIN-SUFFIX,');
    });

    test('completes rule payloads, policies and options', () {
      const rules = '${_profile}rules:\n';
      expect(
        _labels(_complete('$rules  - GEOSITE,geolocation|')),
        unorderedEquals(['geolocation-!cn', 'geolocation-cn']),
      );
      expect(_labels(_complete('$rules  - RULE-SET,a|')), ['ads']);
      final policy = _complete('$rules  - DOMAIN,example.com,Pr|');
      expect(_labels(policy).first, 'Proxy');
      expect(policy!.suggestions.first.detail, 'select');
      expect(_labels(_complete('$rules  - MATCH,DI|')), ['DIRECT']);
      expect(_labels(_complete('$rules  - GEOIP,CN,DIRECT,no|')), [
        'no-resolve',
      ]);
      expect(_labels(_complete('$rules  - AND,((DOMAIN,a),(NET|')), [
        'NETWORK',
      ]);
      expect(
        _labels(_complete('$rules  - AND,((DOMAIN,a),(NETWORK,udp)),node|')),
        ['node-a', 'node-b'],
      );
    });

    test('keeps the names across edits outside the sections holding them', () {
      final source = editorCompletionSource(
        Language.yaml,
        EditorSchema.config,
      )!;
      List<String> policies(
        String profile,
        int version,
        ({int line, int removed, int inserted})? edited, {
        String rules = '  - MATCH,no',
      }) {
        final lines = '${profile}rules:\n$rules'.split('\n');
        return _labels(
          source(
            CodeForgeCompletionRequest(
              lines: lines,
              version: version,
              line: lines.length - 1,
              lineText: lines.last,
              column: lines.last.length,
              linesEditedSince: (_) => edited,
            ),
          ),
        );
      }

      final renamed = _profile.replaceFirst('node-a', 'node-z');
      expect(policies(_profile, 1, null), contains('node-a'));
      expect(
        policies(renamed, 2, (line: 13, removed: 0, inserted: 0)),
        contains('node-a'),
      );
      expect(
        policies(renamed, 3, (line: 1, removed: 0, inserted: 0)),
        contains('node-z'),
      );
      expect(
        policies(_profile, 4, (line: 12, removed: 0, inserted: 0)),
        contains('node-a'),
      );
      expect(
        policies(renamed, 5, (
          line: 13,
          removed: 0,
          inserted: 1,
        ), rules: '  - DOMAIN,a,DIRECT\n  - MATCH,no'),
        contains('node-a'),
      );
    });

    test('completes group members from the names the profile defines', () {
      final completion = _complete(
        _profile.replaceFirst(
          '      - node-a\n',
          '      - node-a\n      - node|\n',
        ),
      );
      expect(_labels(completion), ['node-a', 'node-b']);
      expect(completion!.suggestions.last.detail, 'trojan');
    });

    test('completes a flow sequence member', () {
      const document =
          'proxy-groups:\n  - name: G\n    type: select\n'
          '    proxies: [DIRECT, REJ|';
      expect(_labels(_complete(document)), ['REJECT', 'REJECT-DROP']);
    });

    test('completes against the part of the config being edited', () {
      expect(
        _labels(
          _complete('enable: true\nnameserver-p|', schema: EditorSchema.dns),
        ).first,
        'nameserver-policy',
      );
      expect(
        _labels(
          _complete(
            'nameserver:\n  - https://dns.al|',
            schema: EditorSchema.dns,
          ),
        ),
        ['https://dns.alidns.com/dns-query'],
      );
      expect(
        _labels(
          _complete('name: a\ntype: vless\nfl|', schema: EditorSchema.proxy),
        ),
        ['flow'],
      );
    });

    test('falls back to document words where the schema has no keys', () {
      final completion = _complete(
        'hosts:\n  exa|',
        words: {'example', 'other'},
      );
      expect(_labels(completion), ['example']);
    });

    test('stays quiet in comments', () {
      expect(_complete('# mix|'), isNull);
      expect(_complete('mode: rule # gl|'), isNull);
    });
  });

  group('script', () {
    CodeForgeCompletion? script(
      String document, {
      Set<String> words = const {},
    }) => _complete(document, language: Language.javaScript, words: words);

    test('completes config members, bracketing the dashed ones', () {
      final completion = script('const main = (config) => {\n  config.prox|');
      expect(completion!.prefix, '.prox');
      expect(_labels(completion), containsAll(['proxies', 'proxy-groups']));
      expect(_inserted(completion, 'proxy-groups'), "['proxy-groups']");
      expect(_inserted(completion, 'proxies'), '.proxies');
      expect(_labels(script("config['proxy-p|")).first, 'proxy-providers');
    });

    test('completes known values inside a string', () {
      expect(_labels(script("({ type: 'vm|")), ['vmess']);
      expect(
        _labels(script("proxy.type === 'hyst|")),
        unorderedEquals(['hysteria2', 'hysteria']),
      );
    });

    test('completes methods with their parentheses', () {
      final completion = script('config.proxies.fil|');
      expect(_labels(completion).first, 'filter');
      expect(_inserted(completion, 'filter'), r'filter($0)');
    });

    test('completes object keys only inside an object literal', () {
      final object = script('proxies.push({\n  name: "a",\n  skip|');
      expect(_labels(object), ['skip-cert-verify']);
      expect(_inserted(object, 'skip-cert-verify'), "'skip-cert-verify': ");
      final block = script('if (ok) {\n  ret|');
      expect(_labels(block), ['return']);
    });

    test('completes keywords, globals and document words', () {
      expect(
        _labels(script('con|', words: {'connections'})),
        unorderedEquals([
          'const',
          'config',
          'console',
          'continue',
          'connections',
        ]),
      );
      expect(script("const a = 'con|"), isNull);
      expect(script('// con|'), isNull);
    });
  });
}
