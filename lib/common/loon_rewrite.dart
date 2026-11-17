import 'dart:convert';

/// What a Loon `request|response if <condition> then <actions>` line becomes
/// in the Core's lists. Map Local entries and scripts come back unwritten, as
/// the module parser places their files.
class LoonRewrite {
  final urlRewrite = <String>[];
  final headerRewrite = <String>[];
  final bodyRewrite = <String>[];
  final mapLocal = <LoonLocal>[];
  final requestBodyMock = <LoonLocal>[];
  final scripts = <({String path, Map<String, String> fields, String tag})>[];
}

/// A Map Local or request body mock line: its URL pattern, the request head
/// it is conditioned on, and its parameters.
typedef LoonLocal = ({
  String pattern,
  String? head,
  Map<String, String> params,
});

enum LoonRewriteFailure {
  /// The line is not one Loon's grammar gives.
  unreadable,

  /// It reads, but asks for a condition or action the Core cannot run.
  unsupported,
}

/// Content types Loon names for mocks, as the headers they stand for.
const loonContentTypes = {
  'text': 'text/plain; charset=utf-8',
  'plain': 'text/plain; charset=utf-8',
  'json': 'application/json',
  'html': 'text/html; charset=utf-8',
  'javascript': 'application/javascript',
  'css': 'text/css',
  'xml': 'application/xml',
  'text/event-stream': 'text/event-stream',
  'form-data': 'multipart/form-data',
  'png': 'image/png',
  'jpg': 'image/jpeg',
  'jpeg': 'image/jpeg',
  'gif': 'image/gif',
  'tiff': 'image/tiff',
  'svg': 'image/svg+xml',
  'mp4': 'video/mp4',
};

Object translateLoonRewrite(String line) {
  final tokens = _lex(line);
  if (tokens == null) {
    return LoonRewriteFailure.unreadable;
  }
  try {
    return _Translator(_Reader(tokens)).translate();
  } on _Unsupported {
    return LoonRewriteFailure.unsupported;
  } on FormatException {
    return LoonRewriteFailure.unreadable;
  }
}

class _Unsupported implements Exception {
  const _Unsupported();
}

enum _Kind { word, variable, string, regex, number, symbol, json }

class _Token {
  const _Token(this.kind, this.text, [this.flags = '']);

  final _Kind kind;
  final String text;
  final String flags;

  bool isSymbol(String symbol) => kind == _Kind.symbol && text == symbol;

  bool isWord(String word) => kind == _Kind.word && text == word;
}

