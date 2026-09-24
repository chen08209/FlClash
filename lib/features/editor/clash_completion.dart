import 'package:code_forge/code_forge.dart'
    show
        CodeForgeCompletion,
        CodeForgeCompletionRequest,
        CodeForgeSnippet,
        CodeForgeSuggestion;

import 'clash_schema.dart';
import 'completion_matcher.dart';
import 'yaml_lines.dart';

final _caretLinePattern = RegExp(r'^( *)(-(?: +|$))?(.*)$');
final _keyTypedPattern = RegExp(r'^[\w.-]*$');
final _valueTypedPattern = RegExp(
  r'''^('[^']*'|"[^"]*"|[^\s#'"{\[][^#]*?):\s+(.*)$''',
);
final _wordBeforeCaret = RegExp(r'[\w-]*$');

class ClashCompletionSource {
  final YamlSchema root;

  ClashCompletionSource(this.root);

  int _version = -1;
  YamlDocumentLines? _lines;
  int _namesVersion = -1;
  _DocumentNames? _names;

  YamlDocumentLines _linesOf(CodeForgeCompletionRequest request) {
    if (_version != request.version || _lines == null) {
      _version = request.version;
      _lines = YamlDocumentLines(request.lines);
    }
    return _lines!;
  }

  _DocumentNames _namesOf(CodeForgeCompletionRequest request) {
    final names = _names;
    if (names != null && _namesVersion != request.version) {
      final edit = request.linesEditedSince(_namesVersion);
      if (edit != null && names.follow(edit, request.lines)) {
        _namesVersion = request.version;
      }
    }
    if (_namesVersion != request.version || _names == null) {
      _namesVersion = request.version;
      _names = _DocumentNames(_linesOf(request).lines);
    }
    return _names!;
  }

  CodeForgeCompletion? call(CodeForgeCompletionRequest request) {
    final before = request.textBeforeCaret;
    if (before.contains(' #') || before.trimLeft().startsWith('#')) {
      return null;
    }
    final match = _caretLinePattern.firstMatch(before)!;
    final indent = match[1]!.length;
    final startsItem = match[2] != null;
    final typed = match[3]!;
    final column = indent + (match[2]?.length ?? 0);
    final lines = _linesOf(request);
    final scope = lines.mappingScope(
      request.line,
      column,
      startsItem: startsItem,
      itemIndent: indent,
    );
    final node = scope == null ? null : _resolve(scope.path);
    if (node == null) {
      return _words(request, before);
    }
    final rest = request.lineText.substring(request.column);
    if (node.kind == YamlKind.scalar) {
      return _scalarItem(request, node, typed);
    }
    if (node.kind != YamlKind.map) {
      return null;
    }
    final fields = node.fieldsFor(scope!.siblings['type']);
    final valueMatch = _valueTypedPattern.firstMatch(typed);
    if (valueMatch != null) {
      final key = unquoteYaml(valueMatch[1]!);
      final value = fields[key] ?? node.entry;
      if (value == null) {
        return _words(request, before);
      }
      return _value(request, value, valueMatch[2]!);
    }
    if (typed.isEmpty || !_keyTypedPattern.hasMatch(typed)) {
      return null;
    }
    if (fields.isEmpty) {
      return _words(request, before);
    }
    final extraIndent = startsItem ? ' ' * (column - indent) : '';
    return CodeForgeCompletion(
      prefix: typed,
      suggestions: rankSuggestions(typed, [
        for (final MapEntry(:key, :value) in fields.entries)
          if (!scope.siblings.containsKey(key))
            _keySuggestion(key, value, rest.trim().isEmpty, extraIndent),
      ]),
    );
  }

  YamlSchema? _resolve(List<YamlStep> path) {
    YamlSchema? node = root;
    for (final step in path) {
      node = switch ((node, step)) {
        (final YamlSchema map, YamlKeyStep(:final key))
            when map.kind == YamlKind.map =>
          map.fieldsFor(null)[key] ?? map.entry,
        (final YamlSchema list, YamlItemStep())
            when list.kind == YamlKind.list =>
          list.entry,
        _ => null,
      };
      if (node == null) {
        return null;
      }
    }
    return node;
  }

  CodeForgeSuggestion _keySuggestion(
    String key,
    YamlSchema value,
    bool atLineEnd,
    String extraIndent,
  ) {
    final body = switch (value.kind) {
      YamlKind.scalar => '$key: ',
      YamlKind.map => '$key:\n$extraIndent\t',
      YamlKind.list => '$key:\n$extraIndent\t- ',
    };
    return CodeForgeSuggestion(
      label: key,
      detail: value.hint,
      snippet: atLineEnd ? CodeForgeSnippet(_escapeSnippet(body)) : null,
    );
  }

