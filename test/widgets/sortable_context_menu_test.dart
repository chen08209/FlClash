import 'dart:math' as math;

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/ui/icons/icons.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

class _Harness extends StatefulWidget {
  const _Harness({required this.sorting, required this.pressed});

  final bool sorting;
  final List<String> pressed;

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  var _items = ['a', 'b', 'c'];

  Widget _buildItem(int index) {
    final item = _items[index];
    return SortableItem(
      key: ValueKey(item),
      index: index,
      child: ContextMenuRegion(
        menuItems: [
          CommonPopupMenuItem(
            glyph: AppGlyphs.delete,
            label: 'Delete $item',
            onPressed: () => widget.pressed.add('delete $item'),
          ),
        ],
        child: DecorationListItem(
          title: Text(item),
          trailing: const GlyphIcon(AppGlyphs.info),
          onPressed: () => widget.pressed.add(item),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SortModeScope(
      sorting: widget.sorting,
      child: Scaffold(
        body: ReorderableListView.builder(
          buildDefaultDragHandles: false,
          itemCount: _items.length,
          itemBuilder: (_, index) => _buildItem(index),
          onReorderItem: (oldIndex, newIndex) {
            setState(() {
              _items = _items.copyAndReorder(oldIndex, newIndex);
            });
          },
        ),
      ),
    );
  }
}

Future<List<String>> _pump(
  WidgetTester tester, {
  bool sorting = false,
  bool remote = false,
}) async {
  final pressed = <String>[];
  await tester.pumpWidget(
    TestApp(
      homeBuilder: (child) => RemoteFocusAdapter(enabled: remote, child: child),
      child: _Harness(sorting: sorting, pressed: pressed),
    ),
  );
  await tester.pumpAndSettle();
  return pressed;
}

/// A row whose sync withdraws its menu, as a row does while its item updates,
/// rebuilding the app above the navigator with it.
Future<ValueNotifier<bool>> _pumpSyncing(WidgetTester tester) async {
  final syncing = ValueNotifier(false);
  addTearDown(syncing.dispose);
  await tester.pumpWidget(
    ValueListenableBuilder(
      valueListenable: syncing,
      builder: (_, value, _) => TestApp(
        child: Scaffold(
          body: ContextMenuRegion(
            menuItems: value
                ? null
                : [
                    CommonPopupMenuItem(
                      glyph: AppGlyphs.sync,
                      label: 'Sync',
                      onPressed: () => syncing.value = true,
                    ),
                  ],
            child: const DecorationListItem(title: Text('a')),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return syncing;
}

List<String> _order(WidgetTester tester, List<String> items) =>
    [...items]..sort(
      (a, b) => tester
          .getTopLeft(find.text(a))
          .dy
          .compareTo(tester.getTopLeft(find.text(b)).dy),
    );

Future<void> _rightClick(WidgetTester tester, String text) async {
  await tester.tap(
    find.text(text),
    buttons: kSecondaryButton,
    kind: PointerDeviceKind.mouse,
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('a right click opens the row menu', (tester) async {
    await _pump(tester);

    await _rightClick(tester, 'b');

    expect(find.text('Delete b'), findsOneWidget);
  });

  testWidgets('a touch long press opens the menu and leaves the row', (
    tester,
  ) async {
    final pressed = await _pump(tester);

    await tester.longPress(find.text('a'));
    await tester.pumpAndSettle();

    expect(find.text('Delete a'), findsOneWidget);
    expect(pressed, isEmpty);
  });

  testWidgets('an item that withdraws the menu lets the menu close', (
    tester,
  ) async {
    await _pumpSyncing(tester);
    await _rightClick(tester, 'a');

    await tester.tap(find.text('Sync'));
    await tester.pumpAndSettle();

    expect(find.text('Sync'), findsNothing);
  });

  testWidgets('a row that withdraws its menu closes the open one', (
    tester,
  ) async {
    final syncing = await _pumpSyncing(tester);
    await _rightClick(tester, 'a');

    syncing.value = true;
    await tester.pumpAndSettle();

    expect(find.text('Sync'), findsNothing);
  });

  testWidgets('a mouse long press opens nothing', (tester) async {
    await _pump(tester);

    await tester.longPress(find.text('a'), kind: PointerDeviceKind.mouse);
    await tester.pumpAndSettle();

    expect(find.text('Delete a'), findsNothing);
  });

  testWidgets('the menu key opens the menu of the focused row', (tester) async {
    await _pump(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.contextMenu);
    await tester.pumpAndSettle();

    expect(find.text('Delete a'), findsOneWidget);
  });

  testWidgets('sort mode swaps the trailing for a handle and stops taps', (
    tester,
  ) async {
    final pressed = await _pump(tester, sorting: true);

    expect(find.byType(SortHandle), findsNWidgets(3));
    expect(find.byGlyph(AppGlyphs.info).hitTestable(), findsNothing);

    await tester.tap(find.text('a'));
    await _rightClick(tester, 'a');
    await tester.longPress(find.text('a'));
    await tester.pumpAndSettle();

    expect(pressed, isEmpty);
    expect(find.text('Delete a'), findsNothing);
  });

  testWidgets('a sorting row drags on a long press anywhere on it, its '
      'handle included, and not on a plain press', (tester) async {
    await _pump(tester, sorting: true);
    final rowHeight =
        tester.getTopLeft(find.text('b')).dy -
        tester.getTopLeft(find.text('a')).dy;
    Future<void> dragDown(Offset from, {required bool hold}) async {
      final gesture = await tester.startGesture(from);
      await tester.pump(
        hold
            ? kLongPressTimeout + const Duration(milliseconds: 50)
            : kPressTimeout,
      );
      for (var step = 0; step < 4; step++) {
        await gesture.moveBy(Offset(0, rowHeight * 2 / 4 + 4));
        await tester.pump(const Duration(milliseconds: 50));
      }
      await gesture.up();
      await tester.pumpAndSettle();
    }

    await dragDown(
      tester.getCenter(find.byType(SortHandle).first),
      hold: false,
    );
    expect(_order(tester, ['a', 'b', 'c']), ['a', 'b', 'c']);

    await dragDown(tester.getCenter(find.text('a')), hold: true);
    expect(_order(tester, ['a', 'b', 'c']), ['b', 'c', 'a']);

    await dragDown(tester.getCenter(find.byType(SortHandle).first), hold: true);
    expect(_order(tester, ['a', 'b', 'c']), ['c', 'a', 'b']);
  });

  testWidgets(
    'the handle bounces in from the trailing edge and slides back out',
    (tester) async {
      final sorting = ValueNotifier(false);
      addTearDown(sorting.dispose);
      await tester.pumpWidget(
        TestApp(
          child: Scaffold(
            body: ValueListenableBuilder(
              valueListenable: sorting,
              builder: (_, value, _) => SortModeScope(
                sorting: value,
                child: const SortableItem(
                  index: 0,
                  child: DecorationListItem(
                    title: Text('a'),
                    trailing: GlyphIcon(AppGlyphs.info),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      sorting.value = true;
      await tester.pump();
      final path = <double>[];
      for (var frame = 0; frame < 40; frame++) {
        await tester.pump(const Duration(milliseconds: 16));
        path.add(tester.getTopLeft(find.byType(SortHandle)).dx);
      }
      await tester.pumpAndSettle();
      final settled = tester.getTopLeft(find.byType(SortHandle)).dx;
      expect(path.first, greaterThan(settled));
      expect(path.reduce(math.min), lessThan(settled - 4));

      sorting.value = false;
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(
        tester.getTopLeft(find.byType(SortHandle)).dx,
        greaterThan(settled),
      );
      await tester.pumpAndSettle();
      expect(find.byType(SortHandle), findsNothing);
      expect(find.byGlyph(AppGlyphs.info).hitTestable(), findsOneWidget);
    },
  );

  testWidgets('a held remote select opens the menu without pressing it', (
    tester,
  ) async {
    final pressed = await _pump(tester, remote: true);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.select);
    await tester.pump(kLongPressTimeout + const Duration(milliseconds: 50));
    await tester.pumpAndSettle();
    expect(find.text('Delete a'), findsOneWidget);
    await tester.sendKeyRepeatEvent(LogicalKeyboardKey.select);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();

    expect(find.text('Delete a'), findsOneWidget);
    expect(pressed, isEmpty);
  });

  testWidgets('a short remote select still presses the row', (tester) async {
    final pressed = await _pump(tester, remote: true);

    await tester.sendKeyDownEvent(LogicalKeyboardKey.select);
    await tester.pump(const Duration(milliseconds: 100));
    expect(pressed, isEmpty);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();

    expect(pressed, ['a']);
    expect(find.text('Delete a'), findsNothing);
  });

  testWidgets('without a remote, enter presses the row on key down', (
    tester,
  ) async {
    final pressed = await _pump(tester);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();

    await tester.sendKeyDownEvent(LogicalKeyboardKey.enter);
    await tester.pump();
    expect(pressed, ['a']);
    await tester.sendKeyUpEvent(LogicalKeyboardKey.enter);
  });

  testWidgets('a focused handle lifts its row and moves it with the arrows', (
    tester,
  ) async {
    await _pump(tester, sorting: true, remote: true);

    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    expect(_order(tester, ['a', 'b', 'c']), ['b', 'c', 'a']);

    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();
    expect(_order(tester, ['a', 'b', 'c']), ['b', 'c', 'a']);
  });
}
