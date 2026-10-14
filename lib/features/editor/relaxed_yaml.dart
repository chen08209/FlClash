import 'dart:math';

import 'package:collection/collection.dart';

import 'clash_schema.dart';

/// Runs [read] on [content] and, when that throws, once more on
/// [relaxYaml]'s rewrite of it; the error of the text as written stands when
/// the rewrite fails too.
T readRelaxed<T>(
  String content,
  EditorSchema schema,
  T Function(String content) read,
) {
  try {
    return read(content);
  } catch (_) {
    final relaxed = relaxYaml(content, schema);
    if (relaxed != null && relaxed != content) {
      try {
        return read(relaxed);
      } catch (_) {
        // The rewrite's own error would point at lines the user never wrote.
      }
    }
    rethrow;
  }
}

/// Nests each key [schema] knows under the map that holds it whatever its
/// indentation, drops a `dns:`-style header around the whole document, and
/// turns a list written on one line, comma separated, into block entries.
/// Null when [schema] is not a map.
String? relaxYaml(String content, EditorSchema schema) {
  final root = schema.root;
  if (root.kind != YamlKind.map) {
    return null;
  }
  return _Relaxer(root, schema.section).run(content);
}

final _namedKeyPattern = RegExp(r'^([A-Za-z][A-Za-z0-9-]*)\s*[:：](\s*)(.*)$');
final _freeKeyPattern = RegExp(
  r'''^('[^']*'|"[^"]*"|[^\s#'"{\[\-][^#]*?)\s*:(?:\s+(.*))?$''',
);
final _nodeStart = RegExp(r'^[\[{|>]');
final _plainUnsafeStart = RegExp(r'''^[-?:,\[\]{}#&*!|>%@`'"]''');
final _listSeparator = RegExp('[,，]');
const _opaque = YamlSchema.map({});

class _Frame {
  final YamlSchema schema;
  final int indent;
  final int ownerIndent;
  int? childIndent;

  _Frame(this.schema, this.indent, this.ownerIndent);

  bool get isDict => schema.entry != null;

  MapEntry<String, YamlSchema>? field(String name) {
    final lower = name.toLowerCase();
    return schema
        .fieldsFor(null)
        .entries
        .firstWhereOrNull((entry) => entry.key.toLowerCase() == lower);
  }
}

class _Block {
  final int indent;
  final bool isList;
  int? base;

  _Block(this.indent, {required this.isList});
}

class _Relaxer {
  final List<_Frame> _frames;
  final RegExp? _header;
  final _out = <String>[];
  _Block? _block;
  var _started = false;

  _Relaxer(YamlSchema root, String? section)
    : _frames = [_Frame(root, 0, -1)],
      _header = section == null
          ? null
          : RegExp(
              '^${RegExp.escape(section)}\\s*[:：]\\s*\$',
              caseSensitive: false,
            );

  String run(String content) {
    for (final raw in content.split('\n')) {
      final (indent, text) = _split(raw);
      if (text.isEmpty || text.startsWith('#')) {
        continue;
      }
      if (!_started && (_header?.hasMatch(text) ?? false)) {
        continue;
      }
      _line(indent, text);
    }
    return '${_out.join('\n')}\n';
  }

  static (int, String) _split(String raw) {
    var indent = 0;
    var index = 0;
    for (; index < raw.length; index++) {
      final width = switch (raw[index]) {
        ' ' || '\u00a0' => 1,
        '\t' || '\u3000' => 2,
        _ => 0,
      };
      if (width == 0) {
        break;
      }
      indent += width;
    }
    return (indent, raw.substring(index).trimRight());
  }

  void _line(int indent, String text) {
    if (!_started) {
      final item = _itemOf(text);
      if (item != null &&
          _keyLine(indent + text.length - item.length, item, knownOnly: true)) {
        return;
      }
    }
    if (!_keyLine(indent, text)) {
      _valueLine(indent, text);
    }
  }