List<_Token>? _lex(String line) {
  final tokens = <_Token>[];
  var i = 0;
  while (i < line.length) {
    final c = line[i];
    if (c == ' ' || c == '\t') {
      i++;
    } else if (line.startsWith(r'${', i)) {
      final end = line.indexOf('}', i);
      if (end < 0) {
        return null;
      }
      tokens.add(_Token(_Kind.variable, line.substring(i + 2, end)));
      i = end + 1;
    } else if (c == '"') {
      final buffer = StringBuffer();
      i++;
      while (i < line.length && line[i] != '"') {
        if (line[i] == r'\' && i + 1 < line.length) {
          buffer.write(switch (line[i + 1]) {
            'n' => '\n',
            'r' => '\r',
            't' => '\t',
            final other => other,
          });
          i += 2;
        } else {
          buffer.write(line[i++]);
        }
      }
      if (i >= line.length) {
        return null;
      }
      tokens.add(_Token(_Kind.string, buffer.toString()));
      i++;
    } else if (c == '`') {
      final buffer = StringBuffer();
      i++;
      while (i < line.length) {
        if (line.startsWith('``', i)) {
          buffer.write('`');
          i += 2;
        } else if (line[i] == '`') {
          break;
        } else {
          buffer.write(line[i++]);
        }
      }
      if (i >= line.length) {
        return null;
      }
      tokens.add(_Token(_Kind.string, buffer.toString()));
      i++;
    } else if (c == '/') {
      var end = i + 1;
      while (end < line.length && line[end] != '/') {
        end += line[end] == r'\' ? 2 : 1;
      }
      if (end >= line.length) {
        return null;
      }
      final flags = RegExp('[ims]*').matchAsPrefix(line, end + 1)!.group(0)!;
      tokens.add(_Token(_Kind.regex, line.substring(i + 1, end), flags));
      i = end + 1 + flags.length;
    } else if (c == '{') {
      final end = _closing(line, i);
      if (end < 0) {
        return null;
      }
      tokens.add(_Token(_Kind.json, line.substring(i, end + 1)));
      i = end + 1;
    } else if (RegExp(r'[-\d]').hasMatch(c)) {
      final match = RegExp(r'-?\d+(\.\d+)?').matchAsPrefix(line, i);
      if (match == null) {
        return null;
      }
      tokens.add(_Token(_Kind.number, match.group(0)!));
      i = match.end;
    } else if (RegExp(r'[A-Za-z_]').hasMatch(c)) {
      final match = RegExp(r'[A-Za-z_][\w.]*').matchAsPrefix(line, i)!;
      tokens.add(_Token(_Kind.word, match.group(0)!));
      i = match.end;
    } else {
      final symbol = const [
        '==',
        '~=',
        '&&',
        '||',
        '(',
        ')',
        ',',
        '[',
        ']',
        '|',
        '=',
      ].firstWhere((symbol) => line.startsWith(symbol, i), orElse: () => '');
      if (symbol.isEmpty) {
        return null;
      }
      tokens.add(_Token(_Kind.symbol, symbol));
      i += symbol.length;
    }
  }
  return tokens;
}

/// The index of the brace closing the one at [start], strings skipped.
int _closing(String text, int start) {
  var depth = 0;
  var quoted = false;
  for (var i = start; i < text.length; i++) {
    final c = text[i];
    if (quoted) {
      if (c == r'\') {
        i++;
      } else if (c == '"') {
        quoted = false;
      }
    } else if (c == '"') {
      quoted = true;
    } else if (c == '{') {
      depth++;
    } else if (c == '}' && --depth == 0) {
      return i;
    }
  }
  return -1;
}

class _Reader {
  _Reader(this.tokens);

  final List<_Token> tokens;
  var at = 0;

  bool get done => at == tokens.length;

  _Token? get peek => done ? null : tokens[at];

  _Token next() => done ? throw const FormatException() : tokens[at++];

  bool takeSymbol(String symbol) {
    if (peek?.isSymbol(symbol) ?? false) {
      at++;
      return true;
    }
    return false;
  }

  bool takeWord(String word) {
    if (peek?.isWord(word) ?? false) {
      at++;
      return true;
    }
    return false;
  }

  void expectSymbol(String symbol) {
    if (!takeSymbol(symbol)) {
      throw const FormatException();
    }
  }
}

/// One comparison of the condition.
class _Test {
  const _Test(
    this.subject,
    this.regex,
    this.capture, {
    this.exact,
    this.within,
    this.lookahead,
    this.onResponse = false,
  });

  /// `url`, `method`, [_statusSubject], a header's name, or [_headSubject].
  final String subject;
  final String regex;
  final String? capture;

  /// The value `==` asks for.
  final String? exact;

  final String? within;

  final String? lookahead;

  final bool onResponse;
}

const _statusSubject = ':status';
const _headSubject = ':head';
final _headerVariable = RegExp(
  r"""^(request|response)\.header\[['"](.+)['"]\]$""",
);

class _Translator {
  _Translator(this.reader);

  final _Reader reader;
  late final bool response;
  late final String url;
  String? head;
  String? responseHead;
  String? capture;

  LoonRewrite translate() {
    final phase = reader.next();
    if (!phase.isWord('request') && !phase.isWord('response')) {
      throw const FormatException();
    }
    response = phase.text == 'response';
    if (!reader.takeWord('if')) {
      throw const FormatException();
    }
    _condition(_or());
    if (!reader.takeWord('then')) {
      throw const FormatException();
    }
    final out = LoonRewrite();
    do {
      _action(out);
    } while (reader.takeSymbol('|'));
    if (!reader.done) {
      _with(out);
    }
    return out;
  }

