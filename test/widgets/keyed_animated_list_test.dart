import 'package:fl_clash/widgets/keyed_animated_list.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildList(List<String> items) {
    return MaterialApp(
      home: Scaffold(
        body: KeyedAnimatedList<String>(
          items: items,
          keyOf: (item) => item,
          separator: const Divider(height: 0),
          itemBuilder: (_, item) => SizedBox(
            key: ValueKey('row-$item'),
            height: 40,
            child: Text(item),
          ),
        ),
      ),
    );
  }

  double topOf(WidgetTester tester, String item) {
    return tester.getTopLeft(find.byKey(ValueKey('row-$item'))).dy;
  }

  testWidgets('removed item collapses before leaving the tree', (tester) async {
    await tester.pumpWidget(buildList(const ['a', 'b', 'c']));
    await tester.pumpWidget(buildList(const ['a', 'c']));
    await tester.pump();

    expect(find.text('b'), findsOneWidget);
    final midway = topOf(tester, 'c');
    await tester.pump(const Duration(milliseconds: 150));
    expect(topOf(tester, 'c'), lessThan(midway));

    await tester.pumpAndSettle();
    expect(find.text('b'), findsNothing);
    expect(topOf(tester, 'c'), 40);
  });

  testWidgets('reordered item slides from its old slot', (tester) async {
    await tester.pumpWidget(buildList(const ['a', 'b', 'c']));
    expect(topOf(tester, 'c'), 80);

    await tester.pumpWidget(buildList(const ['c', 'a', 'b']));
    await tester.pump();

    final render = tester.renderObject(find.byKey(const ValueKey('row-c')));
    Offset paintedTop() => (render as RenderBox).localToGlobal(Offset.zero);
    expect(paintedTop().dy, closeTo(80, 0.01));

    await tester.pump(const Duration(milliseconds: 150));
    final midway = paintedTop().dy;
    expect(midway, greaterThan(0));
    expect(midway, lessThan(80));

    await tester.pumpAndSettle();
    expect(paintedTop().dy, closeTo(0, 0.01));
    expect(tester.takeException(), null);
  });

  testWidgets('item removed and re-added keeps a single row', (tester) async {
    await tester.pumpWidget(buildList(const ['a', 'b']));
    await tester.pumpWidget(buildList(const ['a']));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pumpWidget(buildList(const ['a', 'b']));
    await tester.pumpAndSettle();

    expect(find.text('b'), findsOneWidget);
    expect(topOf(tester, 'b'), 40);
  });
}
