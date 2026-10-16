import 'dart:async';
import 'dart:math' as math;

import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/ui/paged_sheet.dart';
import 'package:fl_clash/ui/scaffold.dart';
import 'package:fl_clash/ui/sheet.dart';
import 'package:fl_clash/ui/sheet_header.dart';
import 'package:fl_clash/ui/snap_sheet.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
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

  testWidgets('a short sheet rests at the short detent and closes when '
      'its content is dragged down', (tester) async {
    final result = await openSheet(tester, (_) => _list(3));
    var closed = false;
    unawaited(result.then((_) => closed = true));

    final top = sheetTop(tester);
    expect(top, closeTo(_view.height * (1 - snapSheetDetents.first), 1));
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

  testWidgets('a flick up from the short detent rises to the height of '
      'content a little taller than it without dropping on the way', (
    tester,
  ) async {
    await openSheet(tester, (_) => _list(14));

    await tester.fling(content(), const Offset(0, -100), 3000);
    var top = sheetTop(tester);
    for (var frame = 0; frame < 40; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(sheetTop(tester), lessThan(top + 8), reason: 'frame $frame');
      top = sheetTop(tester);
    }
    await tester.pumpAndSettle();

    expect(sheetTop(tester), greaterThan(_tallTop + 1));
    expect(
      tester.getBottomLeft(find.text('row 13')).dy,
      lessThanOrEqualTo(_view.height),
    );
  });

  testWidgets('a drag let go nearer the height of content a little taller '
      'than the short detent than the detent opens the sheet to it', (
    tester,
  ) async {
    await openSheet(tester, (_) => _list(14));
    final short = sheetTop(tester);

    final gesture = await tester.startGesture(tester.getCenter(content()));
    for (var move = 0; move < 6; move++) {
      await gesture.moveBy(const Offset(0, -20));
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pump(const Duration(milliseconds: 100));
    await gesture.up();
    await tester.pumpAndSettle();

    expect(sheetTop(tester), lessThan(short - 1));
    expect(
      tester.getBottomLeft(find.text('row 13')).dy,
      lessThanOrEqualTo(_view.height),
    );
  });

  testWidgets('a wheel tick opens a sheet a little taller than the short '
      'detent to its content height without dropping on the way', (
    tester,
  ) async {
    await openSheet(tester, (_) => _list(14));
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(pointer.hover(tester.getCenter(content())));

    await tester.sendEventToBinding(pointer.scroll(const Offset(0, 50)));
    var top = sheetTop(tester);
    for (var frame = 0; frame < 40; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(sheetTop(tester), lessThan(top + 8), reason: 'frame $frame');
      top = sheetTop(tester);
    }
    await tester.pumpAndSettle();

    expect(sheetTop(tester), greaterThan(_tallTop + 1));
    expect(
      tester.getBottomLeft(find.text('row 13')).dy,
      lessThanOrEqualTo(_view.height),
    );
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

  testWidgets('a short sheet keeps its content above the keyboard and comes '
      'back to the short detent', (tester) async {
    await openSheet(tester, (_) => _list(3));
    tester.view.viewPadding = const FakeViewPadding(bottom: 30);
    tester.view.padding = const FakeViewPadding(bottom: 30);
    await tester.pumpAndSettle();
    final top = sheetTop(tester);
    expect(top, closeTo(_view.height * (1 - snapSheetDetents.first), 1));

    const keyboard = 400.0;
    await raiseKeyboard(tester, keyboard);
    expect(rowBottom(tester, 2), lessThanOrEqualTo(_view.height - keyboard));

    tester.view.resetViewInsets();
    tester.view.padding = const FakeViewPadding(bottom: 30);
    await tester.pumpAndSettle();
    expect(sheetTop(tester), closeTo(top, 1));
  });

  testWidgets('a long sheet opens past the tall detent to a peek below the '
      'top while the keyboard is still rising', (tester) async {
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
    expect(sheetTop(tester), closeTo(stackedSheetPeek, 1));
  });

  testWidgets('a long sheet at the tall detent rises with the keyboard into '
      'the peek and comes back down with it on every frame', (tester) async {
    await openSheet(tester, (_) => _list(60));
    addTearDown(tester.view.resetViewInsets);
    await tester.fling(content(), const Offset(0, -200), 2000);
    await tester.pumpAndSettle();
    expect(sheetTop(tester), closeTo(_tallTop, 1));

    var top = _tallTop;
    var last = 0.0;
    for (final inset in [40.0, 120.0, 300.0, 120.0, 40.0]) {
      tester.view.viewInsets = FakeViewPadding(bottom: inset);
      await tester.pump(const Duration(milliseconds: 16));
      final moved = sheetTop(tester);
      expect(
        moved,
        inInclusiveRange(
          math.max(stackedSheetPeek, _tallTop - inset) - 1,
          _tallTop - 1,
        ),
      );
      expect(inset > last ? top - moved : moved - top, greaterThan(1));
      top = moved;
      last = inset;
    }
    expect(top, greaterThan(stackedSheetPeek + 1));

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pump(const Duration(milliseconds: 16));
    expect(sheetTop(tester), closeTo(stackedSheetPeek, 1));
    tester.view.resetViewInsets();
    await tester.pump(const Duration(milliseconds: 16));
    expect(sheetTop(tester), closeTo(_tallTop, 1));
  });

  Future<List<double>> trackKeyboard(
    WidgetTester tester,
    Iterable<double> insets,
  ) async {
    final tops = <double>[];
    for (final inset in insets) {
      tester.view.viewInsets = FakeViewPadding(bottom: inset);
      await tester.pump(const Duration(milliseconds: 16));
      tops.add(sheetTop(tester));
    }
    return tops;
  }

  /// A keyboard moving at a steady speed never jolts the sheet: its speed
  /// changes by a small part of the keyboard's from one frame to the next.
  void expectEased(List<double> tops, double step) {
    for (var index = 2; index < tops.length; index++) {
      final speed = tops[index] - tops[index - 1];
      final before = tops[index - 1] - tops[index - 2];
      expect((speed - before).abs(), lessThan(step / 4));
    }
  }

  testWidgets('a short sheet starts and stops rising with the keyboard and '
      'keeps its content above it', (tester) async {
    await openSheet(tester, (_) => _list(3));
    addTearDown(tester.view.resetViewInsets);
    final rest = sheetTop(tester);
    const step = 10.0;
    final insets = [for (var inset = 0.0; inset <= 400; inset += step) inset];

    final rising = await trackKeyboard(tester, insets);
    expect(rising.last, lessThan(rest - 1));
    expect(rowBottom(tester, 2), lessThanOrEqualTo(_view.height - 400));
    expectEased(rising, step);

    final falling = await trackKeyboard(tester, insets.reversed);
    expectEased(falling, step);
    expect(falling.last, closeTo(rest, 0.01));
  });

  testWidgets('a long sheet at the tall detent slows into the peek with the '
      'keyboard', (tester) async {
    await openSheet(tester, (_) => _list(60));
    addTearDown(tester.view.resetViewInsets);
    await tester.fling(content(), const Offset(0, -200), 2000);
    await tester.pumpAndSettle();
    const step = 8.0;
    final insets = [for (var inset = 0.0; inset <= 240; inset += step) inset];

    final tops = await trackKeyboard(tester, insets);
    expectEased(tops, step);
    expect(tops.last, closeTo(stackedSheetPeek, 1));
  });

  testWidgets('the keyboard moves a sheet without laying out or painting its '
      'content again', (tester) async {
    for (final rows in [3, 60]) {
      final counts = _Counts();
      await openSheet(
        tester,
        (_) => CommonScaffold(
          title: 'title',
          body: _Counted(
            counts: counts,
            child: ListView(
              shrinkWrap: true,
              children: [
                for (var index = 0; index < rows; index++)
                  SizedBox(height: _rowHeight, child: Text('row $index')),
              ],
            ),
          ),
        ),
      );
      addTearDown(tester.view.resetViewInsets);
      counts
        ..layouts = 0
        ..paints = 0;

      final tops = await trackKeyboard(tester, [100, 200, 300, 200, 100, 0]);
      expect(tops.toSet(), hasLength(greaterThan(2)), reason: '$rows rows');
      expect(counts.layouts, 0, reason: '$rows rows');
      expect(counts.paints, 0, reason: '$rows rows');

      Navigator.of(tester.element(find.text('row 0'))).pop();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('a settle whose detent the keyboard moves every frame keeps '
      'moving every frame', (tester) async {
    await openSheet(tester, (_) => _list(60));
    addTearDown(tester.view.resetViewInsets);

    await tester.fling(content(), const Offset(0, -100), 2000);
    var top = sheetTop(tester);
    for (var frame = 1; frame <= 12; frame++) {
      tester.view.viewInsets = FakeViewPadding(bottom: frame * 20.0);
      await tester.pump(const Duration(milliseconds: 16));
      expect(sheetTop(tester), lessThan(top - 1));
      top = sheetTop(tester);
    }
    await tester.pumpAndSettle();
    expect(sheetTop(tester), closeTo(stackedSheetPeek, 1));
  });

  testWidgets('a sheet the tall detent would cut off above the keyboard '
      'rises only as far as its content needs', (tester) async {
    await openSheet(tester, (_) => _list(9));
    const keyboard = 400.0;
    await raiseKeyboard(tester, keyboard);

    expect(sheetTop(tester), lessThan(_tallTop));
    expect(sheetTop(tester), greaterThan(stackedSheetPeek));
    expect(rowBottom(tester, 8), lessThanOrEqualTo(_view.height - keyboard));
    expect(
      tester.state<ScrollableState>(content()).position.maxScrollExtent,
      0,
    );

    await lowerKeyboard(tester);
    expect(
      sheetTop(tester),
      closeTo(_view.height * (1 - snapSheetDetents.first), 1),
    );
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
      expect(rowBottom(tester, 2), lessThanOrEqualTo(_view.height - inset + 1));
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
    expect(
      sheetTop(tester),
      closeTo(_view.height * (1 - snapSheetDetents.first), 1),
    );

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(sheetTop(tester), closeTo(_tallTop, 1));
  });

  testWidgets('a nested sheet resting at its page height follows a shorter '
      'page down on every frame of the push', (tester) async {
    final shortTop = _view.height * (1 - snapSheetDetents.first);
    await openSheet(
      tester,
      (_) => NestedPagedSheet(
        builder: (context) => CommonScaffold(
          title: 'title',
          body: ListView(
            shrinkWrap: true,
            children: [
              for (var index = 0; index < 11; index++)
                ListTile(title: Text('row $index'), minTileHeight: _rowHeight),
              ListTile(
                title: const Text('next'),
                minTileHeight: _rowHeight,
                onTap: () => Navigator.of(
                  context,
                ).push(PagedSheetRoute(builder: (_) => _list(3))),
              ),
            ],
          ),
        ),
      ),
      props: nestedPagedSheetProps,
    );
    double top() => tester.getTopLeft(find.byType(SheetDragHandle).first).dy;
    await tester.drag(find.text('row 2'), const Offset(0, -300));
    await tester.pumpAndSettle();
    var last = top();
    expect(last, inExclusiveRange(_tallTop + 1, shortTop - 1));

    await tester.tap(find.text('next'));
    for (var frame = 0; frame < 30; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(top(), greaterThanOrEqualTo(last - 0.5));
      last = top();
    }
    await tester.pumpAndSettle();
    expect(top(), closeTo(shortTop, 1));
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

class _Counts {
  var layouts = 0;
  var paints = 0;
}

class _Counted extends SingleChildRenderObjectWidget {
  const _Counted({required this.counts, required super.child});

  final _Counts counts;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderCounted(counts);
}

class _RenderCounted extends RenderProxyBox {
  _RenderCounted(this.counts);

  final _Counts counts;

  @override
  void performLayout() {
    counts.layouts++;
    super.performLayout();
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    counts.paints++;
    super.paint(context, offset);
  }
}
