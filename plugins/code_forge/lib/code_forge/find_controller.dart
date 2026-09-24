import 'package:flutter/widgets.dart';

import 'controller.dart';
import 'styling.dart';
import 'text_offsets.dart';

/// Controller for managing text search functionality in [CodeForge].
///
/// This controller handles searching for text, navigating through matches,
/// and highlighting results in the editor.
class FindController extends ChangeNotifier {
  final CodeForgeController _codeController;

  List<TextRange> _matches = [];
  int _currentMatchIndex = -1;
  bool _isRegex = false;
  bool _caseSensitive = false;
  bool _matchWholeWord = false;
  String _lastQuery = '';
  bool _isActive = false;
  bool _isReplaceMode = false;

  String _lastText = '';
  VoidCallback? _controllerListener;

  final TextEditingController findInputController = TextEditingController();
  final TextEditingController replaceInputController = TextEditingController();
  final FocusNode findInputFocusNode = FocusNode();
  final FocusNode replaceInputFocusNode = FocusNode();

  /// Creates a [FindController] associated with the given [CodeForgeController].
  FindController(this._codeController) {
    _lastText = _codeController.text;
    _controllerListener = _onCodeControllerChanged;
    _codeController.addListener(_controllerListener!);
    findInputController.addListener(_onFindInputChanged);
  }

  void _onFindInputChanged() {
    find(findInputController.text);
  }

  @override
  void dispose() {
    if (_controllerListener != null) {
      _codeController.removeListener(_controllerListener!);
    }
    findInputController.removeListener(_onFindInputChanged);
    findInputController.dispose();
    replaceInputController.dispose();
    findInputFocusNode.dispose();
    replaceInputFocusNode.dispose();
    super.dispose();
  }

  void _onCodeControllerChanged() {
    if (!_isActive) return;
    final currentText = _codeController.text;
    if (currentText != _lastText) {
      _lastText = currentText;
      _reperformSearch();
    }
  }

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

    if (query.isEmpty) {
      _clearMatches();
      return;
    }

    final text = _codeController.text;
    try {
      final regExp = _buildRegExp(query);
      _matches = text.toScalarRanges(
        regExp
            .allMatches(text)
            .map((m) => TextRange(start: m.start, end: m.end)),
      );
    } catch (e) {
      _matches = [];
      _currentMatchIndex = -1;
      _updateHighlights();
      notifyListeners();
      return;
    }
    if (_matches.isEmpty) {
      _currentMatchIndex = -1;
      _updateHighlights();
      notifyListeners();
      return;
    }

    final cursor = _codeController.selection.start;
    int index = 0;
    bool found = false;

    for (int i = 0; i < _matches.length; i++) {
      if (_matches[i].start >= cursor) {
        index = i;
        found = true;
        break;
      }
    }

    _currentMatchIndex = found ? index : 0;

    _updateHighlights();

    if (scrollToMatch) {
      _scrollToCurrentMatch();
    }
    notifyListeners();
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
    if (_currentMatchIndex < 0 || _currentMatchIndex >= _matches.length) return;

    final match = _matches[_currentMatchIndex];
    _codeController.replaceRange(
      match.start,
      match.end,
      replaceInputController.text,
    );
  }

  /// Replaces all matches with the text in [replaceInputController].
  void replaceAll() {
    if (_matches.isEmpty) return;

    final text = _codeController.text;
    try {
      final regExp = _buildRegExp(_lastQuery);
      final newText = text.replaceAll(regExp, replaceInputController.text);

      _codeController.replaceRange(0, _codeController.length, newText);
    } catch (e) {
      debugPrint('FindController: Replace All failed. Error: $e');
    }
  }

  RegExp _buildRegExp(String query) {
    var pattern = _isRegex ? query : RegExp.escape(query);
    if (_matchWholeWord) pattern = '\\b$pattern\\b';
    return RegExp(pattern, caseSensitive: _caseSensitive, multiLine: true);
  }

  void _clearMatches() {
    _matches = [];
    _currentMatchIndex = -1;
    _codeController.searchHighlights = [];
    _codeController.searchHighlightsChanged = true;
    _codeController.notifyListeners();
    notifyListeners();
  }

  void _scrollToCurrentMatch() {
    if (_currentMatchIndex >= 0 && _currentMatchIndex < _matches.length) {
      final match = _matches[_currentMatchIndex];
      final matchLine = _codeController.getLineAtOffset(match.start);
      _codeController.setSelectionSilently(
        TextSelection.collapsed(offset: match.start),
      );

      try {
        _codeController.scrollToLine(matchLine);
      } on StateError {
        //
      }
    }
  }

  void _updateHighlights() {
    final highlights = <SearchHighlight>[];

    for (int i = 0; i < _matches.length; i++) {
      final match = _matches[i];
      final isCurrent = i == _currentMatchIndex;

      highlights.add(
        SearchHighlight(
          start: match.start,
          end: match.end,
          isCurrentMatch: isCurrent,
        ),
      );
    }

    _codeController.searchHighlights = highlights;
    _codeController.searchHighlightsChanged = true;
    _codeController.notifyListeners();
    notifyListeners();
  }
}
