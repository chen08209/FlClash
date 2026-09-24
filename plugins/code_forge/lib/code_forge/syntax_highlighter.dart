import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:re_highlight/re_highlight.dart';

class _HighlightedLine {
  final String text;
  final TextSpan? span;
  final int version;

  _HighlightedLine(this.text, this.span, this.version);
}

class _SpanData {
  final String text;
  final String? scope;
  final List<_SpanData> children;

  _SpanData(this.text, this.scope, [this.children = const []]);
}

class SyntaxHighlighter {
  final Mode language;
  final Map<String, TextStyle> editorTheme;
  final TextStyle? baseTextStyle;
  final Map<int, _HighlightedLine> _grammarCache = {}, _mergedCache = {};
  final Map<String, TextSpan?> _lineSpanCache = {};
  late final String _langId;
  late final Highlight _highlight;
  late final Map<String, TextStyle> _resolvedTheme;
  static const int _cacheKeepMargin = 500;
  static const int _maxLineCacheEntries = 6000;
  static const int _maxSpanCacheEntries = 8000;
  int get documentVersion => _documentVersion;
  Future<void>? _preHighlightInFlight;
  int _preHighlightInFlightVersion = -1, _version = 0, _documentVersion = 0;

  SyntaxHighlighter({
    required this.language,
    required this.editorTheme,
    this.baseTextStyle,
  }) {
    _langId = language.hashCode.toString();
    _resolvedTheme = _buildResolvedTheme(editorTheme);
    _highlight = Highlight();
    _highlight.registerLanguage(_langId, language);
  }

  void applyDocumentEdit(int editLine) {
    _documentVersion++;
    _grammarCache.removeWhere((line, _) => line >= editLine);
    _mergedCache.removeWhere((line, _) => line >= editLine);
    _version++;
  }

  void invalidateAll() {
    _grammarCache.clear();
    _mergedCache.clear();
    _documentVersion++;
    _version++;
  }

  void invalidateLines(Set<int> lines) {
    for (final line in lines) {
      _grammarCache.remove(line);
      _mergedCache.remove(line);
    }
    _version++;
  }

  TextSpan? getLineSpan(int lineIndex, String lineText) {
    final mergedCache = _mergedCache[lineIndex];
    if (mergedCache != null &&
        mergedCache.version == _version &&
        mergedCache.text == lineText) {
      return mergedCache.span;
    }

    final grammarCache = _grammarCache[lineIndex];
    final cachedGrammarSpan =
        grammarCache != null &&
            grammarCache.version == _version &&
            grammarCache.text == lineText
        ? grammarCache.span
        : null;

    if (_lineSpanCache.containsKey(lineText)) {
      return _lineSpanCache[lineText];
    }
    if (cachedGrammarSpan != null) {
      _lineSpanCache[lineText] = cachedGrammarSpan;
      return cachedGrammarSpan;
    }

    final grammarSpan = _highlightLine(lineText);
    _lineSpanCache[lineText] = grammarSpan;
    _mergedCache[lineIndex] = _HighlightedLine(lineText, grammarSpan, _version);
    return grammarSpan;
  }

  /// Returns whether a highlighted span is already available without doing
  /// syntax parsing.  Rendering must use this on a scroll frame: parsing a
  /// newly visible group of lines in [paint] blocks the UI isolate.
  bool hasCachedLineSpan(int lineIndex, String lineText) {
    final mergedCache = _mergedCache[lineIndex];
    if (mergedCache != null &&
        mergedCache.version == _version &&
        mergedCache.text == lineText) {
      return true;
    }

    final grammarCache = _grammarCache[lineIndex];
    final hasGrammar =
        grammarCache != null &&
        grammarCache.version == _version &&
        grammarCache.text == lineText;
    return hasGrammar || _lineSpanCache.containsKey(lineText);
  }

  /// Obtains a cached span only. Unlike [getLineSpan], this never invokes
  /// `re_highlight`, so it is safe to call from a render object's paint pass.
  TextSpan? getCachedLineSpan(int lineIndex, String lineText) {
    final mergedCache = _mergedCache[lineIndex];
    if (mergedCache != null &&
        mergedCache.version == _version &&
        mergedCache.text == lineText) {
      return mergedCache.span;
    }

    final grammarCache = _grammarCache[lineIndex];
    final hasGrammar =
        grammarCache != null &&
        grammarCache.version == _version &&
        grammarCache.text == lineText;
    if (hasGrammar) return grammarCache.span;

    return _lineSpanCache[lineText];
  }