  CodeForgeCompletion? _value(
    CodeForgeCompletionRequest request,
    YamlSchema schema,
    String typed,
  ) {
    var text = typed;
    if (text.startsWith('[')) {
      final entry = schema.entry;
      if (schema.kind != YamlKind.list || entry == null) {
        return null;
      }
      text = text.substring(text.lastIndexOf(RegExp(r'[\[,]')) + 1).trimLeft();
      return _scalar(request, entry, text);
    }
    if (schema.kind != YamlKind.scalar) {
      return null;
    }
    if (text.startsWith("'") || text.startsWith('"')) {
      text = text.substring(1);
    }
    return _scalar(request, schema, text);
  }

  CodeForgeCompletion? _scalarItem(
    CodeForgeCompletionRequest request,
    YamlSchema item,
    String typed,
  ) {
    return switch (item.scalar) {
      YamlScalar.rule => _rule(request, typed, withPolicy: true),
      YamlScalar.rulePayload => _rule(request, typed, withPolicy: false),
      _ => _scalar(request, item, typed),
    };
  }

  CodeForgeCompletion? _scalar(
    CodeForgeCompletionRequest request,
    YamlSchema schema,
    String typed,
  ) {
    if (typed.isEmpty) {
      return null;
    }
    final candidates = switch (schema.scalar) {
      YamlScalar.policy => _policies(request, includeCompatible: true),
      YamlScalar.proxyProvider => _plain(_namesOf(request).proxyProviders),
      YamlScalar.ruleProvider => _plain(_namesOf(request).ruleProviders),
      YamlScalar.subRule => _plain(_namesOf(request).subRules),
      _ => [
        ..._plain(schema.values),
        if (schema.values.isEmpty) ..._plain(request.documentWords),
      ],
    };
    return completeFrom(typed, candidates);
  }

  CodeForgeCompletion? _rule(
    CodeForgeCompletionRequest request,
    String typed, {
    required bool withPolicy,
  }) {
    final type = typed.split(',').first.trim().toUpperCase();
    final open = typed.indexOf('(');
    if (open >= 0) {
      final depth = '('.allMatches(typed).length - ')'.allMatches(typed).length;
      if (depth > 0) {
        final inner = typed.substring(typed.lastIndexOf('(') + 1);
        return _ruleParts(request, inner, withPolicy: false, nested: true);
      }
      final tail = typed.substring(typed.lastIndexOf(')') + 1);
      if (!withPolicy || !tail.startsWith(',') || tail.indexOf(',', 1) >= 0) {
        return null;
      }
      final text = tail.substring(1).trimLeft();
      return completeFrom(
        text,
        type == 'SUB-RULE'
            ? _plain(_namesOf(request).subRules)
            : _policies(request),
      );
    }
    return _ruleParts(request, typed, withPolicy: withPolicy);
  }

  CodeForgeCompletion? _ruleParts(
    CodeForgeCompletionRequest request,
    String typed, {
    required bool withPolicy,
    bool nested = false,
  }) {
    final parts = typed.split(',');
    final text = parts.last.trimLeft();
    final type = parts.first.trim().toUpperCase();
    switch (parts.length) {
      case 1:
        return completeFrom(text, [
          for (final MapEntry(key: type, value: example) in ruleTypes.entries)
            if (!nested || type != 'MATCH')
              if (withPolicy || !const {'MATCH', 'SUB-RULE'}.contains(type))
                CodeForgeSuggestion(
                  label: type,
                  detail: example,
                  snippet: CodeForgeSnippet(
                    const {'AND', 'OR', 'NOT'}.contains(type)
                        ? '$type,((\$0))'
                        : '$type,',
                  ),
                ),
        ]);
      case 2 when type == 'MATCH':
        return withPolicy ? completeFrom(text, _policies(request)) : null;
      case 2:
        return completeFrom(
          text,
          type == 'RULE-SET'
              ? _plain(_namesOf(request).ruleProviders)
              : _plain(rulePayloadValues[type] ?? const []),
        );
      case 3 when withPolicy && !nested:
        return completeFrom(text, _policies(request));
      case 3 || 4 when noResolveRuleTypes.contains(type):
        return completeFrom(text, _plain(ruleOptions));
    }
    return null;
  }

  CodeForgeCompletion? _words(
    CodeForgeCompletionRequest request,
    String before,
  ) {
    final typed = _wordBeforeCaret.stringMatch(before) ?? '';
    return completeFrom(typed, _plain(request.documentWords));
  }

  List<CodeForgeSuggestion> _policies(
    CodeForgeCompletionRequest request, {
    bool includeCompatible = false,
  }) {
    final names = _namesOf(request);
    return [
      for (final MapEntry(:key, :value) in names.groups.entries)
        CodeForgeSuggestion(label: key, detail: value),
      for (final MapEntry(:key, :value) in names.proxies.entries)
        CodeForgeSuggestion(label: key, detail: value),
      for (final policy in builtinPolicies) CodeForgeSuggestion(label: policy),
      if (includeCompatible) const CodeForgeSuggestion(label: 'COMPATIBLE'),
    ];
  }
}

