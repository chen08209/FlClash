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