/// Block-style YAML in which every string value is double-quoted, apart from
/// multi-line text, and a key stays plain only when neither a YAML 1.1 nor a
/// YAML 1.2 reader can resolve it to anything but that string.
String writeYaml(Object? value) {
  final writer = _YamlWriter();
  writer.document(value);
  return writer.toString();
}

final _unsafePlainKey = RegExp(
  r'''^[\s\-?:,\[\]{}#&*!|>'"%@`]|[\t\n]|\s$|: |\s#|:$''',
);

final _nonStringPlainKey = RegExp(
  r'^(?:~|null|Null|NULL|y|Y|yes|Yes|YES|n|N|no|No|NO|true|True|TRUE'
  r'|false|False|FALSE|on|On|ON|off|Off|OFF|=)$'
  r'|^[-+]?\.?[0-9]|^[-+]?\.(?:inf|Inf|INF)$|^\.(?:nan|NaN|NAN)$',
);

bool _needsEscape(int rune) =>
    (rune < 0x20 && rune != 0x09 && rune != 0x0A) ||
    (rune >= 0x7F && rune <= 0x9F) ||
    rune == 0x2028 ||
    rune == 0x2029 ||
    (rune >= 0xD800 && rune <= 0xDFFF) ||
    rune == 0xFEFF ||
    rune == 0xFFFE ||
    rune == 0xFFFF;

String _escape(int unit) => switch (unit) {
  0x00 => r'\0',
  0x07 => r'\a',
  0x08 => r'\b',
  0x09 => r'\t',
  0x0A => r'\n',
  0x0B => r'\v',
  0x0C => r'\f',
  0x0D => r'\r',
  0x1B => r'\e',
  0x85 => r'\N',
  0x2028 => r'\L',
  0x2029 => r'\P',
  _ when unit <= 0xFF => '\\x${unit.toRadixString(16).padLeft(2, '0')}',
  _ => '\\u${unit.toRadixString(16).padLeft(4, '0')}',
};

String _plain(Object? value) => switch (value) {
  double() when value.isNaN => '.nan',
  double() when value.isInfinite => value.isNegative ? '-.inf' : '.inf',
  _ => '$value',
};

Object? _encodable(Object? value) => switch (value) {
  null || bool() || num() || String() || Map() || List() => value,
  Iterable() => value.toList(),
  _ => _encodable((value as dynamic).toJson()),
};

final class _YamlWriter {
  final StringBuffer _out = StringBuffer();
  final List<String> _indents = [''];
  final Map<String, bool> _plainKeys = {};

  @override
  String toString() => _out.toString();

  void document(Object? value) {
    switch (_encodable(value)) {
      case final Map map when map.isNotEmpty:
        _entries(map, 0, continuesLine: false);
      case final List list when list.isNotEmpty:
        _items(list, 0, continuesLine: false);
      case final node:
        _scalar(node, 2);
    }
  }

  String _indent(int width) {
    while (_indents.length <= width) {
      _indents.add(' ' * _indents.length);
    }
    return _indents[width];
  }

  void _entries(Map map, int indent, {required bool continuesLine}) {
    var inline = continuesLine;
    for (final MapEntry(:key, :value) in map.entries) {
      if (!inline) {
        _out.write(_indent(indent));
      }
      inline = false;
      _key(key);
      _out.write(':');
      switch (_encodable(value)) {
        case final Map map when map.isNotEmpty:
          _out.write('\n');
          _entries(map, indent + 2, continuesLine: false);
        case final List list when list.isNotEmpty:
          _out.write('\n');
          _items(list, indent + 2, continuesLine: false);
        case final node:
          _out.write(' ');
          _scalar(node, indent + 2);
      }
    }
  }

  void _items(List list, int indent, {required bool continuesLine}) {
    var inline = continuesLine;
    for (final item in list) {
      if (!inline) {
        _out.write(_indent(indent));
      }
      inline = false;
      _out.write('- ');
      switch (_encodable(item)) {
        case final Map map when map.isNotEmpty:
          _entries(map, indent + 2, continuesLine: true);
        case final List list when list.isNotEmpty:
          _items(list, indent + 2, continuesLine: true);
        case final node:
          _scalar(node, indent + 2);
      }
    }
  }

  void _key(Object? key) {
    switch (key) {
      case final String text when _isPlainKey(text):
        _out.write(text);
      case final String text:
        _quoted(text);
      case null || bool() || num():
        _out.write(_plain(key));
      default:
        _quoted(key.toString());
    }
  }

  bool _isPlainKey(String key) => _plainKeys.putIfAbsent(
    key,
    () =>
        key.isNotEmpty &&
        !_unsafePlainKey.hasMatch(key) &&
        !_nonStringPlainKey.hasMatch(key) &&
        !key.runes.any(_needsEscape),
  );

  void _scalar(Object? value, int contentIndent) {
    switch (value) {
      case final String text when _fitsLiteral(text):
        _literal(text, contentIndent);
      case final String text:
        _quoted(text);
      case Map():
        _out.write('{}');
      case List():
        _out.write('[]');
      default:
        _out.write(_plain(value));
    }
    _out.write('\n');
  }

  /// A block scalar takes its indentation from its first line and its chomping
  /// keeps at most one final line break.
  bool _fitsLiteral(String text) {
    final firstBreak = text.indexOf('\n');
    if (firstBreak <= 0 || text.endsWith('\n\n')) {
      return false;
    }
    final first = text.codeUnitAt(0);
    return first != 0x20 && first != 0x09 && !text.runes.any(_needsEscape);
  }

  void _literal(String text, int indent) {
    final keepsBreak = text.endsWith('\n');
    _out.write(keepsBreak ? '|' : '|-');
    final body = keepsBreak ? text.substring(0, text.length - 1) : text;
    final prefix = _indent(indent);
    for (final line in body.split('\n')) {
      _out.write('\n');
      if (line.isNotEmpty) {
        _out
          ..write(prefix)
          ..write(line);
      }
    }
  }

  void _quoted(String text) {
    _out.write('"');
    var start = 0;
    for (var i = 0; i < text.length; i++) {
      final unit = text.codeUnitAt(i);
      final String replacement;
      if (unit >= 0xD800 && unit <= 0xDFFF) {
        if (unit <= 0xDBFF &&
            i + 1 < text.length &&
            (text.codeUnitAt(i + 1) & 0xFC00) == 0xDC00) {
          i++;
          continue;
        }
        replacement = '\ufffd';
      } else if (unit == 0x22) {
        replacement = r'\"';
      } else if (unit == 0x5C) {
        replacement = r'\\';
      } else if (unit == 0x09 || unit == 0x0A || _needsEscape(unit)) {
        replacement = _escape(unit);
      } else {
        continue;
      }
      _out
        ..write(text.substring(start, i))
        ..write(replacement);
      start = i + 1;
    }
    _out
      ..write(text.substring(start))
      ..write('"');
  }
}
