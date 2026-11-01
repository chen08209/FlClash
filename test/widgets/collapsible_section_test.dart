import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';
import 'package:prism_ui/prism_ui.dart';

void main() {
  Future<void> pumpSection(WidgetTester tester, int count) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      TestApp(
        child: Surface(
          child: CustomScrollView(
            slivers: [
              SliverCollapsibleSection(
                label: 'Nodes',
                itemCount: count,
                itemBuilder: (_, index) =>
                    SizedBox(height: 64, child: Text('n$index')),
              ),
            ],
          ),
        ),
      ),
    );
  }

  double opacityOf(WidgetTester tester, String text) {
    final fades = find.ancestor(
      of: find.text(text),
      matching: find.descendant(
        of: find.byType(SliverCollapsibleSection),
        matching: find.byType(FadeTransition),
      ),
    );
    if (fades.evaluate().isEmpty) {
      return 1;
    }
    return tester.widget<FadeTransition>(fades.first).opacity.value;
  }

  testWidgets('shows its count and folds away from its header', (tester) async {
    await pumpSection(tester, 3);
    expect(find.text('Nodes (3)'), findsOneWidget);

    await tester.tap(find.text('Nodes (3)'));
    await tester.pumpAndSettle();
    expect(find.text('n0'), findsNothing);

    await tester.tap(find.text('Nodes (3)'));
    await tester.pumpAndSettle();
    expect(opacityOf(tester, 'n0'), 1);
  });

  testWidgets('a keyboard reaches the header and folds the section', (
    tester,
  ) async {
    await pumpSection(tester, 3);
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pump();
    final outline = find.descendant(
      of: find.byType(SliverCollapsibleSection),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is DecoratedBox &&
            ((widget.decoration as ShapeDecoration).shape as OutlinedBorder)
                    .side
                    .width ==
                2,
      ),
    );
    expect(outline, findsOneWidget);

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(find.text('n0'), findsNothing);
  });

  testWidgets('starts collapsed when asked to', (tester) async {
    await tester.pumpWidget(
      const TestApp(
        child: Surface(
          child: CustomScrollView(
            slivers: [
              SliverCollapsibleSection(
                label: 'Nodes',
                initiallyExpanded: false,
                itemCount: 1,
                itemBuilder: _firstEntry,
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Nodes (1)'), findsOneWidget);
    expect(find.text('n0'), findsNothing);
  });

  testWidgets('a long list unfolds with its first entry visible but faint '
      'until the middle of the screen has faded in', (tester) async {
    await pumpSection(tester, 40);
    final top = tester.getTopLeft(find.text('n6')).dy;

    await tester.tap(find.text('Nodes (40)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nodes (40)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(tester.getTopLeft(find.text('n6')).dy, lessThan(top));
    expect(opacityOf(tester, 'n6'), 1);
    expect(opacityOf(tester, 'n0'), lessThan(0.5));

    await tester.pump(const Duration(milliseconds: 60));
    final later = opacityOf(tester, 'n0');
    expect(later, greaterThan(0.5));
    expect(later, lessThan(1));

    await tester.pumpAndSettle();
    expect(opacityOf(tester, 'n0'), 1);
    expect(tester.getTopLeft(find.text('n6')).dy, top);
  });

  testWidgets('builds only the entries in view, open or unfolding', (
    tester,
  ) async {
    await pumpSection(tester, 1000);
    expect(find.text('n0'), findsOneWidget);
    expect(find.text('n100'), findsNothing);

    await tester.tap(find.text('Nodes (1000)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nodes (1000)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.text('n0'), findsOneWidget);
    expect(find.text('n100'), findsNothing);
  });

  testWidgets('groups start folded, unfold one at a time and stay open as '
      'the groups around them move', (tester) async {
    Future<void> pumpGroups(List<String> labels) => tester.pumpWidget(
      TestApp(
        child: Surface(
          child: CustomScrollView(
            slivers: [
              SliverCollapsibleGroups(
                groups: [
                  for (final label in labels)
                    CollapsibleGroup(
                      key: label,
                      label: label,
                      itemCount: 2,
                      trailing: Text('$label total'),
                    ),
                ],
                itemBuilder: (_, group, index) =>
                    Text('${labels[group]}$index'),
              ),
            ],
          ),
        ),
      ),
    );

    await pumpGroups(['a', 'b']);
    expect(find.text('a (2)'), findsOneWidget);
    expect(find.text('b total'), findsOneWidget);
    expect(find.text('a0'), findsNothing);

    await tester.tap(find.text('b (2)'));
    await tester.pumpAndSettle();
    expect(find.text('b0'), findsOneWidget);
    expect(find.text('a0'), findsNothing);

    await pumpGroups(['c', 'b', 'a']);
    await tester.pumpAndSettle();
    expect(find.text('b1'), findsOneWidget);
    expect(find.text('c0'), findsNothing);
    expect(
      tester.getTopLeft(find.text('b (2)')).dy,
      greaterThan(tester.getTopLeft(find.text('c (2)')).dy),
    );
  });

  testWidgets('many groups build only the headers and entries in view, '
      'open or unfolding', (tester) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      TestApp(
        child: Surface(
          child: CustomScrollView(
            slivers: [
              SliverCollapsibleGroups(
                groups: [
                  for (var group = 0; group < 1000; group++)
                    CollapsibleGroup(
                      key: group,
                      label: 'g$group',
                      itemCount: 1000,
                    ),
                ],
                itemBuilder: (_, group, index) =>
                    SizedBox(height: 64, child: Text('g$group-$index')),
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('g0 (1000)'), findsOneWidget);
    expect(find.text('g100 (1000)'), findsNothing);

    await tester.tap(find.text('g0 (1000)'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.text('g0-0'), findsOneWidget);
    expect(find.text('g0-100'), findsNothing);

    await tester.pumpAndSettle();
    expect(find.text('g0-0'), findsOneWidget);
    expect(find.text('g0-100'), findsNothing);
    expect(find.text('g1 (1000)'), findsNothing);
  });

  testWidgets('a group that did not change keeps its header', (tester) async {
    Widget build(int count) => TestApp(
      child: Surface(
        child: CustomScrollView(
          slivers: [
            SliverCollapsibleGroups(
              groups: [
                CollapsibleGroup(key: 'a', label: 'a', itemCount: count),
                const CollapsibleGroup(key: 'b', label: 'b', itemCount: 1),
              ],
              itemBuilder: (_, _, _) => const SizedBox(height: 40),
            ),
          ],
        ),
      ),
    );
    await tester.pumpWidget(build(1));
    var built = 0;
    debugOnRebuildDirtyWidget = (element, _) {
      if (element.widget is CollapsibleHeader) {
        built++;
      }
    };
    addTearDown(() => debugOnRebuildDirtyWidget = null);

    await tester.pumpWidget(build(2));
    debugOnRebuildDirtyWidget = null;

    expect(built, 1);
  });
}

Widget _firstEntry(BuildContext context, int index) => const Text('n0');
