import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'controller.dart' show CodeForgeSnippet;

/// Represents a foldable code region in the editor.
///
/// A fold range defines a region of code that can be collapsed (folded) to hide
/// its contents. This is typically used for code blocks like functions, classes,
/// or control structures.
///
/// Fold ranges are automatically detected based on code structure (braces,
/// indentation).
///
/// Example:
/// ```dart
/// // A fold range from line 5 to line 10
/// final foldRange = FoldRange(5, 10);
/// foldRange.isFolded = true; // Collapse the region
/// ```
class FoldRange {
  /// The starting line index (zero-based) of the fold range.
  ///
  /// This is the line where the fold indicator appears in the gutter.
  final int startIndex;

  /// The ending line index (zero-based) of the fold range.
  ///
  /// When folded, all lines from `startIndex + 1` to `endIndex` are hidden.
  final int endIndex;

  /// Whether this fold range is currently collapsed.
  ///
  /// When true, the contents of this range are hidden in the editor.
  bool isFolded = false;

  /// Child fold ranges that were originally folded when this range was unfolded.
  ///
  /// Used to restore the fold state of nested ranges when toggling folds.
  List<FoldRange> originallyFoldedChildren = [];

  /// Creates a [FoldRange] with the specified start and end line indices.
  FoldRange(this.startIndex, this.endIndex);

  /// Adds a child fold range that was originally folded.
  ///
  /// Used internally to track nested fold states.
  void addOriginallyFoldedChild(FoldRange child) {
    if (!originallyFoldedChildren.contains(child)) {
      originallyFoldedChildren.add(child);
    }
  }

  /// Clears the list of originally folded children.
  void clearOriginallyFoldedChildren() {
    originallyFoldedChildren.clear();
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FoldRange &&
        other.startIndex == startIndex &&
        other.endIndex == endIndex;
  }

  @override
  int get hashCode => startIndex.hashCode ^ endIndex.hashCode;
}

/// Keyboard shortcuts used by the [CodeForge].
///
/// The default constructor follows the Windows and Linux conventions, with
/// `Ctrl` as the primary modifier. [CodeForgeKeyboardShortcuts.apple] follows
/// the macOS and iOS conventions: `Cmd` as the primary modifier, `Option` for
/// word-wise movement and deletion, `Cmd + arrow` for line and document
/// boundaries. [CodeForge] picks one through [forPlatform].
class CodeForgeKeyboardShortcuts {
  /// Places the cursor at the document start.
  /// Defaults to `Ctrl + home`
  final ShortcutActivator jumpToDocumentStart;

  /// Places the cursor at the document end.
  /// Defaults to `Ctrl + end`
  final ShortcutActivator jumpToDocumentEnd;

  /// Extends the selection to the document start.
  /// Defaults to `Ctrl + Shift + home`.
  final ShortcutActivator jumpToDocumentStartAndSelectText;

  /// Extends the selection to the document end.
  /// Defaults to `Ctrl + Shift + end`.
  final ShortcutActivator jumpToDocumentEndAndSelectText;

  /// Duplicates the selection, or the current line when nothing is selected.
  /// Defaults to `Ctrl + D`
  final ShortcutActivator duplicate;

  /// Moves the current line upwards.
  /// Defaults to `Ctrl + Shift + arrowUp`
  final ShortcutActivator shiftLineUp;

  /// Moves the current line downwards.
  /// Defaults to `Ctrl + Shift + arrowDown`
  final ShortcutActivator shiftLineDown;

  /// Deletes the word before the cursor.
  /// Defaults to `Ctrl + backspace`
  final ShortcutActivator deleteWordBackward;

  /// Deletes the word after the cursor.
  /// Defaults to `Ctrl + delete`
  final ShortcutActivator deleteWordForward;

  /// Cursor jumps to the previous word.
  /// Defaults to `Ctrl + arrowLeft`
  final ShortcutActivator moveCursorToPreviousWord;

  /// Cursor jumps to the next word.
  /// Defaults to `Ctrl + arrowRight`
  final ShortcutActivator moveCursorToNextWord;

  /// Similar to [moveCursorToPreviousWord], but selection also jumps with the cursor.
  /// Defaults to `Ctrl + Shift + arrowLeft`
  final ShortcutActivator moveSelectionToPreviousWord;

  /// Extends the selection forward by one character at a time.
  /// Defaults to `Shift + arrowRight`
  final ShortcutActivator moveSelectionForward;

  /// Extends the selection backward by one character at a time.
  /// Defaults to `Shift + arrowLeft`
  final ShortcutActivator moveSelectionBackward;

