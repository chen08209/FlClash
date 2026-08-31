import 'package:fl_clash/widgets/grid.dart';
import 'package:fl_clash/widgets/super_grid.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

GridItem _item(String label, {int crossAxisCellCount = 2}) {
  return GridItem(
    crossAxisCellCount: crossAxisCellCount,
    mainAxisCellCount: 1,
    child: SizedBox(
      key: ValueKey(label),
      height: 100,
      child: ColoredBox(
        color: Colors.blue,
        child: Center(child: Text(label)),
      ),
    ),
  );
}

void main() {
  testWidgets('SuperGrid adds and deletes items while reporting updates', (
    tester,
  ) async {
    final key = GlobalKey<SuperGridState>();
    var updates = 0;

    await tester.pumpWidget(
      TestApp(
        child: Scaffold(
          body: SingleChildScrollView(
            child: SuperGrid(
              key: key,
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              onUpdate: () => updates++,
              children: [_item('A'), _item('B'), _item('C')],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(key.currentState!.length, 3);
    expect(find.byIcon(Icons.close), findsNWidgets(3));

    key.currentState!.handleAdd(_item('D', crossAxisCellCount: 4));
    await tester.pump();
    expect(key.currentState!.length, 4);
    expect(find.byKey(const ValueKey('D')), findsOneWidget);

    final deleteButton = tester.widget<IconButton>(
      find.ancestor(
        of: find.byIcon(Icons.close).at(1),
        matching: find.byType(IconButton),
      ),
    );
    deleteButton.onPressed!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 301));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 421));
    await tester.pump();
    expect(key.currentState!.length, 3);
    expect(find.byKey(const ValueKey('B')), findsNothing);
    expect(updates, greaterThanOrEqualTo(2));
    expect(tester.takeException(), null);
  });

  testWidgets('SuperGrid handles a desktop drag and keeps items mounted', (
    tester,
  ) async {
    final key = GlobalKey<SuperGridState>();

    await tester.pumpWidget(
      TestApp(
        child: Scaffold(
          body: SingleChildScrollView(
            child: SuperGrid(
              key: key,
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [_item('A'), _item('B'), _item('C'), _item('D')],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('A'))),
    );
    await tester.pump();
    await gesture.moveBy(const Offset(10, 0));
    await tester.pump();
    await gesture.moveTo(tester.getCenter(find.byKey(const ValueKey('D'))));
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.up();
    await tester.pump(const Duration(seconds: 2));

    expect(key.currentState!.length, 4);
    for (final label in ['A', 'B', 'C', 'D']) {
      expect(find.byKey(ValueKey(label)), findsOneWidget);
    }
    expect(tester.takeException(), null);
  });

  testWidgets('SuperGrid moves the dragged item into the hovered slot', (
    tester,
  ) async {
    final key = GlobalKey<SuperGridState>();

    await tester.pumpWidget(
      TestApp(
        child: Scaffold(
          body: SingleChildScrollView(
            child: SuperGrid(
              key: key,
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [_item('A'), _item('B'), _item('C'), _item('D')],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    List<String> labels() => key.currentState!.snapshotChildren
        .map(
          (item) => ((item.child as SizedBox).key! as ValueKey).value as String,
        )
        .toList();

    expect(labels(), ['A', 'B', 'C', 'D']);

    final target = tester.getCenter(find.byKey(const ValueKey('D')));
    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('A'))),
    );
    await tester.pump();
    await gesture.moveBy(const Offset(10, 0));
    await tester.pump();
    await gesture.moveTo(target);
    // Past the hover delay, so the grid opens a slot at D's position.
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pump(const Duration(milliseconds: 500));
    await gesture.up();
    await tester.pump(const Duration(seconds: 2));

    expect(labels(), ['B', 'C', 'D', 'A']);
    expect(tester.takeException(), null);
  });

  testWidgets('SuperGrid completes a pending drop when disposed', (
    tester,
  ) async {
    final key = GlobalKey<SuperGridState>();

    await tester.pumpWidget(
      TestApp(
        child: Scaffold(
          body: SingleChildScrollView(
            child: SuperGrid(
              key: key,
              crossAxisCount: 4,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [_item('A'), _item('B'), _item('C'), _item('D')],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final gesture = await tester.startGesture(
      tester.getCenter(find.byKey(const ValueKey('A'))),
    );
    await tester.pump();
    await gesture.moveBy(const Offset(10, 0));
    await tester.pump();
    await gesture.moveTo(tester.getCenter(find.byKey(const ValueKey('D'))));
    await tester.pump(const Duration(milliseconds: 300));
    await gesture.up();
    await tester.pump();

    final transformCompleted = key.currentState!.isTransformCompleter;
    await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));

    expect(await transformCompleted, isFalse);
    await tester.pump(const Duration(seconds: 2));
    expect(tester.takeException(), null);
  });
}
