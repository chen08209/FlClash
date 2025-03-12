import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/material.dart';
import 'color.dart';

extension TextStyleExtension on TextStyle {
  TextStyle get toLight => copyWith(color: color?.opacity80);

  TextStyle get toLighter => copyWith(color: color?.opacity60);

  TextStyle get toSoftBold => copyWith(fontWeight: FontWeight.w500);

  TextStyle get toBold => copyWith(fontWeight: FontWeight.bold);

  TextStyle get toJetBrainsMono => copyWith(
        fontFamily: FontFamily.jetBrainsMono.value,
      );

  TextStyle adjustSize(int size) => copyWith(
        fontSize: fontSize! + size,
      );
}
