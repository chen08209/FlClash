import 'dart:math' as math;

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

  // Where iOS 27's outline spring (stiffness 631.65, critically damped)
  // stands after [seconds] from rest.
  double spring(double seconds) {
    final omega = math.sqrt(631.65);
    return 1 - (1 + omega * seconds) * math.exp(-omega * seconds);
  }

  testWidgets('shows its count and folds away from its header', (tester) async {
    await pumpSection(tester, 3);
    expect(find.text('Nodes 3'), findsOneWidget);

    await tester.tap(find.text('Nodes 3'));
    await tester.pumpAndSettle();
    expect(find.text('n0'), findsNothing);

    await tester.tap(find.text('Nodes 3'));
    await tester.pumpAndSettle();
    expect(find.text('n0'), findsOneWidget);
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

    expect(find.text('Nodes 1'), findsOneWidget);
    expect(find.text('n0'), findsNothing);
  });

  testWidgets('a list unfolds as one block from behind its header on the '
      'iOS outline spring, turns its chevron with it and folds back the '
      'same way', (tester) async {
    await pumpSection(tester, 40);
    final header = find.text('Nodes 40');
    final settled = [
      for (final entry in ['n0', 'n6']) tester.getTopLeft(find.text(entry)).dy,
    ];
    List<double> shifts() => [
      for (final (i, entry) in ['n0', 'n6'].indexed)
        tester.getTopLeft(find.text(entry)).dy - settled[i],
    ];
    double turns() => tester
        .widget<RotationTransition>(
          find.descendant(
            of: find.byType(CollapsibleHeader),
            matching: find.byType(RotationTransition),
          ),
        )
        .turns
        .value;

    await tester.tap(header);
    await tester.pumpAndSettle();
    await tester.tap(header);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    final early = shifts();
    expect(early.first, lessThan(0));
    expect(early.last, moreOrLessEquals(early.first, epsilon: 1e-6));
    expect(
      tester.getTopLeft(find.text('n0')).dy,
      lessThan(tester.getBottomLeft(find.byType(CollapsibleHeader)).dy),
    );
    expect(
      find.descendant(
        of: find.byType(SliverCollapsibleSection),
        matching: find.byType(FadeTransition),
      ),
      findsNothing,
    );
    expect(
      turns(),
      moreOrLessEquals(-0.25 * (1 - spring(0.05)), epsilon: 1e-3),
    );

    await tester.pump(const Duration(milliseconds: 50));
    expect(
      shifts().first / early.first,
      moreOrLessEquals((1 - spring(0.1)) / (1 - spring(0.05)), epsilon: 0.01),
    );

    await tester.pump(const Duration(milliseconds: 260));
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pump(const Duration(milliseconds: 15));
    expect(tester.hasRunningAnimations, isFalse);
    expect(shifts(), [0, 0]);
    expect(turns(), 0);

    await tester.tap(header);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    final folding = shifts().first;
    await tester.pump(const Duration(milliseconds: 50));
    expect(
      shifts().first / folding,
      moreOrLessEquals(spring(0.1) / spring(0.05), epsilon: 0.01),
    );

    await tester.pumpAndSettle();
    expect(find.text('n0'), findsNothing);
  });

  testWidgets('a tap during the motion turns it around at the speed it had', (
    tester,
  ) async {
    await pumpSection(tester, 40);
    final header = find.text('Nodes 40');
    final settled = tester.getTopLeft(find.text('n6')).dy;
    double shift() => tester.getTopLeft(find.text('n6')).dy - settled;

    await tester.tap(header);
    await tester.pumpAndSettle();
    await tester.tap(header);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final turning = shift();
    await tester.tap(header);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 8));
    expect(shift(), greaterThan(turning));

    await tester.pumpAndSettle();
    expect(find.text('n6'), findsNothing);
  });

  testWidgets('entries keep their elements from the motion into the settled '
      'list and back', (tester) async {
    await pumpSection(tester, 40);
    final header = find.text('Nodes 40');
    await tester.tap(header);
    await tester.pumpAndSettle();

    await tester.tap(header);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    final unfolding = tester.element(find.text('n3'));

    await tester.pumpAndSettle();
    expect(tester.element(find.text('n3')), same(unfolding));

    await tester.tap(header);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 16));
    expect(tester.element(find.text('n3')), same(unfolding));
  });

  testWidgets('with animations off a list unfolds and folds at once', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      TestApp(
        child: Builder(
          builder: (context) => MediaQuery(
            data: MediaQuery.of(context).copyWith(disableAnimations: true),
            child: Surface(
              child: CustomScrollView(
                slivers: [
                  SliverCollapsibleSection(
                    label: 'Nodes',
                    itemCount: 40,
                    itemBuilder: (_, index) =>
                        SizedBox(height: 64, child: Text('n$index')),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    final top = tester.getTopLeft(find.text('n6')).dy;

    await tester.tap(find.text('Nodes 40'));
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
    expect(find.text('n0'), findsNothing);

    await tester.tap(find.text('Nodes 40'));
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
    expect(tester.getTopLeft(find.text('n6')).dy, top);
  });

  testWidgets('the motion does not start where it already stands', (
    tester,
  ) async {
    final controller = AnimationController(vsync: tester, value: 1);
    addTearDown(controller.dispose);
    final statuses = <AnimationStatus>[];
    controller.addStatusListener(statuses.add);

    UnfoldMotion.run(controller, open: true);
    expect(controller.isAnimating, isFalse);
    expect(statuses, isEmpty);

    UnfoldMotion.run(controller, open: false);
    expect(controller.isAnimating, isTrue);
    expect(statuses, [AnimationStatus.reverse]);
    controller.stop();
  });

  testWidgets('builds only the entries in view, open or unfolding', (
    tester,
  ) async {
    await pumpSection(tester, 1000);
    expect(find.text('n0'), findsOneWidget);
    expect(find.text('n100'), findsNothing);

    await tester.tap(find.text('Nodes 1000'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Nodes 1000'));
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
    expect(find.text('a 2'), findsOneWidget);
    expect(find.text('b total'), findsOneWidget);
    expect(find.text('a0'), findsNothing);

    await tester.tap(find.text('b 2'));
    await tester.pumpAndSettle();
    expect(find.text('b0'), findsOneWidget);
    expect(find.text('a0'), findsNothing);

    await pumpGroups(['c', 'b', 'a']);
    await tester.pumpAndSettle();
    expect(find.text('b1'), findsOneWidget);
    expect(find.text('c0'), findsNothing);
    expect(
      tester.getTopLeft(find.text('b 2')).dy,
      greaterThan(tester.getTopLeft(find.text('c 2')).dy),
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
    expect(find.text('g0 1000'), findsOneWidget);
    expect(find.text('g100 1000'), findsNothing);

    await tester.tap(find.text('g0 1000'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 60));
    expect(find.text('g0-0'), findsOneWidget);
    expect(find.text('g0-100'), findsNothing);

    await tester.pumpAndSettle();
    expect(find.text('g0-0'), findsOneWidget);
    expect(find.text('g0-100'), findsNothing);
    expect(find.text('g1 1000'), findsNothing);
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
