import 'package:flutter/material.dart';
import 'color.dart';

extension TextStyleExtension on TextStyle {
  toLight() {
    return copyWith(color: color?.toLight());
  }

  toSoftBold() {
    return copyWith(fontWeight: FontWeight.w500);
  }

  toBold() {
    return copyWith(fontWeight: FontWeight.bold);
  }
}