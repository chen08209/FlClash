part of '../controller.dart';

extension CodeForgeControllerCompletion on CodeForgeController {
  /// Inserts the suggestion at [index], or the highlighted one, in place of
  /// the word prefix before the caret and closes the popup.
  void acceptSuggestion([int? index]) {
    final suggestions = suggestionsNotifier.value;
    if (suggestions == null || suggestions.isEmpty) return;
    final selected = (index ?? selectedSuggestionNotifier.value ?? 0).clamp(
      0,
      suggestions.length - 1,
    );
    final suggestion = suggestions[selected];
    if (suggestion.snippet case final snippet?) {
      insertSnippet(snippet);
    } else {
      insertAtCurrentCursor(suggestion.label, replaceTypedChar: true);
    }
    suggestionsNotifier.value = null;
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

  List<CodeForgeSuggestion> _suggestionsFor(String prefix) {
    if (prefix.isEmpty) return const [];
    final lowerPrefix = prefix.toLowerCase();
    final words = [
      if (enableLocalSuggestions)
        for (final word in _wordCache)
          if (word != prefix && word.startsWith(prefix)) word,
    ]..sort((a, b) => _compareMatches(a, b, prefix));
    return [
      for (final snippet in snippets)
        if (snippet.prefix.toLowerCase().startsWith(lowerPrefix))
          CodeForgeSuggestion(
            label: snippet.prefix,
            detail: snippet.description,
            snippet: snippet,
          ),
      for (final word in words) CodeForgeSuggestion(label: word),
    ];
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
