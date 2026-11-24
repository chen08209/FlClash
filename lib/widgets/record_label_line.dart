import 'dart:math';

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

const _gap = 4.0;

/// Lets the labels' fills clear the line of text above them.
const recordLabelLineGap = 4.0;

/// A line of one [text], a long value or a kind, and [labels] after it at
/// their own widths. The text gives way first, then the last label within
/// itself; the labels before it never shrink.
class RecordLabelLine extends StatelessWidget {
  final String text;
  final List<Widget> labels;

  final bool underTitle;

  const RecordLabelLine({
    super.key,
    this.text = '',
    this.labels = const [],
    this.underTitle = false,
  });

  @override
  Widget build(BuildContext context) {
    final line = _LabelLine(
      leadsWithText: text.isNotEmpty,
      children: [
        if (text.isNotEmpty)
          Text(text, maxLines: 1, overflow: TextOverflow.ellipsis),
        ...labels,
      ],
    );
    if (!underTitle || labels.isEmpty) {
      return line;
    }
    return Padding(
      padding: const EdgeInsets.only(top: recordLabelLineGap),
      child: line,
    );
  }
}

class _LabelLine extends MultiChildRenderObjectWidget {
  final bool leadsWithText;

  const _LabelLine({required this.leadsWithText, required super.children});

  @override
  _RenderLabelLine createRenderObject(BuildContext context) => _RenderLabelLine(
    leadsWithText: leadsWithText,
    textDirection: Directionality.of(context),
  );

  @override
  void updateRenderObject(BuildContext context, _RenderLabelLine renderObject) {
    renderObject
      ..leadsWithText = leadsWithText
      ..textDirection = Directionality.of(context);
  }
}

class _LineParentData extends ContainerBoxParentData<RenderBox> {
  bool shown = true;
}

/// Whether a part of a record line shows, which a test reads as the line's
/// parts are all in the tree.
@visibleForTesting
bool recordLinePartShown(RenderObject part) => switch (part.parentData) {
  _LineParentData(:final shown) => shown,
  _ => true,
};

typedef _LineMeasure = ({
  double width,
  double height,
  bool textShown,
  bool lastShown,
  RenderBox? lead,
  BoxConstraints? leadConstraints,
});

class _RenderLabelLine extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, _LineParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, _LineParentData> {
  _RenderLabelLine({
    required bool leadsWithText,
    required TextDirection textDirection,
  }) : _leadsWithText = leadsWithText,
       _textDirection = textDirection;

  bool _leadsWithText;

  set leadsWithText(bool value) {
    if (_leadsWithText != value) {
      _leadsWithText = value;
      markNeedsLayout();
    }
  }

  TextDirection _textDirection;

  set textDirection(TextDirection value) {
    if (_textDirection != value) {
      _textDirection = value;
      markNeedsLayout();
    }
  }

