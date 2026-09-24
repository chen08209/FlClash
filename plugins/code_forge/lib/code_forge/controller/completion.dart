part of '../controller.dart';

/// [column] counts UTF-16 code units into [lineText].
class CodeForgeCompletionRequest {
  final String text;
  final int version;
  final int line;
  final String lineText;
  final int column;
  final Set<String> documentWords;

  const CodeForgeCompletionRequest({
    required this.text,
    required this.version,
    required this.line,
    required this.lineText,
    required this.column,
    this.documentWords = const {},
  });

  String get textBeforeCaret => lineText.substring(0, column);
}

/// Accepting a suggestion replaces [prefix], the text before the caret.
class CodeForgeCompletion {
  final String prefix;
  final List<CodeForgeSuggestion> suggestions;

  const CodeForgeCompletion({required this.prefix, required this.suggestions});
}

typedef CodeForgeCompletionSource = CodeForgeCompletion? Function(
  CodeForgeCompletionRequest request,
);

extension CodeForgeControllerCompletion on CodeForgeController {
  /// Inserts the suggestion at [index], or the highlighted one, in place of
  /// the prefix it was matched against and closes the popup.
  void acceptSuggestion([int? index]) {
    final suggestions = suggestionsNotifier.value;
    if (suggestions == null || suggestions.isEmpty) return;
    final selected = (index ?? selectedSuggestionNotifier.value ?? 0).clamp(
      0,
      suggestions.length - 1,
    );
    final suggestion = suggestions[selected];
    final end = selection.extentOffset;
    final lineStart = getLineStartOffset(getLineAtOffset(end));
    final start = _completionStart.clamp(lineStart, end);
    if (suggestion.snippet case final snippet?) {
      insertSnippet(snippet, start: start);
    } else {
      replaceRange(start, end, suggestion.label);
      _isTyping = false;
    }
    suggestionsNotifier.value = null;
  }

  CodeForgeCompletion? _complete() {
    final current = selection;
    if (!current.isCollapsed) return null;
    final offset = current.extentOffset;
    final source = completionSource;
    if (source == null) {
      final prefix = getCurrentWordPrefixAt(offset);
      return CodeForgeCompletion(
        prefix: prefix,
        suggestions: _wordSuggestionsFor(prefix),
      );
    }
    final line = getLineAtOffset(offset);
    final lineText = getLineText(line);
    return source(
      CodeForgeCompletionRequest(
        text: text,
        version: _currentVersion,
        line: line,
        lineText: lineText,
        column: lineText.toUtf16Offset(offset - getLineStartOffset(line)),
        documentWords: enableLocalSuggestions ? _wordCache : const {},
      ),
    );
  }

  void _showCompletion(CodeForgeCompletion? completion) {
    if (completion == null || completion.suggestions.isEmpty) {
      suggestionsNotifier.value = null;
      return;
    }
    _completionStart = selection.extentOffset - completion.prefix.runes.length;
    suggestionsNotifier.value = completion.suggestions;
  }

  /// Moves the highlight [delta] entries, wrapping around the list.
  void moveSuggestionSelection(int delta) {
    final count = suggestionsNotifier.value?.length ?? 0;
    if (count == 0) return;
    final current = selectedSuggestionNotifier.value;
    selectedSuggestionNotifier.value = current == null
        ? (delta > 0 ? 0 : count - 1)
        : (current + delta) % count;
  }

  String getCurrentWordPrefixAt(int offset) {
    final safeOffset = offset.clamp(0, length);
    if (safeOffset == 0) return '';

    final lineIndex = getLineAtOffset(safeOffset);
    final lineStart = getLineStartOffset(lineIndex);
    final lineText = getLineText(lineIndex);

    final col = lineText.toUtf16Offset(safeOffset - lineStart);
    if (col <= 0) return '';

    int i = col - 1;
    while (i >= 0) {
      final code = lineText.codeUnitAt(i);
      if (!isWordChar(code)) break;
      i--;
    }

    final start = i + 1;
    if (start >= col) return '';
    final firstCode = lineText.codeUnitAt(start);
    if (!isWordStartChar(firstCode)) return '';
    return lineText.substring(start, col);
  }

  bool _startsWord(String s) =>
      s.isNotEmpty && isWordStartChar(s.codeUnitAt(0));

  List<CodeForgeSuggestion> _wordSuggestionsFor(String prefix) {
    if (prefix.isEmpty || !enableLocalSuggestions) return const [];
    final words = [
      for (final word in _wordCache)
        if (word != prefix && word.startsWith(prefix)) word,
    ]..sort((a, b) => _compareMatches(a, b, prefix));
    return [for (final word in words) CodeForgeSuggestion(label: word)];
  }

  int _compareMatches(String a, String b, String prefix) {
    final aScore = _scoreMatch(a, prefix);
    final bScore = _scoreMatch(b, prefix);

    if (aScore != bScore) {
      return bScore.compareTo(aScore);
    }

    return a.compareTo(b);
  }

  int _scoreMatch(String label, String prefix) {
    if (prefix.isEmpty) return 0;

    final lowerLabel = label.toLowerCase();
    final lowerPrefix = prefix.toLowerCase();

    if (!lowerLabel.contains(lowerPrefix)) return -1000000;

    int score = 0;

    if (label.startsWith(prefix)) {
      score += 100000;
    } else if (lowerLabel.startsWith(lowerPrefix)) {
      score += 50000;
    } else {
      score += 10000;
    }

    final matchIndex = lowerLabel.indexOf(lowerPrefix);
    score -= matchIndex * 100;

    if (matchIndex > 0) {
      final charBefore = label[matchIndex - 1];
      final matchChar = label[matchIndex];
      if (charBefore.toLowerCase() == charBefore &&
          matchChar.toUpperCase() == matchChar) {
        score += 5000;
      } else if (charBefore == '_' || charBefore == '-') {
        score += 5000;
      }
    }

    score -= label.length;

    return score;
  }

  Future<Set<String>> _extractWords() async {
    return (await wordsExtract(rope: _rope.core)).toSet();
  }
}