Iterable<CodeForgeSuggestion> _plain(Iterable<String> labels) =>
    labels.map((label) => CodeForgeSuggestion(label: label));

String _escapeSnippet(String text) =>
    text.replaceAllMapped(RegExp(r'[$}\\]'), (match) => '\\${match[0]}');

/// The names rules and groups refer to, read from the document's own
/// top-level sections.
class _DocumentNames {
  static const _namingSections = {
    'proxies',
    'proxy-groups',
    'proxy-providers',
    'rule-providers',
    'sub-rules',
  };

  final groups = <String, String>{};
  final proxies = <String, String>{};
  final proxyProviders = <String>[];
  final ruleProviders = <String>[];
  final subRules = <String>[];

  final _sections = <({int line, bool names})>[];

  _DocumentNames(List<String> lines) {
    String? section;
    int? childIndent;
    _Item? item;
    void flush() {
      final name = item?.name;
      if (name != null && name.isNotEmpty) {
        final target = section == 'proxy-groups' ? groups : proxies;
        target.putIfAbsent(name, () => item!.type ?? '');
      }
      item = null;
    }

    for (var index = 0; index < lines.length; index++) {
      final text = lines[index];
      if (!_mayName(text, section, childIndent, item)) {
        continue;
      }
      final line = YamlLine.parse(text);
      if (line == null) {
        continue;
      }
      if (line.indent == 0 && !line.isItem) {
        flush();
        section = line.key;
        childIndent = null;
        _sections.add((line: index, names: _namingSections.contains(section)));
        continue;
      }
      switch (section) {
        case 'proxies' || 'proxy-groups':
          if (line.isItem && line.indent == (childIndent ??= line.indent)) {
            flush();
            item = _Item(line.contentColumn);
            if (line.content.startsWith('{')) {
              item!.readFlow(line.content);
              flush();
              continue;
            }
          }
          final current = item;
          if (current != null && line.contentColumn == current.column) {
            switch (line.key) {
              case 'name':
                current.name = line.value;
              case 'type':
                current.type = line.value;
            }
          }
        case 'proxy-providers' || 'rule-providers' || 'sub-rules':
          if (!line.isItem &&
              line.key != null &&
              line.indent == (childIndent ??= line.indent)) {
            final names = switch (section) {
              'proxy-providers' => proxyProviders,
              'rule-providers' => ruleProviders,
              _ => subRules,
            };
            names.add(line.key!);
          }
      }
    }
    flush();
  }

  /// Whether the names outlast [edit], which they do inside a section that
  /// names nothing; [lines] is the text after it.
  bool follow(
    ({int line, int removed, int inserted}) edit,
    List<String> lines,
  ) {
    if (edit.line + edit.inserted >= lines.length) {
      return false;
    }
    final replacedEnd = edit.line + edit.removed;
    var owner = -1;
    for (var index = 0; index < _sections.length; index++) {
      final start = _sections[index].line;
      if (start > replacedEnd) {
        break;
      }
      if (start >= edit.line) {
        return false;
      }
      owner = index;
    }
    if (owner >= 0 && _sections[owner].names) {
      return false;
    }
    for (var line = edit.line; line <= edit.line + edit.inserted; line++) {
      final text = lines[line];
      if (YamlLine.indentOf(text) == 0 &&
          !YamlLine.isItemAt(text, 0) &&
          YamlLine.parse(text) != null) {
        return false;
      }
    }
    final shift = edit.inserted - edit.removed;
    for (var index = owner + 1; index < _sections.length; index++) {
      final section = _sections[index];
      _sections[index] = (line: section.line + shift, names: section.names);
    }
    return true;
  }

  static bool _mayName(
    String text,
    String? section,
    int? childIndent,
    _Item? item,
  ) {
    final indent = YamlLine.indentOf(text);
    if (indent == text.length) {
      return false;
    }
    final isItem = YamlLine.isItemAt(text, indent);
    if (indent == 0 && !isItem) {
      return true;
    }
    switch (section) {
      case 'proxies' || 'proxy-groups':
        return isItem ||
            (item != null &&
                indent == item.column &&
                (text.startsWith('name', indent) ||
                    text.startsWith('type', indent) ||
                    text.startsWith('"', indent) ||
                    text.startsWith("'", indent)));
      case 'proxy-providers' || 'rule-providers' || 'sub-rules':
        return !isItem && (childIndent == null || indent == childIndent);
    }
    return false;
  }
}

class _Item {
  final int column;
  String? name;
  String? type;

  _Item(this.column);

  static final _flowField = RegExp(
    r'''(?:^|[{,])\s*(name|type)\s*:\s*('[^']*'|"[^"]*"|[^,}]*)''',
  );

  void readFlow(String content) {
    for (final match in _flowField.allMatches(content)) {
      final value = unquoteYaml(match[2]!);
      if (match[1] == 'name') {
        name = value;
      } else {
        type = value;
      }
    }
  }
}
