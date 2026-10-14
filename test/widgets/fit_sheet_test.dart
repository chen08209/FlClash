import 'dart:async';

import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/widgets/paged_sheet.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:fl_clash/widgets/sheet.dart';
import 'package:fl_clash/widgets/sheet_header.dart';
import 'package:fl_clash/widgets/snap_sheet.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

const _view = Size(400, 900);
final _tallTop = _view.height * (1 - snapSheetDetents.last);
const _rowHeight = 48.0;

Widget _list(int rows) {
  return CommonScaffold(
    title: 'title',
    body: ListView(
      shrinkWrap: true,
      children: [
        for (var index = 0; index < rows; index++)
          ListTile(
            title: Text('row $index'),
            minTileHeight: _rowHeight,
            onTap: () {},
          ),
      ],
    ),
  );
}

void main() {
  Future<Future<Object?>> openSheet(
    WidgetTester tester,
    WidgetBuilder builder, {
    SheetProps props = const SheetProps(),
  }) async {
    tester.view.physicalSize = _view;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    late Future<Object?> result;
    await tester.pumpWidget(
      TestApp(
        overrides: [viewSizeProvider.overrideWithBuild((_, _) => _view)],
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () {
              result = showSheet<Object?>(
                context: context,
                props: props,
                builder: builder,
              );
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return result;
  }

  double sheetTop(WidgetTester tester) =>
      tester.getTopLeft(find.byType(SheetDragHandle)).dy;

  Finder content() => find.byType(Scrollable).last;

  double contentOffset(WidgetTester tester) =>
      tester.state<ScrollableState>(content()).position.pixels;

  bool isOpen(WidgetTester tester) => tester.any(find.text('title'));

  testWidgets('a short sheet rests at its content height and closes when '
      'its content is dragged down', (tester) async {
    final result = await openSheet(tester, (_) => _list(3));
    var closed = false;
    unawaited(result.then((_) => closed = true));

    final top = sheetTop(tester);
    expect(top, greaterThan(_view.height / 2));
    expect(tester.getBottomLeft(find.text('row 2')).dy, lessThan(_view.height));

    await tester.drag(find.text('row 1'), const Offset(0, 40));
    await tester.pumpAndSettle();
    expect(sheetTop(tester), closeTo(top, 1));
    expect(isOpen(tester), isTrue);

    await tester.fling(find.text('row 1'), const Offset(0, -200), 2000);
    await tester.pumpAndSettle();
    expect(sheetTop(tester), closeTo(top, 1));

    await tester.drag(find.text('row 1'), Offset(0, _view.height - top));
    await tester.pumpAndSettle();
    expect(closed, isTrue);
    expect(isOpen(tester), isFalse);
  });

  testWidgets('a long sheet rests at the short detent, opens to the tall one '
      'before its content scrolls and closes from the short detent', (
    tester,
  ) async {
    await openSheet(tester, (_) => _list(60));
    final top = sheetTop(tester);
    expect(top, closeTo(_view.height * (1 - snapSheetDetents.first), 1));

    await tester.fling(content(), const Offset(0, -200), 2000);
    await tester.pumpAndSettle();
    expect(sheetTop(tester), closeTo(_tallTop, 1));
    expect(contentOffset(tester), 0);

    await tester.drag(content(), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(contentOffset(tester), greaterThan(0));
    expect(sheetTop(tester), closeTo(_tallTop, 1));

    await tester.drag(content(), const Offset(0, 200));
    await tester.pumpAndSettle();
    expect(contentOffset(tester), 0);

    await tester.fling(content(), const Offset(0, 300), 2000);
    await tester.pumpAndSettle();
    expect(sheetTop(tester), closeTo(top, 1));
    expect(isOpen(tester), isTrue);

    await tester.fling(content(), const Offset(0, 300), 2000);
    await tester.pumpAndSettle();
    expect(isOpen(tester), isFalse);
  });

  testWidgets('a sheet a little taller than the short detent opens to its '
      'content height and no further', (tester) async {
    await openSheet(tester, (_) => _list(14));
    final top = sheetTop(tester);
    expect(top, closeTo(_view.height * (1 - snapSheetDetents.first), 1));

    await tester.drag(content(), const Offset(0, -600));
    await tester.pumpAndSettle();
    final open = sheetTop(tester);
    expect(open, inExclusiveRange(1, top - 1));
    expect(
      tester.getBottomLeft(find.text('row 13')).dy,
      lessThanOrEqualTo(_view.height),
    );

    await tester.fling(content(), const Offset(0, -300), 2000);
    await tester.pumpAndSettle();
    expect(sheetTop(tester), closeTo(open, 1));
  });

  double rowBottom(WidgetTester tester, int row) =>
      tester.getBottomLeft(find.widgetWithText(ListTile, 'row $row')).dy;

  Future<void> raiseKeyboard(WidgetTester tester, double height) async {
    for (final inset in [height / 4, height / 2, height * 3 / 4, height]) {
      tester.view.viewInsets = FakeViewPadding(bottom: inset);
      // The engine takes the keyboard out of the padding.
      tester.view.padding = FakeViewPadding.zero;
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  Future<void> lowerKeyboard(WidgetTester tester) async {
    tester.view.resetViewInsets();
    tester.view.resetPadding();
    await tester.pumpAndSettle();
  }

  testWidgets('a short sheet clears the bottom bars once, and the keyboard '
      'carries it up past the short detent with its content right above it', (
    tester,
  ) async {
    await openSheet(tester, (_) => _list(3));
    tester.view.viewPadding = const FakeViewPadding(bottom: 30);
    tester.view.padding = const FakeViewPadding(bottom: 30);
    await tester.pumpAndSettle();
    final top = sheetTop(tester);
    expect(rowBottom(tester, 2), closeTo(_view.height - 30, 1));

    const keyboard = 400.0;
    await raiseKeyboard(tester, keyboard);
    expect(
      sheetTop(tester),
      lessThan(_view.height * (1 - snapSheetDetents.first)),
    );
    expect(rowBottom(tester, 2), closeTo(_view.height - keyboard, 1));

    tester.view.resetViewInsets();
    tester.view.padding = const FakeViewPadding(bottom: 30);
    await tester.pumpAndSettle();
    expect(sheetTop(tester), closeTo(top, 1));
  });

  testWidgets('a long sheet opens to the tall detent while the keyboard is '
      'still rising', (tester) async {
    await openSheet(tester, (_) => _list(60));
    for (final inset in [80.0, 160.0]) {
      tester.view.viewInsets = FakeViewPadding(bottom: inset);
      await tester.pump(const Duration(milliseconds: 16));
    }

    var top = sheetTop(tester);
    for (final inset in [240.0, 320.0, 400.0]) {
      tester.view.viewInsets = FakeViewPadding(bottom: inset);
      await tester.pump(const Duration(milliseconds: 16));
      expect(sheetTop(tester), lessThan(top));
      top = sheetTop(tester);
    }
    await tester.pumpAndSettle();
    expect(sheetTop(tester), closeTo(_tallTop, 1));
  });

  testWidgets('a nested sheet keeps its content above the keyboard on every '
      'frame the keyboard moves', (tester) async {
    await openSheet(
      tester,
      (_) => NestedPagedSheet(builder: (_) => _list(3)),
      props: nestedPagedSheetProps,
    );

    for (final inset in [100.0, 200.0, 300.0, 400.0, 250.0, 0.0]) {
      tester.view.viewInsets = FakeViewPadding(bottom: inset);
      await tester.pump();
      expect(rowBottom(tester, 2), closeTo(_view.height - inset, 1));
    }
  });

  testWidgets('a short sheet the keyboard has left grows to the short detent '
      'as if it had never risen', (tester) async {
    final rows = ValueNotifier(3);
    addTearDown(rows.dispose);
    await openSheet(
      tester,
      (_) => ValueListenableBuilder(
        valueListenable: rows,
        builder: (_, count, _) => _list(count),
      ),
    );
    await raiseKeyboard(tester, 400);
    await lowerKeyboard(tester);

    rows.value = 20;
    await tester.pumpAndSettle();
    expect(
      sheetTop(tester),
      closeTo(_view.height * (1 - snapSheetDetents.first), 1),
    );
  });

  testWidgets('a nested sheet opened to the tall detent stays there across '
      'a shorter page', (tester) async {
    Widget page({required VoidCallback onNext}) => CommonScaffold(
      title: 'title',
      body: ListView(
        children: [
          for (var index = 0; index < 60; index++)
            SizedBox(
              height: _rowHeight,
              child: index == 3
                  ? TextButton(onPressed: onNext, child: const Text('next'))
                  : Text('row $index'),
            ),
        ],
      ),
    );
    await openSheet(
      tester,
      (_) => NestedPagedSheet(
        builder: (context) => page(
          onNext: () => Navigator.of(
            context,
          ).push(PagedSheetRoute(builder: (_) => _list(3))),
        ),
      ),
      props: nestedPagedSheetProps,
    );
    await tester.fling(find.text('row 5'), const Offset(0, -200), 2000);
    await tester.pumpAndSettle();
    expect(sheetTop(tester), closeTo(_tallTop, 1));

    await tester.tap(find.text('next'));
    await tester.pumpAndSettle();
    expect(sheetTop(tester), greaterThan(_view.height / 2));

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(sheetTop(tester), closeTo(_tallTop, 1));
  });

  testWidgets('a mouse moving over the sheet between frames finds it laid '
      'out after a drag moved it', (tester) async {
    await openSheet(tester, (_) => _list(60));
    final handle = tester.getCenter(find.byType(SheetDragHandle));
    final drag = await tester.startGesture(
      handle,
      kind: PointerDeviceKind.mouse,
    );
    await drag.moveBy(const Offset(0, -40));
    await drag.moveBy(const Offset(0, -40));
    await drag.up();
    await drag.moveBy(const Offset(0, 40));

    expect(tester.takeException(), isNull);
    await tester.pumpAndSettle();
    await drag.removePointer();
  });

  testWidgets('a tap outside closes the sheet', (tester) async {
    await openSheet(tester, (_) => _list(3));

    await tester.tapAt(const Offset(200, 40));
    await tester.pumpAndSettle();

    expect(isOpen(tester), isFalse);
  });

  testWidgets('a nested sheet decides what a drag away and a tap outside do', (
    tester,
  ) async {
    final dismissals = <bool>[];
    await openSheet(
      tester,
      (_) =>
          NestedPagedSheet(builder: (_) => _list(3), onDismiss: dismissals.add),
      props: nestedPagedSheetProps,
    );
    final top = sheetTop(tester);

    await tester.fling(find.text('row 1'), const Offset(0, 300), 2000);
    await tester.pumpAndSettle();
    await tester.tapAt(const Offset(200, 40));
    await tester.pumpAndSettle();

    expect(dismissals, [false, false]);
    expect(isOpen(tester), isTrue);
    expect(sheetTop(tester), closeTo(top, 1));
  });

  for (final closes in [true, false]) {
    testWidgets('a nested sheet that ${closes ? 'closes' : 'stays'} after a '
        'drag away springs back while it decides', (tester) async {
      final decision = Completer<void>();
      await openSheet(
        tester,
        (_) => NestedPagedSheet(
          builder: (_) => _list(3),
          onDismiss: (_) async {
            await decision.future;
            if (closes) {
              globalState.navigatorKey.currentState!.pop();
            }
          },
        ),
        props: nestedPagedSheetProps,
      );
      final top = sheetTop(tester);

      await tester.fling(find.text('row 1'), const Offset(0, 300), 2000);
      await tester.pump();
      expect(sheetTop(tester), greaterThan(top));
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
      expect(isOpen(tester), isTrue);
      expect(sheetTop(tester), closeTo(top, 1));

      decision.complete();
      var lowest = top;
      for (var frame = 0; frame < 30 && isOpen(tester); frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        if (!isOpen(tester)) {
          break;
        }
        final current = sheetTop(tester);
        expect(current, greaterThanOrEqualTo(lowest - 1));
        lowest = current;
      }
      await tester.pumpAndSettle();

      expect(isOpen(tester), !closes);
      if (!closes) {
        expect(sheetTop(tester), closeTo(top, 1));
      }
    });
  }

  testWidgets(
    'pages kept alive in a nested sheet scroll on their own controllers and '
    'still hand a drag down to the sheet',
    (tester) async {
      final dismissals = <bool>[];
      Widget page(String name, {VoidCallback? onNext}) => CommonScaffold(
        title: 'title',
        body: ListView(
          children: [
            if (onNext != null)
              TextButton(onPressed: onNext, child: const Text('next')),
            for (var index = 0; index < 60; index++)
              SizedBox(height: _rowHeight, child: Text('$name $index')),
          ],
        ),
      );
      await openSheet(
        tester,
        (_) => NestedPagedSheet(
          builder: (context) => page(
            'a',
            onNext: () => Navigator.of(
              context,
            ).push(PagedSheetRoute(builder: (_) => page('b'))),
          ),
          onDismiss: dismissals.add,
        ),
        props: nestedPagedSheetProps,
      );
      await tester.tap(find.text('next'));
      await tester.pumpAndSettle();

      await tester.drag(find.text('b 5'), const Offset(0, -200));
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      await tester.drag(find.text('b 8'), const Offset(0, 200));
      await tester.pumpAndSettle();
      await tester.fling(find.text('b 3'), const Offset(0, 300), 2000);
      await tester.pumpAndSettle();

      expect(dismissals, [true]);
    },
    variant: TargetPlatformVariant.only(TargetPlatform.macOS),
  );
}
