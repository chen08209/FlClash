final _linePattern = RegExp(r'^( *)(-(?: +|$))?(.*)$');
final _keyPattern = RegExp(
  r'''^('[^']*'|"[^"]*"|[^\s#'"{\[\-][^#]*?|-[^\s#][^#]*?):(?:\s+(.*))?$''',
);

class YamlLine {
  final int indent;
  final bool isItem;
  final int contentColumn;
  final String content;
  final String? key;
  final String? value;

  const YamlLine._({
    required this.indent,
    required this.isItem,
    required this.contentColumn,
    required this.content,
    this.key,
    this.value,
  });

  static int indentOf(String text) {
    var indent = 0;
    while (indent < text.length && text.codeUnitAt(indent) == 0x20) {
      indent++;
    }
    return indent;
  }

  static bool isItemAt(String text, int indent) =>
      indent < text.length &&
      text.codeUnitAt(indent) == 0x2D &&
      (indent + 1 == text.length || text.codeUnitAt(indent + 1) == 0x20);

  static YamlLine? parse(String text) {
    final match = _linePattern.firstMatch(text)!;
    final content = match[3]!;
    final dash = match[2];
    if (dash == null && (content.isEmpty || content.startsWith('#'))) {
      return null;
    }
    final indent = match[1]!.length;
    final keyMatch = _keyPattern.firstMatch(content);
    return YamlLine._(
      indent: indent,
      isItem: dash != null,
      contentColumn: indent + (dash?.length ?? 0),
      content: content,
      key: keyMatch == null ? null : unquoteYaml(keyMatch[1]!),
      value: keyMatch == null ? null : unquoteYaml(keyMatch[2] ?? ''),
    );
  }
}

String unquoteYaml(String text) {
  var value = text.trim();
  final comment = value.startsWith('#') ? 0 : value.indexOf(' #');
  if (comment >= 0) {
    value = value.substring(0, comment).trimRight();
  }
  if (value.length >= 2 &&
      (value.startsWith("'") && value.endsWith("'") ||
          value.startsWith('"') && value.endsWith('"'))) {
    return value.substring(1, value.length - 1);
  }
  return value;
}

sealed class YamlStep {
  const YamlStep();
}

class YamlKeyStep extends YamlStep {
  final String key;

  const YamlKeyStep(this.key);
}

class YamlItemStep extends YamlStep {
  const YamlItemStep();
}

/// The keys a block mapping already has on lines other than the caret's.
class YamlMappingScope {
  final List<YamlStep> path;
  final Map<String, String> siblings;

  const YamlMappingScope(this.path, this.siblings);
}

class YamlDocumentLines {
  final List<String> lines;

  YamlDocumentLines(this.lines);

  YamlLine? _lineWithin(int index, int maxIndent) {
    final text = lines[index];
    return YamlLine.indentOf(text) > maxIndent ? null : YamlLine.parse(text);
  }

  /// Null when an ancestor is not a bare key the scope could hang from.
  YamlMappingScope? mappingScope(
    int line,
    int column, {
    bool startsItem = false,
    int itemIndent = 0,
  }) {
    final path = <YamlStep>[];
    final siblings = <String, String>{};
    _collectFollowingSiblings(line, column, siblings);
    var index = line - 1;
    var collecting = true;
    if (startsItem) {
      path.add(const YamlItemStep());
      collecting = false;
      final owner = _listOwner(index, itemIndent, path);
      if (owner == null) {
        return null;
      }
      (index, column) = owner;
    }
    // Above a top-level key only siblings remain, read only while collecting.
    while (index >= 0 && (column > 0 || collecting)) {
      final current = _lineWithin(index, column);
      index--;
      if (current == null || current.contentColumn > column) {
        continue;
      }
      if (current.contentColumn == column) {
        if (collecting && current.key != null) {
          siblings.putIfAbsent(current.key!, () => current.value ?? '');
        }
        if (!current.isItem) {
          continue;
        }
        path.add(const YamlItemStep());
        collecting = false;
        final owner = _listOwner(index, current.indent, path);
        if (owner == null) {
          return null;
        }
        (index, column) = owner;
        continue;
      }
      final key = current.key;
      if (key == null || (current.value?.isNotEmpty ?? false)) {
        return null;
      }
      path.add(YamlKeyStep(key));
      collecting = false;
      if (current.isItem) {
        path.add(const YamlItemStep());
        final owner = _listOwner(index, current.indent, path);
        if (owner == null) {
          return null;
        }
        (index, column) = owner;
      } else {
        column = current.indent;
      }
    }
    return YamlMappingScope(path.reversed.toList(), siblings);
  }

  (int, int)? _listOwner(int from, int dashColumn, List<YamlStep> path) {
    var index = from;
    while (index >= 0) {
      final text = lines[index];
      index--;
      final indent = YamlLine.indentOf(text);
      if (indent > dashColumn ||
          (indent == dashColumn && YamlLine.isItemAt(text, indent))) {
        continue;
      }
      final current = YamlLine.parse(text);
      if (current == null) {
        continue;
      }
      final key = current.key;
      if (key == null || (current.value?.isNotEmpty ?? false)) {
        return null;
      }
      path.add(YamlKeyStep(key));
      if (current.isItem) {
        path.add(const YamlItemStep());
        return _listOwner(index, current.indent, path);
      }
      return (index, current.indent);
    }
    return (-1, 0);
  }

  void _collectFollowingSiblings(
    int line,
    int column,
    Map<String, String> siblings,
  ) {
    for (var index = line + 1; index < lines.length; index++) {
      final current = _lineWithin(index, column);
      if (current == null || current.contentColumn > column) {
        continue;
      }
      if (current.contentColumn < column || current.isItem) {
        return;
      }
      if (current.key case final key?) {
        siblings.putIfAbsent(key, () => current.value ?? '');
      }
    }
  }
}
