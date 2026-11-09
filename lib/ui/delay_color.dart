import 'package:flutter/widgets.dart';
import 'package:prism_ui/prism_ui.dart';

extension DelayColorScheme on ColorScheme {
  Color? delayColor(int? delay) {
    if (delay == null) return null;
    if (delay < 0) return error;
    if (delay < 600) return success;
    return warning;
  }
}
