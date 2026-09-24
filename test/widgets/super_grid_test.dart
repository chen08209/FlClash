import 'dart:async';

import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/widgets/grid.dart';
import 'package:fl_clash/widgets/super_grid.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/glyph_finders.dart';
import '../helpers/test_app.dart';

GridItem _item(String label, {int crossAxisCellCount = 2}) {
  return GridItem(
    key: ValueKey(label),
    crossAxisCellCount: crossAxisCellCount,
    mainAxisCellCount: 1,
    child: SizedBox(
      key: ValueKey('content-$label'),
      height: 100,
      child: ColoredBox(
        color: Colors.blue,
        child: Center(child: Text(label)),
      ),
    ),
  );
}

/// The shake never stops while editing, so pumpAndSettle would not return.
Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 30; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

Finder _content(String label) => find.byKey(ValueKey('content-$label'));

List<String> _labels(List<GridItem> items) {
  return [for (final item in items) (item.key! as ValueKey<String>).value];
}

class _Harness extends StatefulWidget {
  final GlobalKey<SuperGridState> gridKey;
  final List<String> labels;
  final bool editing;
  final ValueChanged<List<GridItem>>? onChanged;

  const _Harness({
    required this.gridKey,
    required this.labels,
    this.editing = true,
    this.onChanged,
  });

  @override
  State<_Harness> createState() => _HarnessState();
}

class _HarnessState extends State<_Harness> {
  late List<GridItem> _children = [
    for (final label in widget.labels) _item(label),
  ];

  @override
  Widget build(BuildContext context) {
    return TestApp(
      child: Scaffold(
        body: SingleChildScrollView(
          child: SuperGrid(
            key: widget.gridKey,
            editing: widget.editing,
            crossAxisCount: 4,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            onChanged: (items) {
              setState(() => _children = items);
              widget.onChanged?.call(items);
            },
            children: _children,
          ),
        ),
      ),
    );
  }
}

