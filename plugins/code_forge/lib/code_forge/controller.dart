import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:rust_api/editor.dart';

import '../code_forge.dart';
import 'clipboard.dart';
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

typedef DocumentEditListener = void Function(
  int offset,
  int removed,
  int inserted,
);

/// What changed since the last [CodeForgeController.takeChange].
final class CodeForgeChange {
  CodeForgeChange._();

  bool _replaced = false, _selection = false, _composition = false;
  bool _searchHighlights = false, _typing = false;
  ({int line, int removed, int inserted})? _lines;

  bool get replaced => _replaced;

  bool get selection => _selection;

  bool get composition => _composition;

  bool get searchHighlights => _searchHighlights;

  /// Typing in the line buffer, which reaches [lines] once it flushes.
  bool get typing => _typing;

  /// From `line` on, `removed` line breaks gave way to `inserted`.
  ({int line, int removed, int inserted})? get lines => _lines;

  bool get isEmpty =>
      !_replaced &&
      !_selection &&
      !_composition &&
      !_searchHighlights &&
      !_typing &&
      _lines == null;
}

abstract interface class CodeForgeView {
  FocusNode get focusNode;

  /// Reopens the input connection so the platform drops its composition.
  void resetInput();

  Offset? caretOffset();

  int? textOffsetAt(Offset position);

  void toggleFold(int line);

