import 'package:fl_clash/widgets/open_container.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('OpenContainer opens, closes, and returns a value', (
    tester,
  ) async {
    String? result;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 160,
              height: 80,
              child: OpenContainer<String>(
                middleColor: Colors.orange,
                routeSettings: const RouteSettings(name: 'details'),
                transitionDuration: const Duration(milliseconds: 200),
                closedBuilder: (_, open) {
                  return FilledButton(
                    onPressed: open,
                    child: const Text('Closed'),
                  );
                },
                openBuilder: (_, close) {
                  return Center(
                    child: FilledButton(
                      onPressed: () => close(returnValue: 'done'),
                      child: const Text('Close'),
                    ),
                  );
                },
                onClosed: (value) {
                  result = value;
                },
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Closed'));
    await tester.pump(const Duration(milliseconds: 80));
    expect(find.text('Close'), findsOneWidget);
    await tester.pumpAndSettle();

    await tester.tap(find.text('Close'));
    await tester.pump(const Duration(milliseconds: 80));
    await tester.pumpAndSettle();

    expect(result, 'done');
    expect(find.text('Closed'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('morphs the closed shape and color into the open page', (
    tester,
  ) async {
    const closedShape = RoundedSuperellipseBorder(
      borderRadius: BorderRadius.all(Radius.circular(24)),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 160,
              height: 80,
              child: OpenContainer<void>(
                closedShape: closedShape,
                closedColor: Colors.red,
                openColor: Colors.blue,
                curve: Curves.linear,
                transitionDuration: const Duration(milliseconds: 300),
                closedBuilder: (_, open) {
                  return GestureDetector(
                    onTap: open,
                    child: const Text('Card'),
                  );
                },
                openBuilder: (_, close) {
                  return GestureDetector(
                    onTap: () => close(),
                    child: const Text('Page'),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );

    Material container() {
      return tester.widget<Material>(
        find
            .ancestor(of: find.text('Page'), matching: find.byType(Material))
            .first,
      );
    }

    double corner(ShapeBorder? shape) {
      final border = shape! as RoundedSuperellipseBorder;
      return border.borderRadius.resolve(TextDirection.ltr).topLeft.x;
    }

    final closedMaterial = tester.widget<Material>(
      find
          .ancestor(of: find.text('Card'), matching: find.byType(Material))
          .first,
    );
    expect(closedMaterial.shape, closedShape);

    await tester.tap(find.text('Card'));
    await tester.pump();
    expect(corner(container().shape), 24);
    expect(container().color, Colors.red);

    await tester.pump(const Duration(milliseconds: 150));
    expect(corner(container().shape), closeTo(12, 0.01));

    await tester.pumpAndSettle();
    expect(container().shape, isNull);

    await tester.tap(find.text('Page'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(corner(container().shape), closeTo(12, 0.01));

    await tester.pumpAndSettle();
    expect(find.text('Page'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'fadeThrough opens by callback and supports interrupted reverse',
    (tester) async {
      String? result = 'unchanged';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: OpenContainer<String>(
                tappable: false,
                useRootNavigator: true,
                transitionType: ContainerTransitionType.fadeThrough,
                transitionDuration: const Duration(milliseconds: 300),
                closedBuilder: (_, open) {
                  return TextButton(
                    onPressed: open,
                    child: const Text('Open manually'),
                  );
                },
                openBuilder: (_, close) {
                  return TextButton(
                    onPressed: () => close(),
                    child: const Text('Reverse now'),
                  );
                },
                onClosed: (value) {
                  result = value;
                },
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open manually'));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(find.text('Reverse now'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.pumpAndSettle();
      await tester.pump();

      expect(result, isNull);
      expect(find.text('Reverse now'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