  /// The disjunction, each branch a conjunction of tests.
  List<List<_Test>> _or() {
    final branches = <List<_Test>>[];
    do {
      branches.add(_and());
    } while (reader.takeSymbol('||'));
    return branches;
  }

  List<_Test> _and() {
    final tests = <_Test>[];
    do {
      if (reader.takeSymbol('(')) {
        final inner = _or();
        reader.expectSymbol(')');
        tests.addAll(inner.length == 1 ? inner.single : [_alternation(inner)]);
      } else {
        tests.add(_test());
      }
    } while (reader.takeSymbol('&&'));
    return tests;
  }

  _Test _test() {
    final variable = reader.next();
    if (variable.kind != _Kind.variable) {
      throw const FormatException();
    }
    final header = _headerVariable.firstMatch(variable.text);
    final onResponse =
        variable.text == 'response.status' || header?.group(1) == 'response';
    if (onResponse && !response) {
      throw const FormatException();
    }
    final subject = switch (variable.text) {
      'url' => 'url',
      'request.method' => 'method',
      'response.status' => _statusSubject,
      final text when text.startsWith(RegExp(r'(request|response)\.header')) =>
        header?.group(2),
      _ => throw const _Unsupported(),
    };
    if (subject == null) {
      throw const FormatException();
    }
    final operator = reader.next();
    final value = reader.next();
    String? capture;
    if (reader.takeWord('as')) {
      capture = reader.next().text;
    }
    final literal = subject == _statusSubject ? _Kind.number : _Kind.string;
    if (operator.isSymbol('==') && value.kind == literal) {
      return _Test(
        subject,
        '^${RegExp.escape(value.text)}\$',
        capture,
        exact: value.text,
        onResponse: onResponse,
      );
    }
    if (operator.isSymbol('~=') && value.kind == _Kind.regex) {
      return _Test(
        subject,
        _scoped(value.text, value.flags),
        capture,
        within: _within(value.text, value.flags, switch (subject) {
          'method' => '[^ ]*',
          _statusSubject => r'\d*',
          _ => r'[^\r\n]*',
        }),
        onResponse: onResponse,
      );
    }
    throw const FormatException();
  }

  /// Branches that any may pass, as one test: all on the URL, or all on the
  /// same head, since the Core asks the URL and each head apart.
  _Test _alternation(List<List<_Test>> branches) {
    final tests = branches.expand((branch) => branch);
    if (tests.any((test) => test.capture != null)) {
      throw const _Unsupported();
    }
    if (tests.every((test) => test.subject == 'url')) {
      return _Test(
        'url',
        branches.map((branch) => '(?:${_allUrls(branch)})').join('|'),
        null,
      );
    }
    final onResponse = tests.first.onResponse;
    if (tests.any(
      (test) => test.subject == 'url' || test.onResponse != onResponse,
    )) {
      throw const _Unsupported();
    }
    return _Test(
      _headSubject,
      '',
      null,
      lookahead:
          '(?:${branches.map((branch) => branch.map(_lookahead).join()).join('|')})',
      onResponse: onResponse,
    );
  }

  String _allUrls(List<_Test> tests) => tests.length == 1
      ? tests.single.regex
      : '^${tests.map((test) => '(?=[\\s\\S]*?(?:${test.regex}))').join()}';

  void _condition(List<List<_Test>> branches) {
    final tests = branches.length == 1
        ? branches.single
        : [_alternation(branches)];
    final urls = tests.where((test) => test.subject == 'url').toList();
    if (urls.length > 1 && urls.any((test) => test.capture != null)) {
      throw const _Unsupported();
    }
    url = urls.isEmpty ? '^' : _allUrls(urls);
    capture = urls.length == 1 ? urls.single.capture : null;
    final others = tests.where((test) => test.subject != 'url').toList();
    if (others.isEmpty) {
      return;
    }
    if (others.any((test) => test.capture != null)) {
      throw const _Unsupported();
    }
    String? headOf(Iterable<_Test> tests) =>
        tests.isEmpty ? null : '^${tests.map(_lookahead).join()}';
    head = headOf(others.where((test) => !test.onResponse));
    responseHead = headOf(others.where((test) => test.onResponse));
  }

