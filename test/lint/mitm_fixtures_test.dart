import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:test/test.dart';

const _self = 'test/lint/mitm_fixtures_test.dart';
const _allowFile = 'test/lint/mitm_fixture_hosts.txt';

final _scoped = RegExp(r'(^|/)[^/]*(mitm|module)[^/]*$|/(mitm|modules?)/');

const _tlds =
    r'(?:com|net|org|cn|io|tv|me|co|cc|info|biz|app|dev|xyz|top|site|online'
    r'|jp|hk|tw|kr|uk|de|ru|fr|sg|us|ca|au|im|gg|link|cloud|fun|live|shop'
    r'|club|tech|store|ws|la|edu|gov|asia|pro|ink|work|art|wang|ltd|xin|eu)';

/// A name not inside a longer one: `*.a.com` and `+.a.com` start at `a`.
final _host = RegExp(
  r'(?<![\w-])(?<![\w-]\.)(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+'
  '$_tlds'
  r'(?![\w-])',
  caseSensitive: false,
);

/// A regex group of labels before a suffix, as in `(api|cdn)\.a\.com`.
final _group = RegExp(
  r'\((?:\?:)?([a-z0-9|-]+)\)\.((?:[a-z0-9-]+\.)*'
  '$_tlds'
  r')(?![\w-])',
  caseSensitive: false,
);

final _reserved = RegExp(
  r'(^|\.)(test|example|invalid|localhost|local)$|(^|\.)example\.(com|net|org)$',
);

/// Authors and channels the headers of published third-party modules carry.
const _markers = [
  'fmz200',
  'chavyleung',
  'zirawell',
  'kokoryh',
  'luestr',
  'app2smile',
  'maasea',
  'keywos',
  'blackmatrix7',
  'ifflagged',
  'ddgksf2013',
  'lodepuly',
  'wool_scripts',
  'tg-channel',
  'tg-group',
  '可莉',
  '奶思',
];

final _thirdPartyNotice = RegExp(r'^(SOURCES\.md|LICENSE.*)$');

/// A host listed for a path in [_allowFile] passes there with its subdomains.
typedef _Allowed = Map<String, Set<String>>;

_Allowed _readAllowed(String text) {
  final allowed = <String, Set<String>>{};
  for (final (index, raw) in text.split('\n').indexed) {
    final line = raw.trim();
    if (line.isEmpty || line.startsWith('#')) continue;
    final match = RegExp(r'^(\S+)\s+(\S+)\s+#\s*\S').firstMatch(line);
    if (match == null) {
      throw FormatException('$_allowFile:${index + 1}: "<path> <host> # why"');
    }
    allowed.putIfAbsent(match[1]!, () => {}).add(match[2]!.toLowerCase());
  }
  return allowed;
}

/// The text of each string literal and comment in Dart [source], each with
/// the offset it starts at; identifiers such as `this.app` are code.
List<(int, String)> _dartTexts(String source) {
  final texts = <(int, String)>[];
  var i = 0;
  while (i < source.length) {
    if (source.startsWith('//', i)) {
      final end = _indexOrEnd(source, '\n', i);
      texts.add((i, source.substring(i, end)));
      i = end;
    } else if (source.startsWith('/*', i)) {
      final end = _indexOrEnd(source, '*/', i + 2);
      texts.add((i, source.substring(i, end)));
      i = end + 2;
    } else if (source[i] == "'" || source[i] == '"') {
      final raw = i > 0 && source[i - 1] == 'r';
      final quote = source.startsWith(source[i] * 3, i)
          ? source[i] * 3
          : source[i];
      var end = i + quote.length;
      while (end < source.length && !source.startsWith(quote, end)) {
        if (quote.length == 1 && source[end] == '\n') break;
        end += !raw && source[end] == r'\' ? 2 : 1;
      }
      texts.add((i, source.substring(i + quote.length, end)));
      i = end + quote.length;
    } else {
      i++;
    }
  }
  return texts;
}

int _indexOrEnd(String source, String pattern, int start) {
  final index = source.indexOf(pattern, start);
  return index < 0 ? source.length : index;
}

/// Each host in [text], with regex and string escapes before its dots undone.
Iterable<String> _hostsIn(String text) sync* {
  final plain = text
      .replaceAll(RegExp(r'\\+\.'), '.')
      .replaceAll('[.]', '.')
      .toLowerCase();
  for (final match in _host.allMatches(plain)) {
    yield match[0]!;
  }
  for (final match in _group.allMatches(plain)) {
    for (final label in match[1]!.split('|')) {
      yield '$label.${match[2]}';
    }
  }
}

bool _passes(String host, Set<String> allowed) =>
    _reserved.hasMatch(host) ||
    allowed.any((entry) => host == entry || host.endsWith('.$entry'));

