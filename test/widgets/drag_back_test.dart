import 'package:fl_clash/common/navigator.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:fl_clash/widgets/open_container.dart';
import 'package:fl_clash/widgets/paged_sheet.dart';
import 'package:fl_clash/widgets/sheet.dart';
import 'package:fl_clash/widgets/side_sheet.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

Future<void> _dragRight(WidgetTester tester, Finder finder, double dx) {
  return tester.timedDrag(finder, Offset(dx, 0), const Duration(seconds: 1));
}

Future<void> _pumpOpener(
  WidgetTester tester,
  void Function(BuildContext context) open,
) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => TextButton(
            onPressed: () => open(context),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  group('controls that take a horizontal drag', () {
    var sliderValue = 0.5;

    Widget page() {
      return Scaffold(
        body: Column(
          children: [
            const SizedBox(height: 200, child: Center(child: Text('blank'))),
            SizedBox(
              height: 80,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (var i = 0; i < 20; i++)
                    SizedBox(width: 120, child: Text('chip $i')),
                ],
              ),
            ),
            StatefulBuilder(
              builder: (context, setState) => Slider(
                value: sliderValue,
                onChanged: (value) => setState(() => sliderValue = value),
              ),
            ),
          ],
        ),
      );
    }

    Future<void> openPage(WidgetTester tester) {
      sliderValue = 0.5;
      return _pumpOpener(
        tester,
        (context) => Navigator.of(
          context,
        ).push(CommonRoute<void>(builder: (_) => page())),
      );
    }

    testWidgets('absorb the drag, even at the scroll start', (tester) async {
      await openPage(tester);

      await _dragRight(tester, find.text('chip 0'), 500);
      await tester.pumpAndSettle();
      expect(find.text('blank'), findsOneWidget);

      await _dragRight(tester, find.byType(Slider), 300);
      await tester.pumpAndSettle();
      expect(find.text('blank'), findsOneWidget);
      expect(sliderValue, greaterThan(0.5));
    });

    testWidgets('leave the blank area free to drag back', (tester) async {
      await openPage(tester);

      await _dragRight(tester, find.text('blank'), 600);
      await tester.pumpAndSettle();

      expect(find.text('blank'), findsNothing);
      expect(find.text('open'), findsOneWidget);
    });
  });

  testWidgets('an open container drags back to its closed tile', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 160,
              height: 80,
              child: OpenContainer<void>(
                closedBuilder: (_, open) =>
                    TextButton(onPressed: open, child: const Text('tile')),
                openBuilder: (_, _) =>
                    const Scaffold(body: Center(child: Text('opened'))),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('tile'));
    await tester.pumpAndSettle();

    await _dragRight(tester, find.text('opened'), 600);
    await tester.pumpAndSettle();

    expect(find.text('opened'), findsNothing);
    expect(find.text('tile'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('tile'));
    await tester.pumpAndSettle();
    await _dragRight(tester, find.text('opened'), 600);
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 30));
      expect(find.text('tile'), findsOneWidget);
    }
    await tester.pumpAndSettle();
    expect(find.text('opened'), findsNothing);
  });

  testWidgets('a modal side sheet drags off to close', (tester) async {
    await _pumpOpener(
      tester,
      (context) => showModalSideSheet<void>(
        context: context,
        constraints: const BoxConstraints(maxWidth: 300),
        builder: (_) =>
            const SizedBox.expand(child: Center(child: Text('side'))),
      ),
    );

    await _dragRight(tester, find.text('side'), 60);
    await tester.pumpAndSettle();
    expect(find.text('side'), findsOneWidget);

    await _dragRight(tester, find.text('side'), 220);
    await tester.pumpAndSettle();
    expect(find.text('side'), findsNothing);
  });

  testWidgets('a paged sheet drags back one page and keeps its first', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SheetProvider(
          type: SheetType.bottomSheet,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: PagedSheet(
              child: Navigator(
                onGenerateInitialRoutes: (_, _) => [
                  PagedSheetRoute<void>(
                    builder: (context) => SizedBox(
                      height: 300,
                      child: TextButton(
                        onPressed: () => Navigator.of(context).push(
                          PagedSheetRoute<void>(
                            builder: (_) => const SizedBox(
                              height: 400,
                              child: Center(child: Text('second')),
                            ),
                          ),
                        ),
                        child: const Text('first'),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('first'));
    await tester.pumpAndSettle();

    await _dragRight(tester, find.text('second'), 600);
    await tester.pumpAndSettle();
    expect(find.text('second'), findsNothing);
    expect(find.text('first'), findsOneWidget);

    await _dragRight(tester, find.text('first'), 600);
    await tester.pumpAndSettle();
    expect(find.text('first'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