  /// Extends the text selection to upward lines.
  /// Defaults to `Shift + arrowUp`.
  final ShortcutActivator moveSelectionUpward;

  /// Extends the text selection to downward lines.
  /// Defaults to `Shift + arrowDown`.
  final ShortcutActivator moveSelectionDownward;

  /// Similar to [moveCursorToNextWord], but selection also jumps with the cursor.
  /// Defaults to `Ctrl + Shift + arrowRight`
  final ShortcutActivator moveSelectionToNextWord;

  /// Shows the find panel.
  /// Defaults to `Ctrl + F`
  final ShortcutActivator showFindBar;

  /// Shows the find panel with the replace field.
  /// Defaults to `Ctrl + H`; `Cmd + Option + F` on Apple platforms.
  final ShortcutActivator showFindAndReplaceBar;

  /// Extends the selection to the start of the current line.
  /// Defaults to `Shift + home`.
  final ShortcutActivator selectToLineStart;

  /// Extends the selection to the end of the current line.
  /// Defaults to `Shift + end`.
  final ShortcutActivator selectToLineEnd;

  /// Copies the selection. Defaults to `Ctrl + C`.
  final ShortcutActivator copy;

  /// Cuts the selection. Defaults to `Ctrl + X`.
  final ShortcutActivator cut;

  /// Pastes the clipboard text. Defaults to `Ctrl + V`.
  final ShortcutActivator paste;

  /// Selects the whole document. Defaults to `Ctrl + A`.
  final ShortcutActivator selectAll;

  /// Undoes the last edit. Defaults to `Ctrl + Z`.
  final ShortcutActivator undo;

  /// Redoes the last undone edit. Defaults to `Ctrl + Y` or `Ctrl + Shift + Z`.
  final ShortcutActivator redo;

  /// Places the cursor at the start of the current line.
  /// Defaults to `home`.
  final ShortcutActivator jumpToLineStart;

  /// Places the cursor at the end of the current line.
  /// Defaults to `end`.
  final ShortcutActivator jumpToLineEnd;

  /// Deletes from the cursor back to the start of the current line.
  /// Unbound by default; `Cmd + backspace` on Apple platforms.
  final ShortcutActivator? deleteToLineStart;

  const CodeForgeKeyboardShortcuts({
    this.duplicate = const SingleActivator(
      LogicalKeyboardKey.keyD,
      control: true,
    ),
    this.shiftLineUp = const SingleActivator(
      LogicalKeyboardKey.arrowUp,
      control: true,
      shift: true,
    ),
    this.shiftLineDown = const SingleActivator(
      LogicalKeyboardKey.arrowDown,
      control: true,
      shift: true,
    ),
    this.deleteWordBackward = const SingleActivator(
      LogicalKeyboardKey.backspace,
      control: true,
    ),
    this.deleteWordForward = const SingleActivator(
      LogicalKeyboardKey.delete,
      control: true,
    ),
    this.moveCursorToNextWord = const SingleActivator(
      LogicalKeyboardKey.arrowRight,
      control: true,
    ),
    this.moveCursorToPreviousWord = const SingleActivator(
      LogicalKeyboardKey.arrowLeft,
      control: true,
    ),
    this.moveSelectionToNextWord = const SingleActivator(
      LogicalKeyboardKey.arrowRight,
      control: true,
      shift: true,
    ),
    this.moveSelectionToPreviousWord = const SingleActivator(
      LogicalKeyboardKey.arrowLeft,
      control: true,
      shift: true,
    ),
    this.moveSelectionUpward = const SingleActivator(
      LogicalKeyboardKey.arrowUp,
      shift: true,
    ),
    this.moveSelectionDownward = const SingleActivator(
      LogicalKeyboardKey.arrowDown,
      shift: true,
    ),
    this.moveSelectionForward = const SingleActivator(
      LogicalKeyboardKey.arrowRight,
      shift: true,
    ),
    this.moveSelectionBackward = const SingleActivator(
      LogicalKeyboardKey.arrowLeft,
      shift: true,
    ),
    this.showFindBar = const SingleActivator(
      LogicalKeyboardKey.keyF,
      control: true,
    ),
    this.showFindAndReplaceBar = const SingleActivator(
      LogicalKeyboardKey.keyH,
      control: true,
    ),
    this.jumpToDocumentStart = const SingleActivator(
      LogicalKeyboardKey.home,
      control: true,
    ),
    this.jumpToDocumentEnd = const SingleActivator(
      LogicalKeyboardKey.end,
      control: true,
    ),
    this.jumpToDocumentStartAndSelectText = const SingleActivator(
      LogicalKeyboardKey.home,
      control: true,
      shift: true,
    ),
    this.jumpToDocumentEndAndSelectText = const SingleActivator(
      LogicalKeyboardKey.end,
      control: true,
      shift: true,
    ),
    this.selectToLineStart = const SingleActivator(
      LogicalKeyboardKey.home,
      shift: true,
    ),
    this.selectToLineEnd = const SingleActivator(
      LogicalKeyboardKey.end,
      shift: true,
    ),
    this.copy = const SingleActivator(LogicalKeyboardKey.keyC, control: true),
    this.cut = const SingleActivator(LogicalKeyboardKey.keyX, control: true),
    this.paste = const SingleActivator(LogicalKeyboardKey.keyV, control: true),
    this.selectAll = const SingleActivator(
      LogicalKeyboardKey.keyA,
      control: true,
    ),
    this.undo = const SingleActivator(LogicalKeyboardKey.keyZ, control: true),
    this.redo = const AnyShortcutActivator([
      SingleActivator(LogicalKeyboardKey.keyY, control: true),
      SingleActivator(LogicalKeyboardKey.keyZ, control: true, shift: true),
    ]),
    this.jumpToLineStart = const SingleActivator(LogicalKeyboardKey.home),
    this.jumpToLineEnd = const SingleActivator(LogicalKeyboardKey.end),
    this.deleteToLineStart,
  });

