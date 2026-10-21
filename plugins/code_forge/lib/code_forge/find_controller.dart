import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';

import 'controller.dart';
import 'rope.dart' show backgroundTextLength;
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

  /// Each match's start and end in turn, so a search finding hundreds of
  /// thousands allocates no object per match.
  Int32List _matches = Int32List(0);
  int _currentMatchIndex = -1;
  bool _isRegex = false;
  bool _caseSensitive = false;
  bool _matchWholeWord = false;
  String _lastQuery = '';
  bool _isActive = false;
  bool _isReplaceMode = false;

  TextRange? _edited;
  Timer? _researchTimer;

  int _searchGeneration = 0;
  ({bool scrollToMatch})? _backgroundSearch;
  bool _searching = false, _disposed = false;

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
    _disposed = true;
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
    final kept = Int32List(_matches.length);
    var length = 0;
    for (var i = 0; i < _matches.length; i += 2) {
      final start = _matches[i], end = _matches[i + 1];
      if (end <= offset) {
        kept[length++] = start;
        kept[length++] = end;
      } else if (start >= oldEnd) {
        kept[length++] = start + delta;
        kept[length++] = end + delta;
      }
    }
    _matches = Int32List.sublistView(kept, 0, length);
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
    final Int32List found;
    try {
      found = _search(
        controller.getLinesRange(firstLine, lastLine + 1).join('\n'),
      );
    } on FormatException {
      return true;
    }
    for (var i = 0; i < found.length; i++) {
      found[i] += start;
    }
    final from = _firstMatchFrom(start);
    var to = from;
    while (to < matchCount && _matches[to * 2] <= end) {
      to++;
    }
    final old = _matches, head = from * 2, tail = to * 2;
    _matches = Int32List(old.length - (tail - head) + found.length)
      ..setRange(0, head, old)
      ..setAll(head, found)
      ..setRange(
        head + found.length,
        old.length - tail + head + found.length,
        old,
        tail,
      );
    _selectMatchAtCaret();
    _updateHighlights();
    return firstLine == 0 && lastLine == controller.lineCount - 1;
  }

  int _firstMatchFrom(int offset) {
    var low = 0, high = matchCount;
    while (low < high) {
      final mid = (low + high) >> 1;
      if (_matches[mid * 2] < offset) {
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
    _currentMatchIndex = index < matchCount ? index : 0;
  }

  Int32List _search(String text) =>
      _matchesIn(text, _pattern(_lastQuery), _caseSensitive);

  /// The number of matches found for the current query.
  int get matchCount => _matches.length >> 1;

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
    _searchGeneration++;
    _backgroundSearch = null;

    if (query.isEmpty) {
      _clearMatches();
      return;
    }
    if (_codeController.length >= backgroundTextLength) {
      _clearMatches();
      _backgroundSearch = (scrollToMatch: scrollToMatch);
      if (!_searching) unawaited(_searchInBackground());
      return;
    }

    try {
      _matches = _search(_codeController.text);
    } on FormatException {
      _matches = Int32List(0);
    }
    _showMatches(scrollToMatch: scrollToMatch);
  }

  void _showMatches({required bool scrollToMatch}) {
    _selectMatchAtCaret();
    if (scrollToMatch) _scrollToCurrentMatch();
    _updateHighlights();
  }

  // Shows only the latest query's matches in the latest text, searching
  // again until neither has changed while it ran.
  Future<void> _searchInBackground() async {
    _searching = true;
    try {
      while (!_disposed) {
        final request = _backgroundSearch;
        if (request == null) return;
        final generation = _searchGeneration;
        final version = _codeController.contentVersion;
        final pattern = _pattern(_lastQuery), caseSensitive = _caseSensitive;
        final bytes = await _codeController.readBytes();
        final found = await _searchOffIsolate(bytes, pattern, caseSensitive);
        if (_disposed ||
            generation != _searchGeneration ||
            version != _codeController.contentVersion) {
          continue;
        }
        _backgroundSearch = null;
        _matches = found;
        _showMatches(scrollToMatch: request.scrollToMatch);
      }
    } finally {
      _searching = false;
    }
  }

  /// Moves to the next match.
  void next() {
    if (_matches.isEmpty) return;
    _currentMatchIndex = (_currentMatchIndex + 1) % matchCount;
    _scrollToCurrentMatch();
    _updateHighlights();
  }

  /// Moves to the previous match.
  void previous() {
    if (_matches.isEmpty) return;
    _currentMatchIndex = (_currentMatchIndex - 1 + matchCount) % matchCount;
    _scrollToCurrentMatch();
    _updateHighlights();
  }

  /// Replaces the currently selected match with the text in [replaceInputController].
  void replace() {
    _codeController.commitComposition();
    if (_currentMatchIndex < 0 || _currentMatchIndex >= matchCount) return;

    final start = _matches[_currentMatchIndex * 2];
    final end = _matches[_currentMatchIndex * 2 + 1];
    final replacement = CodeForgeController.normalizeLineBreaks(
      replaceInputController.text,
    );
    final isEmpty = start == end;
    if (isEmpty && replacement.isEmpty) return next();
    _emptyMatchReplacedAt = isEmpty ? start + replacement.runes.length : null;
    _codeController.replaceRange(start, end, replacement);
  }

  /// Replaces all matches with the text in [replaceInputController]. A long
  /// text is rewritten off the UI isolate, and left alone if it changes
  /// meanwhile.
  Future<void> replaceAll() async {
    _codeController.commitComposition();
    if (_matches.isEmpty) return;
    final pattern = _pattern(_lastQuery);
    final replacement = replaceInputController.text;
    if (_codeController.length < backgroundTextLength) {
      _codeController.replaceText(
        _codeController.text.replaceAll(
          _regExp(pattern, _caseSensitive),
          replacement,
        ),
      );
      _reperformSearch();
      return;
    }
    final version = _codeController.contentVersion;
    final bytes = await _codeController.readBytes();
    final replaced = await _replaceOffIsolate(
      bytes,
      pattern,
      _caseSensitive,
      replacement,
    );
    final document = await CodeForgeDocument.fromUtf8(replaced);
    if (!_disposed && version == _codeController.contentVersion) {
      _codeController.replaceDocument(document);
      _reperformSearch();
    }
    document.dispose();
  }

  String _pattern(String query) {
    final pattern = _isRegex ? query : RegExp.escape(query);
    return _matchWholeWord ? '\\b$pattern\\b' : pattern;
  }

  void _clearMatches() {
    _searchGeneration++;
    _backgroundSearch = null;
    _matches = Int32List(0);
    _currentMatchIndex = -1;
    _updateHighlights();
  }

  void _scrollToCurrentMatch() {
    if (_currentMatchIndex >= 0 && _currentMatchIndex < matchCount) {
      final start = _matches[_currentMatchIndex * 2];
      final matchLine = _codeController.getLineAtOffset(start);
      _codeController.selection = TextSelection.collapsed(offset: start);

      try {
        _codeController.scrollToLine(matchLine);
      } on StateError {
        //
      }
    }
  }

  void _updateHighlights() {
    _codeController.searchHighlights = _PackedHighlights(
      _matches,
      _currentMatchIndex,
    );
    notifyListeners();
  }
}