  /// A key the schema does not know still nests by its indentation.
  bool _keyLine(int indent, String text, {bool knownOnly = false}) {
    final named = _namedKeyPattern.firstMatch(text);
    if (named != null) {
      final rest = named[3]!;
      final spaced = named[2]!.isNotEmpty || rest.isEmpty;
      final known = [
        for (final (index, frame) in _frames.indexed)
          if (frame.field(named[1]!) != null) index,
      ];
      if (known.isNotEmpty && (spaced || !rest.contains(':'))) {
        final frame = _enter(_pick(known, indent), indent);
        final field = frame.field(named[1]!)!;
        _emitKey(frame, field.key, field.value, rest, indent);
        return true;
      }
    }
    final free = knownOnly ? null : _freeKeyPattern.firstMatch(text);
    if (free == null) {
      return false;
    }
    final all = List.generate(_frames.length, (index) => index);
    final frame = _enter(_pick(all, indent), indent);
    final schema = frame.schema.entry ?? _opaque;
    _emitKey(frame, free[1]!, schema, free[2] ?? '', indent);
    return true;
  }

  /// The innermost of [candidates] whose keys sit at [indent], then the
  /// innermost [indent] could still be inside.
  int _pick(List<int> candidates, int indent) {
    bool within(int index) {
      final frame = _frames[index];
      final childIndent = frame.childIndent;
      return childIndent == null
          ? indent > frame.ownerIndent
          : childIndent <= indent;
    }

    return candidates.lastWhereOrNull(
          (index) => _frames[index].childIndent == indent,
        ) ??
        candidates.lastWhereOrNull(within) ??
        candidates.first;
  }

  _Frame _enter(int index, int indent) {
    _frames.removeRange(index + 1, _frames.length);
    _started = true;
    return _frames[index]..childIndent ??= indent;
  }

  void _emitKey(
    _Frame frame,
    String key,
    YamlSchema schema,
    String value,
    int indent,
  ) {
    final pad = ' ' * frame.indent;
    final inline = _stripComment(value);
    final isList = _isScalarList(schema);
    if (inline.isNotEmpty && (!isList || _nodeStart.hasMatch(inline))) {
      _block = _Block(frame.indent + 2, isList: false);
      _out.add('$pad$key: $value');
      return;
    }
    _block = _Block(frame.indent + 2, isList: isList);
    _out.add('$pad$key:');
    if (inline.isNotEmpty) {
      _entries(inline);
    } else if (schema.kind == YamlKind.map) {
      _frames.add(_Frame(schema, frame.indent + 2, indent));
    }
  }

  void _valueLine(int indent, String text) {
    final block = _block;
    if (block == null) {
      _out.add('${' ' * indent}$text');
      return;
    }
    if (block.isList) {
      final item = _itemOf(text, loose: true);
      if (item != null) {
        final entry = _stripComment(item);
        final pad = ' ' * block.indent;
        _out.add(entry.isEmpty ? '$pad-' : '$pad- ${_scalar(entry)}');
        return;
      }
      if (!_nodeStart.hasMatch(text)) {
        _entries(_stripComment(text));
        return;
      }
    }
    final base = block.base ??= indent;
    _out.add('${' ' * (block.indent + max(0, indent - base))}$text');
  }

  void _entries(String text) {
    final pad = ' ' * _block!.indent;
    for (final part in text.split(_listSeparator)) {
      final entry = part.trim();
      if (entry.isNotEmpty) {
        _out.add('$pad- ${_scalar(entry)}');
      }
    }
  }

  static bool _isScalarList(YamlSchema schema) =>
      schema.kind == YamlKind.list && schema.entry!.kind == YamlKind.scalar;

  /// [loose] also takes `-entry`, which YAML reads as a plain scalar.
  static String? _itemOf(String text, {bool loose = false}) {
    if (!text.startsWith('-')) {
      return null;
    }
    final rest = text.substring(1);
    if (rest.isEmpty || rest.trimLeft() != rest) {
      return rest.trimLeft();
    }
    return loose && !rest.startsWith('-') ? rest : null;
  }

  static bool _isQuote(String text) =>
      text.startsWith("'") || text.startsWith('"');

  static String _stripComment(String text) {
    final from = _isQuote(text) ? max(text.indexOf(text[0], 1), 0) : 0;
    final index = text.startsWith('#') ? 0 : text.indexOf(' #', from);
    return index < 0 ? text : text.substring(0, index).trimRight();
  }

  static String _scalar(String text) {
    if (text.length > 1 && _isQuote(text) && text.endsWith(text[0])) {
      return text;
    }
    final plain =
        !_plainUnsafeStart.hasMatch(text) &&
        !text.contains(': ') &&
        !text.contains(' #') &&
        !text.endsWith(':');
    return plain ? text : "'${text.replaceAll("'", "''")}'";
  }
}
