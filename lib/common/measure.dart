import 'package:fl_clash/common/common.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Measure {
  final TextScaler _textScale;
  late BuildContext context;

  Measure.of(this.context)
      : _textScale = TextScaler.linear(
          WidgetsBinding.instance.platformDispatcher.textScaleFactor,
        );

  Size computeTextSize(
    Text text, {
    double maxWidth = double.infinity,
  }) {
    final textPainter = TextPainter(
      text: TextSpan(text: text.data, style: text.style),
      maxLines: text.maxLines,
      textScaler: _textScale,
      textDirection: text.textDirection ?? TextDirection.ltr,
    )..layout(
        maxWidth: maxWidth,
      );
    return textPainter.size;
  }

  double? _bodyMediumHeight;
  Size? _bodyLargeSize;
  double? _bodySmallHeight;
  double? _labelSmallHeight;
  double? _labelMediumHeight;
  double? _titleLargeHeight;
  double? _titleMediumHeight;

  double get bodyMediumHeight {
    _bodyMediumHeight ??= computeTextSize(
      Text(
        "X",
        style: context.textTheme.bodyMedium,
      ),
    ).height;
    return _bodyMediumHeight!;
  }

  Size get bodyLargeSize {
    _bodyLargeSize ??= computeTextSize(
      Text(
        "X",
        style: context.textTheme.bodyLarge,
      ),
    );
    return _bodyLargeSize!;
  }

  double get bodySmallHeight {
    _bodySmallHeight ??= computeTextSize(
      Text(
        "X",
        style: context.textTheme.bodySmall,
      ),
    ).height;
    return _bodySmallHeight!;
  }

  double get labelSmallHeight {
    _labelSmallHeight ??= computeTextSize(
      Text(
        "X",
        style: context.textTheme.labelSmall,
      ),
    ).height;
    return _labelSmallHeight!;
  }

  double get labelMediumHeight {
    _labelMediumHeight ??= computeTextSize(
      Text(
        "X",
        style: context.textTheme.labelMedium,
      ),
    ).height;
    return _labelMediumHeight!;
  }

  double get titleLargeHeight {
    _titleLargeHeight ??= computeTextSize(
      Text(
        "X",
        style: context.textTheme.titleLarge,
      ),
    ).height;
    return _titleLargeHeight!;
  }

  double get titleMediumHeight {
    _titleMediumHeight ??= computeTextSize(
      Text(
        "X",
        style: context.textTheme.titleMedium,
      ),
    ).height;
    return _titleMediumHeight!;
  }
}
