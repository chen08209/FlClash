import 'package:flutter/gestures.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> rightClick(WidgetTester tester, Finder target) {
  return tester.tap(
    target,
    buttons: kSecondaryButton,
    kind: PointerDeviceKind.mouse,
  );
}
