import 'dart:async';

import 'package:fl_clash/providers/app.dart';
import 'package:fl_clash/widgets/paged_sheet.dart';
import 'package:fl_clash/widgets/scaffold.dart';
import 'package:fl_clash/widgets/sheet.dart';
import 'package:fl_clash/widgets/sheet_navigator.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

const _view = Size(400, 900);
const _stackedWidth = 400 * stackedSheetScale;

const _nestedProps = SheetProps(
  backgroundColor: Colors.transparent,
  transition: SheetTransition.stack,
);

Widget _page(String name, int rows, {VoidCallback? onNext}) {
  return CommonScaffold(
    key: ValueKey(name),
    title: 'Page $name',
    body: ListView(
      shrinkWrap: true,
      children: [
        for (var index = 0; index < rows; index++)
          ListTile(title: Text('$name row $index'), onTap: () {}),
        if (onNext != null) ListTile(title: const Text('next'), onTap: onNext),
      ],
    ),
  );
}

Rect _rectOf(WidgetTester tester, String page) =>
    tester.getRect(find.byKey(ValueKey(page)));

void main() {
  Future<void> openSheet(
    WidgetTester tester,
    WidgetBuilder builder, {
    required SheetProps props,
  }) async {
    tester.view.physicalSize = _view;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      TestApp(
        overrides: [viewSizeProvider.overrideWithBuild((_, _) => _view)],
        child: Builder(
          builder: (context) => TextButton(
            onPressed: () => unawaited(
              showSheet<void>(context: context, props: props, builder: builder),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  Widget nested(BuildContext context) => NestedPagedSheet(
    builder: (context) => _page(
      'A',
      6,
      onNext: () => Navigator.of(
        context,
      ).push(PagedSheetRoute(builder: (_) => _page('B', 2))),
    ),
  );

  testWidgets('a stacking nested sheet shrinks the page it covers back and '
      'lets it peek above the new one', (tester) async {
    await openSheet(tester, nested, props: _nestedProps);
    final rest = _rectOf(tester, 'A');
    expect(rest.width, 400);

    await tester.tap(find.text('next'));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final mid = _rectOf(tester, 'A').width;
    expect(mid, inExclusiveRange(_stackedWidth, 400));

    await tester.pumpAndSettle();
    final covered = _rectOf(tester, 'A');
    final page = _rectOf(tester, 'B');
    expect(covered.width, closeTo(_stackedWidth, 0.1));
    expect(page.width, 400);
    expect(page.top - covered.top, closeTo(stackedSheetPeek, 0.1));

    tester.state<NavigatorState>(find.byType(SheetPagesNavigator)).pop();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('B')), findsNothing);
    expect(_rectOf(tester, 'A').width, 400);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a page dragged back out of a stacking sheet grows the one '
      'below back as it goes', (tester) async {
    await openSheet(tester, nested, props: _nestedProps);
    await tester.tap(find.text('next'));
    await tester.pumpAndSettle();

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('B row 1')),
    );
    await gesture.moveBy(const Offset(40, 0));
    await gesture.moveBy(const Offset(160, 0));
    await tester.pump();
    expect(_rectOf(tester, 'A').width, inExclusiveRange(_stackedWidth, 400));

    await gesture.moveBy(const Offset(150, 0));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('B')), findsNothing);
    expect(_rectOf(tester, 'A').width, 400);
  });

  Widget threePages(BuildContext context) => NestedPagedSheet(
    builder: (context) => _page(
      'A',
      2,
      onNext: () => Navigator.of(context).push(
        PagedSheetRoute(
          builder: (context) => _page(
            'B',
            6,
            onNext: () => Navigator.of(
              context,
            ).push(PagedSheetRoute(builder: (_) => _page('C', 2))),
          ),
        ),
      ),
    ),
  );

  Future<void> openThreePages(WidgetTester tester) async {
    await openSheet(tester, threePages, props: _nestedProps);
    await tester.tap(find.text('next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('next').last);
    await tester.pumpAndSettle();
  }

  testWidgets('the page a stacking sheet uncovers takes no drag back until '
      'the page over it is gone', (tester) async {
    await openThreePages(tester);
    final below = _rectOf(tester, 'B');
    tester.state<NavigatorState>(find.byType(SheetPagesNavigator)).pop();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));

    final popping = _rectOf(tester, 'C');
    await tester.timedDragFrom(
      Offset(below.center.dx, (below.top + popping.top) / 2),
      const Offset(400, 0),
      const Duration(milliseconds: 300),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('C')), findsNothing);
    expect(find.byKey(const ValueKey('B')), findsOneWidget);
  });

  testWidgets('a back pressed while a drag back settles goes back once more', (
    tester,
  ) async {
    await openSheet(tester, threePages, props: _nestedProps);
    final rest = _rectOf(tester, 'A');
    await tester.tap(find.text('next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('next').last);
    await tester.pumpAndSettle();

    await tester.fling(find.text('C row 1'), const Offset(300, 0), 2000);
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('C')), findsNothing);
    expect(find.byKey(const ValueKey('B')), findsNothing);
    expect(_rectOf(tester, 'A'), rest);
  });

  testWidgets('a sliding nested sheet still hides the page it covers', (
    tester,
  ) async {
    await openSheet(tester, nested, props: nestedPagedSheetProps);
    await tester.tap(find.text('next'));
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('A')), findsNothing);
    expect(_rectOf(tester, 'B').width, 400);
  });

  testWidgets('a sheet shrinks back behind a sheet opened over it but not '
      'behind a dialog', (tester) async {
    late BuildContext sheetContext;
    await openSheet(tester, (context) {
      sheetContext = context;
      return _page('A', 8);
    }, props: const SheetProps());
    final rest = _rectOf(tester, 'A');

    unawaited(
      showSheet<void>(context: sheetContext, builder: (_) => _page('B', 2)),
    );
    await tester.pumpAndSettle();
    final covered = _rectOf(tester, 'A');
    expect(covered.width, closeTo(_stackedWidth, 0.1));
    expect(covered.top, closeTo(rest.top - stackedSheetPeek, 0.1));
    expect(covered.center.dx, closeTo(rest.center.dx, 0.1));

    Navigator.of(sheetContext).pop();
    await tester.pumpAndSettle();
    expect(_rectOf(tester, 'A'), rest);

    unawaited(
      showDialog<void>(
        context: sheetContext,
        builder: (_) => const AlertDialog(content: Text('dialog')),
      ),
    );
    await tester.pumpAndSettle();
    expect(_rectOf(tester, 'A'), rest);
  });

  testWidgets('a sheet grows back as the sheet over it is dragged away', (
    tester,
  ) async {
    late BuildContext sheetContext;
    await openSheet(tester, (context) {
      sheetContext = context;
      return _page('A', 8);
    }, props: const SheetProps());
    final rest = _rectOf(tester, 'A');
    unawaited(
      showSheet<void>(context: sheetContext, builder: (_) => _page('B', 8)),
    );
    await tester.pumpAndSettle();
    expect(_rectOf(tester, 'A').width, closeTo(_stackedWidth, 0.1));

    final covering = _rectOf(tester, 'B');
    final gesture = await tester.startGesture(
      covering.topCenter.translate(0, 8),
    );
    await gesture.moveBy(const Offset(0, 20));
    await gesture.moveBy(Offset(0, covering.height / 2 - 20));
    await tester.pump();
    expect(
      _rectOf(tester, 'A').width,
      closeTo(400 - (400 - _stackedWidth) / 2, 1),
    );

    await gesture.moveBy(Offset(0, -covering.height / 2));
    await tester.pump();
    expect(_rectOf(tester, 'A').width, closeTo(_stackedWidth, 0.1));

    await gesture.moveBy(Offset(0, covering.height * 0.8));
    await gesture.up();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('B')), findsNothing);
    expect(_rectOf(tester, 'A'), rest);
  });
}
