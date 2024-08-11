import 'package:flutter/material.dart';

extension ColorExtension on Color {
  toLight() {
    return withOpacity(0.6);
  }

  toLighter() {
    return withOpacity(0.4);
  }

  toSoft() {
    return withOpacity(0.12);
  }

  toLittle() {
    return withOpacity(0.03);
  }

  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}

extension ColorSchemeExtension on ColorScheme {
  ColorScheme toPrueBlack(bool isPrueBlack) => isPrueBlack
      ? copyWith(
          surface: Colors.black,
          surfaceContainer: surfaceContainer.darken(0.05),
        )
      : this;
}
