part of '../controller.dart';

/// [column] counts UTF-16 code units into [lineText].
class CodeForgeCompletionRequest {
  final List<String> lines;
  final int version;

  /// Counted as [CodeForgeController.lineEdit] counts; null once forgotten.
  final ({int line, int removed, int inserted})? Function(int since)
  linesEditedSince;

  final int line;
  final String lineText;
  final int column;
  final Set<String> documentWords;

  const CodeForgeCompletionRequest({
    required this.lines,
    required this.version,
    this.linesEditedSince = _unknownEdits,
    required this.line,
    required this.lineText,
    required this.column,
    this.documentWords = const {},
  });

  String get textBeforeCaret => lineText.substring(0, column);

  static ({int line, int removed, int inserted})? _unknownEdits(int since) =>
      null;
}

/// Accepting a suggestion replaces [prefix], the text before the caret.
class CodeForgeCompletion {
  final String prefix;
  final List<CodeForgeSuggestion> suggestions;

  const CodeForgeCompletion({required this.prefix, required this.suggestions});
}

/// One entry of the completion popup, as [CodeForge.suggestionPopupBuilder]
/// sees it.
class CodeForgeSuggestion {
  final String label;

  final String? detail;
  final CodeForgeSnippet? snippet;

  const CodeForgeSuggestion({required this.label, this.detail, this.snippet});
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
    commitComposition();
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
    final version = _currentVersion;
    return source(
      CodeForgeCompletionRequest(
        lines: _DocumentLines(this),
        version: version,
        linesEditedSince: (since) => _linesEditedBetween(since, version),
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
      s.isNotEmpty && isWordStartChar(s.codeUnitAt(0)) && !s.contains('\n');

  List<CodeForgeSuggestion> _wordSuggestionsFor(String prefix) {
    if (prefix.isEmpty || !enableLocalSuggestions) return const [];
    final words =
        [
          for (final word in _wordCache)
            if (word != prefix && word.startsWith(prefix)) word,
        ]..sort(
          (a, b) => a.length != b.length ? a.length - b.length : a.compareTo(b),
        );
    return [for (final word in words) CodeForgeSuggestion(label: word)];
  }

  Future<Set<String>> _extractWords() async {
    return (await wordsExtract(rope: _rope.core)).toSet();
  }
}

class _DocumentLines extends ListBase<String> {
  static const _blockSize = 256;

  final CodeForgeController _controller;
  final int _length;
  final Map<int, List<String>> _blocks = {};

  _DocumentLines(this._controller) : _length = _controller.lineCount;

  @override
  int get length => _length;

  @override
  set length(int value) => throw UnsupportedError('The lines are read-only');

  @override
  String operator [](int index) {
    RangeError.checkValidIndex(index, this);
    final block = index ~/ _blockSize;
    final start = block * _blockSize;
    final lines = _blocks[block] ??= _controller.getLinesRange(
      start,
      min(start + _blockSize, _length),
    );
    return lines[index - start];
  }

  @override
  void operator []=(int index, String value) =>
      throw UnsupportedError('The lines are read-only');
}
