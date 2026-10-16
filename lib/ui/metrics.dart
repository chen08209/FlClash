import 'dart:math';

import 'package:flutter/widgets.dart';

extension AdaptiveSizeExt on num {
  double ap(BuildContext context) => this * _adaptiveScaleOf(context);

  double mAp(BuildContext context) => this * min(_adaptiveScaleOf(context), 1);
}

double _adaptiveScaleOf(BuildContext context) =>
    1 + (MediaQuery.textScalerOf(context).scale(1) - 1) * 0.5;

EdgeInsets baseInfoEdgeInsetsOf(BuildContext context) =>
    EdgeInsets.all(16.mAp(context));

EdgeInsets listHeaderPaddingOf(BuildContext context) =>
    const EdgeInsets.only(left: 16, right: 16, top: 24, bottom: 8) *
    1.mAp(context);

const listRowMinHeight = 56.0;
const listRowVerticalPadding = 10.0;
const pageToolbarHeight = 72.0;
const sheetToolbarHeight = 48.0;
const sheetAppBarHeight = 68.0;

const midDuration = Duration(milliseconds: 200);
const commonDuration = Duration(milliseconds: 300);
