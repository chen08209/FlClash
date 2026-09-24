import 'package:code_forge/code_forge.dart'
    show
        CodeForgeCompletion,
        CodeForgeCompletionRequest,
        CodeForgeSnippet,
        CodeForgeSuggestion;

import 'clash_schema.dart';
import 'completion_matcher.dart';

final _identifier = RegExp(r'^[A-Za-z_$][\w$]*$');
final _bracketKey = RegExp(r'''([\w$]+)\s*\[\s*['"]([\w-]*)$''');
final _stringValue = RegExp(
  r'''(?:([\w$]+)|'([\w-]+)'|"([\w-]+)")\s*(?::|[!=]==?)\s*['"]([\w.\-]*)$''',
);
final _member = RegExp(r'([\w$]+|[\])])\s*(\.\s*([\w$]*))$');
final _word = RegExp(r'[\w$]+$');
final _objectKeyStart = RegExp(r'(?:^|[{,])\s*([\w$]+)$');

const _keywords = [
  'const',
  'let',
  'return',
  'function',
  'if',
  'else',
  'for',
  'of',
  'in',
  'while',
  'break',
  'continue',
  'switch',
  'case',
  'default',
  'new',
  'typeof',
  'instanceof',
  'true',
  'false',
  'null',
  'undefined',
  'try',
  'catch',
  'finally',
  'throw',
  'delete',
  'async',
  'await',
];

const _globals = [
  'config',
  'console',
  'JSON',
  'Object',
  'Array',
  'RegExp',
  'Math',
  'String',
  'Number',
  'Boolean',
  'Date',
  'Set',
  'Map',
  'parseInt',
  'parseFloat',
  'encodeURIComponent',
  'decodeURIComponent',
];

const _globalMembers = {
  'console': ['log', 'info', 'warn', 'error'],
  'JSON': ['stringify', 'parse'],
  'Object': ['keys', 'values', 'entries', 'assign', 'fromEntries'],
  'Array': ['isArray', 'from', 'of'],
  'Math': ['max', 'min', 'floor', 'ceil', 'round', 'random', 'abs'],
  'Number': ['isInteger', 'isNaN', 'parseInt', 'parseFloat'],
  'String': ['fromCharCode'],
};

const _methods = {
  'Array': [
    'filter',
    'map',
    'forEach',
    'find',
    'findIndex',
    'some',
    'every',
    'includes',
    'indexOf',
    'push',
    'unshift',
    'splice',
    'slice',
    'concat',
    'join',
    'sort',
    'reverse',
    'reduce',
    'flatMap',
  ],
  'String': [
    'replace',
    'replaceAll',
    'startsWith',
    'endsWith',
    'includes',
    'split',
    'trim',
    'toLowerCase',
    'toUpperCase',
    'match',
    'test',
  ],
};

const _properties = ['length'];

class ScriptCompletionSource {
  late final _configKeys = clashConfigSchema.fields.keys.toList();
  late final _entryFields = {
    for (final schema in [
      clashConfigSchema.fields['proxies']!.entry!,
      clashConfigSchema.fields['proxy-groups']!.entry!,
      clashConfigSchema.fields['proxy-providers']!.entry!,
      clashConfigSchema.fields['rule-providers']!.entry!,
    ])
      ...schema.fieldsFor(null),
  };
  late final _valuesByKey = _collectValues();

  Map<String, Set<String>> _collectValues() {
    final values = <String, Set<String>>{};
    final visited = <YamlSchema>{};
    void visit(YamlSchema schema) {
      if (!visited.add(schema)) {
        return;
      }
      for (final MapEntry(:key, :value) in schema.fieldsFor(null).entries) {
        if (value.values.isNotEmpty) {
          (values[key] ??= {}).addAll(value.values);
        }
        visit(value);
      }
      if (schema.entry case final entry?) {
        visit(entry);
      }
    }

    visit(clashConfigSchema);
    return values;
  }

