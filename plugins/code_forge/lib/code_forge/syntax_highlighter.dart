import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_highlight/re_highlight.dart';

/// Highlights each line on its own, so a line's spans follow from its text
/// alone and are cached by it.
class SyntaxHighlighter {
  /// re_highlight slows with the square of line length; longer lines stay plain.
  static const maxHighlightedLineLength = 4096;

  static bool isPlain(String lineText) =>
      lineText.length > maxHighlightedLineLength;

  static const _maxCachedLines = 8000;
  static const _maxInlineBatchChars = 2000;

  final Mode language;
  final Map<String, TextStyle> editorTheme;
  final TextStyle? baseTextStyle;
  final Map<String, TextSpan?> _spans = {};
  late final _grammar = _Grammar(
    language,
    _resolveTheme(editorTheme),
    baseTextStyle,
  );
  Future<void>? _pending;

  SyntaxHighlighter({
    required this.language,
    required this.editorTheme,
    this.baseTextStyle,
  });

  bool hasLineSpan(String lineText) =>
      isPlain(lineText) || _spans.containsKey(lineText);

  TextSpan? lineSpan(String lineText) {
    if (isPlain(lineText)) return null;
    if (_spans.containsKey(lineText)) return _spans[lineText];
    return _remember(lineText, _grammar.highlight(lineText));
  }

  TextSpan? _remember(String lineText, TextSpan? span) {
    if (_spans.length >= _maxCachedLines) _spans.clear();
    return _spans[lineText] = span;
  }

  ui.Paragraph buildHighlightedParagraph(
    String lineText,
    ui.ParagraphStyle paragraphStyle,
    double fontSize,
    String? fontFamily, {
    double? width,
    bool allowSynchronousHighlight = true,
  }) {
    final span = allowSynchronousHighlight
        ? lineSpan(lineText)
        : _spans[lineText];
    if (span == null || lineText.isEmpty) {
      return buildPlainParagraph(
        lineText,
        paragraphStyle,
        fontSize,
        fontFamily,
        width: width,
      );
    }

    final builder = ui.ParagraphBuilder(paragraphStyle);
    _addTextSpanToBuilder(builder, span, fontSize, fontFamily);

    final p = builder.build();
    p.layout(ui.ParagraphConstraints(width: width ?? double.infinity));
    return p;
  }

  ui.Paragraph buildPlainParagraph(
    String text,
    ui.ParagraphStyle paragraphStyle,
    double fontSize,
    String? fontFamily, {
    double? width,
  }) {
    final builder = ui.ParagraphBuilder(paragraphStyle)
      ..pushStyle(_getUiTextStyle(fontSize, fontFamily))
      ..addText(text.isEmpty ? ' ' : text);
    return builder.build()
      ..layout(ui.ParagraphConstraints(width: width ?? double.infinity));
  }

  void _addTextSpanToBuilder(
    ui.ParagraphBuilder builder,
    TextSpan span,
    double fontSize,
    String? fontFamily, {
    TextStyle? inheritedStyle,
  }) {
    final effectiveStyle =
        (inheritedStyle ??
                baseTextStyle ??
                editorTheme['root'] ??
                const TextStyle())
            .merge(span.style);
    final style = _textStyleToUiStyle(effectiveStyle, fontSize, fontFamily);
    builder.pushStyle(style);

    if (span.text != null) {
      builder.addText(span.text!);
    }

    if (span.children != null) {
      for (final child in span.children!) {
        if (child is TextSpan) {
          _addTextSpanToBuilder(
            builder,
            child,
            fontSize,
            fontFamily,
            inheritedStyle: effectiveStyle,
          );
        }
      }
    }

    builder.pop();
  }

  ui.TextStyle _textStyleToUiStyle(
    TextStyle? style,
    double fontSize,
    String? fontFamily,
  ) {
    return ui.TextStyle(
      color: style?.color ?? editorTheme['root']?.color ?? Colors.black,
      fontSize: fontSize,
      fontFamily: fontFamily,
      fontWeight: style?.fontWeight,
      fontStyle: style?.fontStyle,
    );
  }

  ui.TextStyle _getUiTextStyle(double fontSize, String? fontFamily) {
    final baseStyle = baseTextStyle ?? editorTheme['root'];

    return ui.TextStyle(
      color: baseStyle?.color ?? editorTheme['root']?.color ?? Colors.black,
      fontSize: fontSize,
      fontFamily: fontFamily,
      fontWeight: baseStyle?.fontWeight,
      fontStyle: baseStyle?.fontStyle,
    );
  }

  /// A call while one runs joins it, leaving its own lines to the next paint.
  Future<void> preHighlightLines(
    List<int> lines,
    String Function(int) getLineText,
  ) => _pending ??= _preHighlight(
    lines,
    getLineText,
  ).whenComplete(() => _pending = null);

  Future<void> _preHighlight(
    List<int> lines,
    String Function(int) getLineText,
  ) async {
    final pending = {
      for (final line in lines)
        if (getLineText(line) case final text when !hasLineSpan(text)) text,
    }.toList();
    final chars = pending.fold(0, (sum, text) => sum + text.length);
    if (chars < _maxInlineBatchChars) {
      for (final text in pending) {
        lineSpan(text);
      }
      return;
    }
    final spans = await compute(_grammar.highlightAll, pending);
    for (final (index, text) in pending.indexed) {
      _remember(text, spans[index]);
    }
  }

  void dispose() => _spans.clear();
}

Map<String, TextStyle> _resolveTheme(Map<String, TextStyle> theme) => {
  ...theme,
  if (!theme.containsKey('tag'))
    'tag': ?(theme['selector-tag'] ?? theme['name']),
};

class _Grammar {
  _Grammar(this.language, this.theme, this.base);

  final Mode language;
  final Map<String, TextStyle> theme;
  final TextStyle? base;
  late final String _id = language.hashCode.toString();
  late final Highlight _highlight = Highlight()
    ..registerLanguage(_id, language);

  TextSpan? highlight(String lineText) {
    if (lineText.isEmpty) return null;
    try {
      final renderer = TextSpanRenderer(base, theme);
      _highlight.highlight(code: lineText, language: _id).render(renderer);
      return renderer.span;
    } catch (_) {
      return TextSpan(text: lineText, style: base);
    }
  }

  List<TextSpan?> highlightAll(List<String> lines) => [
    for (final line in lines) highlight(line),
  ];
}