  /// A test on the method, the status or a header as a lookahead over a head,
  /// whose first line starts with the method and whose header lines run
  /// `\r\nName: value`.
  String _lookahead(_Test test) {
    if (test.lookahead case final lookahead?) {
      return lookahead;
    }
    final value = test.exact != null
        ? RegExp.escape(test.exact!)
        : test.within!;
    return switch (test.subject) {
      'method' => '(?=$value )',
      _statusSubject => '(?=\\S+ $value(?: |\\r\\n))',
      final name =>
        '(?=[\\s\\S]*\\r\\n(?i:${RegExp.escape(name)}): $value\\r\\n)',
    };
  }

  /// A regex Loon finds in a value as a match of the whole value, `filler`
  /// standing for the rest of it on a side the regex does not anchor.
  String _within(String regex, String flags, String filler) {
    final start = regex.startsWith('^') && !regex.contains('|');
    final end =
        regex.endsWith(r'$') && !regex.endsWith(r'\$') && !regex.contains('|');
    final inner = regex.substring(start ? 1 : 0, regex.length - (end ? 1 : 0));
    return '${start ? '' : filler}(?:${_scoped(inner, flags)})${end ? '' : filler}';
  }

  String _scoped(String regex, String flags) =>
      flags.isEmpty ? regex : '(?$flags:$regex)';

  void _action(LoonRewrite out) {
    final name = reader.next();
    if (name.kind != _Kind.word) {
      throw const FormatException();
    }
    reader.expectSymbol('(');
    final args = <Object>[];
    if (!reader.takeSymbol(')')) {
      do {
        args.add(_argument());
      } while (reader.takeSymbol(','));
      reader.expectSymbol(')');
    }
    final batch = args.isNotEmpty && args.every((arg) => arg is List);
    if (batch) {
      final count = (args.first as List).length;
      if (args.any((arg) => (arg as List).length != count) || count == 0) {
        throw const FormatException();
      }
      for (var i = 0; i < count; i++) {
        _one(out, name.text, [for (final arg in args) (arg as List)[i]]);
      }
    } else if (args.any((arg) => arg is List)) {
      throw const FormatException();
    } else {
      _one(out, name.text, args);
    }
  }

  Object _argument() {
    if (reader.takeSymbol('[')) {
      final items = <Object>[];
      do {
        items.add(_argument());
      } while (reader.takeSymbol(','));
      reader.expectSymbol(']');
      return items;
    }
    final token = reader.next();
    return switch (token.kind) {
      _Kind.string || _Kind.regex || _Kind.number || _Kind.json => token,
      _Kind.word when const {'true', 'false', 'null'}.contains(token.text) =>
        token,
      _ => throw const FormatException(),
    };
  }

  String _text(Object arg) {
    if (arg case _Token(kind: _Kind.string, :final text)) {
      return text;
    }
    throw const FormatException();
  }

  int _status(Object arg) {
    final status = arg is _Token && arg.kind == _Kind.number
        ? int.tryParse(arg.text)
        : null;
    if (status == null || status < 100 || status > 599) {
      throw const FormatException();
    }
    return status;
  }

  /// A string that may name the URL's captures, which only URL rewrites
  /// hand on, as `$n`.
  String _withCaptures(String text, {required bool allowed}) {
    final name = capture;
    if (name == null || !text.contains('\${$name.')) {
      return text;
    }
    if (!allowed) {
      throw const _Unsupported();
    }
    return text.replaceAllMapped(
      RegExp('\\\$\\{${RegExp.escape(name)}\\.(\\d+)\\}'),
      (match) => '\$${match[1]}',
    );
  }

  String get _phase => response ? 'http-response' : 'http-request';

