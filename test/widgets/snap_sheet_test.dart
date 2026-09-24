import 'dart:async';
import 'dart:math';

import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:fl_clash/widgets/sheet.dart';
import 'package:fl_clash/widgets/sheet_header.dart';
import 'package:fl_clash/widgets/side_sheet.dart';
import 'package:fl_clash/widgets/snap_sheet.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

const _mobile = Size(400, 900);
const _desktop = Size(1200, 900);

Widget _sheet(BuildContext context, ScrollController? controller) {
  return CommonScaffold(
    title: 'title',
    body: ListView.builder(
      controller: controller,
      itemCount: 60,
      // Past the floating header, so it can be tapped.
      itemBuilder: (context, index) => index == 3
          ? TextButton(
              onPressed: () => Navigator.of(context).pop('done'),
              child: const Text('done'),
            )
          : SizedBox(height: 40, child: Text('$index')),
    ),
  );
}

void main() {
  Future<void> setView(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    ProviderScope.containerOf(
      tester.element(find.text('open')),
    ).read(viewSizeProvider.notifier).value = size;
    await tester.pumpAndSettle();
  }

  Future<Future<Object?>> openSheet(
    WidgetTester tester, {
    SnapSheetBuilder builder = _sheet,
  }) async {
    tester.view.physicalSize = _mobile;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    late Future<Object?> result;
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () {
              result = showSnapSheet<Object?>(context, builder: builder);
            },
            child: const Text('open'),
          ),
        ),
      ),
    );
    await setView(tester, _mobile);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return result;
  }

  double sheetTop(WidgetTester tester) =>
      tester.getTopLeft(find.byType(SheetDragHandle)).dy;

  double contentOffset(WidgetTester tester) => tester
      .state<ScrollableState>(find.byType(Scrollable).last)
      .position
      .pixels;

  Finder content() => find.byType(Scrollable).last;

  Future<void> close(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 2));
  }

  testWidgets('a drag on a collapsed sheet expands it and leaves the content '
      'where it was', (tester) async {
    await openSheet(tester);
    final collapsed = _mobile.height * (1 - snapSheetDetents.first);
    final expanded = _mobile.height * (1 - snapSheetDetents.last);
    expect(sheetTop(tester), closeTo(collapsed, 1));

    await tester.drag(content(), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(sheetTop(tester), closeTo(expanded, 1));
    expect(contentOffset(tester), 0);

    await tester.drag(content(), const Offset(0, -100));
    await tester.pumpAndSettle();

    expect(sheetTop(tester), closeTo(expanded, 1));
    expect(contentOffset(tester), greaterThan(0));

    await close(tester);
  });

  testWidgets('the keyboard raises the sheet without rebuilding its content', (
    tester,
  ) async {
    var builds = 0;
    await openSheet(
      tester,
      builder: (context, controller) {
        builds++;
        return _sheet(context, controller);
      },
    );
    addTearDown(tester.view.resetViewInsets);
    final shown = builds;

    for (final height in [100.0, 200.0, 300.0]) {
      tester.view.viewInsets = FakeViewPadding(bottom: height);
      await tester.pump();
    }
    expect(builds, shown);

    await tester.pumpAndSettle();
    expect(
      sheetTop(tester),
      closeTo(_mobile.height * (1 - snapSheetDetents.last), 1),
    );

    await close(tester);
  });

  testWidgets('a drag down past half of the collapsed sheet closes it', (
    tester,
  ) async {
    final result = await openSheet(tester);
    var closed = false;
    unawaited(result.then((_) => closed = true));

    await tester.drag(content(), const Offset(0, 300));
    await tester.pumpAndSettle();

    expect(closed, isTrue);
    expect(find.text('title'), findsNothing);

    await close(tester);
  });

  testWidgets('a short drag down springs the collapsed sheet back and a fling '
      'down closes it', (tester) async {
    final result = await openSheet(tester);
    var closed = false;
    unawaited(result.then((_) => closed = true));
    final collapsed = _mobile.height * (1 - snapSheetDetents.first);

    await tester.drag(content(), const Offset(0, 80));
    await tester.pumpAndSettle();

    expect(closed, isFalse);
    expect(sheetTop(tester), closeTo(collapsed, 1));

    await tester.fling(content(), const Offset(0, 80), 1500);
    await tester.pumpAndSettle();

    expect(closed, isTrue);

    await close(tester);
  });

  testWidgets('a tap while the sheet settles stays off its content', (
    tester,
  ) async {
    final result = await openSheet(tester);
    var closed = false;
    unawaited(result.then((_) => closed = true));

    await tester.fling(content(), const Offset(0, -100), 1000);
    await tester.pump(const Duration(milliseconds: 100));
    await tester.tap(find.text('done'), warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(closed, isFalse);

    await tester.tap(find.text('done'));
    await tester.pumpAndSettle();

    expect(closed, isTrue);

    await close(tester);
  });

  testWidgets('the content takes taps again once the sheet looks still', (
    tester,
  ) async {
    final result = await openSheet(tester);
    var closed = false;
    unawaited(result.then((_) => closed = true));

    await tester.fling(content(), const Offset(0, -100), 1000);
    for (var i = 0; i < 42; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.tap(find.text('done'));
    await tester.pump();

    expect(closed, isTrue);

    await close(tester);
  });

  testWidgets('a short flick up lands on the detent its velocity projects to', (
    tester,
  ) async {
    await openSheet(tester);
    final collapsed = _mobile.height * (1 - snapSheetDetents.first);
    final expanded = _mobile.height * (1 - snapSheetDetents.last);

    await tester.drag(content(), const Offset(0, -60));
    await tester.pumpAndSettle();
    expect(sheetTop(tester), closeTo(collapsed, 1));

    await tester.fling(content(), const Offset(0, -60), 800);
    await tester.pumpAndSettle();
    expect(sheetTop(tester), closeTo(expanded, 1));

    await close(tester);
  });

  testWidgets('a hard fling up settles without overshooting the detent', (
    tester,
  ) async {
    await openSheet(tester);
    final expanded = _mobile.height * (1 - snapSheetDetents.last);

    await tester.fling(content(), const Offset(0, -100), 8000);
    var highest = sheetTop(tester);
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 16));
      highest = min(highest, sheetTop(tester));
    }

    expect(highest, greaterThan(expanded - 1));

    await close(tester);
  });

  testWidgets('a sideways wheel tick leaves a settling sheet on its way', (
    tester,
  ) async {
    await openSheet(tester);
    final expanded = _mobile.height * (1 - snapSheetDetents.last);
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(pointer.hover(tester.getCenter(content())));

    await tester.sendEventToBinding(pointer.scroll(const Offset(0, 50)));
    await tester.pump(const Duration(milliseconds: 30));
    await tester.sendEventToBinding(pointer.scroll(const Offset(50, 0)));
    await tester.pumpAndSettle();

    expect(sheetTop(tester), closeTo(expanded, 1));

    await close(tester);
  });

  testWidgets('a collapsed sheet fits its content on screen', (tester) async {
    await openSheet(tester);

    expect(
      tester.getBottomLeft(content()).dy,
      lessThanOrEqualTo(_mobile.height),
    );

    await close(tester);
  });

  testWidgets('a second drag up while the sheet expands scrolls the content '
      'at once and the sheet still opens', (tester) async {
    await openSheet(tester);
    final expanded = _mobile.height * (1 - snapSheetDetents.last);

    await tester.fling(content(), const Offset(0, -100), 1000);
    await tester.pump(const Duration(milliseconds: 100));
    expect(sheetTop(tester), greaterThan(expanded + 1));
    expect(contentOffset(tester), 0);

    await tester.drag(content(), const Offset(0, -300));
    await tester.pumpAndSettle();

    expect(sheetTop(tester), closeTo(expanded, 1));
    expect(contentOffset(tester), closeTo(300 - kDragSlopDefault, 1));

    await close(tester);
  });

  testWidgets('a drag down while the sheet expands takes it back', (
    tester,
  ) async {
    await openSheet(tester);
    final collapsed = _mobile.height * (1 - snapSheetDetents.first);

    await tester.fling(content(), const Offset(0, -100), 1000);
    await tester.pump(const Duration(milliseconds: 100));

    await tester.drag(content(), const Offset(0, 150));
    await tester.pumpAndSettle();

    expect(sheetTop(tester), closeTo(collapsed, 1));
    expect(contentOffset(tester), 0);

    await close(tester);
  });

  testWidgets('a wheel tick on a collapsed sheet expands it and leaves the '
      'content where it was', (tester) async {
    await openSheet(tester);
    final expanded = _mobile.height * (1 - snapSheetDetents.last);
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    final location = tester.getCenter(content());
    await tester.sendEventToBinding(pointer.hover(location));

    await tester.sendEventToBinding(pointer.scroll(const Offset(0, 50)));
    await tester.pumpAndSettle();

    expect(sheetTop(tester), closeTo(expanded, 1));
    expect(contentOffset(tester), 0);

    await tester.sendEventToBinding(pointer.scroll(const Offset(0, 50)));
    await tester.pumpAndSettle();

    expect(sheetTop(tester), closeTo(expanded, 1));
    expect(contentOffset(tester), 50);

    await close(tester);
  });

  testWidgets('a wheel tick on a sheet too short to scroll expands it', (
    tester,
  ) async {
    await openSheet(
      tester,
      builder: (_, controller) => CommonScaffold(
        title: 'title',
        body: ListView(
          controller: controller,
          children: const [SizedBox(height: 40, child: Text('0'))],
        ),
      ),
    );
    final expanded = _mobile.height * (1 - snapSheetDetents.last);
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(pointer.hover(tester.getCenter(content())));

    await tester.sendEventToBinding(pointer.scroll(const Offset(0, 50)));
    await tester.pumpAndSettle();

    expect(sheetTop(tester), closeTo(expanded, 1));

    await close(tester);
  });

  testWidgets('a wheel turn that scrolls the content to its top leaves the '
      'sheet where it is, and the next turn takes it down', (tester) async {
    await openSheet(tester);
    final collapsed = _mobile.height * (1 - snapSheetDetents.first);
    final expanded = _mobile.height * (1 - snapSheetDetents.last);
    final pointer = TestPointer(1, PointerDeviceKind.mouse);
    await tester.sendEventToBinding(pointer.hover(tester.getCenter(content())));
    await tester.sendEventToBinding(pointer.scroll(const Offset(0, 50)));
    await tester.pumpAndSettle();
    await tester.sendEventToBinding(pointer.scroll(const Offset(0, 50)));
    await tester.pumpAndSettle();
    expect(contentOffset(tester), 50);

    for (var tick = 0; tick < 4; tick++) {
      await tester.sendEventToBinding(
        pointer.scroll(
          const Offset(0, -50),
          timeStamp: Duration(seconds: 1, milliseconds: 16 * tick),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));
    }
    await tester.pumpAndSettle();

    expect(contentOffset(tester), 0);
    expect(sheetTop(tester), closeTo(expanded, 1));

    await tester.sendEventToBinding(
      pointer.scroll(
        const Offset(0, -50),
        timeStamp: const Duration(seconds: 2),
      ),
    );
    await tester.pumpAndSettle();

    expect(sheetTop(tester), closeTo(collapsed, 1));

    await close(tester);
  });

  testWidgets('a settle cut short by a resize lands on the detent of the new '
      'size', (tester) async {
    await openSheet(tester);
    await tester.drag(content(), const Offset(0, -300));
    await tester.pumpAndSettle();

    await tester.fling(content(), const Offset(0, 120), 900);
    await tester.pump(const Duration(milliseconds: 30));

    const shorter = Size(400, 500);
    await setView(tester, shorter);

    expect(
      sheetTop(tester),
      closeTo(shorter.height * (1 - snapSheetDetents.first), 1),
    );

    await close(tester);
  });

  testWidgets('the sheet follows the view across the mobile breakpoint and '
      'reports the result of the form it closes in', (tester) async {
    final result = await openSheet(tester);
    Object? closedWith;
    var closed = false;
    unawaited(
      result.then((value) {
        closedWith = value;
        closed = true;
      }),
    );
    expect(find.byType(SheetDragHandle), findsOneWidget);

    await setView(tester, _desktop);

    expect(find.byType(SideSheet), findsOneWidget);
    expect(find.byType(SheetDragHandle), findsNothing);
    expect(find.text('title'), findsOneWidget);

    await setView(tester, _mobile);

    expect(find.byType(SideSheet), findsNothing);
    expect(find.byType(SheetDragHandle), findsOneWidget);

    expect(closed, isFalse);
    await tester.tap(find.text('done'));
    await tester.pumpAndSettle();

    expect(closed, isTrue);
    expect(closedWith, 'done');
    expect(find.text('title'), findsNothing);

    await close(tester);
  });

  testWidgets('a side sheet on a page navigator the mobile layout drops comes '
      'back as a bottom sheet', (tester) async {
    tester.view.physicalSize = _desktop;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    late Future<Object?> result;
    final page = Builder(
      key: GlobalKey(),
      builder: (context) => TextButton(
        onPressed: () {
          result = showSnapSheet<Object?>(context, builder: _sheet);
        },
        child: const Text('open'),
      ),
    );
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: Consumer(
          builder: (context, ref, _) => ref.watch(isMobileViewProvider)
              ? page
              : Navigator(
                  pages: [MaterialPage<void>(child: page)],
                  onDidRemovePage: (_) {},
                ),
        ),
      ),
    );
    await setView(tester, _desktop);
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.byType(SideSheet), findsOneWidget);
    Object? closedWith;
    var closed = false;
    unawaited(
      result.then((value) {
        closedWith = value;
        closed = true;
      }),
    );

    await setView(tester, _mobile);

    expect(find.byType(SideSheet), findsNothing);
    expect(find.byType(SheetDragHandle), findsOneWidget);
    expect(closed, isFalse);

    await tester.tap(find.text('done'));
    await tester.pumpAndSettle();

    expect(closed, isTrue);
    expect(closedWith, 'done');

    await close(tester);
  });
}
