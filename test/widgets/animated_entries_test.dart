import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildEntries(List<String> items, {bool grouped = false}) {
    return MaterialApp(
      home: Scaffold(
        body: AnimatedEntries(
          grouped: grouped,
          children: [
            for (final item in items)
              SizedBox(
                key: ValueKey(item),
                height: 40,
                child: Builder(
                  builder: (context) => Text(
                    '$item ${ItemPositionProvider.of(context)?.position.name}',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Finder row(String item) => find.byWidgetPredicate(
    (widget) => widget is SizedBox && widget.key == ValueKey(item),
  );

  double topOf(WidgetTester tester, String item) =>
      tester.getTopLeft(row(item)).dy;

  test('keepLeaving holds a removed item before the one it preceded', () {
    expect(keepLeaving(['a', 'b', 'c', 'd'], ['a', 'd', 'e'], (item) => item), [
      'a',
      'b',
      'c',
      'd',
      'e',
    ]);
    expect(keepLeaving(['a', 'b'], ['b', 'a'], (item) => item), ['b', 'a']);
    expect(keepLeaving(['a', 'b'], ['a'], (item) => item), ['a', 'b']);
  });

  testWidgets('a removed entry collapses before leaving the tree', (
    tester,
  ) async {
    await tester.pumpWidget(buildEntries(const ['a', 'b', 'c']));
    await tester.pumpWidget(buildEntries(const ['a', 'c']));
    await tester.pump();

    expect(row('b'), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 150));
    expect(topOf(tester, 'c'), inExclusiveRange(40, 80));

    await tester.pumpAndSettle();
    expect(row('b'), findsNothing);
    expect(topOf(tester, 'c'), 40);
  });

  testWidgets('an added entry grows in', (tester) async {
    await tester.pumpWidget(buildEntries(const ['a', 'c']));
    await tester.pumpWidget(buildEntries(const ['a', 'b', 'c']));
    await tester.pump(const Duration(milliseconds: 150));

    expect(topOf(tester, 'c'), inExclusiveRange(40, 80));
    await tester.pumpAndSettle();
    expect(topOf(tester, 'c'), 80);
  });

  testWidgets('an entry put back while collapsing grows back', (tester) async {
    await tester.pumpWidget(buildEntries(const ['a', 'b', 'c']));
    await tester.pumpWidget(buildEntries(const ['a', 'c']));
    await tester.pump(const Duration(milliseconds: 150));
    await tester.pumpWidget(buildEntries(const ['a', 'b', 'c']));

    await tester.pumpAndSettle();
    expect(row('b'), findsOneWidget);
    expect(topOf(tester, 'c'), 80);
  });

  testWidgets('grouped rows close up while a leaving one keeps its place', (
    tester,
  ) async {
    await tester.pumpWidget(buildEntries(const ['a', 'b', 'c'], grouped: true));
    expect(find.text('c ${ItemPosition.end.name}'), findsOneWidget);

    await tester.pumpWidget(buildEntries(const ['a', 'b'], grouped: true));
    await tester.pump();
    expect(find.text('b ${ItemPosition.end.name}'), findsOneWidget);
    expect(find.text('c ${ItemPosition.end.name}'), findsOneWidget);

    await tester.pumpAndSettle();
    expect(row('c'), findsNothing);
  });
}
