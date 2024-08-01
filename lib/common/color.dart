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
}

extension ColorSchemeExtension on ColorScheme {
  ColorScheme toPrueBlack(bool isPrueBlack) => isPrueBlack
      ? copyWith(
          surface: Colors.black,
          background: Colors.black,
        )
      : this;
}
