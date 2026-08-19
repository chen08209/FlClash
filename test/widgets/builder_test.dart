import 'package:fl_clash/widgets/builder.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('TickBuilder rebuilds on the configured interval', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: TickBuilder(
          duration: const Duration(seconds: 1),
          builder: (_, tick) => Text('tick: $tick'),
        ),
      ),
    );

    expect(find.text('tick: 0'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('tick: 1'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('tick: 2'), findsOneWidget);
  });

  testWidgets('TickBuilder ticks only while the page is active', (
    tester,
  ) async {
    Widget buildApp({required bool isPageActive}) {
      return MaterialApp(
        home: PageActivityScope(
          isActive: isPageActive,
          child: TickBuilder(
            duration: const Duration(seconds: 1),
            builder: (_, tick) => Text('tick: $tick'),
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp(isPageActive: false));
    await tester.pump(const Duration(seconds: 3));

    expect(find.text('tick: 0'), findsOneWidget);

    await tester.pumpWidget(buildApp(isPageActive: true));
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('tick: 1'), findsOneWidget);

    await tester.pumpWidget(buildApp(isPageActive: false));
    await tester.pump(const Duration(seconds: 3));

    expect(find.text('tick: 1'), findsOneWidget);
  });

  testWidgets('TickBuilder stops ticking while the app is paused', (
    tester,
  ) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpWidget(
      MaterialApp(
        home: TickBuilder(
          duration: const Duration(seconds: 1),
          builder: (_, tick) => Text('tick: $tick'),
        ),
      ),
    );

    await tester.pump(const Duration(seconds: 1));
    expect(find.text('tick: 1'), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump(const Duration(seconds: 3));

    expect(find.text('tick: 1'), findsOneWidget);

    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('tick: 2'), findsOneWidget);
  });
}
