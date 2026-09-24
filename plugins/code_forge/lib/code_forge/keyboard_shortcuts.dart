import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Keyboard shortcuts used by the [CodeForge].
///
/// The default constructor follows the Windows and Linux conventions, with
/// `Ctrl` as the primary modifier. [CodeForgeKeyboardShortcuts.apple] follows
/// the macOS and iOS conventions: `Cmd` as the primary modifier, `Option` for
/// word-wise movement and deletion, `Cmd + arrow` for line and document
/// boundaries. [CodeForge] picks one through [forPlatform].
class CodeForgeKeyboardShortcuts {
  final ShortcutActivator jumpToDocumentStart;
  final ShortcutActivator jumpToDocumentEnd;
  final ShortcutActivator jumpToDocumentStartAndSelectText;
  final ShortcutActivator jumpToDocumentEndAndSelectText;
  final ShortcutActivator duplicate;
  final ShortcutActivator shiftLineUp;
  final ShortcutActivator shiftLineDown;
  final ShortcutActivator deleteWordBackward;
  final ShortcutActivator deleteWordForward;
  final ShortcutActivator moveCursorToPreviousWord;
  final ShortcutActivator moveCursorToNextWord;
  final ShortcutActivator moveSelectionToPreviousWord;
  final ShortcutActivator moveSelectionForward;
  final ShortcutActivator moveSelectionBackward;
  final ShortcutActivator moveSelectionUpward;
  final ShortcutActivator moveSelectionDownward;
  final ShortcutActivator moveSelectionToNextWord;
  final ShortcutActivator showFindBar;
  final ShortcutActivator showFindAndReplaceBar;
  final ShortcutActivator selectToLineStart;
  final ShortcutActivator selectToLineEnd;
  final ShortcutActivator copy;
  final ShortcutActivator cut;
  final ShortcutActivator paste;
  final ShortcutActivator selectAll;
  final ShortcutActivator undo;
  final ShortcutActivator redo;
  final ShortcutActivator jumpToLineStart;
  final ShortcutActivator jumpToLineEnd;
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
