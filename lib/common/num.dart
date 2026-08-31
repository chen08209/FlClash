import 'dart:math';

import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';

extension NumExt on num {
  String fixed({int decimals = 2}) {
    String formatted = toStringAsFixed(decimals);
    if (formatted.contains('.')) {
      formatted = formatted.replaceAll(RegExp(r'0*$'), '');
      if (formatted.endsWith('.')) {
        formatted = formatted.substring(0, formatted.length - 1);
      }
    }
    return formatted;
  }

  double get ap {
    return this * (1 + (globalState.theme.textScaleFactor - 1) * 0.5);
  }

  double get mAp {
    return this * min((1 + (globalState.theme.textScaleFactor - 1) * 0.5), 1);
  }

  TrafficShow get traffic {
    const units = TrafficUnit.values;
    var size = toDouble();
    var unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return TrafficShow(
      value: size.fixed(decimals: 1),
      unit: units[unitIndex].name,
    );
  }

  TrafficShow get shortTraffic {
    const units = TrafficUnit.values;
    var size = toDouble();
    var unitIndex = 0;
    while (size >= 1024 && unitIndex < units.length - 1) {
      size /= 1024;
      unitIndex++;
    }
    return TrafficShow(
      value: size.toStringAsFixed(0),
      unit: ' ${units[unitIndex].name}',
    );
  }
}

extension DoubleExt on double {
  bool moreOrEqual(double value) {
    return this > value || (value - this).abs() < precisionErrorTolerance;
  }
}

extension OffsetExt on Offset {
  double getCrossAxisOffset(Axis direction) {
    return direction == Axis.vertical ? dx : dy;
  }

  double getMainAxisOffset(Axis direction) {
    return direction == Axis.vertical ? dy : dx;
  }
}
