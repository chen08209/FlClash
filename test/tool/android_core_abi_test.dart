import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Reads a Rust source down to the shape of its C ABI: comments go, names of
/// parameters go, and the given type aliases are spelled out.
class _RustSource {
  _RustSource(List<String> paths, {Map<String, String> aliases = const {}})
    : _text = paths
          .map((path) => File(path).readAsStringSync())
          .join('\n')
          .replaceAll(RegExp(r'//[^\n]*'), ''),
      _aliases = aliases;

  final String _text;
  final Map<String, String> _aliases;

  String alias(String name) {
    final match = RegExp('pub type $name\\s*=\\s*([^;]+);').firstMatch(_text);
    expect(match, isNotNull, reason: 'type $name');
    return _shape(match!.group(1)!);
  }

  Map<String, String> fields(String struct) {
    final start = _text.indexOf(RegExp('pub struct $struct\\s*\\{'));
    expect(start, isNot(-1), reason: 'struct $struct');
    final open = _text.indexOf('{', start);
    final body = _text.substring(open + 1, _closing(open, '{', '}'));
    return {
      for (final field in _split(body))
        if (RegExp(r'^pub (\w+)\s*:\s*(.+)$', dotAll: true).firstMatch(field)
            case final match?)
          match.group(1)!: _shape(match.group(2)!),
    };
  }

  String function(String name) {
    final start = _text.indexOf(RegExp('fn $name\\s*\\('));
    expect(start, isNot(-1), reason: 'fn $name');
    final open = _text.indexOf('(', start);
    final close = _closing(open, '(', ')');
    final rest = _text.substring(close + 1);
    final returns = RegExp(r'^\s*->\s*([^{;]+)').firstMatch(rest)?.group(1);
    final params = _split(_text.substring(open + 1, close)).map(_shape);
    return '(${params.join(', ')})${returns == null ? '' : ' -> ${_shape(returns)}'}';
  }

  int _closing(int open, String opening, String closing) {
    var depth = 0;
    for (var index = open; index < _text.length; index++) {
      if (_text[index] == opening) depth++;
      if (_text[index] == closing && --depth == 0) return index;
    }
    fail('unbalanced $opening at $open');
  }

  String _shape(String type) {
    var shaped = type
        .replaceAll(RegExp(r'(?<![:\w])[a-z_]\w*\s*:(?!:)'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAllMapped(RegExp(r'\s*([(),<>])\s*'), (match) => match[1]!)
        .replaceAll(',)', ')')
        .trim();
    for (final MapEntry(:key, :value) in _aliases.entries) {
      shaped = shaped.replaceAll(RegExp('\\b$key\\b'), value);
    }
    return shaped;
  }

  static List<String> _split(String list) {
    final parts = <String>[];
    var depth = 0;
    var start = 0;
    for (var index = 0; index < list.length; index++) {
      final char = list[index];
      if ('(<['.contains(char)) depth++;
      if (')>]'.contains(char) && list[index - 1] != '-') depth--;
      if (char == ',' && depth == 0) {
        parts.add(list.substring(start, index));
        start = index + 1;
      }
    }
    parts.add(list.substring(start));
    return [
      for (final part in parts)
        if (part.trim().isNotEmpty) part.trim(),
    ];
  }
}

void main() {
  const glue = 'android/core/jni/src/concord.rs';
  const host = 'concord/bins/android/src/abi.rs';
  const ffi = [
    'concord/crates/ffi/src/abi.rs',
    'concord/crates/ffi/src/callback.rs',
  ];

  late final concord = _RustSource([host, ...ffi]);
  late final callbacks = {
    'Deliver': concord.alias('Deliver'),
    'Release': concord.alias('Release'),
  };
  late final theirs = _RustSource(
    [host, ...ffi],
    aliases: {...callbacks, 'ConcordPlatformHost': 'PlatformHost'},
  );
  late final ours = _RustSource(
    [glue],
    aliases: {
      'Callback': callbacks['Release']!,
      'Deliver': callbacks['Deliver']!,
    },
  );

  test('the JNI glue sees the platform host as Concord defines it', () {
    expect(ours.fields('PlatformHost'), theirs.fields('ConcordPlatformHost'));
  });

  test(
    'the JNI glue declares each Concord export it links as Concord does',
    () {
      for (final name in const [
        'concord_start',
        'concord_set_platform_host',
        'concord_open_callback',
        'concord_send',
        'concord_close',
        'concord_adopt_fd',
      ]) {
        expect(ours.function(name), theirs.function(name), reason: name);
      }
    },
  );
}
