import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_ui/prism_ui.dart';

/// How often a [T] rebuilds while a page covers [target] and leaves again.
Future<int> rebuildsWhileCovered<T extends Widget>(
  WidgetTester tester,
  Finder target,
) async {
  var rebuilds = 0;
  debugOnRebuildDirtyWidget = (element, _) {
    if (element.widget is T) {
      rebuilds++;
    }
  };
  addTearDown(() => debugOnRebuildDirtyWidget = null);
  final navigator = Navigator.of(tester.element(target));
  unawaited(
    navigator.push(CardPageRoute<void>(builder: (_) => const SizedBox())),
  );
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
  navigator.pop();
  for (var i = 0; i < 3; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
  debugOnRebuildDirtyWidget = null;
  return rebuilds;
}
