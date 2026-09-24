import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rust_api/editor.dart';

import '../code_forge.dart';
import 'rope.dart';
import 'text_offsets.dart';
import 'word_chars.dart';

part 'controller/navigation.dart';
part 'controller/editing.dart';
part 'controller/ime.dart';
part 'controller/edit_pipeline.dart';
part 'controller/folding.dart';
part 'controller/completion.dart';
part 'controller/snippet.dart';

/// Controller for the [CodeForge] code editor widget.
///
/// This controller manages the text content, selection state, and various
/// editing operations for the code editor. It implements [DeltaTextInputClient]
/// to handle text input from the platform.
///
/// The controller uses a rope data structure internally for efficient text
/// manipulation, especially for large documents.
///
/// Example:
/// ```dart
/// final controller = CodeForgeController();
/// controller.text = 'void main() {\n  print("Hello");\n}';
///
/// // Access selection
/// print(controller.selection);
///
/// // Get specific line
/// print(controller.getLineText(0)); // 'void main() {'
/// ```
class CodeForgeController implements DeltaTextInputClient {
  static const _flushDelay = Duration(milliseconds: 100);
  static const _imeProjectionLineRadius = 2, _imeProjectionMaxChars = 4096;
  final _isMobile = Platform.isAndroid || Platform.isIOS;
  final List<VoidCallback> _listeners = [];
  void Function(int lineNumber)? _toggleFoldCallback;
  void Function(int line)? _scrollToLineCallback;
  Timer? _flushTimer, _debounceTimer;
  String? _cachedText, _bufferLineText;
  String _imeProjectionText = '';
  TextSelection? _lastSentSelection;
  TextSelection _imeProjectionSelection = const TextSelection.collapsed(
    offset: 0,
  );
  bool _suppressImeSync = false;
  CompoundOperationHandle? _imeCompositionUndoGroup;
  ImeComposition? _imeComposition;
  String _imeMirrorText = '';
  TextSelection _imeMirrorSelection = const TextSelection.collapsed(offset: 0);
  TextRange _imeMirrorComposing = TextRange.empty;
  String _imeWindowCommitted = '';
  int _imeWindowStart = 0;
  bool imeCompositionChanged = false;
  TextSelection? _pendingSelectionReplacement;
  String? _copiedLine;
  int _imeMirrorDeleteStart = -1;
  int _imeMirrorDeleteLen = 0;
  String _imeMirrorDeletedText = '';
  String _rawTypedComposingText = '';
  String _lastComposingText = '';
  bool _bufferDirty = false, bufferNeedsRepaint = false, selectionOnly = false;
  bool _imeProjectionDirty = true, _imeSelectionNeedsResync = false;
  bool _isTyping = false, _isDisposed = false;
  int _imeProjectionStartOffset = 0;
  int _cachedTextVersion = -1, _currentVersion = 0;
  int _bufferLineRopeStart = 0, _bufferLineOriginalLength = 0;
  int? dirtyLine, _bufferLineIndex;
  List<TextRange>? _snippetStops;
  int _snippetStopIndex = 0;
  UndoRedoController? _undoController;
  Set<String> _wordCache = {};
  int _wordCacheVersion = -1;

