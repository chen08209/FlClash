import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

typedef PlainTextLine = ({String text, TextStyle? style});

/// Lines of text, each of one style and cut short where it would wrap,
/// stacked and aligned to the end, that measure and lay out one paragraph a
/// line.
///
/// A [Column] of [Text]s builds a second paragraph per line to answer
/// intrinsic sizes, so figures that change every second under a parent that
/// measures them, such as a list row's trailing values, cost twice that.
class PlainTextLines extends LeafRenderObjectWidget {
  final List<PlainTextLine> lines;
  final double spacing;

  const PlainTextLines(this.lines, {super.key, this.spacing = 0});

  List<TextSpan> _spansOf(BuildContext context) {
    final base = DefaultTextStyle.of(context).style;
    return [
      for (final line in lines)
        TextSpan(text: line.text, style: base.merge(line.style)),
    ];
  }

  @override
  RenderPlainTextLines createRenderObject(BuildContext context) =>
      RenderPlainTextLines(
        _spansOf(context),
        spacing: spacing,
        textDirection: Directionality.of(context),
        textScaler: MediaQuery.textScalerOf(context),
      );

  @override
  void updateRenderObject(
    BuildContext context,
    RenderPlainTextLines renderObject,
  ) {
    renderObject
      ..lines = _spansOf(context)
      ..spacing = spacing
      ..textDirection = Directionality.of(context)
      ..textScaler = MediaQuery.textScalerOf(context);
  }
}

class RenderPlainTextLines extends RenderBox {
  List<TextPainter> _painters;
  double _spacing;
  TextDirection _textDirection;
  TextScaler _textScaler;

  RenderPlainTextLines(
    List<TextSpan> lines, {
    required double spacing,
    required TextDirection textDirection,
    required TextScaler textScaler,
  }) : _spacing = spacing,
       _textDirection = textDirection,
       _textScaler = textScaler,
       _painters = [] {
    this.lines = lines;
  }

  set lines(List<TextSpan> lines) {
    if (lines.length == _painters.length) {
      var changed = false;
      for (final (index, line) in lines.indexed) {
        final painter = _painters[index];
        if (painter.text != line) {
          painter.text = line;
          changed = true;
        }
      }
      if (changed) {
        markNeedsLayout();
        markNeedsSemanticsUpdate();
      }
      return;
    }
    for (final painter in _painters) {
      painter.dispose();
    }
    _painters = [
      for (final line in lines)
        TextPainter(
          text: line,
          textDirection: _textDirection,
          textScaler: _textScaler,
          maxLines: 1,
          ellipsis: '…',
        ),
    ];
    markNeedsLayout();
    markNeedsSemanticsUpdate();
  }

  set spacing(double spacing) {
    if (spacing == _spacing) {
      return;
    }
    _spacing = spacing;
    markNeedsLayout();
  }

  set textDirection(TextDirection textDirection) {
    if (textDirection == _textDirection) {
      return;
    }
    _textDirection = textDirection;
    for (final painter in _painters) {
      painter.textDirection = textDirection;
    }
    markNeedsLayout();
  }

  set textScaler(TextScaler textScaler) {
    if (textScaler == _textScaler) {
      return;
    }
    _textScaler = textScaler;
    for (final painter in _painters) {
      painter.textScaler = textScaler;
    }
    markNeedsLayout();
  }

  Size _layout(double maxWidth) {
    var width = 0.0;
    var height = max(0.0, _spacing * (_painters.length - 1));
    for (final painter in _painters) {
      painter.layout(maxWidth: maxWidth);
      width = max(width, painter.width);
      height += painter.height;
    }
    return Size(width, height);
  }

  @override
  double computeMinIntrinsicWidth(double height) {
    _layout(double.infinity);
    return _painters.fold(
      0.0,
      (width, painter) => max(width, painter.minIntrinsicWidth),
    );
  }

  @override
  double computeMaxIntrinsicWidth(double height) =>
      _layout(double.infinity).width;

  @override
  double computeMinIntrinsicHeight(double width) => _layout(width).height;

  @override
  double computeMaxIntrinsicHeight(double width) => _layout(width).height;

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) =>
      constraints.constrain(_layout(constraints.maxWidth));

  double? _baseline(double maxWidth, TextBaseline baseline) {
    if (_painters.isEmpty) {
      return null;
    }
    _layout(maxWidth);
    return _painters.first.computeDistanceToActualBaseline(baseline);
  }

  @override
  double? computeDryBaseline(
    covariant BoxConstraints constraints,
    TextBaseline baseline,
  ) => _baseline(constraints.maxWidth, baseline);

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) =>
      _baseline(constraints.maxWidth, baseline);

  @override
  void performLayout() {
    size = constraints.constrain(_layout(constraints.maxWidth));
  }

  @visibleForTesting
  List<Offset> get debugLineOffsets => _lineOffsets().toList();

  Iterable<Offset> _lineOffsets() sync* {
    var y = 0.0;
    for (final painter in _painters) {
      yield Offset(
        _textDirection == TextDirection.ltr ? size.width - painter.width : 0,
        y,
      );
      y += painter.height + _spacing;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    _layout(constraints.maxWidth);
    for (final (index, lineOffset) in _lineOffsets().indexed) {
      _painters[index].paint(context.canvas, offset + lineOffset);
    }
  }

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    config
      ..label = _painters
          .map((painter) => painter.text!.toPlainText())
          .join('\n')
      ..textDirection = _textDirection;
  }

  @override
  void dispose() {
    for (final painter in _painters) {
      painter.dispose();
    }
    super.dispose();
  }
}
