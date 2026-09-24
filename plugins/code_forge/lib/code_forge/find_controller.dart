import 'dart:async';
import 'dart:math';

import 'package:flutter/widgets.dart';

import 'controller.dart';
import 'text_offsets.dart';

/// Controller for managing text search functionality in [CodeForge].
///
/// This controller handles searching for text, navigating through matches,
/// and highlighting results in the editor.
class FindController extends ChangeNotifier {
  // A regex can match across the lines an edit touched, so once typing
  // pauses it searches the whole text again.
  static const _regexResearchDelay = Duration(milliseconds: 300);
  static const _maxResearchedLines = 2000;

  final CodeForgeController _codeController;

  List<TextRange> _matches = [];
  int _currentMatchIndex = -1;
  bool _isRegex = false;
  bool _caseSensitive = false;
  bool _matchWholeWord = false;
  String _lastQuery = '';
  bool _isActive = false;
  bool _isReplaceMode = false;

  TextRange? _edited;
  Timer? _researchTimer;

  // An empty match, as `$` finds, is found at the caret again once replaced.
  int? _emptyMatchReplacedAt;

  final TextEditingController findInputController = TextEditingController();
  final TextEditingController replaceInputController = TextEditingController();
  final FocusNode findInputFocusNode = FocusNode();
  final FocusNode replaceInputFocusNode = FocusNode();

  /// Creates a [FindController] associated with the given [CodeForgeController].
  FindController(this._codeController) {
    _codeController
      ..addEditListener(_onEdit)
      ..addListener(_onCodeControllerChanged);
    findInputController.addListener(_onFindInputChanged);
  }

  void _onFindInputChanged() {
    _emptyMatchReplacedAt = null;
    find(findInputController.text);
  }

  @override
  void dispose() {
    _researchTimer?.cancel();
    _codeController
      ..removeEditListener(_onEdit)
      ..removeListener(_onCodeControllerChanged);
    findInputController.removeListener(_onFindInputChanged);
    findInputController.dispose();
    replaceInputController.dispose();
    findInputFocusNode.dispose();
    replaceInputFocusNode.dispose();
    super.dispose();
  }

  bool get _tracksEdits => _isActive && _lastQuery.isNotEmpty;

  // The touched lines are searched once the controller notifies, so a burst
  // of edits costs one search.
  void _onEdit(int offset, int removed, int inserted) {
    if (!_tracksEdits) return;
    final delta = inserted - removed;
    final oldEnd = offset + removed;
    _matches = [
      for (final match in _matches)
        if (match.end <= offset)
          match
        else if (match.start >= oldEnd)
          TextRange(start: match.start + delta, end: match.end + delta),
    ];
    int moved(int position) => position <= offset
        ? position
        : position >= oldEnd
        ? position + delta
        : offset + inserted;
    final edited = _edited;
    _edited = TextRange(
      start: edited == null ? offset : min(moved(edited.start), offset),
      end: edited == null
          ? offset + inserted
          : max(moved(edited.end), offset + inserted),
    );
  }

  void _onCodeControllerChanged() {
    final edited = _edited;
    if (edited == null) return;
    _edited = null;
    if (!_tracksEdits) return;
    if (!_searchLines(edited) && _isRegex) {
      _researchTimer?.cancel();
      _researchTimer = Timer(_regexResearchDelay, () {
        if (_tracksEdits) _reperformSearch();
      });
    }
  }

  /// Whether the search covered the whole text.
  bool _searchLines(TextRange edited) {
    final controller = _codeController;
    final firstLine = controller.getLineAtOffset(edited.start);
    final lastLine = controller.getLineAtOffset(edited.end);
    if (lastLine - firstLine > _maxResearchedLines) {
      _reperformSearch();
      return true;
    }
    final start = controller.getLineStartOffset(firstLine);
    final end = lastLine + 1 < controller.lineCount
        ? controller.getLineStartOffset(lastLine + 1) - 1
        : controller.length;
    final List<TextRange> ranges;
    try {
      ranges = _search(
        controller.getLinesRange(firstLine, lastLine + 1).join('\n'),
      );
    } on FormatException {
      return true;
    }
    final found = [
      for (final range in ranges)
        TextRange(start: start + range.start, end: start + range.end),
    ];
    final from = _firstMatchFrom(start);
    var to = from;
    while (to < _matches.length && _matches[to].start <= end) {
      to++;
    }
    _matches = [..._matches.take(from), ...found, ..._matches.skip(to)];
    _selectMatchAtCaret();
    _updateHighlights();
    return firstLine == 0 && lastLine == controller.lineCount - 1;
  }

  int _firstMatchFrom(int offset) {
    var low = 0, high = _matches.length;
    while (low < high) {
      final mid = (low + high) >> 1;
      if (_matches[mid].start < offset) {
        low = mid + 1;
      } else {
        high = mid;
      }
    }
    return low;
  }

  void _selectMatchAtCaret() {
    if (_matches.isEmpty) {
      _currentMatchIndex = -1;
      return;
    }
    final caret = _codeController.selection.start;
    final index = _firstMatchFrom(
      caret == _emptyMatchReplacedAt ? caret + 1 : caret,
    );
    _currentMatchIndex = index < _matches.length ? index : 0;
  }

  List<TextRange> _search(String text) => text.toScalarRanges(
    _buildRegExp(_lastQuery)
        .allMatches(text)
        .map((m) => TextRange(start: m.start, end: m.end)),
  );

  /// The number of matches found for the current query.
  int get matchCount => _matches.length;

  /// The current match index (0-based) or -1 if no match is selected.
  int get currentMatchIndex => _currentMatchIndex;

