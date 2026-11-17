import 'dart:io';

/// The values Surge's requirement expressions read, as FlClash stands in for
/// them: only macOS names a system Surge runs on, and the core is taken as the
/// newest, since FlClash reads every feature a version check guards.
class MitmRequirementEnvironment {
  const MitmRequirementEnvironment({this.system = '', this.language = ''});

  factory MitmRequirementEnvironment.current() => MitmRequirementEnvironment(
    system: Platform.isMacOS ? 'macOS' : '',
    language: Platform.localeName.replaceAll('_', '-'),
  );

  /// Surge Mac 6.10.0, the newest version the manual's Core Version list
  /// names (`major * 1000000 + minor * 1000 + patch`).
  static const coreVersion = 6010000;

  final String system;
  final String language;

  Object? valueOf(String name) => switch (name) {
    'CORE_VERSION' => coreVersion,
    'SYSTEM' => system,
    'LANGUAGE' => language,
    'SYSTEM_VERSION' || 'DEVICE_MODEL' || 'DEVICE_NAME' => '',
    _ => null,
  };
}

/// Whether [expression] holds, or null when it cannot be read.
bool? evaluateMitmRequirement(
  String expression,
  MitmRequirementEnvironment environment,
) {
  final tokens = _lex(expression.trim());
  if (tokens == null || tokens.isEmpty) {
    return null;
  }
  final reader = _Reader(tokens, environment);
  try {
    final result = reader.or();
    return reader.done ? result : null;
  } on FormatException {
    return null;
  }
}

final _token = RegExp(
  r"\s*(\(|\)|&&|\|\||==|=>|>=|=<|<=|!=|<>|=|>|<|!|'[^']*'|"
  r'"[^"]*"|[A-Za-z_][A-Za-z0-9_]*|-?\d+(?:\.\d+)?)',
);

List<String>? _lex(String text) {
  final tokens = <String>[];
  var index = 0;
  while (index < text.length) {
    final match = _token.matchAsPrefix(text, index);
    if (match == null) {
      return text.substring(index).trim().isEmpty ? tokens : null;
    }
    tokens.add(match.group(1)!);
    index = match.end;
  }
  return tokens;
}

const _comparisons = {
  '=',
  '==',
  '>=',
  '=>',
  '<=',
  '=<',
  '>',
  '<',
  '!=',
  '<>',
  'BEGINSWITH',
  'CONTAINS',
  'ENDSWITH',
  'LIKE',
  'MATCHES',
};

class _Reader {
  _Reader(this.tokens, this.environment);

  final List<String> tokens;
  final MitmRequirementEnvironment environment;
  var _at = 0;

  bool get done => _at == tokens.length;

  String? get _peek => _at < tokens.length ? tokens[_at] : null;

  String _next() {
    if (done) {
      throw const FormatException();
    }
    return tokens[_at++];
  }

  bool _take(Set<String> words) {
    if (words.contains(_peek?.toUpperCase())) {
      _at++;
      return true;
    }
    return false;
  }

  bool or() {
    var value = and();
    while (_take(const {'||', 'OR'})) {
      value = and() || value;
    }
    return value;
  }

  bool and() {
    var value = not();
    while (_take(const {'&&', 'AND'})) {
      value = not() && value;
    }
    return value;
  }

  bool not() {
    if (_take(const {'!', 'NOT'})) {
      return !not();
    }
    if (_take(const {'('})) {
      final value = or();
      if (!_take(const {')'})) {
        throw const FormatException();
      }
      return value;
    }
    final left = _operand(_next());
    final operator = _next().toUpperCase();
    if (!_comparisons.contains(operator)) {
      throw const FormatException();
    }
    return _compare(left, operator, _operand(_next()));
  }

  Object _operand(String token) {
    if (token.length >= 2 &&
        (token.startsWith("'") || token.startsWith('"')) &&
        token.endsWith(token[0])) {
      return token.substring(1, token.length - 1);
    }
    if (num.tryParse(token) case final number?) {
      return number;
    }
    return environment.valueOf(token) ?? (throw const FormatException());
  }
}

bool _compare(Object left, String operator, Object right) {
  if (left is num && right is num) {
    return switch (operator) {
      '=' || '==' => left == right,
      '!=' || '<>' => left != right,
      '>=' || '=>' => left >= right,
      '<=' || '=<' => left <= right,
      '>' => left > right,
      '<' => left < right,
      _ => throw const FormatException(),
    };
  }
  final a = '$left';
  final b = '$right';
  return switch (operator) {
    '=' || '==' => a == b,
    '!=' || '<>' => a != b,
    '>=' || '=>' => a.compareTo(b) >= 0,
    '<=' || '=<' => a.compareTo(b) <= 0,
    '>' => a.compareTo(b) > 0,
    '<' => a.compareTo(b) < 0,
    'BEGINSWITH' => a.startsWith(b),
    'CONTAINS' => a.contains(b),
    'ENDSWITH' => a.endsWith(b),
    'LIKE' => RegExp(
      '^${RegExp.escape(b).replaceAll(r'\*', '.*').replaceAll(r'\?', '.')}\$',
      dotAll: true,
    ).hasMatch(a),
    _ => RegExp('^(?:$b)\$').hasMatch(a),
  };
}
