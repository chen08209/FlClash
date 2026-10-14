import 'dart:async';

import 'package:fl_clash/common/navigator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  final navigatorKey = GlobalKey<NavigatorState>();

  Future<void> pumpHome(WidgetTester tester) {
    return tester.pumpWidget(
      MaterialApp(navigatorKey: navigatorKey, home: const SizedBox()),
    );
  }

  testWidgets('a push keeps its whole transition after a long first frame', (
    tester,
  ) async {
    await pumpHome(tester);
    final route = CommonDesktopRoute<void>(builder: (_) => const Text('page'));
    unawaited(navigatorKey.currentState!.push(route));

    await tester.pump();
    expect(find.text('page', skipOffstage: false), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 150));
    expect(route.animation!.value, 0);

    await tester.pump(const Duration(milliseconds: 100));
    expect(route.animation!.value, closeTo(0.5, 0.01));
  });

  testWidgets('a route popped in the frame it was pushed in still leaves', (
    tester,
  ) async {
    await pumpHome(tester);
    final navigator = navigatorKey.currentState!;
    unawaited(
      navigator.push(
        CommonDesktopRoute<void>(builder: (_) => const Text('page')),
      ),
    );
    navigator.pop();

    await tester.pumpAndSettle();
    expect(find.text('page'), findsNothing);
    expect(navigator.canPop(), isFalse);
  });
}