  bool _overflows = false;
  final _clipLayer = LayerHandle<ClipRectLayer>();
  BoxConstraints? _dryConstraints;
  _LineMeasure? _dryMeasure;

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! _LineParentData) {
      child.parentData = _LineParentData();
    }
  }

  @override
  void markNeedsLayout() {
    _dryMeasure = null;
    super.markNeedsLayout();
  }

  RenderBox? get _text => _leadsWithText ? firstChild : null;

  /// A part cut to narrower than twice its height would show little more
  /// than an ellipsis, so it goes; one that fits whole stays however narrow.
  static bool _shows(RenderBox part, Size size, double room) =>
      room >= 2 * size.height ||
      part.getMaxIntrinsicWidth(double.infinity) <= room;

  _LineMeasure _measure(BoxConstraints constraints, ChildLayouter layoutChild) {
    final loose = BoxConstraints(maxHeight: constraints.maxHeight);
    final room = constraints.maxWidth;
    final text = _text;
    var height = 0.0;
    var labelsWidth = 0.0;
    var labelShown = false;
    var lastShown = true;
    RenderBox? firstLabel;
    BoxConstraints? firstLabelConstraints;
    var label = text == null ? firstChild : childAfter(text);
    while (label != null) {
      final next = childAfter(label);
      final labelConstraints = next == null
          ? loose.copyWith(maxWidth: max(0.0, room - labelsWidth))
          : loose;
      final size = layoutChild(label, labelConstraints);
      height = max(height, size.height);
      if (next == null) {
        lastShown = _shows(label, size, room - labelsWidth);
      }
      if (next != null || lastShown) {
        labelsWidth += size.width + _gap;
        labelShown = true;
      }
      if (firstLabel == null) {
        firstLabel = label;
        firstLabelConstraints = labelConstraints;
      }
      label = next;
    }
    var width = max(0.0, labelsWidth - _gap);
    var textShown = false;
    BoxConstraints? textConstraints;
    if (text != null) {
      final textRoom = room - labelsWidth;
      textConstraints = loose.copyWith(maxWidth: max(0.0, textRoom));
      final size = layoutChild(text, textConstraints);
      height = max(height, size.height);
      textShown = _shows(text, size, textRoom);
      if (textShown) {
        width = size.width + labelsWidth;
      }
    }
    final leadsWithLabel = firstLabel != null && labelShown;
    return (
      width: width,
      height: height,
      textShown: textShown,
      lastShown: lastShown,
      lead: textShown ? text : (leadsWithLabel ? firstLabel : null),
      leadConstraints: textShown
          ? textConstraints
          : (leadsWithLabel ? firstLabelConstraints : null),
    );
  }

  _LineMeasure _dryMeasureOf(BoxConstraints constraints) {
    if (_dryMeasure == null || _dryConstraints != constraints) {
      _dryMeasure = _measure(constraints, ChildLayoutHelper.dryLayoutChild);
      _dryConstraints = constraints;
    }
    return _dryMeasure!;
  }

  @override
  Size computeDryLayout(covariant BoxConstraints constraints) {
    final line = _dryMeasureOf(constraints);
    return constraints.constrain(Size(line.width, line.height));
  }

  @override
  void performLayout() {
    final line = _measure(constraints, ChildLayoutHelper.layoutChild);
    size = constraints.constrain(Size(line.width, line.height));
    _overflows = line.width > size.width;
    final text = _text;
    var start = 0.0;
    var shownChanged = false;
    var child = firstChild;
    while (child != null) {
      final parentData = child.parentData! as _LineParentData;
      final childSize = child.size;
      final shown = child == text
          ? line.textShown
          : child != lastChild || line.lastShown;
      shownChanged |= shown != parentData.shown;
      parentData
        ..shown = shown
        ..offset = Offset(
          _textDirection == TextDirection.rtl
              ? size.width - start - childSize.width
              : start,
          (size.height - childSize.height) / 2,
        );
      if (parentData.shown) {
        start += childSize.width + _gap;
      }
      child = parentData.nextSibling;
    }
    if (shownChanged) {
      markNeedsSemanticsUpdate();
    }
  }

  @override
  double? computeDistanceToActualBaseline(TextBaseline baseline) {
    var child = firstChild;
    while (child != null) {
      final parentData = child.parentData! as _LineParentData;
      if (parentData.shown) {
        return switch (child.getDistanceToActualBaseline(baseline)) {
          null => null,
          final distance => distance + parentData.offset.dy,
        };
      }
      child = parentData.nextSibling;
    }
    return null;
  }

  @override
  double? computeDryBaseline(
    covariant BoxConstraints constraints,
    TextBaseline baseline,
  ) {
    final line = _dryMeasureOf(constraints);
    final lead = line.lead;
    final leadConstraints = line.leadConstraints;
    if (lead == null || leadConstraints == null) {
      return null;
    }
    final height = constraints.constrain(Size(line.width, line.height)).height;
    final leadHeight = lead.getDryLayout(leadConstraints).height;
    return switch (lead.getDryBaseline(leadConstraints, baseline)) {
      null => null,
      final distance => distance + (height - leadHeight) / 2,
    };
  }

  @override
  double computeMinIntrinsicWidth(double height) => 0;

  @override
  double computeMaxIntrinsicWidth(double height) {
    var width = -_gap;
    var child = firstChild;
    while (child != null) {
      width += child.getMaxIntrinsicWidth(height) + _gap;
      child = childAfter(child);
    }
    return max(0, width);
  }

  double _tallest(double Function(RenderBox child) heightOf) {
    var tallest = 0.0;
    var child = firstChild;
    while (child != null) {
      tallest = max(tallest, heightOf(child));
      child = childAfter(child);
    }
    return tallest;
  }

  @override
  double computeMinIntrinsicHeight(double width) =>
      _tallest((child) => child.getMinIntrinsicHeight(double.infinity));

  @override
  double computeMaxIntrinsicHeight(double width) =>
      _tallest((child) => child.getMaxIntrinsicHeight(double.infinity));

  void _paintShown(PaintingContext context, Offset offset) {
    var child = firstChild;
    while (child != null) {
      final parentData = child.parentData! as _LineParentData;
      if (parentData.shown) {
        context.paintChild(child, parentData.offset + offset);
      }
      child = parentData.nextSibling;
    }
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    if (!_overflows) {
      _clipLayer.layer = null;
      _paintShown(context, offset);
      return;
    }
    _clipLayer.layer = context.pushClipRect(
      needsCompositing,
      offset,
      Offset.zero & size,
      _paintShown,
      oldLayer: _clipLayer.layer,
    );
  }

  @override
  void visitChildrenForSemantics(RenderObjectVisitor visitor) {
    var child = firstChild;
    while (child != null) {
      final parentData = child.parentData! as _LineParentData;
      if (parentData.shown) {
        visitor(child);
      }
      child = parentData.nextSibling;
    }
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    var child = lastChild;
    while (child != null) {
      final parentData = child.parentData! as _LineParentData;
      if (parentData.shown &&
          result.addWithPaintOffset(
            offset: parentData.offset,
            position: position,
            hitTest: (result, transformed) =>
                child!.hitTest(result, position: transformed),
          )) {
        return true;
      }
      child = parentData.previousSibling;
    }
    return false;
  }

  @override
  void dispose() {
    _clipLayer.layer = null;
    super.dispose();
  }
}
