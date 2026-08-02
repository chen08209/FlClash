import 'package:fl_clash/widgets/animated_visibility.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('releases horizontal layout space throughout the exit', (
    tester,
  ) async {
    final visibilityKey = GlobalKey();
    final contentKey = GlobalKey();

    Widget buildApp(bool visible) {
      return MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              AnimatedVisibility(
                key: visibilityKey,
                visible: visible,
                axis: Axis.horizontal,
                child: const SizedBox(width: 180, height: 80),
              ),
              Expanded(child: SizedBox(key: contentKey)),
            ],
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp(true));
    expect(tester.getSize(find.byKey(contentKey)).width, 620);

    await tester.pumpWidget(buildApp(false));
    await tester.pump(const Duration(milliseconds: 150));

    final midTransitionWidth = tester.getSize(find.byKey(visibilityKey)).width;
    final midContentWidth = tester.getSize(find.byKey(contentKey)).width;
    expect(midTransitionWidth, allOf(greaterThan(0), lessThan(180)));
    expect(midContentWidth, allOf(greaterThan(620), lessThan(800)));

    await tester.pump(const Duration(milliseconds: 149));
    final nearEndContentWidth = tester.getSize(find.byKey(contentKey)).width;

    await tester.pump(const Duration(milliseconds: 2));

    expect(tester.getSize(find.byKey(visibilityKey)).width, 0);
    expect(tester.getSize(find.byKey(contentKey)).width, 800);
    expect(800 - nearEndContentWidth, lessThan(5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('releases vertical layout space throughout the exit', (
    tester,
  ) async {
    final visibilityKey = GlobalKey();
    final contentKey = GlobalKey();

    Widget buildApp(bool visible) {
      return MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              Expanded(child: SizedBox(key: contentKey)),
              AnimatedVisibility(
                key: visibilityKey,
                visible: visible,
                axis: Axis.vertical,
                child: const SizedBox(width: 180, height: 80),
              ),
            ],
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp(true));
    expect(tester.getSize(find.byKey(contentKey)).height, 520);

    await tester.pumpWidget(buildApp(false));
    await tester.pump(const Duration(milliseconds: 150));

    final midTransitionHeight = tester
        .getSize(find.byKey(visibilityKey))
        .height;
    final midContentHeight = tester.getSize(find.byKey(contentKey)).height;
    expect(midTransitionHeight, allOf(greaterThan(0), lessThan(80)));
    expect(midContentHeight, allOf(greaterThan(520), lessThan(600)));

    await tester.pump(const Duration(milliseconds: 149));
    final nearEndContentHeight = tester.getSize(find.byKey(contentKey)).height;

    await tester.pump(const Duration(milliseconds: 2));

    expect(tester.getSize(find.byKey(visibilityKey)).height, 0);
    expect(tester.getSize(find.byKey(contentKey)).height, 600);
    expect(600 - nearEndContentHeight, lessThan(5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows initially visible content without a transition', (
    tester,
  ) async {
    final contentKey = GlobalKey();

    Widget buildApp(bool visible) {
      return MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              AnimatedVisibility(
                visible: visible,
                axis: Axis.horizontal,
                child: SizedBox(key: contentKey, width: 180, height: 80),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp(true));

    expect(tester.getTopLeft(find.byKey(contentKey)), Offset.zero);
  });

  testWidgets('fades and slides content while entering', (tester) async {
    final visibilityKey = GlobalKey();
    final contentKey = GlobalKey();

    Widget buildApp(bool visible) {
      return MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              AnimatedVisibility(
                key: visibilityKey,
                visible: visible,
                axis: Axis.horizontal,
                child: SizedBox(key: contentKey, width: 180, height: 80),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp(false));
    await tester.pumpWidget(buildApp(true));
    await tester.pump(const Duration(milliseconds: 150));

    final fadeTransition = find.descendant(
      of: find.byKey(visibilityKey),
      matching: find.byType(FadeTransition),
    );
    expect(fadeTransition, findsOneWidget);
    expect(
      tester.widget<FadeTransition>(fadeTransition).opacity.value,
      allOf(greaterThan(0), lessThan(1)),
    );
    expect(tester.getTopLeft(find.byKey(contentKey)).dx, lessThan(0));
  });

  testWidgets('fades content while exiting', (tester) async {
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
    await tester.pump(const Duration(milliseconds: 150));

    final fadeTransition = find.descendant(
      of: find.byKey(visibilityKey),
      matching: find.byType(FadeTransition),
    );
    expect(fadeTransition, findsOneWidget);
    expect(
      tester.widget<FadeTransition>(fadeTransition).opacity.value,
      allOf(greaterThan(0), lessThan(1)),
    );
  });

  testWidgets('horizontal content exits from right to left', (tester) async {
    final contentKey = GlobalKey();

    Widget buildApp(bool visible) {
      return MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              AnimatedVisibility(
                visible: visible,
                axis: Axis.horizontal,
                child: SizedBox(key: contentKey, width: 180, height: 80),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp(true));
    final visiblePosition = tester.getTopLeft(find.byKey(contentKey));

    await tester.pumpWidget(buildApp(false));
    await tester.pump(const Duration(milliseconds: 150));

    final exitingPosition = tester.getTopLeft(find.byKey(contentKey));
    expect(exitingPosition.dx, lessThan(visiblePosition.dx - 25));
    expect(exitingPosition.dy, closeTo(visiblePosition.dy, 0.01));
  });

  testWidgets('vertical content exits from top to bottom', (tester) async {
    final contentKey = GlobalKey();

    Widget buildApp(bool visible) {
      return MaterialApp(
        home: Scaffold(
          body: Column(
            children: [
              AnimatedVisibility(
                visible: visible,
                axis: Axis.vertical,
                child: SizedBox(key: contentKey, width: 180, height: 80),
              ),
              const Expanded(child: SizedBox()),
            ],
          ),
        ),
      );
    }

    await tester.pumpWidget(buildApp(true));
    final visiblePosition = tester.getTopLeft(find.byKey(contentKey));

    await tester.pumpWidget(buildApp(false));
    await tester.pump(const Duration(milliseconds: 150));

    final exitingPosition = tester.getTopLeft(find.byKey(contentKey));
    expect(exitingPosition.dx, closeTo(visiblePosition.dx, 0.01));
    expect(exitingPosition.dy, greaterThan(visiblePosition.dy + 20));
  });

  testWidgets('horizontal transition clips without narrowing its child', (
    tester,
  ) async {
    final visibilityKey = GlobalKey();
    final contentKey = GlobalKey();

    Widget buildApp(bool visible) {
      return MaterialApp(
        home: Scaffold(
          body: Row(
            children: [
              AnimatedVisibility(
                key: visibilityKey,
                visible: visible,
                axis: Axis.horizontal,
                child: SizedBox(
                  key: contentKey,
                  width: 180,
                  child: const ListTile(
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

    expect(
      tester.getSize(find.byKey(visibilityKey)).width,
      allOf(greaterThan(0), lessThan(180)),
    );
    expect(tester.getSize(find.byKey(contentKey)).width, 180);
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