void main() {
  testWidgets('SuperGrid flies an added item into its slot', (tester) async {
    final key = GlobalKey<SuperGridState>();
    final changes = <List<String>>[];

    await tester.pumpWidget(
      _Harness(
        gridKey: key,
        labels: const ['A', 'B', 'C'],
        editing: false,
        onChanged: (items) => changes.add(_labels(items)),
      ),
    );

    unawaited(
      key.currentState!.addItem(
        _item('D', crossAxisCellCount: 4),
        from: const Rect.fromLTWH(500, 500, 100, 50),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(changes, [
      ['A', 'B', 'C', 'D'],
    ]);
    // The slot is laid out but hidden while an overlay copy flies in.
    expect(_content('D'), findsNWidgets(2));
    final slot = tester.getRect(_content('D').first);
    final copy = tester.getTopLeft(_content('D').last);
    expect(copy, isNot(slot.topLeft));

    await _settle(tester);

    expect(_content('D'), findsOneWidget);
    expect(tester.getRect(_content('D')), slot);
    expect(tester.takeException(), null);
  });

  testWidgets('SuperGrid fades a deleted item while its neighbours slide in', (
    tester,
  ) async {
    final key = GlobalKey<SuperGridState>();
    final changes = <List<String>>[];

    await tester.pumpWidget(
      _Harness(
        gridKey: key,
        labels: const ['A', 'B', 'C'],
        onChanged: (items) => changes.add(_labels(items)),
      ),
    );
    final bSlot = tester.getTopLeft(_content('B'));
    final cSlot = tester.getTopLeft(_content('C'));

    await tester.tap(find.byGlyph(AppGlyphs.close).at(1));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(changes, [
      ['A', 'C'],
    ]);
    expect(_content('B'), findsOneWidget);
    final cMoving = tester.getTopLeft(_content('C'));
    expect(cMoving.dx, inExclusiveRange(cSlot.dx, bSlot.dx));
    expect(cMoving.dy, inExclusiveRange(bSlot.dy, cSlot.dy));

    await _settle(tester);

    expect(_content('B'), findsNothing);
    // Within the shake's reach of B's old slot.
    expect(tester.getTopLeft(_content('C')), within(distance: 8, from: bSlot));
    expect(tester.takeException(), null);
  });

  testWidgets('SuperGrid shrinks over the motion when its last row leaves', (
    tester,
  ) async {
    final key = GlobalKey<SuperGridState>();
    final labels = [for (var i = 0; i < 13; i++) 'item-$i'];

    await tester.pumpWidget(_Harness(gridKey: key, labels: labels));
    final position = tester
        .state<ScrollableState>(find.byType(Scrollable))
        .position;
    position.jumpTo(position.maxScrollExtent);
    await tester.pump();
    final before = position.pixels;

    await tester.tap(find.byGlyph(AppGlyphs.close).last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));

    final early = position.pixels;

    await _settle(tester);

    final settled = position.maxScrollExtent;
    expect(settled, lessThan(before));
    expect(position.pixels, closeTo(settled, 0.5));
    expect(early, greaterThan((before + settled) / 2));
    expect(tester.takeException(), null);
  });

  testWidgets('SuperGrid moves the dragged item into the hovered slot', (
    tester,
  ) async {
    final key = GlobalKey<SuperGridState>();
    final changes = <List<String>>[];

    await tester.pumpWidget(
      _Harness(
        gridKey: key,
        labels: const ['A', 'B', 'C', 'D'],
        onChanged: (items) => changes.add(_labels(items)),
      ),
    );

    final target = tester.getCenter(_content('D'));
    final gesture = await tester.startGesture(tester.getCenter(_content('A')));
    await tester.pump();
    await gesture.moveBy(const Offset(10, 0));
    await tester.pump();
    await gesture.moveTo(target);
    // Past the hover delay, so the grid opens a slot at D's position.
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 500));
    expect(changes, isEmpty);
    await gesture.up();
    await _settle(tester);

    expect(_labels(key.currentState!.items), ['B', 'C', 'D', 'A']);
    expect(changes, [
      ['B', 'C', 'D', 'A'],
    ]);
    expect(_content('A'), findsOneWidget);
    expect(tester.takeException(), null);
  });

  testWidgets('SuperGrid keeps item state when editing toggles', (
    tester,
  ) async {
    final key = GlobalKey<SuperGridState>();

    await tester.pumpWidget(
      _Harness(gridKey: key, labels: const ['A', 'B'], editing: false),
    );
    final element = tester.element(_content('A'));

    await tester.pumpWidget(_Harness(gridKey: key, labels: const ['A', 'B']));
    await tester.pump();
    expect(find.byGlyph(AppGlyphs.close), findsNWidgets(2));
    expect(tester.element(_content('A')), same(element));

    await tester.pumpWidget(
      _Harness(gridKey: key, labels: const ['A', 'B'], editing: false),
    );
    await tester.pump();
    expect(find.byGlyph(AppGlyphs.close), findsNothing);
    expect(tester.element(_content('A')), same(element));
  });

  testWidgets('SuperGrid keeps the dragged item state through the drag', (
    tester,
  ) async {
    final key = GlobalKey<SuperGridState>();

    await tester.pumpWidget(
      _Harness(gridKey: key, labels: const ['A', 'B', 'C', 'D']),
    );
    final element = tester.element(_content('A'));

    final gesture = await tester.startGesture(tester.getCenter(_content('A')));
    await tester.pump();
    await gesture.moveBy(const Offset(10, 0));
    await tester.pump();
    await gesture.moveTo(tester.getCenter(_content('D')));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      find.byElementPredicate((candidate) => identical(candidate, element)),
      findsOneWidget,
    );
    await gesture.up();
    await _settle(tester);

    expect(_labels(key.currentState!.items), ['B', 'C', 'D', 'A']);
    expect(tester.element(_content('A')), same(element));
  });

  testWidgets('SuperGrid drops a flight when disposed mid-air', (tester) async {
    final key = GlobalKey<SuperGridState>();

    await tester.pumpWidget(_Harness(gridKey: key, labels: const ['A', 'B']));
    unawaited(
      key.currentState!.addItem(
        _item('C'),
        from: const Rect.fromLTWH(400, 400, 100, 50),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
    await tester.pump(const Duration(seconds: 2));

    expect(_content('C'), findsNothing);
    expect(tester.takeException(), null);
  });
}
