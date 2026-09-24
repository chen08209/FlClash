import 'package:material_ui/material_ui.dart';

/// This class provides styling options for code selection in the code editor.
class CodeSelectionStyle {
  /// The color of the cursor line, defaults to the highlight theme text color.
  final Color? cursorColor;

  /// The color used to highlight selected text in the code editor.
  final Color selectionColor;

  /// The color of the cursor bubble that appears when selecting text.
  final Color cursorBubbleColor;

  CodeSelectionStyle({
    this.cursorColor,
    this.selectionColor = const Color(0x6E2195F3),
    this.cursorBubbleColor = Colors.blue,
  });
}

/// This class provides styling options for the Gutter.
class GutterStyle {
  /// The background color of the gutter bar.
  final Color? backgroundColor;

  /// The color of the fold indicator icons. Defaults to the line number color.
  final Color? foldIconColor;

  const GutterStyle({this.backgroundColor, this.foldIconColor});
}

/// Represents a highlighted search result in the editor
class SearchHighlight {
  /// The start offset of the highlighted text
  final int start;

  /// The end offset of the highlighted text
  final int end;

  /// Whether this highlight represents the currently selected match
  final bool isCurrentMatch;

  const SearchHighlight({
    required this.start,
    required this.end,
    this.isCurrentMatch = false,
  });
}

/// An in-progress IME composition (e.g. CJK pinyin/kana), rendered as a
/// transient overlay above the document rather than written into it.
///
/// While a composition is active the editor's document (rope) is left
/// untouched; the composing text lives only in an instance of this class and
/// is painted at [anchor]. The committed result is written to the document as
/// a single edit only when the platform input method finalizes the
/// composition. This keeps the document free of transient composing glyphs
/// and lets the editor render the composing string itself. [displayText]
/// preserves the platform composing string for display (for example `hao'jia`),
/// while [commitText] stores the user's typed intent for interruption commits.
@immutable
class ImeComposition {
  /// Global document offset where composition starts.
  final int anchor;

  /// The text displayed in the IME overlay (exactly as reported by the platform).
  /// This includes any input method decorators like pinyin separators (a'a'a'a).
  final String displayText;

  /// Local caret position within [displayText].
  final int displayCaret;

  /// The intended text to be committed if the composition is interrupted.
  /// This is determined by the Incremental Intent Tracking algorithm to
  /// distinguish between user-typed characters and IME-auto-generated characters.
  final String commitText;

  const ImeComposition({
    required this.anchor,
    required this.displayText,
    required this.displayCaret,
    required this.commitText,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ImeComposition &&
          other.anchor == anchor &&
          other.displayText == displayText &&
          other.displayCaret == displayCaret &&
          other.commitText == commitText;

  @override
  int get hashCode =>
      Object.hash(anchor, displayText, displayCaret, commitText);
}
