import 'dart:math';

import 'package:flutter/widgets.dart';

abstract final class UiTextScale {
  /// Global rather than inherited: some sizes below are top-level finals.
  static double factor = 1;
}

extension AdaptiveSizeExt on num {
  double get ap => this * (1 + (UiTextScale.factor - 1) * 0.5);

  double get mAp => this * min((1 + (UiTextScale.factor - 1) * 0.5), 1);
}

final baseInfoEdgeInsets = EdgeInsets.symmetric(
  vertical: 16.mAp,
  horizontal: 16.mAp,
);
final listHeaderPadding = EdgeInsets.only(
  left: 16.mAp,
  right: 16.mAp,
  top: 24.mAp,
  bottom: 8.mAp,
);

const listRowMinHeight = 56.0;
const listRowVerticalPadding = 10.0;
const pageToolbarHeight = 72.0;
const sheetToolbarHeight = 48.0;
const sheetAppBarHeight = 68.0;

const midDuration = Duration(milliseconds: 200);
const commonDuration = Duration(milliseconds: 300);