int _lineOf(String source, int offset) =>
    '\n'.allMatches(source.substring(0, offset)).length + 1;

List<String> _fixtureProblems(String path, String source, _Allowed allowed) {
  final problems = <String>[];
  final texts = path.endsWith('.dart') ? _dartTexts(source) : [(0, source)];
  for (final (start, text) in texts) {
    final first = _lineOf(source, start);
    for (final (index, line) in text.split('\n').indexed) {
      for (final host in _hostsIn(line)) {
        if (!_passes(host, allowed[path] ?? const {})) {
          problems.add(
            '$path:${first + index} — $host is a real host; use a reserved '
            'name such as a.test or example.com, or list it in $_allowFile '
            'with the reason.',
          );
        }
      }
    }
  }
  final lower = source.toLowerCase();
  for (final marker in _markers) {
    final index = lower.indexOf(marker.toLowerCase());
    if (index >= 0) {
      problems.add(
        '$path:${_lineOf(source, index)} — `$marker` marks a published '
        'third-party module; write a neutral sample instead.',
      );
    }
  }
  return problems;
}

/// Matches each path in the `/` form [_self], [_scoped] and [_allowFile] use,
/// however [style] writes it; reads it as written.
List<String> _scanProblems(
  Iterable<String> paths,
  String Function(String path) read,
  _Allowed allowed, {
  p.Context? style,
}) {
  final problems = <String>[];
  final seen = <String>{};
  for (final native in paths) {
    final path = p.posix.joinAll((style ?? p.context).split(native));
    if (path == _self || path == _allowFile) continue;
    if (path.startsWith('test/') &&
        _thirdPartyNotice.hasMatch(p.posix.basename(path))) {
      problems.add('$path — fixtures carry no third-party notices.');
      continue;
    }
    if (!_scoped.hasMatch(path)) continue;
    seen.add(path);
    problems.addAll(_fixtureProblems(path, read(native), allowed));
  }
  for (final path in allowed.keys) {
    if (!seen.contains(path) && File(path).existsSync()) {
      problems.add('$_allowFile names $path, which the check does not read.');
    }
  }
  return problems;
}

void main() {
  group('the fixture check', () {
    List<String> check(String source, [_Allowed allowed = const {}]) =>
        _fixtureProblems('test/x_mitm_test.dart', source, allowed);

    test('passes reserved hosts and code that only looks like one', () {
      expect(
        check(r'''
final app = this.app;
const module = r"""
hostname = a.test, *.example.com, api.example.net, b.localhost
^https?:\/\/a\.test\/ad reject
""";
'''),
        isEmpty,
      );
    });

    test('reports a real host in a string, a regex or a comment', () {
      expect(check("const a = 'DOMAIN,ads.real.com,REJECT';"), hasLength(1));
      expect(
        check(r"const a = r'^https:\/\/api\.real\.cn\/ad';"),
        hasLength(1),
      );
      expect(check("const a = '^https:\\\\/\\\\/api\\\\.real\\\\.cn';"), [
        contains('api.real.cn'),
      ]);
      expect(check('// from https://raw.real.io/x.sgmodule'), hasLength(1));
      expect(check("const a = 'always-real-ip = *.srv.real.net';"), [
        contains('srv.real.net'),
      ]);
      expect(
        check(r"const a = r'^https:\/\/(api|cdn)\.real\.com\/';").join(),
        allOf(contains('api.real.com'), contains('cdn.real.com')),
      );
    });

    test('passes a host its path lists, with its subdomains', () {
      expect(
        check("const a = 'https://link.real.ws/x';", {
          'test/x_mitm_test.dart': {'real.ws'},
        }),
        isEmpty,
      );
    });

    test('reports the marks of a published module', () {
      expect(check("const a = '#!author=fmz200';"), [contains('fmz200')]);
    });
  });

  test('reads a Windows path in the repository form', () {
    final files = {
      r'test\lint\mitm_fixtures_test.dart': "const a = 'fmz200';",
      r'lib\features\mitm\rules.dart': "const a = 'ads.real.com';",
      r'test\fixtures\LICENSE': '',
    };

    expect(
      _scanProblems(
        files.keys,
        (path) => files[path]!,
        const {},
        style: p.windows,
      ),
      [
        startsWith('lib/features/mitm/rules.dart:1 — ads.real.com'),
        startsWith('test/fixtures/LICENSE — '),
      ],
    );
  });

  test('MITM sources and fixtures hold only reserved hosts', () {
    final problems = _scanProblems(
      [
        for (final root in ['lib', 'test'])
          for (final entity in Directory(root).listSync(recursive: true))
            if (entity is File) entity.path,
      ],
      (path) => File(path).readAsStringSync(),
      _readAllowed(File(_allowFile).readAsStringSync()),
    );
    expect(problems, isEmpty, reason: problems.join('\n'));
  });
}
