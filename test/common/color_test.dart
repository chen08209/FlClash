import 'package:fl_clash/common/color.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('opacity extensions use their named alpha values', () {
    const color = Colors.blue;
    const tolerance = 0.0001;

    expect(color.opacity80.a, closeTo(0.8, tolerance));
    expect(color.opacity50.a, closeTo(0.5, tolerance));
    expect(color.opacity10.a, closeTo(0.1, tolerance));
    expect(color.opacity3.a, closeTo(0.03, tolerance));
    expect(color.opacity0.a, 0);
  });
}
