import 'package:fl_clash/widgets/popup.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<PopupOpen> pumpBox(WidgetTester tester) async {
    late PopupOpen open;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: CommonPopupBox(
              targetBuilder: (value) {
                open = value;
                return const SizedBox(width: 40, height: 40);
              },
              popupBuilder: (_) =>
                  const SizedBox(width: 80, height: 80, key: Key('popup')),
            ),
          ),
        ),
      ),
    );
    return open;
  }

  Future<PopupOpen> pumpMenu(
    WidgetTester tester,
    List<CommonPopupMenuItem> items,
  ) async {
    late PopupOpen open;
    await tester.pumpWidget(
      TestApp(
        homeBuilder: (child) => Scaffold(body: Center(child: child)),
        child: CommonPopupBox(
          targetBuilder: (value) {
            open = value;
            return const SizedBox(width: 40, height: 40);
          },
          popupBuilder: (_) => CommonPopupMenu(items: items),
        ),
      ),
    );
    return open;
  }

  testWidgets('opening pushes the popup above the target', (tester) async {
    final open = await pumpBox(tester);

    open();
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('popup')), findsOneWidget);
  });

  testWidgets('the popup is only built once it opens', (tester) async {
    var builds = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: CommonPopupBox(
              targetBuilder: (_) => const SizedBox(width: 40, height: 40),
              popupBuilder: (_) {
                builds++;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );

    expect(builds, 0);
  });

  testWidgets('the box can be removed while its popup is still up', (
    tester,
  ) async {
    // The box goes away under an open popup while the navigator carrying that
    // popup stays; the route then holds an anchor it can no longer measure.
    final showBox = ValueNotifier<bool>(true);
    addTearDown(showBox.dispose);
    late PopupOpen open;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: ValueListenableBuilder<bool>(
              valueListenable: showBox,
              builder: (_, visible, _) {
                if (!visible) {
                  return const SizedBox.shrink();
                }
                return CommonPopupBox(
                  targetBuilder: (value) {
                    open = value;
                    return const SizedBox(width: 40, height: 40);
                  },
                  popupBuilder: (_) =>
                      const SizedBox(width: 80, height: 80, key: Key('popup')),
                );
              },
            ),
          ),
        ),
      ),
    );

    open();
    await tester.pumpAndSettle();

    showBox.value = false;
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('popup')), findsOneWidget);

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('popup')), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('dismissing the barrier closes the popup', (tester) async {
    final open = await pumpBox(tester);
    open();
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('popup')), findsNothing);
  });

  testWidgets('a sub menu opens above the level that owns it', (tester) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'child')],
      ),
    ]);
    open();
    await tester.pumpAndSettle();

    expect(find.byIcon(Icons.chevron_right), findsOneWidget);

    await tester.tap(find.text('parent'));
    await tester.pumpAndSettle();

    expect(find.text('child'), findsOneWidget);
    expect(find.byType(Card), findsNWidgets(2));
    expect(find.text('parent'), findsNWidgets(2));
  });

  testWidgets('the sub menu header lands exactly on the opening item', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(label: 'first'),
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'child')],
      ),
    ]);
    open();
    await tester.pumpAndSettle();

    final itemTop = tester.getTopLeft(find.text('parent')).dy;

    await tester.tap(find.text('parent'));
    await tester.pumpAndSettle();

    expect(tester.getTopLeft(find.text('parent').last).dy, itemTop);
  });

  testWidgets('the menu stays between its min and max width', (tester) async {
    Future<double> widthOf(String label) async {
      final open = await pumpMenu(tester, [CommonPopupMenuItem(label: label)]);
      open();
      await tester.pumpAndSettle();
      final width = tester.getSize(find.byType(Card)).width;
      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle();
      return width;
    }

    expect(await widthOf('a'), 160);
    expect(
      await widthOf('a label far too long to ever fit inside a menu'),
      280,
    );
  });

  testWidgets('only a sub menu carries a divider, under its header', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(label: 'first'),
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'child')],
      ),
    ]);
    open();
    await tester.pumpAndSettle();
    expect(find.byType(Divider), findsNothing);

    await tester.tap(find.text('parent'));
    await tester.pumpAndSettle();

    expect(find.byType(Divider), findsOneWidget);
    expect(tester.getSize(find.byType(Divider)).height, greaterThan(0));
  });

  testWidgets('the header folds the sub menu back into its item', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'child')],
      ),
    ]);
    open();
    await tester.pumpAndSettle();
    await tester.tap(find.text('parent'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('parent').last);
    await tester.pumpAndSettle();

    expect(find.text('child'), findsNothing);
    expect(find.text('parent'), findsOneWidget);
  });

  testWidgets('a sub menu can be opened again after it was folded back', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'child')],
      ),
    ]);
    open();
    await tester.pumpAndSettle();
    await tester.tap(find.text('parent'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('parent').last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('parent'));
    await tester.pumpAndSettle();

    expect(find.text('child'), findsOneWidget);
  });

  testWidgets('back walks one level up and leaves the popup open', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'child')],
      ),
    ]);
    open();
    await tester.pumpAndSettle();
    await tester.tap(find.text('parent'));
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();

    expect(find.text('child'), findsNothing);
    expect(find.text('parent'), findsOneWidget);
  });

  testWidgets('a tap outside closes every level at once', (tester) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'child')],
      ),
    ]);
    open();
    await tester.pumpAndSettle();
    await tester.tap(find.text('parent'));
    await tester.pumpAndSettle();

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();

    expect(find.text('child'), findsNothing);
    expect(find.text('parent'), findsNothing);
  });

  testWidgets('picking an item runs it and closes the popup', (tester) async {
    var pressed = 0;
    final open = await pumpMenu(tester, [
      CommonPopupMenuItem(label: 'run', onPressed: () => pressed++),
      const CommonPopupMenuItem(label: 'disabled'),
    ]);
    open();
    await tester.pumpAndSettle();

    await tester.tap(find.text('disabled'));
    await tester.pumpAndSettle();
    expect(find.text('run'), findsOneWidget);

    await tester.tap(find.text('run'));
    await tester.pumpAndSettle();

    expect(pressed, 1);
    expect(find.text('run'), findsNothing);
  });

  testWidgets('a danger item keeps the error color off its background', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      CommonPopupMenuItem(label: 'plain', onPressed: () {}),
      CommonPopupMenuItem(
        icon: Icons.delete_outlined,
        label: 'delete',
        danger: true,
        onPressed: () {},
      ),
    ]);
    open();
    await tester.pumpAndSettle();

    final colorScheme = Theme.of(
      tester.element(find.text('delete')),
    ).colorScheme;

    expect(
      tester.widget<Text>(find.text('delete')).style?.color,
      colorScheme.error,
    );
    expect(
      tester.widget<Icon>(find.byIcon(Icons.delete_outlined)).color,
      colorScheme.error,
    );
    expect(
      find.ancestor(of: find.text('delete'), matching: find.byType(Ink)),
      findsNothing,
    );
    expect(
      tester
          .widget<InkWell>(
            find.ancestor(
              of: find.text('delete'),
              matching: find.byType(InkWell),
            ),
          )
          .hoverColor,
      colorScheme.error.withValues(alpha: 0.1),
    );
    expect(
      tester.widget<Text>(find.text('plain')).style?.color,
      colorScheme.onSurface,
    );
    expect(
      tester
          .widget<InkWell>(
            find.ancestor(
              of: find.text('plain'),
              matching: find.byType(InkWell),
            ),
          )
          .hoverColor,
      isNull,
    );
  });

  testWidgets('a sub menu is at least as wide as its parent', (tester) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(
        label: 'a label long enough to widen the parent menu',
      ),
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'x')],
      ),
    ]);
    open();
    await tester.pumpAndSettle();
    await tester.tap(find.text('parent'));
    await tester.pumpAndSettle();

    expect(find.byType(Card), findsNWidgets(2));
    final parentWidth = tester.getSize(find.byType(Card).first).width;
    final childWidth = tester.getSize(find.byType(Card).last).width;
    expect(childWidth, greaterThanOrEqualTo(parentWidth));
  });

  testWidgets('the open sub menu casts the stronger shadow', (tester) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'child')],
      ),
    ]);
    open();
    await tester.pumpAndSettle();
    await tester.tap(find.text('parent'));
    await tester.pumpAndSettle();

    final elevations = tester
        .widgetList<Card>(find.byType(Card))
        .map((card) => card.elevation)
        .toList();
    expect(elevations, hasLength(2));
    expect(elevations[0], isNotNull);
    expect(elevations[1], isNotNull);
    expect(elevations[0]!, lessThan(elevations[1]!));
  });

  testWidgets('a sub menu settles wider than the parent it opened from', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'child')],
      ),
    ]);
    open();
    await tester.pumpAndSettle();
    final parentWidth = tester.getSize(find.byType(Card)).width;

    await tester.tap(find.text('parent'));
    await tester.pumpAndSettle();

    expect(
      tester.getSize(find.byType(Card).last).width,
      closeTo(parentWidth * 1.12, 0.01),
    );
  });

  testWidgets('a sub menu grows out of its item instead of snapping open', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [CommonPopupMenuItem(label: 'child')],
      ),
    ]);
    open();
    await tester.pumpAndSettle();
    final parentWidth = tester.getSize(find.byType(Card)).width;

    await tester.tap(find.text('parent'));
    await tester.pump();

    final active = find.byType(Card).last;
    expect(tester.getSize(active).width, parentWidth);
    expect(tester.widget<Card>(active).elevation, 0);

    await tester.pump(const Duration(milliseconds: 40));
    final midWidth = tester.getSize(active).width;
    expect(midWidth, greaterThan(parentWidth));
    expect(midWidth, lessThan(parentWidth * 1.12));

    await tester.pumpAndSettle();
    expect(tester.getSize(active).width, closeTo(parentWidth * 1.12, 0.01));
  });

  testWidgets('a sub menu settles its width before it finishes unfolding', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [
          CommonPopupMenuItem(label: 'first child'),
          CommonPopupMenuItem(label: 'second child'),
        ],
      ),
    ]);
    open();
    await tester.pumpAndSettle();
    final parentWidth = tester.getSize(find.byType(Card)).width;

    await tester.tap(find.text('parent'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 130));

    final active = find.byType(Card).last;
    final midSize = tester.getSize(active);
    expect(midSize.width, greaterThanOrEqualTo(parentWidth * 1.12));

    await tester.pumpAndSettle();
    final settledSize = tester.getSize(active);
    expect(settledSize.width, midSize.width);
    expect(settledSize.height, greaterThan(midSize.height));
  });

  testWidgets('folding back lands on the item without a jump at the end', (
    tester,
  ) async {
    final open = await pumpMenu(tester, [
      const CommonPopupMenuItem(label: 'plain item'),
      const CommonPopupMenuItem(
        label: 'parent',
        subItems: [
          CommonPopupMenuItem(label: 'first child'),
          CommonPopupMenuItem(label: 'second child'),
        ],
      ),
    ]);
    open();
    await tester.pumpAndSettle();

    await tester.tap(find.text('parent'));
    await tester.pump();
    final foldedSize = tester.getSize(find.byType(Card).last);
    await tester.pumpAndSettle();

    await tester.tap(find.text('parent').last);
    Size? lastSize;
    var frames = 0;
    while (find.byType(Card).evaluate().length > 1) {
      lastSize = tester.getSize(find.byType(Card).last);
      await tester.pump(const Duration(milliseconds: 16));
      frames++;
      expect(frames, lessThan(60));
    }

    expect(lastSize!.width, closeTo(foldedSize.width, 1));
    expect(lastSize.height, closeTo(foldedSize.height, 1));
    await tester.pumpAndSettle();
  });
}