  List<String> get _conditions => [
    if (head case final head?) ...['request-head', _field(head)],
    if (responseHead case final head?) ...['response-head', _field(head)],
  ];

  void _one(LoonRewrite out, String name, List<Object> args) {
    final pattern = _field(url);
    if (responseHead != null &&
        !name.startsWith('response.') &&
        name != 'script') {
      throw const _Unsupported();
    }
    switch ((name, args.length)) {
      case ('url.replace', 1):
        final target = _withCaptures(_text(args[0]), allowed: true);
        out.urlRewrite.add(
          head == null
              ? '$pattern ${_field(target)} header'
              : '$pattern ${_field(head!)} url-and-header header ${_field(target)}',
        );
      case ('redirect', 2):
        final status = _status(args[0]);
        if (status != 302 && status != 307) {
          throw const FormatException();
        }
        final target = _withCaptures(_text(args[1]), allowed: true);
        out.urlRewrite.add(
          head == null
              ? '$pattern ${_field(target)} $status'
              : '$pattern ${_field(head!)} url-and-header $status ${_field(target)}',
        );
      case (
        'reject' ||
            'reject_img' ||
            'reject_dict' ||
            'reject_array' ||
            'reject_video',
        1 || 2,
      ):
        _reject(out, name, args);
      case ('request.header.add' || 'response.header.add', 2):
        _header(out, name, 'header-add', [_text(args[0]), _text(args[1])]);
      case ('request.header.set' || 'response.header.set', 2):
        _header(out, name, 'header-del', [_text(args[0])]);
        _header(out, name, 'header-add', [_text(args[0]), _text(args[1])]);
      case ('request.header.del' || 'response.header.del', 1):
        _header(out, name, 'header-del', [_text(args[0])]);
      case ('request.header.replace' || 'response.header.replace', 3):
        _header(out, name, 'header-replace-regex', [
          _text(args[0]),
          _regex(args[1]),
          _text(args[2]),
        ]);
      case ('request.body.replace' || 'response.body.replace', 2):
        _phaseOf(name);
        out.bodyRewrite.add(
          [
            _phase,
            pattern,
            ..._conditions,
            _field(_regex(args[0])),
            _field(_withCaptures(_text(args[1]), allowed: false)),
          ].join(' '),
        );
      case ('request.json.add' || 'response.json.add', 2):
        _jq(out, name, _jsonEdit('add', _path(_text(args[0])), _json(args[1])));
      case ('request.json.replace' || 'response.json.replace', 2):
        _jq(
          out,
          name,
          _jsonEdit('replace', _path(_text(args[0])), _json(args[1])),
        );
      case ('request.json.delete' || 'response.json.delete', 1):
        _jq(out, name, _jsonEdit('del', _path(_text(args[0])), null));
      case ('request.json.jq' || 'response.json.jq', 1):
        _jq(out, name, _text(args[0]));
      case ('response.body.mock' || 'response.body.mock_file', >= 2 && <= 4):
        _phaseOf(name);
        if (responseHead != null) {
          throw const FormatException();
        }
        out.mapLocal.add(
          _local({
            ..._mockData(name, args, base64At: 3),
            if (args.length > 2) 'status-code': '${_status(args[2])}',
            ..._contentType(args),
          }),
        );
      case ('request.body.mock' || 'request.body.mock_file', 2 || 3):
        _phaseOf(name);
        out.requestBodyMock.add(
          _local({
            ..._mockData(name, args, base64At: 2),
            ..._contentType(args),
          }),
        );
      case ('script', 1 || 2):
        out.scripts.add((
          path: _text(args[0]),
          tag: '',
          fields: {
            'type': _phase,
            'pattern': url,
            'request-head': ?head,
            'response-head': ?responseHead,
            if (args.length == 2) 'argument': _argumentText(args[1]),
          },
        ));
      default:
        throw const _Unsupported();
    }
  }

  LoonLocal _local(Map<String, String> params) =>
      (pattern: url, head: head, params: params);

