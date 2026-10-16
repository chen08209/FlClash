import 'dart:math';

import 'package:fl_clash/ui/metrics.dart';
import 'package:fl_clash/ui/typography.dart';
import 'package:material_ui/material_ui.dart';

typedef _TextMeasureKey = (String?, TextStyle?, int?, TextDirection?, double?);

class Measure {
  static const _textMeasureCacheLimit = 512;

  final TextScaler _textScaler;
  final BuildContext context;
  final Map<_TextMeasureKey, Size> _textSizeCache = {};
  final Map<_TextMeasureKey, bool> _textOverflowCache = {};

  Measure.of(this.context, double textScaleFactor)
    : _textScaler = TextScaler.linear(textScaleFactor);

  TextPainter _computeText(Text text, {double? maxWidth}) {
    return TextPainter(
      text: TextSpan(text: text.data, style: text.style),
      maxLines: text.maxLines,
      textScaler: _textScaler,
      ellipsis: '...',
      locale: Localizations.localeOf(context),
      textDirection: text.textDirection ?? TextDirection.ltr,
    )..layout(maxWidth: maxWidth ?? double.infinity);
  }

  R _measuring<R>(
    Text text,
    double? maxWidth,
    R Function(TextPainter painter) read,
  ) {
    final textPainter = _computeText(text, maxWidth: maxWidth);
    try {
      return read(textPainter);
    } finally {
      textPainter.dispose();
    }
  }

  _TextMeasureKey _measureKey(Text text, double? maxWidth) {
    return (text.data, text.style, text.maxLines, text.textDirection, maxWidth);
  }

  R _cached<R extends Object>(
    Map<_TextMeasureKey, R> cache,
    _TextMeasureKey key,
    R Function() compute,
  ) {
    final cachedValue = cache[key];
    if (cachedValue != null) {
      return cachedValue;
    }
    if (cache.length >= _textMeasureCacheLimit) {
      cache.clear();
    }
    return cache[key] = compute();
  }

  Size computeTextSize(Text text) {
    return _cached(
      _textSizeCache,
      _measureKey(text, null),
      () => _measuring(text, null, (painter) => painter.size),
    );
  }

  bool computeTextIsOverflow(Text text, {double? maxWidth}) {
    return _cached(
      _textOverflowCache,
      _measureKey(text, maxWidth),
      () => _measuring(text, maxWidth, (painter) => painter.didExceedMaxLines),
    );
  }

  final Map<AppTextStyle, double> _textHeights = {};

  double textHeight(AppTextStyle style) => _textHeights[style] ??=
      computeTextSize(Text('X', style: style.of(context))).height;

  double get listTitleHeight => textHeight(AppTextStyle.body);

  double get listSubtitleHeight => textHeight(AppTextStyle.subheadline);

  double get cardHeaderHeight => textHeight(AppTextStyle.headline);

  double get listRowHeight =>
      max(listRowMinHeight, listTitleHeight + 2 * listRowVerticalPadding);

  double get listTwoLineRowHeight => max(
    listRowMinHeight,
    listTitleHeight + listSubtitleHeight + 2 * listRowVerticalPadding,
  );
}

class MeasureScope extends InheritedWidget {
  const MeasureScope({super.key, required this.measure, required super.child});

  final Measure measure;

  static Measure of(BuildContext context, {bool listen = true}) {
    final scope = listen
        ? context.dependOnInheritedWidgetOfExactType<MeasureScope>()
        : context.getInheritedWidgetOfExactType<MeasureScope>();
    assert(scope != null, 'No MeasureScope found above $context.');
    return scope!.measure;
  }

  @override
  bool updateShouldNotify(MeasureScope oldWidget) =>
      measure != oldWidget.measure;
}
