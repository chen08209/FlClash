import 'package:fl_clash/common/common.dart';
import 'package:material_ui/material_ui.dart';

typedef _TextMeasureKey = (
  String?,
  TextStyle?,
  TextStyle?,
  int?,
  TextDirection?,
  double?,
);

class Measure {
  static const _textMeasureCacheLimit = 512;

  final TextScaler _textScaler;
  final BuildContext context;
  final Map<String, dynamic> _measureMap;
  final Map<_TextMeasureKey, Size> _textSizeCache = {};
  final Map<_TextMeasureKey, bool> _textOverflowCache = {};

  Measure.of(this.context, double textScaleFactor)
    : _measureMap = {},
      _textScaler = TextScaler.linear(textScaleFactor);

  TextPainter _computeText(Text text, {TextStyle? style, double? maxWidth}) {
    return TextPainter(
      text: TextSpan(text: text.data, style: text.style ?? style),
      maxLines: text.maxLines,
      textScaler: _textScaler,
      ellipsis: '...',
      locale: Localizations.localeOf(context),
      textDirection: text.textDirection ?? TextDirection.ltr,
    )..layout(maxWidth: maxWidth ?? double.infinity);
  }

  R _measuring<R>(
    Text text,
    TextStyle? style,
    double? maxWidth,
    R Function(TextPainter painter) read,
  ) {
    final textPainter = _computeText(text, style: style, maxWidth: maxWidth);
    try {
      return read(textPainter);
    } finally {
      textPainter.dispose();
    }
  }

  _TextMeasureKey _measureKey(Text text, TextStyle? style, double? maxWidth) {
    return (
      text.data,
      text.style,
      style,
      text.maxLines,
      text.textDirection,
      maxWidth,
    );
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

  Size computeTextSize(Text text, {TextStyle? style, double? maxWidth}) {
    return _cached(
      _textSizeCache,
      _measureKey(text, style, maxWidth),
      () => _measuring(text, style, maxWidth, (painter) => painter.size),
    );
  }

  bool computeTextIsOverflow(Text text, {TextStyle? style, double? maxWidth}) {
    return _cached(
      _textOverflowCache,
      _measureKey(text, style, maxWidth),
      () => _measuring(
        text,
        style,
        maxWidth,
        (painter) => painter.didExceedMaxLines,
      ),
    );
  }

  double get bodyMediumHeight {
    return _measureMap.updateCacheValue(
      'bodyMediumHeight',
      () => computeTextSize(
        Text('X', style: context.textTheme.bodyMedium),
      ).height,
    );
  }

  double get bodyLargeHeight {
    return _measureMap.updateCacheValue(
      'bodyLargeHeight',
      () =>
          computeTextSize(Text('X', style: context.textTheme.bodyLarge)).height,
    );
  }

  double get bodySmallHeight {
    return _measureMap.updateCacheValue(
      'bodySmallHeight',
      () =>
          computeTextSize(Text('X', style: context.textTheme.bodySmall)).height,
    );
  }

  double get labelSmallHeight {
    return _measureMap.updateCacheValue(
      'labelSmallHeight',
      () => computeTextSize(
        Text('X', style: context.textTheme.labelSmall),
      ).height,
    );
  }

  double get titleSmallHeight {
    return _measureMap.updateCacheValue(
      'titleSmallHeight',
      () => computeTextSize(
        Text('X', style: context.textTheme.titleSmall),
      ).height,
    );
  }

  double get labelMediumHeight {
    return _measureMap.updateCacheValue(
      'labelMediumHeight',
      () => computeTextSize(
        Text('X', style: context.textTheme.labelMedium),
      ).height,
    );
  }

  double get titleLargeHeight {
    return _measureMap.updateCacheValue(
      'titleLargeHeight',
      () => computeTextSize(
        Text('X', style: context.textTheme.titleLarge),
      ).height,
    );
  }

  double get titleMediumHeight {
    return _measureMap.updateCacheValue(
      'titleMediumHeight',
      () => computeTextSize(
        Text('X', style: context.textTheme.titleMedium),
      ).height,
    );
  }
}
