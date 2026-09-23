enum InputIssueKind { keyTooLong, valueTooLong, missingValue }

class InputIssue {
  final int line;
  final String raw;
  final InputIssueKind kind;

  const InputIssue({required this.line, required this.raw, required this.kind});

  @override
  bool operator ==(Object other) =>
      other is InputIssue &&
      other.line == line &&
      other.raw == raw &&
      other.kind == kind;

  @override
  int get hashCode => Object.hash(line, raw, kind);

  @override
  String toString() => 'InputIssue(line: $line, raw: $raw, kind: $kind)';
}

class ParsedInput<T> {
  final List<T> entries;
  final int skippedExisting;
  final List<InputIssue> issues;

  const ParsedInput({
    required this.entries,
    required this.skippedExisting,
    required this.issues,
  });

  bool get isValid => issues.isEmpty;
}

final _lineSeparator = RegExp(r'\r?\n');
final _listSeparator = RegExp(r'[,，]');
final _whitespace = RegExp(r'\s');

/// Lines copied out of a YAML sequence keep their `- ` marker and quotes.
String _stripLineMarkup(String line) {
  var value = line.trim();
  if (value.startsWith('- ')) {
    value = value.substring(2).trim();
  }
  if (value.endsWith(',')) {
    value = value.substring(0, value.length - 1).trim();
  }
  return value;
}

String _unquote(String value) {
  if (value.length < 2) {
    return value;
  }
  final first = value[0];
  if ((first == '"' || first == "'") && value.endsWith(first)) {
    return value.substring(1, value.length - 1).trim();
  }
  return value;
}

ParsedInput<String> parseListInput(
  String text, {
  Set<String> existing = const {},
  int? maxLength,
}) {
  final entries = <String>[];
  final issues = <InputIssue>[];
  final seen = <String>{};
  var skippedExisting = 0;
  final lines = text.split(_lineSeparator);
  for (var index = 0; index < lines.length; index++) {
    final line = _stripLineMarkup(lines[index]);
    for (final raw in line.split(_listSeparator)) {
      final value = _unquote(raw.trim());
      if (value.isEmpty) {
        continue;
      }
      if (maxLength != null && value.length > maxLength) {
        issues.add(
          InputIssue(
            line: index + 1,
            raw: value,
            kind: InputIssueKind.valueTooLong,
          ),
        );
        continue;
      }
      if (!seen.add(value)) {
        continue;
      }
      if (existing.contains(value)) {
        skippedExisting++;
        continue;
      }
      entries.add(value);
    }
  }
  return ParsedInput(
    entries: entries,
    skippedExisting: skippedExisting,
    issues: issues,
  );
}

/// Keys never carry whitespace and values may carry `:` (`geosite:cn`,
/// `tls://1.1.1.1:853`, IPv6), so the first run of whitespace splits a line
/// and a bare `:` never does. A key may end in `:` or `=` and a value may
/// start with `=` so YAML and `key=value` lines parse without cleanup.
MapEntry<String, String>? _splitMapLine(String line) {
  final whitespaceIndex = line.indexOf(_whitespace);
  String key;
  String value;
  if (whitespaceIndex == -1) {
    final equalsIndex = line.indexOf('=');
    if (equalsIndex == -1) {
      return null;
    }
    key = line.substring(0, equalsIndex);
    value = line.substring(equalsIndex + 1);
  } else {
    key = line.substring(0, whitespaceIndex);
    value = line.substring(whitespaceIndex).trim();
    if (value.startsWith('=')) {
      value = value.substring(1).trim();
    } else if (value.startsWith(':') && value.length > 1 && value[1] == ' ') {
      value = value.substring(1).trim();
    }
  }
  if (key.endsWith(':') || key.endsWith('=')) {
    key = key.substring(0, key.length - 1);
  }
  key = _unquote(key.trim());
  value = _unquote(value);
  if (key.isEmpty || value.isEmpty) {
    return null;
  }
  return MapEntry(key, value);
}

ParsedInput<MapEntry<String, String>> parseMapInput(
  String text, {
  Set<String> existingKeys = const {},
  int? keyMaxLength,
  int? valueMaxLength,
}) {
  final entries = <MapEntry<String, String>>[];
  final issues = <InputIssue>[];
  final seen = <String>{};
  var skippedExisting = 0;
  final lines = text.split(_lineSeparator);
  for (var index = 0; index < lines.length; index++) {
    final line = _stripLineMarkup(lines[index]);
    if (line.isEmpty) {
      continue;
    }
    final entry = _splitMapLine(line);
    if (entry == null) {
      issues.add(
        InputIssue(
          line: index + 1,
          raw: line,
          kind: InputIssueKind.missingValue,
        ),
      );
      continue;
    }
    if (keyMaxLength != null && entry.key.length > keyMaxLength) {
      issues.add(
        InputIssue(
          line: index + 1,
          raw: entry.key,
          kind: InputIssueKind.keyTooLong,
        ),
      );
      continue;
    }
    if (valueMaxLength != null && entry.value.length > valueMaxLength) {
      issues.add(
        InputIssue(
          line: index + 1,
          raw: entry.value,
          kind: InputIssueKind.valueTooLong,
        ),
      );
      continue;
    }
    if (!seen.add(entry.key)) {
      continue;
    }
    if (existingKeys.contains(entry.key)) {
      skippedExisting++;
      continue;
    }
    entries.add(entry);
  }
  return ParsedInput(
    entries: entries,
    skippedExisting: skippedExisting,
    issues: issues,
  );
}
