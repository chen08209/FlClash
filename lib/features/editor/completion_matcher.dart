import 'package:code_forge/code_forge.dart'
    show CodeForgeCompletion, CodeForgeSuggestion;

const _maxSuggestions = 60;

/// A prefix beats a segment prefix, which beats the letters in order.
int? completionScore(String candidate, String typed) {
  if (typed.isEmpty) {
    return 0;
  }
  final lower = candidate.toLowerCase();
  final lowerTyped = typed.toLowerCase();
  if (lower.startsWith(lowerTyped)) {
    return 3000 - candidate.length + (candidate.startsWith(typed) ? 100 : 0);
  }
  for (var i = 1; i < candidate.length; i++) {
    if (_startsSegment(candidate, i) && lower.startsWith(lowerTyped, i)) {
      return 2000 - i - candidate.length;
    }
  }
  if (lower.isEmpty || lower[0] != lowerTyped[0]) {
    return null;
  }
  var matched = 1;
  for (var i = 1; i < lower.length && matched < lowerTyped.length; i++) {
    if (lower[i] == lowerTyped[matched]) {
      matched++;
    }
  }
  return matched == lowerTyped.length ? 1000 - candidate.length : null;
}

bool _startsSegment(String text, int index) {
  final previous = text[index - 1];
  if (previous == '-' || previous == '_' || previous == '.') {
    return true;
  }
  final current = text[index];
  return previous.toLowerCase() == previous &&
      previous.toUpperCase() != previous &&
      current.toUpperCase() == current &&
      current.toLowerCase() != current;
}

List<CodeForgeSuggestion> rankSuggestions(
  String typed,
  Iterable<CodeForgeSuggestion> candidates,
) {
  final seen = <String>{};
  final scored = <(int, int, CodeForgeSuggestion)>[];
  var index = 0;
  for (final candidate in candidates) {
    final label = candidate.label;
    if (!seen.add(label) || (label == typed && candidate.snippet == null)) {
      continue;
    }
    final score = completionScore(label, typed);
    if (score != null) {
      scored.add((score, index++, candidate));
    }
  }
  scored.sort((a, b) {
    final byScore = b.$1.compareTo(a.$1);
    return byScore != 0 ? byScore : a.$2.compareTo(b.$2);
  });
  return [
    for (final (_, _, suggestion) in scored.take(_maxSuggestions)) suggestion,
  ];
}

CodeForgeCompletion? completeFrom(
  String typed,
  Iterable<CodeForgeSuggestion> candidates,
) {
  if (typed.isEmpty) {
    return null;
  }
  return CodeForgeCompletion(
    prefix: typed,
    suggestions: rankSuggestions(typed, candidates),
  );
}
