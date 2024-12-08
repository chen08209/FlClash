import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

extension NumExt on num {
  String fixed({digit = 2}) {
    return toStringAsFixed(truncateToDouble() == this ? 0 : digit);
  }
}

extension DoubleExt on double {
  moreOrEqual(double value) {
    return this > value || (value - this).abs() < precisionErrorTolerance + 1;
  }
}

extension OffsetExt on Offset {
  double getCrossAxisOffset(Axis direction) {
    return direction == Axis.vertical ? dx : dy;
  }

  double getMainAxisOffset(Axis direction) {
    return direction == Axis.vertical ? dy : dx;
  }

  bool less(Offset offset) {
    if (dy < offset.dy) {
      return true;
    }
    if (dy == offset.dy && dx < offset.dx) {
      return true;
    }
    return false;
  }
}

extension RectExt on Rect {
  doRectIntersect(Rect rect) {
    return left < rect.right &&
        right > rect.left &&
        top < rect.bottom &&
        bottom > rect.top;
  }
}
