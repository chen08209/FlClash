import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

/// Opens a popup below the caret line when it fits there or that side has
/// more room, and above it otherwise, measuring the popup rather than
/// estimating its height, inside the area it is laid over less [padding].
class CaretPopupLayout extends SingleChildLayoutDelegate {
  final Rect caretRect;
  final EdgeInsets padding;
  final double maxWidth;
  final double maxHeight;
  final double gap;
  final double margin;

  const CaretPopupLayout({
    required this.caretRect,
    this.padding = EdgeInsets.zero,
    this.maxWidth = 400,
    this.maxHeight = 400,
    this.gap = 4,
    this.margin = 8,
  });

  double get _below => caretRect.bottom + gap;

  double get _above => caretRect.top - gap;

  double get _top => padding.top + margin;

  double _bottom(double height) => height - padding.bottom - margin;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) {
    final room = math.max(
      _bottom(constraints.maxHeight) - _below,
      _above - _top,
    );
    return BoxConstraints(
      maxWidth: math.min(
        maxWidth,
        math.max(0.0, constraints.maxWidth - padding.horizontal - margin * 2),
      ),
      maxHeight: room.clamp(0.0, maxHeight),
    );
  }

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final spaceBelow = _bottom(size.height) - _below;
    final spaceAbove = _above - _top;
    final opensBelow =
        childSize.height <= spaceBelow || spaceBelow >= spaceAbove;
    final top = opensBelow ? _below : _above - childSize.height;
    return Offset(
      _clampInto(
        caretRect.left,
        childSize.width,
        padding.left + margin,
        size.width - padding.right - margin,
      ),
      _clampInto(top, childSize.height, _top, _bottom(size.height)),
    );
  }

  double _clampInto(double start, double extent, double min, double max) =>
      start.clamp(min, math.max(min, max - extent));

  @override
  bool shouldRelayout(CaretPopupLayout oldDelegate) {
    return caretRect != oldDelegate.caretRect ||
        padding != oldDelegate.padding ||
        maxWidth != oldDelegate.maxWidth ||
        maxHeight != oldDelegate.maxHeight ||
        gap != oldDelegate.gap ||
        margin != oldDelegate.margin;
  }
}
