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

  /// The text style of the line numbers. Defaults to the editor's text style;
  /// a missing color comes from the theme.
  final TextStyle? lineNumberStyle;

  const GutterStyle({
    this.backgroundColor,
    this.foldIconColor,
    this.lineNumberStyle,
  });
}
