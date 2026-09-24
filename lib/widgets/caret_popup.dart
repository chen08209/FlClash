import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Opens a popup below the caret line when it fits there or that side has
/// more room, and above it otherwise, measuring the popup rather than
/// estimating its height. The popup stays inside the area it is laid over.
class CaretPopupLayout extends SingleChildLayoutDelegate {
  final Rect caretRect;
  final double maxWidth;
  final double maxHeight;
  final double gap;
  final double margin;

  const CaretPopupLayout({
    required this.caretRect,
    this.maxWidth = 400,
    this.maxHeight = 400,
    this.gap = 4,
    this.margin = 8,
  });

  double get _below => caretRect.bottom + gap;

  double get _above => caretRect.top - gap;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final room = math.max(
      constraints.maxHeight - margin - _below,
      _above - margin,
    );
    return BoxConstraints(
      maxWidth: math.min(
        maxWidth,
        math.max(0.0, constraints.maxWidth - margin * 2),
      ),
      maxHeight: room.clamp(0.0, maxHeight),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final spaceBelow = size.height - margin - _below;
    final spaceAbove = _above - margin;
    final opensBelow =
        childSize.height <= spaceBelow || spaceBelow >= spaceAbove;
    final top = opensBelow ? _below : _above - childSize.height;
    return Offset(
      _clampInto(caretRect.left, childSize.width, size.width),
      _clampInto(top, childSize.height, size.height),
    );
  }

  double _clampInto(double start, double extent, double available) =>
      start.clamp(margin, math.max(margin, available - margin - extent));

  @override
  bool shouldRelayout(CaretPopupLayout oldDelegate) {
    return caretRect != oldDelegate.caretRect ||
        maxWidth != oldDelegate.maxWidth ||
        maxHeight != oldDelegate.maxHeight ||
        gap != oldDelegate.gap ||
        margin != oldDelegate.margin;
  }
}
