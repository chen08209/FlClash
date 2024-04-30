import 'package:fl_clash/common/constant.dart';
import 'package:flutter/material.dart';

class SystemColorSchemes {
  SystemColorSchemes({
    ColorScheme? lightColorScheme,
    ColorScheme? darkColorScheme,
  })  : lightColorScheme = lightColorScheme ??
            ColorScheme.fromSeed(seedColor: appConstant.defaultPrimaryColor),
        darkColorScheme = darkColorScheme ??
            ColorScheme.fromSeed(
              seedColor: appConstant.defaultPrimaryColor,
              brightness: Brightness.dark,
            );
  ColorScheme lightColorScheme;
  ColorScheme darkColorScheme;

  getSystemColorSchemeForBrightness(Brightness? brightness) {
    if (brightness != null && brightness == Brightness.dark) {
      return darkColorScheme;
    }
    return lightColorScheme;
  }
}
