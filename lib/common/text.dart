import 'package:flutter/material.dart';
import 'color.dart';

extension TextStyleExtension on TextStyle {
  TextStyle get toLight => copyWith(color: color?.toLight());

  TextStyle get toLighter => copyWith(color: color?.toLighter());

  TextStyle get toSoftBold => copyWith(fontWeight: FontWeight.w500);

  TextStyle get toBold => copyWith(fontWeight: FontWeight.bold);

  TextStyle get toMinus => copyWith(fontSize: fontSize! - 2);
}