RegExp _regExp(String pattern, bool caseSensitive) =>
    RegExp(pattern, caseSensitive: caseSensitive, multiLine: true);

Int32List _matchesIn(String text, String pattern, bool caseSensitive) =>
    text.toScalarRanges(
      _regExp(
        pattern,
        caseSensitive,
      ).allMatches(text).map((m) => TextRange(start: m.start, end: m.end)),
    );

// Not async, so the closure sent to the isolate captures only the arguments.
Future<Int32List> _searchOffIsolate(
  Uint8List bytes,
  String pattern,
  bool caseSensitive,
) => Isolate.run(() {
  try {
    return _matchesIn(utf8.decode(bytes), pattern, caseSensitive);
  } on FormatException {
    return Int32List(0);
  }
});

Future<Uint8List> _replaceOffIsolate(
  Uint8List bytes,
  String pattern,
  bool caseSensitive,
  String replacement,
) => Isolate.run(
  () => utf8.encode(
    utf8.decode(bytes).replaceAll(_regExp(pattern, caseSensitive), replacement),
  ),
);

class _PackedHighlights extends ListBase<SearchHighlight> {
  _PackedHighlights(this._ranges, this._current);

  final Int32List _ranges;
  final int _current;

  @override
  int get length => _ranges.length >> 1;

  @override
  set length(int _) => throw UnsupportedError('read-only');

  @override
  SearchHighlight operator [](int index) => SearchHighlight(
    start: _ranges[index * 2],
    end: _ranges[index * 2 + 1],
    isCurrentMatch: index == _current,
  );

  @override
  void operator []=(int index, SearchHighlight value) =>
      throw UnsupportedError('read-only');
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