  Map<String, String> _mockData(
    String name,
    List<Object> args, {
    required int base64At,
  }) {
    final base64 = args.length > base64At && _bool(args[base64At]);
    return {
      'data-type': name.endsWith('_file')
          ? 'file'
          : base64
          ? 'base64'
          : 'text',
      'data': _text(args[1]),
    };
  }

  Map<String, String> _contentType(List<Object> args) => {
    if (loonContentTypes[_text(args[0]).toLowerCase()] case final type?)
      'header': 'Content-Type:$type',
  };

  String _argumentText(Object arg) => switch (arg) {
    _Token(kind: _Kind.string, :final text) => text,
    _Token(kind: _Kind.json) => throw const _Unsupported(),
    _ => throw const FormatException(),
  };

  void _reject(LoonRewrite out, String name, List<Object> args) {
    final status = _status(args[0]);
    final body = args.length == 2 ? _text(args[1]) : null;
    if (body != null && name != 'reject') {
      throw const FormatException();
    }
    final urlType = switch (name) {
      _ when status != 200 || body != null => null,
      'reject_img' => 'reject-img',
      'reject_dict' => 'reject-dict',
      'reject_array' => 'reject-array',
      _ => 'reject-200',
    };
    if (head != null && urlType != null) {
      out.urlRewrite.add(
        '${_field(url)} ${_field(head!)} url-and-header $urlType',
      );
      return;
    }
    out.mapLocal.add(
      _local(switch (name) {
        'reject_img' => {'data-type': 'tiny-gif', 'status-code': '$status'},
        'reject_dict' || 'reject_array' => {
          'data-type': 'text',
          'data': name == 'reject_dict' ? '{}' : '[]',
          'status-code': '$status',
          'header': 'Content-Type:application/json',
        },
        _ => {
          'data-type': 'text',
          'data': body ?? '',
          'status-code': '$status',
        },
      }),
    );
  }

  void _phaseOf(String name) {
    if (name.startsWith('response.') != response) {
      throw const FormatException();
    }
  }

  void _header(
    LoonRewrite out,
    String name,
    String action,
    List<String> values,
  ) {
    _phaseOf(name);
    out.headerRewrite.add(
      [
        _phase,
        _field(url),
        ..._conditions,
        action,
        for (final value in values)
          _field(_withCaptures(value, allowed: false)),
      ].join(' '),
    );
  }

  void _jq(LoonRewrite out, String name, String expression) {
    _phaseOf(name);
    out.bodyRewrite.add(
      ['$_phase-jq', _field(url), ..._conditions, expression].join(' '),
    );
  }

  String _regex(Object arg) {
    if (arg case _Token(kind: _Kind.regex, :final text, :final flags)) {
      return _scoped(text, flags);
    }
    throw const FormatException();
  }

  bool _bool(Object arg) => switch (arg) {
    _Token(kind: _Kind.word, text: 'true') => true,
    _Token(kind: _Kind.word, text: 'false') => false,
    _ => throw const FormatException(),
  };

  /// A Loon value as the JSON literal jq reads.
  String _json(Object arg) => switch (arg) {
    _Token(kind: _Kind.string, :final text) => jsonEncode(
      _withCaptures(text, allowed: false),
    ),
    _Token(kind: _Kind.number || _Kind.json || _Kind.word, :final text) => text,
    _ => throw const FormatException(),
  };

  void _with(LoonRewrite out) {
    if (!reader.takeWord('with') || out.scripts.isEmpty) {
      throw const FormatException();
    }
    final options = <String, String>{};
    do {
      final key = reader.next();
      reader.expectSymbol('=');
      final value = reader.next();
      if (key.kind != _Kind.word || value.kind == _Kind.symbol) {
        throw const FormatException();
      }
      options[key.text] = value.text;
    } while (reader.takeSymbol(','));
    if (!reader.done) {
      throw const FormatException();
    }
    final script = out.scripts.single;
    out.scripts
      ..clear()
      ..add((
        path: script.path,
        tag: options['tag'] ?? '',
        fields: {
          ...script.fields,
          'requires-body': ?options['requires_body'],
          'binary-body-mode': ?options['binary_body_mode'],
          'timeout': ?options['timeout'],
          'enable': ?options['enable'],
        },
      ));
  }
}