  /// The macOS and iOS conventions.
  const CodeForgeKeyboardShortcuts.apple({
    this.duplicate = const SingleActivator(LogicalKeyboardKey.keyD, meta: true),
    this.shiftLineUp = const SingleActivator(
      LogicalKeyboardKey.arrowUp,
      alt: true,
    ),
    this.shiftLineDown = const SingleActivator(
      LogicalKeyboardKey.arrowDown,
      alt: true,
    ),
    this.deleteWordBackward = const SingleActivator(
      LogicalKeyboardKey.backspace,
      alt: true,
    ),
    this.deleteWordForward = const SingleActivator(
      LogicalKeyboardKey.delete,
      alt: true,
    ),
    this.moveCursorToNextWord = const SingleActivator(
      LogicalKeyboardKey.arrowRight,
      alt: true,
    ),
    this.moveCursorToPreviousWord = const SingleActivator(
      LogicalKeyboardKey.arrowLeft,
      alt: true,
    ),
    this.moveSelectionToNextWord = const SingleActivator(
      LogicalKeyboardKey.arrowRight,
      alt: true,
      shift: true,
    ),
    this.moveSelectionToPreviousWord = const SingleActivator(
      LogicalKeyboardKey.arrowLeft,
      alt: true,
      shift: true,
    ),
    this.moveSelectionUpward = const SingleActivator(
      LogicalKeyboardKey.arrowUp,
      shift: true,
    ),
    this.moveSelectionDownward = const SingleActivator(
      LogicalKeyboardKey.arrowDown,
      shift: true,
    ),
    this.moveSelectionForward = const SingleActivator(
      LogicalKeyboardKey.arrowRight,
      shift: true,
    ),
    this.moveSelectionBackward = const SingleActivator(
      LogicalKeyboardKey.arrowLeft,
      shift: true,
    ),
    this.showFindBar = const SingleActivator(
      LogicalKeyboardKey.keyF,
      meta: true,
    ),
    // `Cmd + H` hides the application on macOS before the editor sees it.
    this.showFindAndReplaceBar = const SingleActivator(
      LogicalKeyboardKey.keyF,
      meta: true,
      alt: true,
    ),
    this.jumpToDocumentStart = const SingleActivator(
      LogicalKeyboardKey.arrowUp,
      meta: true,
    ),
    this.jumpToDocumentEnd = const SingleActivator(
      LogicalKeyboardKey.arrowDown,
      meta: true,
    ),
    this.jumpToDocumentStartAndSelectText = const SingleActivator(
      LogicalKeyboardKey.arrowUp,
      meta: true,
      shift: true,
    ),
    this.jumpToDocumentEndAndSelectText = const SingleActivator(
      LogicalKeyboardKey.arrowDown,
      meta: true,
      shift: true,
    ),
    this.selectToLineStart = const AnyShortcutActivator([
      SingleActivator(LogicalKeyboardKey.home, shift: true),
      SingleActivator(LogicalKeyboardKey.arrowLeft, meta: true, shift: true),
    ]),
    this.selectToLineEnd = const AnyShortcutActivator([
      SingleActivator(LogicalKeyboardKey.end, shift: true),
      SingleActivator(LogicalKeyboardKey.arrowRight, meta: true, shift: true),
    ]),
    this.copy = const SingleActivator(LogicalKeyboardKey.keyC, meta: true),
    this.cut = const SingleActivator(LogicalKeyboardKey.keyX, meta: true),
    this.paste = const SingleActivator(LogicalKeyboardKey.keyV, meta: true),
    this.selectAll = const SingleActivator(LogicalKeyboardKey.keyA, meta: true),
    this.undo = const SingleActivator(LogicalKeyboardKey.keyZ, meta: true),
    this.redo = const SingleActivator(
      LogicalKeyboardKey.keyZ,
      meta: true,
      shift: true,
    ),
    this.jumpToLineStart = const AnyShortcutActivator([
      SingleActivator(LogicalKeyboardKey.home),
      SingleActivator(LogicalKeyboardKey.arrowLeft, meta: true),
    ]),
    this.jumpToLineEnd = const AnyShortcutActivator([
      SingleActivator(LogicalKeyboardKey.end),
      SingleActivator(LogicalKeyboardKey.arrowRight, meta: true),
    ]),
    this.deleteToLineStart = const SingleActivator(
      LogicalKeyboardKey.backspace,
      meta: true,
    ),
  });