  void scrollToLine(int line);
}

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
  static const _lineEditLogLimit = 256;
  final _isMobile = Platform.isAndroid || Platform.isIOS;
  final List<VoidCallback> _listeners = [];
  final List<DocumentEditListener> _editListeners = [];
  CodeForgeView? _view;
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
  TextEditingValue _imeMirror = TextEditingValue.empty;
  String _imeWindowCommitted = '';
  int _imeWindowStart = 0;
  TextSelection? _pendingSelectionReplacement;
  final Set<String> _supersededPlatformTexts = {};
  ({int start, int length})? _imeHeldWindow;
  ({int version, DateTime at})? _selectionRemoval;
  ({int start, int caret})? _imeShiftedWindow;
  String? _copiedLine;
  ({int start, String text})? _imeMirrorDeletion;
  String _rawTypedComposingText = '';
  String _lastComposingText = '';
  bool _bufferDirty = false;
  bool _imeProjectionDirty = true, _imeSelectionNeedsResync = false;
  bool _isTyping = false, _isDisposed = false;
  int _imeProjectionStartOffset = 0;
  int _cachedTextVersion = -1, _currentVersion = 0;
  final List<({int version, int line, int removed, int inserted})>
  _lineEditLog = [];
  int _lineEditLogStart = 0;
  int _bufferLineRopeStart = 0, _bufferLineOriginalLength = 0;
  int? _bufferLineIndex;
  var _change = CodeForgeChange._();
  List<TextRange>? _snippetStops;
  int _snippetStopIndex = 0;
  UndoRedoController? _undoController;
  Set<String> _wordCache = {};
  int _wordCacheVersion = -1;
  int _completionStart = 0;

  CodeForgeController() {
    suggestionsNotifier.addListener(() {
      selectedSuggestionNotifier.value =
          suggestionsNotifier.value == null || _isMobile ? null : 0;
    });
    _listeners.add(() async {
      if (!enableLocalSuggestions && completionSource == null) return;
      _debounceTimer?.cancel();
      _debounceTimer = Timer(const Duration(milliseconds: 200), () async {
        if (enableLocalSuggestions && _wordCacheVersion != _currentVersion) {
          _wordCacheVersion = _currentVersion;
          _wordCache = await _extractWords();
        }
        if (_isDisposed) return;
        final typing = _isTyping && (focusNode?.hasFocus ?? true);
        _showCompletion(typing ? _complete() : null);
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

  /// Replaces the popup's document-word matching when set.
  CodeForgeCompletionSource? completionSource;

  FocusNode? get focusNode => _view?.focusNode;

  VoidCallback? onClipboardWriteFailed;

  List<CodeForgeSuggestion>? get suggestions => suggestionsNotifier.value;

  Rope _rope = Rope('');
  Rope get rope => _rope;
  TextSelection _selection = const TextSelection.collapsed(offset: 0);

  /// The text input connection to the platform.
  TextInputConnection? connection;

  void attachView(CodeForgeView view) => _view = view;

  void detachView(CodeForgeView view) {
    if (identical(_view, view)) _view = null;
  }

  /// The fold ranges the renderer has found, keyed by start line. The
  /// renderer publishes them when a fold is toggled, so this is empty until
  /// then.
  ///
  /// Use the setter to update this map — it rebuilds internal sorted caches
  /// used for O(log n) fold-region lookups.
  Map<int, FoldRange?> get foldings => _foldings;

  Map<int, FoldRange?> _foldings = {};
  List<({int start, int end})> _folded = const [];

  /// Set fold ranges in the editor
  set foldings(Map<int, FoldRange?> value) {
    _foldings = value;
    _rebuildFoldSortedCache();
  }

  List<SearchHighlight> get searchHighlights => _searchHighlights;
  List<SearchHighlight> _searchHighlights = const [];

  /// In document order.
  set searchHighlights(List<SearchHighlight> value) {
    _searchHighlights = value;
    _change._searchHighlights = true;
    notifyListeners();
  }

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

  CodeForgeChange takeChange() {
    final change = _change;
    _change = CodeForgeChange._();
    return change;
  }

  ({int line, int removed, int inserted})? get pendingLineEdit =>
      _change._lines;

  /// Sets the undo controller for this editor.
  ///
  /// The undo controller manages the undo/redo history for text operations.
  /// Pass null to disable undo/redo functionality.
  UndoRedoController? get undoController => _undoController;

  // One closure, so the history can tell this controller's from another's.
  late final void Function(EditOperation) _applyUndoRedo =
      _applyUndoRedoOperation;

  void setUndoController(UndoRedoController? controller) {
    if (identical(controller, _undoController)) return;
    _undoController?.releaseApplyEditCallback(_applyUndoRedo);
    _undoController = controller;
    controller?.setApplyEditCallback(
      _applyUndoRedo,
      settleInput: commitComposition,
    );
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
    final previousLength = length;
    _flushTimer?.cancel();
    _debounceTimer?.cancel();
    suggestionsNotifier.value = null;
    _snippetStops = null;
    _bufferLineIndex = null;
    _bufferLineText = null;
    _bufferDirty = false;
    if (isComposingActive) {
      _dropImeComposition();
      _view?.resetInput();
    }
    _pendingSelectionReplacement = null;
    _rope.dispose();
    _rope = Rope(document);
    _currentVersion++;
    _lineEditLog.clear();
    _lineEditLogStart = _currentVersion;
    _cachedText = document;
    _cachedTextVersion = _currentVersion;
    _selection = TextSelection.collapsed(offset: _rope.length);
    foldings = {};
    _change = CodeForgeChange._().._replaced = true;
    _isTyping = false;
    _invalidateImeSnapshotAndScheduleSync();
    _notifyEdit(0, previousLength, _rope.length);
    notifyListeners();
  }

  /// Clamped to the document; a composition in progress is committed first.
  set selection(TextSelection newSelection) {
    if (_selection == newSelection) return;
    final composing = isComposingActive;
    if (composing) {
      newSelection = _commitCompositionAndRemapSelection(newSelection);
    }
    _flushBuffer();
    _pendingSelectionReplacement = null;
    final end = length;
    _selection = newSelection.copyWith(
      baseOffset: newSelection.baseOffset.clamp(0, end),
      extentOffset: newSelection.extentOffset.clamp(0, end),
    );
    _change._selection = true;
    _isTyping = false;
    _imeProjectionDirty = true;
    if (composing) {
      _view?.resetInput();
    } else {
      _syncToConnection();
    }
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

  void addEditListener(DocumentEditListener listener) {
    _editListeners.add(listener);
  }

  void removeEditListener(DocumentEditListener listener) {
    _editListeners.remove(listener);
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

    if (_editSupersededWindow(textEditingDeltas)) {
      _retypeSupersededInsertions(textEditingDeltas);
      return;
    }
    if (textEditingDeltas.isEmpty) {
      if (_imeComposition != null) _endCompositionAsShown();
      return;
    }
    _supersededPlatformTexts.clear();

    final selectionBefore = _selection;
    if (_imeComposition == null && !_selection.isCollapsed) {
      _pendingSelectionReplacement = _selection;
    }

    final involvesComposition =
        _imeComposition != null ||
        textEditingDeltas.any(
          (d) => _changesText(d) && _isComposing(d.composing),
        );
    var deltas = textEditingDeltas;
    if (involvesComposition) {
      // Deltas over a selection the platform still shows are not typing.
      final mirrorsDocument =
          _imeMirrorDeletion == null &&
          (_imeComposition != null || _selectionBeingReplaced() == null);
      final typing = mirrorsDocument ? _typingAfterComposition(deltas) : -1;
      if (typing < 0) {
        _imeShiftedWindow = null;
        _processCompositionDeltas(deltas);
        return;
      }
      _endCompositionBefore(deltas.sublist(0, typing), deltas[typing]);
      deltas = deltas.sublist(typing);
    }

    _ensureImeProjection();
    var windowStart = _imeProjectionStartOffset;
    var window = _buildCurrentImeEditingValue();
    if (_shiftedWindowEdited(deltas, window) case (
      :final start,
      :final caret,
    )) {
      windowStart = start;
      window = window.copyWith(
        selection: TextSelection.collapsed(offset: caret),
      );
    }
    _imeShiftedWindow = null;
    bool typingDetected = false, removedSelection = false;
    var removalUndoGroup = deltas.any(_changesText)
        ? _joinSelectionRemoval()
        : null;
    TextEditingValue? platform;

    _suppressImeSync = true;
    for (final delta in deltas) {
      final windowCaret = window.selection.extentOffset;
      int toGlobal(int local) =>
          _windowOffsetToGlobal(windowStart, delta.oldText, local);
      final removed = _changesText(delta) ? _removedRange(delta) : null;
      if (removed != null) {
        final windowEnd = toGlobal(delta.oldText.length);
        final range = TextRange(
          start: toGlobal(removed.start),
          end: toGlobal(removed.end),
        );
        final cutShort = _selectionCutShortByWindow(
          windowStart,
          windowEnd,
          range,
        );
        final pending = _pendingSelectionReplacement;
        final removesCollapsedSelection =
            _selection.isCollapsed &&
            pending != null &&
            (cutShort != null ||
                range.start == pending.start && range.end == pending.end);
        // Undoing the removal then gives the selection back.
        if (removesCollapsedSelection) {
          _selection = pending;
          removedSelection = true;
        }
        if (cutShort != null) {
          removalUndoGroup ??= _undoController?.beginCompoundOperation();
          if (delta is TextEditingDeltaDeletion &&
              !removesCollapsedSelection &&
              !_selection.isCollapsed) {
            unawaited(
              _widenPlatformCut(
                delta.textDeleted,
                _documentSubstring(cutShort.start, cutShort.end),
              ),
            );
          }
          windowStart = _deleteSelectionOutsideWindow(
            cutShort,
            windowStart,
            windowEnd,
          );
        }
      }
      window = delta.apply(window);
      final selectionAfter = _windowSelectionToGlobal(
        windowStart,
        window.text,
        delta.selection,
      );

      if (!_changesText(delta)) {
        final isEcho =
            _lastSentSelection != null && delta.selection == _lastSentSelection;
        if (!isEcho) {
          if (selectionAfter != _selection) _change._selection = true;
          _selection = selectionAfter;
          _lastSentSelection = null;
        }
        if (!isEcho || delta is! TextEditingDeltaNonTextUpdate) {
          platform = window;
        }
        _imeSelectionNeedsResync = false;
        continue;
      }

      _lastSentSelection = null;
      platform = window;

      if (delta is TextEditingDeltaInsertion) {
        removedSelection = false;
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
    removalUndoGroup?.end();
    _selectionRemoval = removedSelection
        ? (version: _currentVersion, at: DateTime.now())
        : null;
    _suppressImeSync = false;

    _isTyping = typingDetected;

    _imeProjectionDirty = true;

    _maybeAcquireFocusForInput();

    _keepPendingSelectionAtRest(
      selectionBefore,
      windowStart,
      _windowOffsetToGlobal(windowStart, window.text, window.text.length),
    );
    if (platform != null) _replacePlatformWindow(platform, windowStart);

    notifyListeners();
  }

  bool get isBufferActive => _bufferLineIndex != null && _bufferDirty;

  /// Whether an IME composition (e.g. CJK pinyin/kana) is currently in
  /// progress. While true, the platform input method owns the keyboard, so
  /// hardware-key handlers must defer to it and external selection changes
  /// must finalize the composition first.
  bool get isComposingActive => _imeComposition != null;

  /// Commits a composition in progress where it is shown, so positions read
  /// from the layout afterwards line up with the document.
  void commitComposition() {
    if (!isComposingActive) return;
    _commitCompositionInPlace();
    _imeProjectionDirty = true;
    _view?.resetInput();
    notifyListeners();
  }

  /// [later] puts the notification off for a caller inside a build or dispose.
  void commitCompositionOnClose({bool later = false}) {
    if (!isComposingActive) return;
    _commitCompositionInPlace();
    _imeProjectionDirty = true;
    later ? scheduleMicrotask(notifyListeners) : notifyListeners();
  }

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
    commitCompositionOnClose();
  }

  void _dropImeComposition() {
    _imeComposition = null;
    _pendingSelectionReplacement = null;
    _imeMirrorDeletion = null;
    _rawTypedComposingText = '';
    _lastComposingText = '';
    _change._composition = true;
    _imeCompositionUndoGroup?.end();
    _imeCompositionUndoGroup = null;
  }

  @protected
  @override
  AutofillScope? get currentAutofillScope => null;

  @override
  TextEditingValue get currentTextEditingValue =>
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

    final selectionBefore = _selection;
    if (_imeComposition == null && !_selection.isCollapsed) {
      _pendingSelectionReplacement = _selection;
    }

    _ensureImeProjection();
    final involvesComposition =
        _imeComposition != null ||
        (_isComposing(value.composing) &&
            _withoutCarriageReturns(value).text != _imeProjectionText);
    if (involvesComposition) {
      _processCompositionValue(value);
      return;
    }

    _suppressImeSync = true;
    var windowStart = _imeProjectionStartOffset;
    final next = _withoutCarriageReturns(value);

    final currentText = _imeProjectionText;
    final nextText = next.text;
    if (_changedSpan(currentText, nextText) case final change?) {
      final windowEnd = windowStart + currentText.runes.length;
      final cutShort = change.start < change.end
          ? _selectionCutShortByWindow(
              windowStart,
              windowEnd,
              TextRange(
                start: windowStart + currentText.toScalarOffset(change.start),
                end: windowStart + currentText.toScalarOffset(change.end),
              ),
            )
          : null;
      CompoundOperationHandle? removalUndoGroup;
      if (cutShort != null) {
        removalUndoGroup = _undoController?.beginCompoundOperation();
        windowStart = _deleteSelectionOutsideWindow(
          cutShort,
          windowStart,
          windowEnd,
        );
      }
      replaceRange(
        windowStart + currentText.toScalarOffset(change.start),
        windowStart + currentText.toScalarOffset(change.end),
        change.replacement,
      );
      removalUndoGroup?.end();
    }

    _selection = _windowSelectionToGlobal(
      windowStart,
      nextText,
      next.selection,
    );
    if (_selection != selectionBefore) _change._selection = true;
    _keepPendingSelectionAtRest(
      selectionBefore,
      windowStart,
      windowStart + nextText.runes.length,
    );
    _imeProjectionDirty = true;
    _suppressImeSync = false;
    _replacePlatformWindow(value, windowStart);
    _maybeAcquireFocusForInput();
    notifyListeners();
  }

  @protected
  @override
  bool onFocusReceived() {
    return true;
  }

  Offset? _floatingCursorStartPosition;

  @protected
  @override
  void updateFloatingCursor(RawFloatingCursorPoint point) {
    if (readOnly) return;

    switch (point.state) {
      case FloatingCursorDragState.Start:
        _floatingCursorStartPosition = _view?.caretOffset();
      case FloatingCursorDragState.Update:
        final start = _floatingCursorStartPosition;
        final moved = point.offset;
        if (start == null || moved == null) return;
        if (_view?.textOffsetAt(start + moved) case final offset?) {
          selection = TextSelection.collapsed(offset: offset);
        }
      case FloatingCursorDragState.End:
        _floatingCursorStartPosition = null;
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
    _editListeners.clear();
    connection?.close();
    setUndoController(null);
    suggestionsNotifier.dispose();
    selectedSuggestionNotifier.dispose();
    _rope.dispose();
  }
}