  TextSpan? _highlightLine(String lineText) {
    if (lineText.isEmpty) return null;

    try {
      final result = _highlight.highlight(code: lineText, language: _langId);
      final renderer = TextSpanRenderer(baseTextStyle, _resolvedTheme);
      result.render(renderer);
      return renderer.span;
    } catch (e) {
      return TextSpan(text: lineText, style: baseTextStyle);
    }
  }

  ui.Paragraph buildHighlightedParagraph(
    int lineIndex,
    String lineText,
    ui.ParagraphStyle paragraphStyle,
    double fontSize,
    String? fontFamily, {
    double? width,
    bool allowSynchronousHighlight = true,
  }) {
    final span = allowSynchronousHighlight
        ? getLineSpan(lineIndex, lineText)
        : getCachedLineSpan(lineIndex, lineText);
    final builder = ui.ParagraphBuilder(paragraphStyle);

    if (span == null || lineText.isEmpty) {
      final style = _getUiTextStyle(fontSize, fontFamily);
      builder.pushStyle(style);
      builder.addText(lineText.isEmpty ? ' ' : lineText);
      final p = builder.build();
      p.layout(ui.ParagraphConstraints(width: width ?? double.infinity));
      return p;
    }

    _addTextSpanToBuilder(builder, span, fontSize, fontFamily);

    final p = builder.build();
    p.layout(ui.ParagraphConstraints(width: width ?? double.infinity));
    return p;
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

  Future<void> preHighlightLines(
    int startLine,
    int endLine,
    String Function(int) getLineText,
  ) async {
    if (_preHighlightInFlight != null &&
        _preHighlightInFlightVersion == _version) {
      return _preHighlightInFlight;
    }

    final requestVersion = _version;
    _preHighlightInFlightVersion = requestVersion;
    final future = _preHighlightLinesInternal(
      startLine,
      endLine,
      getLineText,
      requestVersion,
    );
    _preHighlightInFlight = future;

    try {
      await future;
    } finally {
      if (identical(_preHighlightInFlight, future)) {
        _preHighlightInFlight = null;
        _preHighlightInFlightVersion = -1;
      }
    }
  }

  Future<void> _preHighlightLinesInternal(
    int startLine,
    int endLine,
    String Function(int) getLineText,
    int requestVersion,
  ) async {
    _pruneCachesForViewport(startLine, endLine);

    final linesToProcess = <int, String>{};

    for (int i = startLine; i <= endLine; i++) {
      final lineText = getLineText(i);
      final cached = _grammarCache[i];
      if ((cached == null ||
              cached.text != lineText ||
              cached.version != _version) &&
          !_lineSpanCache.containsKey(lineText)) {
        linesToProcess[i] = lineText;
      }
    }

    if (linesToProcess.isEmpty) return;

    final totalChars = linesToProcess.values.fold<int>(
      0,
      (sum, line) => sum + line.length,
    );
    if (totalChars < 2000) {
      if (requestVersion != _version) return;
      for (final entry in linesToProcess.entries) {
        if (requestVersion != _version) return;
        final span = _lineSpanCache[entry.value] = _highlightLine(entry.value);
        _grammarCache[entry.key] = _HighlightedLine(
          entry.value,
          span,
          _version,
        );
      }
      return;
    }

    final results = await compute(
      _highlightLinesInBackground,
      _BackgroundHighlightData(
        langId: _langId,
        lines: linesToProcess,
        languageMode: language,
        theme: _resolvedTheme,
        baseStyle: baseTextStyle,
      ),
    );

    for (final entry in results.entries) {
      final spanData = entry.value;
      final textSpan = spanData != null ? _spanDataToTextSpan(spanData) : null;
      final lineText = linesToProcess[entry.key]!;
      _lineSpanCache[lineText] = textSpan;
      if (requestVersion != _version) continue;
      _grammarCache[entry.key] = _HighlightedLine(
        lineText,
        textSpan,
        requestVersion,
      );
    }

    _pruneCachesForViewport(startLine, endLine);
  }

  void _pruneCachesForViewport(int startLine, int endLine) {
    final minKeep = (startLine - _cacheKeepMargin).clamp(0, 1 << 30);
    final maxKeep = endLine + _cacheKeepMargin;

    if (_grammarCache.length > _maxLineCacheEntries) {
      _grammarCache.removeWhere((line, _) => line < minKeep || line > maxKeep);
    }

    if (_mergedCache.length > _maxLineCacheEntries) {
      _mergedCache.removeWhere((line, _) => line < minKeep || line > maxKeep);
    }

    if (_lineSpanCache.length > _maxSpanCacheEntries) {
      _lineSpanCache.clear();
    }
  }

  TextSpan? _spanDataToTextSpan(_SpanData? data, {TextStyle? inheritedStyle}) {
    if (data == null) return null;

    final style = data.scope != null
        ? (_resolvedTheme[data.scope] ?? inheritedStyle ?? baseTextStyle)
        : (inheritedStyle ?? baseTextStyle);

    if (data.children.isEmpty) {
      return TextSpan(text: data.text, style: style);
    }

    return TextSpan(
      text: data.text.isEmpty ? null : data.text,
      style: style,
      children: data.children
          .map((c) => _spanDataToTextSpan(c, inheritedStyle: style)!)
          .toList(),
    );
  }

  Map<String, TextStyle> _buildResolvedTheme(Map<String, TextStyle> theme) {
    final resolved = Map<String, TextStyle>.from(theme);

    if (!resolved.containsKey('tag')) {
      final fallbackTagStyle = resolved['selector-tag'] ?? resolved['name'];
      if (fallbackTagStyle != null) {
        resolved['tag'] = fallbackTagStyle;
      }
    }

    return resolved;
  }

  void dispose() {
    _grammarCache.clear();
    _mergedCache.clear();
    _lineSpanCache.clear();
  }
}

class _BackgroundHighlightData {
  final String langId;
  final Map<int, String> lines;
  final Mode languageMode;
  final Map<String, TextStyle> theme;
  final TextStyle? baseStyle;