/// Stash's edits leave null and false be, but add writes over null; Loon's
/// paths to delete name the body as it came, as `data[0] data[1]` means.
String? jsonEditJq(String edit, List<String> args, {required bool stash}) {
  final delete = edit == 'del';
  if (args.isEmpty || (!delete && args.length.isOdd)) {
    return null;
  }
  try {
    if (delete && !stash) {
      return 'del(${args.map(_path).join(', ')})';
    }
    return [
      for (var i = 0; i < args.length; i += delete ? 1 : 2)
        _jsonEdit(
          edit,
          _path(args[i]),
          delete ? null : _literal(args[i + 1]),
          stash: stash,
        ),
    ].join(' | ');
  } on FormatException {
    return null;
  }
}

String _jsonEdit(
  String edit,
  String path,
  String? value, {
  bool stash = false,
}) {
  const present = '. != null and . != false';
  return switch ((edit, stash)) {
    ('add', false) => '$path = $value',
    ('add', true) => 'if $path == null then $path = $value else . end',
    ('replace', false) => 'if $path != null then $path = $value else . end',
    ('replace', true) => 'if ($path | $present) then $path = $value else . end',
    ('del', false) => 'del($path)',
    ('del', true) => 'if ($path | $present) then del($path) else . end',
    _ => throw const FormatException(),
  };
}

/// Loon writes a space in a quoted value as `\x20`, which JSON lacks.
String _literal(String text) {
  try {
    return jsonEncode(jsonDecode(text));
  } on FormatException {
    final quoted =
        text.length > 1 &&
        (text[0] == '"' || text[0] == "'") &&
        text.endsWith(text[0]);
    if (!quoted) {
      return jsonEncode(text);
    }
    return jsonEncode(
      text
          .substring(1, text.length - 1)
          .replaceAllMapped(
            RegExp(r'\\x([0-9A-Fa-f]{2})'),
            (match) => String.fromCharCode(int.parse(match[1]!, radix: 16)),
          )
          .replaceAll('\\${text[0]}', text[0]),
    );
  }
}

List<String>? jsonEditArgs(String text) {
  final args = <String>[];
  final current = StringBuffer();
  var depth = 0;
  var quoted = false;
  for (var i = 0; i < text.length; i++) {
    final c = text[i];
    if (quoted) {
      current.write(c);
      if (c == r'\' && i + 1 < text.length) {
        current.write(text[++i]);
      } else if (c == '"') {
        quoted = false;
      }
      continue;
    }
    if ((c == ' ' || c == '\t') && depth == 0) {
      if (current.isNotEmpty) {
        args.add(current.toString());
        current.clear();
      }
      continue;
    }
    current.write(c);
    switch (c) {
      case '"':
        quoted = true;
      case '{' || '[':
        depth++;
      case '}' || ']':
        depth--;
    }
  }
  if (quoted || depth != 0) {
    return null;
  }
  if (current.isNotEmpty) {
    args.add(current.toString());
  }
  return args;
}

/// A Loon JSON path, dotted with `[n]` for array items, as jq's.
String _path(String path) {
  final buffer = StringBuffer();
  for (final segment in path.split('.')) {
    final match = RegExp(r'^([^\[\]]*)((?:\[\d+\])*)$').firstMatch(segment);
    if (match == null) {
      throw const FormatException();
    }
    final key = match.group(1)!;
    if (key.isNotEmpty) {
      buffer.write(
        RegExp(r'^[A-Za-z_]\w*$').hasMatch(key)
            ? '.$key'
            : '.${jsonEncode(key)}',
      );
    }
    buffer.write(match.group(2));
  }
  final text = buffer.toString();
  return text.isEmpty ? '.' : (text.startsWith('.') ? text : '.$text');
}

String _field(String text) {
  if (text.isNotEmpty && !RegExp(r'[\s"]').hasMatch(text)) {
    return text;
  }
  return '"${text.replaceAll('"', r'\"')}"';
}
