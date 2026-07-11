import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('GlobalState exposes a fallback accent color before plugin startup', () {
    expect(GlobalState().accentColor, const Color(defaultPrimaryColor));
  });
}