  /// The shortcuts that follow the conventions of [platform].
  static CodeForgeKeyboardShortcuts forPlatform(TargetPlatform platform) {
    return switch (platform) {
      TargetPlatform.macOS ||
      TargetPlatform.iOS => const CodeForgeKeyboardShortcuts.apple(),
      _ => const CodeForgeKeyboardShortcuts(),
    };
  }
}

/// A shortcut that fires when any of [activators] accepts the key event,
/// for commands bound to more than one key combination.
class AnyShortcutActivator extends ShortcutActivator {
  final List<ShortcutActivator> activators;

  const AnyShortcutActivator(this.activators);

  @override
  Iterable<LogicalKeyboardKey>? get triggers {
    final keys = <LogicalKeyboardKey>{};
    for (final activator in activators) {
      final triggers = activator.triggers;
      if (triggers == null) return null;
      keys.addAll(triggers);
    }
    return keys;
  }

  @override
  bool accepts(KeyEvent event, HardwareKeyboard state) {
    return activators.any((activator) => activator.accepts(event, state));
  }

  @override
  String debugDescribeKeys() {
    return activators
        .map((activator) => activator.debugDescribeKeys())
        .join(' | ');
  }
}

/// A request to show the context menu, passed to [CodeForge.onContextMenu].
class CodeForgeContextMenuRequest {
  /// Where the menu was requested, in global coordinates.
  final Offset globalPosition;

  /// Whether the editor has a non-empty selection.
  final bool hasSelection;

  /// Whether the whole document is selected.
  final bool isAllSelected;

  /// Whether the editor is read-only.
  final bool readOnly;

  final VoidCallback copy;
  final VoidCallback cut;
  final VoidCallback paste;
  final VoidCallback selectAll;

  const CodeForgeContextMenuRequest({
    required this.globalPosition,
    required this.hasSelection,
    required this.isAllSelected,
    required this.readOnly,
    required this.copy,
    required this.cut,
    required this.paste,
    required this.selectAll,
  });
}

/// What [CodeForge.scrollbarBuilder] needs to build the vertical scrollbar.
class CodeForgeScrollbarDetails {
  /// The vertical scroll controller of the editor.
  final ScrollController controller;

  /// The 1-based line at the top of the viewport.
  final ValueListenable<int> firstVisibleLine;

  const CodeForgeScrollbarDetails({
    required this.controller,
    required this.firstVisibleLine,
  });
}

/// One entry of the completion popup, as [CodeForge.suggestionPopupBuilder]
/// sees it.
class CodeForgeSuggestion {
  final String label;

  final String? detail;
  final CodeForgeSnippet? snippet;

  const CodeForgeSuggestion({required this.label, this.detail, this.snippet});
}

/// What [CodeForge.suggestionPopupBuilder] needs to build the completion
/// popup.
class CodeForgeSuggestionDetails {
  final List<CodeForgeSuggestion> suggestions;

  /// The entry Enter or Tab accepts, or null when none is highlighted.
  final int? selectedIndex;

  /// Inserts the entry at the index.
  final ValueChanged<int> onAccept;

  /// The caret's line box, zero wide, in the coordinates of the editor area
  /// the popup is laid over.
  final Rect caretRect;

  const CodeForgeSuggestionDetails({
    required this.suggestions,
    required this.selectedIndex,
    required this.onAccept,
    required this.caretRect,
  });
}
