import 'package:fl_clash/common/navigator.dart';
import 'package:fl_clash/widgets/inherited.dart';
import 'package:fl_clash/widgets/open_container.dart';
import 'package:fl_clash/widgets/paged_sheet.dart';
import 'package:fl_clash/widgets/sheet.dart';
import 'package:fl_clash/widgets/side_sheet.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
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

Future<Color> _pixelAt(WidgetTester tester, Offset point) async {
  final size = tester.view.physicalSize;
  final pixel = point * tester.view.devicePixelRatio;
  final layer = tester.binding.renderViews.first.debugLayer! as OffsetLayer;
  final bytes = await tester.runAsync(() async {
    final image = await layer.toImage(Offset.zero & size);
    return image.toByteData();
  });
  final offset = (pixel.dy.floor() * size.width.toInt() + pixel.dx.floor()) * 4;
  final [r, g, b, a] = bytes!.buffer.asUint8List(offset, 4);
  return Color.fromARGB(a, r, g, b);
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

  testWidgets(
    'a slow mouse drag across a text field selects instead of dragging back',
    (tester) async {
      final controller = TextEditingController(text: 'select these words');
      addTearDown(controller.dispose);
      await _pumpOpener(
        tester,
        (context) => Navigator.of(context).push(
          CommonDesktopRoute<void>(
            builder: (_) => Scaffold(
              body: Column(
                children: [
                  const SizedBox(
                    height: 200,
                    child: Center(child: Text('blank')),
                  ),
                  SizedBox(
                    width: 300,
                    child: TextField(controller: controller),
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(EditableText)),
        kind: PointerDeviceKind.mouse,
      );
      for (var i = 0; i < 40; i++) {
        await gesture.moveBy(const Offset(1.5, 0));
        await tester.pump();
      }
      await gesture.up();
      await tester.pumpAndSettle();

      expect(controller.selection.isCollapsed, isFalse);

      await tester.dragFrom(
        tester.getCenter(find.text('blank')),
        const Offset(600, 0),
        kind: PointerDeviceKind.mouse,
      );
      await tester.pumpAndSettle();
      expect(find.text('blank'), findsNothing);
      expect(find.text('open'), findsOneWidget);
    },
    variant: TargetPlatformVariant.desktop(),
  );

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

  testWidgets('a paged sheet drags back one page, even past its edge', (
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

    await _dragRight(tester, find.text('second'), 1200);
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.text('second'), findsNothing);
    expect(find.text('first'), findsOneWidget);

    await _dragRight(tester, find.text('first'), 600);
    await tester.pumpAndSettle();
    expect(find.text('first'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a paged sheet takes no drag back while the last one settles', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    PagedSheetRoute<void> page(String label, double height) =>
        PagedSheetRoute<void>(
          builder: (_) => SizedBox(
            height: height,
            child: Center(child: Text(label)),
          ),
        );
    await tester.pumpWidget(
      MaterialApp(
        home: SheetProvider(
          type: SheetType.bottomSheet,
          child: Align(
            alignment: Alignment.bottomCenter,
            child: PagedSheet(
              child: Navigator(
                key: navigatorKey,
                onGenerateInitialRoutes: (_, _) => [page('first', 200)],
              ),
            ),
          ),
        ),
      ),
    );
    navigatorKey.currentState!.push(page('second', 300));
    await tester.pumpAndSettle();
    navigatorKey.currentState!.push(page('third', 400));
    await tester.pumpAndSettle();

    await tester.fling(find.text('third'), const Offset(300, 0), 2000);
    await tester.pump();
    await tester.flingFrom(
      tester.getCenter(find.text('second')),
      const Offset(300, 0),
      2000,
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('second'), findsOneWidget);
    expect(tester.getSize(find.byType(PagedSheet)).height, 300);
  });

  group('a cancelled drag back leaves the page alone', () {
    var builds = 0;
    final page = Builder(
      builder: (context) {
        builds++;
        return SizedBox(
          height: 400,
          child: Center(child: Text('page ${Theme.of(context).brightness}')),
        );
      },
    );

    Future<void> dragAndCancel(WidgetTester tester) async {
      builds = 0;
      final gesture = await tester.startGesture(
        tester.getCenter(find.textContaining('page')),
      );
      for (var i = 0; i < 5; i++) {
        await gesture.moveBy(const Offset(20, 0));
        await tester.pump(const Duration(milliseconds: 16));
      }
      await gesture.moveBy(const Offset(-100, 0));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.textContaining('page'), findsOneWidget);
      expect(builds, 0);
    }

    testWidgets('on a pushed page', (tester) async {
      await _pumpOpener(tester, (context) {
        Navigator.of(context).push(CommonRoute<void>(builder: (_) => page));
      });
      await dragAndCancel(tester);
    });

    testWidgets('on an open container', (tester) async {
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
                  openBuilder: (_, _) => page,
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('tile'));
      await tester.pumpAndSettle();
      await dragAndCancel(tester);
    });

    testWidgets('on a paged sheet', (tester) async {
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
                          onPressed: () => Navigator.of(
                            context,
                          ).push(PagedSheetRoute<void>(builder: (_) => page)),
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
      await dragAndCancel(tester);
    });
  });

  group('the page under a drag back', () {
    Future<double> labelContrast(WidgetTester tester) async {
      final label = tester.getRect(find.text('below'));
      final text = await _pixelAt(tester, label.center);
      final blank = await _pixelAt(
        tester,
        label.centerRight + const Offset(20, 0),
      );
      return (text.r - blank.r).abs() +
          (text.g - blank.g).abs() +
          (text.b - blank.b).abs();
    }

    Future<void> dragBack(WidgetTester tester) async {
      final gesture = await tester.startGesture(
        tester.getCenter(find.text('top')),
      );
      await gesture.moveBy(const Offset(20, 0));
      await gesture.moveBy(const Offset(300, 0));
      await tester.pump();
      final faint = await labelContrast(tester);
      final trailing = tester.getTopLeft(find.text('below')).dx;

      await gesture.moveBy(const Offset(200, 0));
      await tester.pump();
      expect(faint, greaterThan(0));
      expect(await labelContrast(tester), greaterThan(faint));

      await gesture.up();
      await tester.pumpAndSettle();
      expect(find.text('top'), findsNothing);
      expect(tester.getTopLeft(find.text('below')).dx, greaterThan(trailing));
    }

    Widget opener(BuildContext context, Route<void> Function() top) {
      return Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 200),
          child: TextButton(
            onPressed: () => Navigator.of(context).push(top()),
            child: const Text('below'),
          ),
        ),
      );
    }

    testWidgets('fades in and trails the finger as it is uncovered', (
      tester,
    ) async {
      await _pumpOpener(
        tester,
        (context) => Navigator.of(context).push(
          CommonRoute<void>(
            builder: (context) => Scaffold(
              body: opener(
                context,
                () => CommonRoute<void>(
                  builder: (_) =>
                      const Scaffold(body: Center(child: Text('top'))),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('below'));
      await tester.pumpAndSettle();

      await dragBack(tester);
    });

    testWidgets('of a paged sheet fades in and trails the finger', (
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
                        height: 400,
                        child: Center(
                          child: opener(
                            context,
                            () => PagedSheetRoute<void>(
                              builder: (_) => const SizedBox(
                                height: 400,
                                child: Center(child: Text('top')),
                              ),
                            ),
                          ),
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
      await tester.tap(find.text('below'));
      await tester.pumpAndSettle();

      await dragBack(tester);
    });
  });
}
