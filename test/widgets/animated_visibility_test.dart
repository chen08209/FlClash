import 'package:fl_clash/widgets/animated_visibility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('keeps its background during the extended exit transition', (
    tester,
  ) async {
    final visibilityKey = GlobalKey();

    Widget buildApp(bool visible) {
      return MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              AnimatedVisibility(
                key: visibilityKey,
                visible: visible,
                axis: Axis.horizontal,
                backgroundColor: Colors.blue,
                child: const SizedBox(width: 180, height: 80),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp(true));
    await tester.pumpWidget(buildApp(false));
    await tester.pump(const Duration(milliseconds: 350));

    expect(tester.getSize(find.byKey(visibilityKey)).width, 180);
    expect(
      find.descendant(
        of: find.byKey(visibilityKey),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Material &&
              widget.color != null &&
              widget.color!.b > widget.color!.r &&
              widget.color!.a > 0,
        ),
      ),
      findsOneWidget,
    );

    await tester.pump(const Duration(milliseconds: 101));

    expect(tester.getSize(find.byKey(visibilityKey)).width, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets('horizontal transition clips without narrowing its child', (
    tester,
  ) async {
    final visibilityKey = GlobalKey();

    Widget buildApp(bool visible) {
      return MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              AnimatedVisibility(
                key: visibilityKey,
                visible: visible,
                axis: Axis.horizontal,
                child: const SizedBox(
                  width: 180,
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    leading: SizedBox(width: 80),
                    title: Text('Title'),
                  ),
                ),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp(true));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(buildApp(false));
    await tester.pump(const Duration(milliseconds: 150));

    expect(tester.getSize(find.byKey(visibilityKey)).width, 180);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rapid reversals never exceed the visible child width', (
    tester,
  ) async {
    final visibilityKey = GlobalKey();

    Widget buildApp(bool visible) {
      return MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              AnimatedVisibility(
                key: visibilityKey,
                visible: visible,
                axis: Axis.horizontal,
                child: const SizedBox(width: 180),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp(true));
    expect(tester.getSize(find.byKey(visibilityKey)).width, 180);

    await tester.pumpWidget(buildApp(false));
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pumpWidget(buildApp(true));
    await tester.pump(const Duration(milliseconds: 60));
    await tester.pumpWidget(buildApp(false));
    await tester.pump(const Duration(milliseconds: 60));

    expect(
      tester.getSize(find.byKey(visibilityKey)).width,
      lessThanOrEqualTo(180),
    );
    expect(tester.takeException(), isNull);
  });
}
