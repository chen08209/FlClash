import 'package:fl_clash/widgets/open_container.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

const _viewSize = Size(800, 600);

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

    final closedMaterial = tester.widget<Material>(
      find
          .ancestor(of: find.text('Card'), matching: find.byType(Material))
          .first,
    );
    expect(closedMaterial.shape, closedShape);
    final closedRect = tester.getRect(find.byType(OpenContainer<void>));
    final navigator = find.byType(Navigator);

    await tester.tap(find.text('Card'));
    await tester.pump();
    expect(
      navigator,
      paints..path(
        color: Colors.red,
        includes: [closedRect.center],
        excludes: [closedRect.topLeft + const Offset(2, 2)],
      ),
    );

    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    final halfway = Rect.lerp(closedRect, Offset.zero & _viewSize, 0.5)!;
    expect(
      navigator,
      paints..path(
        color: Colors.blue,
        includes: [halfway.topLeft + const Offset(5, 5)],
        excludes: [halfway.topLeft + const Offset(1, 1)],
      ),
    );

    await tester.pumpAndSettle();
    expect(navigator, isNot(paints..path(color: Colors.blue)));

    await tester.tap(find.text('Page'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));
    expect(
      navigator,
      paints..path(
        color: Colors.red,
        includes: [halfway.topLeft + const Offset(5, 5)],
        excludes: [halfway.topLeft + const Offset(1, 1)],
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Page'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('opens by callback and supports interrupted reverse', (
    tester,
  ) async {
    String? result = 'unchanged';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: OpenContainer<String>(
              tappable: false,
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
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('Reverse now'));
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpAndSettle();
    await tester.pump();

    expect(result, isNull);
    expect(find.text('Reverse now'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  Widget containerApp({
    required CloseContainerBuilder closedBuilder,
    required OpenContainerBuilder<void> openBuilder,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 160,
            height: 80,
            child: OpenContainer<void>(
              closedBuilder: closedBuilder,
              openBuilder: openBuilder,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('a transition builds the page once and the tile twice', (
    tester,
  ) async {
    var pageBuilds = 0;
    var tileBuilds = 0;
    final page = Builder(
      builder: (context) {
        pageBuilds++;
        return Text('${Theme.of(context).brightness}');
      },
    );

    await tester.pumpWidget(
      containerApp(
        closedBuilder: (_, open) {
          tileBuilds++;
          return TextButton(onPressed: open, child: const Text('Tile'));
        },
        openBuilder: (_, _) => page,
      ),
    );
    tileBuilds = 0;

    await tester.tap(find.text('Tile'));
    await tester.pumpAndSettle();
    expect(pageBuilds, 1);

    Navigator.of(tester.element(find.byWidget(page))).pop();
    await tester.pumpAndSettle();
    expect(pageBuilds, 1);
    expect(tileBuilds, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a transition leaves no animation undisposed', (tester) async {
    var undisposed = 0;
    void track(ObjectEvent event) {
      if (event.object is! CurvedAnimation) {
        return;
      }
      undisposed += event is ObjectCreated ? 1 : -1;
    }

    await tester.pumpWidget(
      containerApp(
        closedBuilder: (_, open) {
          return GestureDetector(onTap: open, child: const Text('Tile'));
        },
        openBuilder: (_, close) {
          return GestureDetector(onTap: close, child: const Text('Page'));
        },
      ),
    );
    FlutterMemoryAllocations.instance.addListener(track);
    addTearDown(() => FlutterMemoryAllocations.instance.removeListener(track));

    await tester.tap(find.text('Tile'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Page'));
    await tester.pumpAndSettle();
    expect(undisposed, 0);
  });

  testWidgets('the page takes no taps until it starts to show', (tester) async {
    var taps = 0;

    await tester.pumpWidget(
      containerApp(
        closedBuilder: (_, open) {
          return TextButton(onPressed: open, child: const Text('Tile'));
        },
        openBuilder: (_, _) {
          return Align(
            alignment: Alignment.topLeft,
            child: TextButton(
              onPressed: () => taps++,
              child: const Text('Page'),
            ),
          );
        },
      ),
    );

    await tester.tap(find.text('Tile'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 30));
    await tester.tap(find.text('Page'), warnIfMissed: false);
    expect(taps, 0);

    await tester.pumpAndSettle();
    await tester.tap(find.text('Page'));
    expect(taps, 1);
  });
}
