import 'dart:ui';

import 'package:fl_clash/common/common.dart';
import 'package:flutter/material.dart';

class BaseScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.stylus,
        PointerDeviceKind.invertedStylus,
        PointerDeviceKind.trackpad,
        if (system.isDesktop) PointerDeviceKind.mouse,
        PointerDeviceKind.unknown,
      };
}