  _BackgroundHighlightData({
    required this.langId,
    required this.lines,
    required this.languageMode,
    required this.theme,
    this.baseStyle,
  });
}

Map<int, _SpanData?> _highlightLinesInBackground(
  _BackgroundHighlightData data,
) {
  final highlight = Highlight();
  highlight.registerLanguage(data.langId, data.languageMode);

  final results = <int, _SpanData?>{};

  for (final entry in data.lines.entries) {
    final lineIndex = entry.key;
    final lineText = entry.value;

    if (lineText.isEmpty) {
      results[lineIndex] = null;
      continue;
    }

    try {
      final result = highlight.highlight(code: lineText, language: data.langId);
      final renderer = _ScopeSpanRenderer();
      result.render(renderer);
      results[lineIndex] = renderer.span;
    } catch (e) {
      results[lineIndex] = _SpanData(lineText, null);
    }
  }

  return results;
}

class _ScopeSpanRenderer implements HighlightRenderer {
  final List<_SpanData> _stack = [];
  final List<_SpanData> _results = [];

  @override
  void openNode(DataNode node) => _stack.add(_SpanData('', node.scope));

  @override
  void addText(String text) {
    final span = _SpanData(text, _stack.isEmpty ? null : _stack.last.scope);
    if (_stack.isEmpty) {
      _results.add(span);
      return;
    }
    final parent = _stack.removeLast();
    _stack.add(
      _SpanData(parent.text, parent.scope, [...parent.children, span]),
    );
  }

  @override
  void closeNode(DataNode node) {
    final span = _stack.removeLast();
    if (_stack.isEmpty) {
      _results.add(span);
      return;
    }
    final parent = _stack.removeLast();
    _stack.add(
      _SpanData(parent.text, parent.scope, [...parent.children, span]),
    );
  }

  _SpanData? get span {
    if (_results.isEmpty) return null;
    if (_results.length == 1) return _results.first;
    return _SpanData('', null, _results);
  }
}