  /// The case sensitivity of the search.
  bool get caseSensitive => _caseSensitive;

  /// Whether the search uses regular expressions.
  bool get isRegex => _isRegex;

  /// Whether the search matches whole words only.
  bool get matchWholeWord => _matchWholeWord;

  /// Whether the finder is currently active/visible.
  bool get isActive => _isActive;

  /// Whether the replace mode is active.
  bool get isReplaceMode => _isReplaceMode;

  /// Sets the case sensitivity of the search.
  set caseSensitive(bool value) {
    if (_caseSensitive == value) return;
    _caseSensitive = value;
    _reperformSearch();
    notifyListeners();
  }

  /// Sets whether the search uses regular expressions.
  set isRegex(bool value) {
    if (_isRegex == value) return;
    _isRegex = value;
    _reperformSearch();
    notifyListeners();
  }

  /// Sets whether the search matches whole words only.
  set matchWholeWord(bool value) {
    if (_matchWholeWord == value) return;
    _matchWholeWord = value;
    _reperformSearch();
    notifyListeners();
  }

  /// Sets whether the finder is currently active/visible.
  set isActive(bool value) {
    if (_isActive == value) return;
    _isActive = value;
    if (_isActive) {
      Future.microtask(() => findInputFocusNode.requestFocus());
      if (_lastQuery.isNotEmpty) {
        _reperformSearch();
      }
    } else {
      _clearMatches();
    }
    notifyListeners();
  }

  /// Sets whether the replace mode is active.
  set isReplaceMode(bool value) {
    if (_isReplaceMode == value) return;
    _isReplaceMode = value;
    notifyListeners();
  }

  /// Opens the panel, or focuses its field again when it is already open.
  void show({bool replace = false}) {
    if (_isActive) findInputFocusNode.requestFocus();
    isActive = true;
    isReplaceMode = replace;
  }

  void hide() {
    isReplaceMode = false;
    isActive = false;
  }

  void toggleReplaceMode() {
    isReplaceMode = !isReplaceMode;
  }

  void toggleCaseSensitive() {
    caseSensitive = !caseSensitive;
  }

  void toggleRegex() {
    isRegex = !isRegex;
  }

  void _reperformSearch() {
    if (_lastQuery.isNotEmpty) {
      find(_lastQuery, scrollToMatch: false);
    }
  }

  /// Performs a text search.
  ///
  /// [query] is the text to search for.
  /// [scrollToMatch] determines if the editor should scroll to the selected match.
  void find(String query, {bool scrollToMatch = true}) {
    _lastQuery = query;
    _researchTimer?.cancel();
    _edited = null;

    if (query.isEmpty) {
      _clearMatches();
      return;
    }

    try {
      _matches = _search(_codeController.text);
    } on FormatException {
      _matches = [];
    }
    _selectMatchAtCaret();
    if (scrollToMatch) _scrollToCurrentMatch();
    _updateHighlights();
  }

  /// Moves to the next match.
  void next() {
    if (_matches.isEmpty) return;
    _currentMatchIndex = (_currentMatchIndex + 1) % _matches.length;
    _scrollToCurrentMatch();
    _updateHighlights();
  }

  /// Moves to the previous match.
  void previous() {
    if (_matches.isEmpty) return;
    _currentMatchIndex =
        (_currentMatchIndex - 1 + _matches.length) % _matches.length;
    _scrollToCurrentMatch();
    _updateHighlights();
  }

  /// Replaces the currently selected match with the text in [replaceInputController].
  void replace() {
    _codeController.commitComposition();
    if (_currentMatchIndex < 0 || _currentMatchIndex >= _matches.length) return;

    final match = _matches[_currentMatchIndex];
    final replacement = CodeForgeController.normalizeLineBreaks(
      replaceInputController.text,
    );
    final isEmpty = match.start == match.end;
    if (isEmpty && replacement.isEmpty) return next();
    _emptyMatchReplacedAt = isEmpty
        ? match.start + replacement.runes.length
        : null;
    _codeController.replaceRange(match.start, match.end, replacement);
  }

  /// Replaces all matches with the text in [replaceInputController].
  void replaceAll() {
    _codeController.commitComposition();
    if (_matches.isEmpty) return;
    _codeController.replaceText(
      _codeController.text.replaceAll(
        _buildRegExp(_lastQuery),
        replaceInputController.text,
      ),
    );
    _reperformSearch();
  }

  RegExp _buildRegExp(String query) {
    var pattern = _isRegex ? query : RegExp.escape(query);
    if (_matchWholeWord) pattern = '\\b$pattern\\b';
    return RegExp(pattern, caseSensitive: _caseSensitive, multiLine: true);
  }

  void _clearMatches() {
    _matches = [];
    _currentMatchIndex = -1;
    _updateHighlights();
  }

  void _scrollToCurrentMatch() {
    if (_currentMatchIndex >= 0 && _currentMatchIndex < _matches.length) {
      final match = _matches[_currentMatchIndex];
      final matchLine = _codeController.getLineAtOffset(match.start);
      _codeController.selection = TextSelection.collapsed(offset: match.start);

      try {
        _codeController.scrollToLine(matchLine);
      } on StateError {
        //
      }
    }
  }

  void _updateHighlights() {
    _codeController.searchHighlights = [
      for (final (index, match) in _matches.indexed)
        SearchHighlight(
          start: match.start,
          end: match.end,
          isCurrentMatch: index == _currentMatchIndex,
        ),
    ];
    notifyListeners();
  }
}

class SearchHighlight {
  final int start;
  final int end;
  final bool isCurrentMatch;

  const SearchHighlight({
    required this.start,
    required this.end,
    this.isCurrentMatch = false,
  });
}