  CodeForgeController() {
    suggestionsNotifier.addListener(() {
      selectedSuggestionNotifier.value =
          suggestionsNotifier.value == null || _isMobile ? null : 0;
    });
    _listeners.add(() async {
      if (!enableLocalSuggestions && snippets.isEmpty) return;
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 200), () async {
        if (enableLocalSuggestions && _wordCacheVersion != _currentVersion) {
          _wordCacheVersion = _currentVersion;
          _wordCache = await _extractWords();
        }
        if (_isDisposed) return;
        final prefix = _isTyping
            ? getCurrentWordPrefixAt(selection.extentOffset)
            : '';
        final suggestions = _suggestionsFor(prefix);
        suggestionsNotifier.value = suggestions.isEmpty ? null : suggestions;
      });
    });
  }

  /// The completion popup's entries, or null while it is closed.
  final ValueNotifier<List<CodeForgeSuggestion>?> suggestionsNotifier =
      ValueNotifier(null);

  /// The entry of [suggestionsNotifier] Enter accepts. Starts at the first
  /// entry on desktop; on mobile nothing is highlighted until the arrow keys
  /// move it, so the soft keyboard's Enter still inserts a newline.
  final ValueNotifier<int?> selectedSuggestionNotifier = ValueNotifier(null);

  /// Whether the suggestions/completions are enabled or not.
  bool enableLocalSuggestions = false;

  /// Offered in the completion popup ahead of document words.
  List<CodeForgeSnippet> snippets = const [];

  /// The [FocusNode] instance, used to control editor focus
  FocusNode? focusNode;

  List<CodeForgeSuggestion>? get suggestions => suggestionsNotifier.value;

  Rope _rope = Rope('');
  Rope get rope => _rope;
  TextSelection _selectionCache = const TextSelection.collapsed(offset: 0);

  TextSelection get _selection {
    if (isBufferActive) {
      return _selectionCache;
    }
    final currentSelection = _rope.selection;
    if (_selectionCache != currentSelection) {
      _selectionCache = currentSelection;
    }
    return _selectionCache;
  }

  set _selection(TextSelection value) {
    _selectionCache = value;
    if (isBufferActive) {
      return;
    }
    _rope.setSelection(value);
  }

  /// The text input connection to the platform.
  TextInputConnection? connection;

  /// Set by the view layer. Invoked when the editor needs the platform input
  /// connection hard-reset (close + re-attach) -- e.g. to make the IME drop an
  /// in-progress composition and close its candidate window after the caret is
  /// moved by a click during composition.
  VoidCallback? requestImeReset;

  /// The range of text that has been modified and needs reprocessing.
  TextRange? dirtyRegion;

  bool documentReplaced = false;

  /// The fold ranges the renderer has found, keyed by start line. The
  /// renderer publishes them when a fold is toggled, so this is empty until
  /// then.
  ///
  /// Use the setter to update this map — it rebuilds internal sorted caches
  /// used for O(log n) fold-region lookups.
  Map<int, FoldRange?> get foldings => _foldings;

  Map<int, FoldRange?> _foldings = {};
  List<int> _foldedStartsSorted = [];
  List<int> _foldedEndsSorted = [];

  /// Set fold ranges in the editor
  set foldings(Map<int, FoldRange?> value) {
    _foldings = value;
    _rebuildFoldSortedCache();
  }

  /// List of search highlights to display in the editor.
  ///
  /// Add [SearchHighlight] objects to this list to highlight
  /// search results or other text ranges.
  List<SearchHighlight> searchHighlights = [];

  /// Whether the search highlights have changed and need repaint.
  bool searchHighlightsChanged = false;

  /// Whether the editor is in read-only mode.
  ///
  /// When true, the user cannot modify the text content.
  bool readOnly = false;

  /// Use space instead of the `\t` character for tab key press.
  bool useSpaceAsTab = false;

  /// Custom tabSize for the editor.
  int tabSize = 1;

  /// The tabspace inserted on tab key press.
  String get tabSpace {
    if (useSpaceAsTab) {
      return ' ' * tabSize;
    }
    return '\t' * tabSize;
  }

  /// The lines the pending edits replaced: from [line] on, [removed] line
  /// breaks gave way to [inserted]. Edits made before the renderer consumes
  /// this are merged into one covering range.
  ({int line, int removed, int inserted})? lineEdit;

  /// Sets the undo controller for this editor.
  ///
  /// The undo controller manages the undo/redo history for text operations.
  /// Pass null to disable undo/redo functionality.
  UndoRedoController? get undoController => _undoController;

  void setUndoController(UndoRedoController? controller) {
    _undoController = controller;
    if (controller != null) {
      controller.setApplyEditCallback(_applyUndoRedoOperation);
    }
  }

  /// The complete text content of the editor.
  ///
  /// Getting this property returns the full document text.
  /// Setting this property replaces all content and moves the cursor to the end.
  String get text {
    if (_cachedText == null || _cachedTextVersion != _currentVersion) {
      if (_bufferLineIndex != null && _bufferDirty) {
        final before = _rope.substring(0, _bufferLineRopeStart);
        final after = _rope.substring(
          _bufferLineRopeStart + _bufferLineOriginalLength,
        );
        _cachedText = before + _bufferLineText! + after;
      } else {
        _cachedText = _rope.getText();
      }
      _cachedTextVersion = _currentVersion;
    }
    return _cachedText!;
  }

  /// The total length of the document in characters.
  int get length {
    if (_bufferLineIndex != null && _bufferDirty) {
      return _rope.length + (_bufferLineLength - _bufferLineOriginalLength);
    }
    return _rope.length;
  }

  /// The current text selection in the editor.
  ///
  /// For a cursor with no selection, [TextSelection.isCollapsed] will be true.
  TextSelection get selection => _selection;

  /// Returns a window of lines without allocating the full buffer.
  List<String> getLinesRange(int startLine, int endLine) {
    final lines = _rope.cachedLinesRange(startLine, endLine);
    final buffered = isBufferActive ? _bufferLineIndex! - startLine : -1;
    if (buffered >= 0 && buffered < lines.length) {
      lines[buffered] = _bufferLineText!;
    }
    return lines;
  }

  /// The total number of lines in the document.
  int get lineCount => _rope.lineCount;

  /// Gets the text content of a specific line.
  ///
  /// [lineIndex] is zero-based (0 for the first line).
  /// Returns the text of the line without the newline character.
  String getLineText(int lineIndex) {
    if (isBufferActive && lineIndex == _bufferLineIndex) {
      return _bufferLineText!;
    }
    return _rope.getLineText(lineIndex);
  }

  /// Gets the line number (zero-based) for a character offset.
  ///
  /// [charOffset] is the character position in the document.
  /// Returns the line index containing that character.
  int getLineAtOffset(int charOffset) {
    if (isBufferActive) {
      final bufferEnd = _bufferLineRopeStart + _bufferLineLength;
      if (charOffset > bufferEnd) {
        return _rope.getLineAtOffset(
          charOffset - (_bufferLineLength - _bufferLineOriginalLength),
        );
      }
      if (charOffset >= _bufferLineRopeStart) return _bufferLineIndex!;
    }
    return _rope.getLineAtOffset(charOffset);
  }

  /// Gets the character offset where a line starts.
  ///
  /// [lineIndex] is zero-based (0 for the first line).
  /// Returns the character offset of the first character in that line.
  int getLineStartOffset(int lineIndex) {
    if (isBufferActive && lineIndex > _bufferLineIndex!) {
      return _rope.getLineStartOffset(lineIndex) +
          _bufferLineLength -
          _bufferLineOriginalLength;
    }
    return _rope.getLineStartOffset(lineIndex);
  }

  /// Lines break at LF alone, and a line's text leaves out the CR of a CRLF
  /// pair that its offsets still count, so CRLF text comes in as LF.
  static String normalizeLineBreaks(String text) =>
      text.replaceAll('\r\n', '\n');

  /// Keeps the undo history; a caller loading another file clears it.
  set text(String newText) {
    final document = normalizeLineBreaks(newText);
    _flushTimer?.cancel();
    _debounceTimer?.cancel();
    suggestionsNotifier.value = null;
    _snippetStops = null;
    _bufferLineIndex = null;
    _bufferLineText = null;
    _bufferDirty = false;
    if (isComposingActive) {
      _dropImeComposition();
      requestImeReset?.call();
    }
    _pendingSelectionReplacement = null;
    _rope.dispose();
    _rope = Rope(document);
    _currentVersion++;
    _cachedText = document;
    _cachedTextVersion = _currentVersion;
    _selection = TextSelection.collapsed(offset: _rope.length);
    foldings = {};
    clearDirtyRegion();
    documentReplaced = true;
    _isTyping = false;
    _invalidateImeSnapshotAndScheduleSync();
    notifyListeners();
  }

  /// Sets the current text selection.
  ///
  /// Setting this property will update the selection and notify listeners.
  /// For a collapsed cursor, use `TextSelection.collapsed(offset: pos)`.
  set selection(TextSelection newSelection) {
    if (_selection == newSelection) return;

    if (isComposingActive) {
      _selection = _commitCompositionAndRemapSelection(newSelection);
      selectionOnly = true;
      _isTyping = false;
      _imeProjectionDirty = true;
      requestImeReset?.call();
      notifyListeners();
      return;
    }

    _flushBuffer();

    _pendingSelectionReplacement = null;
    _selection = newSelection;
    selectionOnly = true;
    _isTyping = false;
    _imeProjectionDirty = true;

    _syncToConnection();

    notifyListeners();
  }

  /// Adds a listener that will be called when the controller state changes.
  ///
  /// Listeners are notified on text changes, selection changes, and other
  /// state updates.
  void addListener(VoidCallback listener) {
    _listeners.add(listener);
  }

  /// Removes a previously added listener.
  void removeListener(VoidCallback listener) {
    _listeners.remove(listener);
  }

  /// Notifies all registered listeners of a state change.
  void notifyListeners() {
    if (_isDisposed) return;
    for (final listener in _listeners) {
      listener();
    }
  }

  @protected
  @override
  void updateEditingValueWithDeltas(List<TextEditingDelta> textEditingDeltas) {
    if (readOnly) return;

    if (_imeComposition == null && !_selection.isCollapsed) {
      _pendingSelectionReplacement = _selection;
    }

    final involvesComposition =
        _imeComposition != null ||
        textEditingDeltas.any(
          (d) => d.composing.isValid && !d.composing.isCollapsed,
        );
    if (involvesComposition) {
      _processCompositionDeltas(textEditingDeltas);
      return;
    }

    _ensureImeProjection();
    final windowStart = _imeProjectionStartOffset;
    var window = _buildCurrentImeEditingValue();
    bool typingDetected = false;

    _suppressImeSync = true;
    for (final delta in textEditingDeltas) {
      final windowCaret = window.selection.extentOffset;
      window = delta.apply(window);
      int toGlobal(int local) =>
          _windowOffsetToGlobal(windowStart, delta.oldText, local);
      final selectionAfter = _windowSelectionToGlobal(
        windowStart,
        window.text,
        delta.selection,
      );

      if (delta is TextEditingDeltaNonTextUpdate) {
        final isEcho =
            _lastSentSelection != null && delta.selection == _lastSentSelection;
        if (!isEcho) {
          _selection = selectionAfter;
          _lastSentSelection = null;
        }
        _imeSelectionNeedsResync = false;
        continue;
      }

      _lastSentSelection = null;

      if (delta is TextEditingDeltaInsertion) {
        final mappedInsertionOffset = toGlobal(delta.insertionOffset);
        final staleMappedOffset =
            mappedInsertionOffset < _selection.extentOffset;
        bool useCurrentSelection =
            _imeSelectionNeedsResync ||
            delta.insertionOffset != windowCaret ||
            staleMappedOffset;
        if (isBufferActive) useCurrentSelection = true;
        _imeSelectionNeedsResync = false;

        if (delta.textInserted == '\n' &&
            (suggestionsNotifier.value?.isNotEmpty ?? false) &&
            selectedSuggestionNotifier.value != null) {
          acceptSuggestion();
          continue;
        }

        if (_startsWord(delta.textInserted)) {
          typingDetected = true;
        }
        final insertionOffset = useCurrentSelection
            ? _selection.extentOffset
            : mappedInsertionOffset;
        final insertionSelection = TextSelection.collapsed(
          offset: insertionOffset + delta.textInserted.runes.length,
        );

        _handleInsertion(
          insertionOffset,
          delta.textInserted,
          insertionSelection,
        );
      } else if (delta is TextEditingDeltaDeletion) {
        _handleDeletion(
          TextRange(
            start: toGlobal(delta.deletedRange.start),
            end: toGlobal(delta.deletedRange.end),
          ),
          selectionAfter,
        );
      } else if (delta is TextEditingDeltaReplacement) {
        if (delta.replacementText.isNotEmpty &&
            _startsWord(delta.replacementText)) {
          typingDetected = true;
        }
        _handleReplacement(
          TextRange(
            start: toGlobal(delta.replacedRange.start),
            end: toGlobal(delta.replacedRange.end),
          ),
          delta.replacementText,
          selectionAfter,
        );
      }
    }
    _suppressImeSync = false;

    _isTyping = typingDetected;

    _imeProjectionDirty = true;

    _maybeAcquireFocusForInput();

    _ensureImeProjection();
    if (_platformValueDivergesFromProjection(textEditingDeltas)) {
      _syncToConnection();
    }

    notifyListeners();
  }

  bool get isBufferActive => _bufferLineIndex != null && _bufferDirty;

  /// Whether an IME composition (e.g. CJK pinyin/kana) is currently in
  /// progress. While true, the platform input method owns the keyboard, so
  /// hardware-key handlers must defer to it and external selection changes
  /// must finalize the composition first.
  bool get isComposingActive => _imeComposition != null;
  int? get bufferLineIndex => _bufferLineIndex;
  String? get bufferLineText => _bufferLineText;
  int get contentVersion => _currentVersion;

  int get bufferCursorColumn {
    if (!isBufferActive) return 0;
    return _selection.extentOffset - _bufferLineRopeStart;
  }

  /// The active IME composition overlay, or null when no composition is in
  /// progress. Read by the renderer to paint the composing string.
  ImeComposition? get imeComposition => _imeComposition;

  @protected
  @override
  void connectionClosed() {
    if (connection != null && connection!.attached) {
      connection?.connectionClosedReceived();
      connection = null;
      focusNode?.unfocus();
    }
    _dropImeComposition();
  }

  void _dropImeComposition() {
    _imeComposition = null;
    _pendingSelectionReplacement = null;
    _imeMirrorDeleteStart = -1;
    _imeMirrorDeleteLen = 0;
    _imeMirrorDeletedText = '';
    _rawTypedComposingText = '';
    _lastComposingText = '';
    imeCompositionChanged = true;
    _imeCompositionUndoGroup?.end();
    _imeCompositionUndoGroup = null;
  }

  @protected
  @override
  AutofillScope? get currentAutofillScope => null;

  @override
  TextEditingValue? get currentTextEditingValue =>
      _buildCurrentImeEditingValue();

  @protected
  @override
  void didChangeInputControl(
    TextInputControl? oldControl,
    TextInputControl? newControl,
  ) {}

  @protected
  @override
  void insertContent(KeyboardInsertedContent content) {}

  @protected
  @override
  void insertTextPlaceholder(Size size) {}

  @protected
  @override
  void performAction(TextInputAction action) {}

  @protected
  @override
  void performPrivateCommand(String action, Map<String, dynamic> data) {}

  @protected
  @override
  void performSelector(String selectorName) {}

  @protected
  @override
  void removeTextPlaceholder() {}

  @protected
  @override
  void showAutocorrectionPromptRect(int start, int end) {}

  @protected
  @override
  void showToolbar() {}

  @protected
  @override
  void updateEditingValue(TextEditingValue value) {
    if (readOnly) return;

    if (_imeComposition == null && !_selection.isCollapsed) {
      _pendingSelectionReplacement = _selection;
    }

    final involvesComposition =
        _imeComposition != null ||
        (value.composing.isValid && !value.composing.isCollapsed);
    if (involvesComposition) {
      _processCompositionValue(value);
      return;
    }

    _suppressImeSync = true;
    _ensureImeProjection();
    final windowStart = _imeProjectionStartOffset;
    final next = _withoutCarriageReturns(value);

    final currentText = _imeProjectionText;
    final nextText = next.text;

    if (currentText != nextText) {
      int prefixLength = 0;
      final maxPrefix = currentText.length < nextText.length
          ? currentText.length
          : nextText.length;
      while (prefixLength < maxPrefix &&
          currentText.codeUnitAt(prefixLength) ==
              nextText.codeUnitAt(prefixLength)) {
        prefixLength++;
      }

      int suffixLength = 0;
      final currentTail = currentText.length - prefixLength;
      final nextTail = nextText.length - prefixLength;
      while (suffixLength < currentTail &&
          suffixLength < nextTail &&
          currentText.codeUnitAt(currentText.length - suffixLength - 1) ==
              nextText.codeUnitAt(nextText.length - suffixLength - 1)) {
        suffixLength++;
      }
      if (currentText.isLowSurrogateAt(prefixLength)) prefixLength--;
      if (suffixLength > 0 &&
          currentText.isLowSurrogateAt(currentText.length - suffixLength)) {
        suffixLength--;
      }

      final replaceStart =
          windowStart + currentText.toScalarOffset(prefixLength);
      final replaceEnd =
          windowStart +
          currentText.toScalarOffset(currentText.length - suffixLength);
      final replacement = nextText.substring(
        prefixLength,
        nextText.length - suffixLength,
      );

      replaceRange(replaceStart, replaceEnd, replacement);
    }

    _selection = _windowSelectionToGlobal(
      windowStart,
      nextText,
      next.selection,
    );
    _imeProjectionDirty = true;
    _suppressImeSync = false;
    if (nextText != value.text) _syncToConnection();
    _maybeAcquireFocusForInput();
    notifyListeners();
  }

  @protected
  @override
  bool onFocusReceived() {
    return true;
  }

  Offset? Function()? getFloatingCursorStartPosition;
  int Function(Offset)? getTextOffsetForFloatingCursorPosition;
  Offset? _floatingCursorStartPosition;

  @protected
  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {
    if (readOnly) return;

    switch (point.state) {
      case FloatingCursorDragState.Start:
        _floatingCursorStartPosition = getFloatingCursorStartPosition?.call();
        break;
      case FloatingCursorDragState.Update:
        if (point.offset == null ||
            _floatingCursorStartPosition == null ||
            getTextOffsetForFloatingCursorPosition == null) {
          return;
        }
        final targetPosition = _floatingCursorStartPosition! + point.offset!;
        final newOffset = getTextOffsetForFloatingCursorPosition!(
          targetPosition,
        );
        setSelectionSilently(TextSelection.collapsed(offset: newOffset));
        break;
      case FloatingCursorDragState.End:
        _floatingCursorStartPosition = null;
        break;
    }
  }

  /// Disposes of the controller and releases resources.
  ///
  /// Call this method when the controller is no longer needed to prevent
  /// memory leaks.
  void dispose() {
    _isDisposed = true;
    _debounceTimer?.cancel();
    _flushTimer?.cancel();
    _listeners.clear();
    connection?.close();
    suggestionsNotifier.dispose();
    selectedSuggestionNotifier.dispose();
  }

  void clearDirtyRegion() {
    dirtyRegion = null;
    dirtyLine = null;
    lineEdit = null;
    searchHighlightsChanged = false;
  }

  static int _lineStartBefore(String text, int index) {
    return index > 0 ? text.lastIndexOf('\n', index - 1) + 1 : 0;
  }
}