  CodeForgeCompletion? call(CodeForgeCompletionRequest request) {
    final before = request.textBeforeCaret;
    if (_inComment(before)) {
      return null;
    }
    if (_bracketKey.firstMatch(before) case final match?) {
      final keys = match[1] == 'config' ? _configKeys : _entryFields.keys;
      return completeFrom(match[2]!, keys.map(_plain));
    }
    if (_stringValue.firstMatch(before) case final match?) {
      final key = match[1] ?? match[2] ?? match[3]!;
      final values = _valuesByKey[key];
      return values == null
          ? null
          : completeFrom(match[4]!, values.map(_plain));
    }
    if (_inString(before)) {
      return null;
    }
    if (_member.firstMatch(before) case final match?) {
      return _memberCompletion(match[1]!, match[2]!, match[3]!);
    }
    final typed = _word.stringMatch(before);
    if (typed == null || RegExp(r'^\d').hasMatch(typed)) {
      return null;
    }
    final keyStart = _objectKeyStart.firstMatch(before);
    if (keyStart != null &&
        _isObjectLiteral(request, before.length - typed.length)) {
      return completeFrom(typed, [
        for (final MapEntry(:key, :value) in _entryFields.entries)
          CodeForgeSuggestion(
            label: key,
            detail: value.hint,
            snippet: CodeForgeSnippet(
              _identifier.hasMatch(key) ? '$key: ' : "'$key': ",
            ),
          ),
      ]);
    }
    return completeFrom(typed, [
      ..._keywords.map(_plain),
      ..._globals.map(_plain),
      ...request.documentWords.map(_plain),
    ]);
  }

  CodeForgeCompletion? _memberCompletion(
    String target,
    String access,
    String typed,
  ) {
    if (typed.isEmpty) {
      return null;
    }
    if (target == 'config') {
      final completion = completeFrom(typed, [
        for (final key in _configKeys)
          CodeForgeSuggestion(
            label: key,
            snippet: CodeForgeSnippet(
              _identifier.hasMatch(key) ? '.$key' : "['$key']",
            ),
          ),
      ]);
      return completion == null
          ? null
          : CodeForgeCompletion(
              prefix: access,
              suggestions: completion.suggestions,
            );
    }
    final globalMembers = _globalMembers[target];
    if (globalMembers != null) {
      return completeFrom(typed, globalMembers.map(_method(target)));
    }
    return completeFrom(typed, [
      for (final MapEntry(key: owner, value: names) in _methods.entries)
        ...names.map(_method(owner)),
      ..._properties.map(_plain),
      for (final key in _entryFields.keys)
        if (_identifier.hasMatch(key)) _plain(key),
    ]);
  }

  bool _isObjectLiteral(CodeForgeCompletionRequest request, int column) {
    final lines = request.lines;
    var depth = 0;
    final firstLine = (request.line - 200).clamp(0, request.line);
    for (var line = request.line; line >= firstLine; line--) {
      final text = line == request.line
          ? request.lineText.substring(0, column)
          : lines[line];
      for (var i = text.length - 1; i >= 0; i--) {
        final char = text[i];
        if (char == '}') {
          depth++;
        } else if (char == '{') {
          if (depth > 0) {
            depth--;
            continue;
          }
          return _opensObject(lines, line, text.substring(0, i));
        }
      }
    }
    return false;
  }

  bool _opensObject(List<String> lines, int line, String before) {
    var text = before.trimRight();
    for (var index = line - 1; text.isEmpty && index >= 0; index--) {
      text = lines[index].trimRight();
    }
    if (text.isEmpty) {
      return false;
    }
    if (text.endsWith(')') || text.endsWith('=>')) {
      return false;
    }
    return !RegExp(r'\b(else|try|finally|do)$').hasMatch(text);
  }
}

bool _inComment(String before) {
  final index = before.indexOf('//');
  return index >= 0 && !_inString(before.substring(0, index));
}

bool _inString(String before) {
  String? quote;
  for (var i = 0; i < before.length; i++) {
    final char = before[i];
    if (quote != null) {
      if (char == r'\') {
        i++;
      } else if (char == quote) {
        quote = null;
      }
    } else if (char == "'" || char == '"' || char == '`') {
      quote = char;
    }
  }
  return quote != null;
}

CodeForgeSuggestion _plain(String label) => CodeForgeSuggestion(label: label);

CodeForgeSuggestion Function(String) _method(String owner) =>
    (name) => CodeForgeSuggestion(
      label: name,
      detail: owner,
      snippet: CodeForgeSnippet('$name(\$0)'),
    );
