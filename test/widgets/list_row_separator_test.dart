import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

void main() {
  Future<List<Finder>> pumpRows(
    WidgetTester tester, {
    int? selected,
    Widget? leading,
    double top = 0,
  }) async {
    await tester.pumpWidget(
      TestApp(
        child: Scaffold(
          body: Padding(
            padding: EdgeInsets.only(top: top),
            child: generateSectionV3(
              items: [
                for (var index = 0; index < 3; index++)
                  DecorationListItem(
                    leading: leading,
                    title: Text('row $index'),
                    isSelected: index == selected,
                    onPressed: () {},
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    return [
      for (var index = 0; index < 3; index++)
        find.widgetWithText(DecorationListItem, 'row $index'),
    ];
  }

  PaintPattern separator(WidgetTester tester, Finder row, {Rect? rect}) {
    final color = Theme.of(tester.element(row)).colorScheme.outlineVariant;
    return paints..something(
      (method, arguments) =>
          method == #drawRect &&
          (arguments[1] as Paint).color.toARGB32() == color.toARGB32() &&
          (rect == null || arguments[0] == rect),
    );
  }

  testWidgets('every row but the last draws a separator', (tester) async {
    final rows = await pumpRows(tester);

    expect(tester.renderObject(rows[0]), separator(tester, rows[0]));
    expect(tester.renderObject(rows[1]), separator(tester, rows[1]));
    expect(tester.renderObject(rows[2]), isNot(separator(tester, rows[2])));
  });

  testWidgets('a selected row drops the separators on both its edges', (
    tester,
  ) async {
    final rows = await pumpRows(tester, selected: 1);

    expect(tester.renderObject(rows[0]), isNot(separator(tester, rows[0])));
    expect(tester.renderObject(rows[1]), isNot(separator(tester, rows[1])));
  });

  testWidgets('pressing a row hides the separator above it until release', (
    tester,
  ) async {
    final rows = await pumpRows(tester);

    final gesture = await tester.startGesture(tester.getCenter(rows[2]));
    await tester.pump();
    expect(tester.renderObject(rows[1]), isNot(separator(tester, rows[1])));
    expect(tester.renderObject(rows[0]), separator(tester, rows[0]));

    await gesture.up();
    await tester.pumpAndSettle();
    expect(tester.renderObject(rows[1]), separator(tester, rows[1]));
  });

  testWidgets('hovering a row keeps the separators on both its edges', (
    tester,
  ) async {
    final rows = await pumpRows(tester);

    final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
    addTearDown(mouse.removePointer);
    await mouse.addPointer(location: tester.getCenter(rows[1]));
    await tester.pumpAndSettle();

    expect(tester.renderObject(rows[0]), separator(tester, rows[0]));
    expect(tester.renderObject(rows[1]), separator(tester, rows[1]));
  });

  testWidgets('the separator starts where the title starts', (tester) async {
    final rows = await pumpRows(tester, leading: const Icon(Icons.language));

    final row = tester.getRect(rows[0]);
    final title = tester.getRect(find.text('row 0'));
    final thickness = 2 / tester.view.devicePixelRatio;
    expect(
      tester.renderObject(rows[0]),
      separator(
        tester,
        rows[0],
        rect: Rect.fromLTRB(
          title.left - row.left,
          row.height - thickness,
          row.width - 14,
          row.height,
        ),
      ),
    );
  });

  for (final (ratio, pixels) in [(3.0, 2), (2.0, 2), (1.0, 1)]) {
    testWidgets(
      'a row between device pixels keeps a $pixels pixel separator at ${ratio}x',
      (tester) async {
        tester.view.devicePixelRatio = ratio;
        addTearDown(tester.view.reset);
        final rows = await pumpRows(tester, top: 0.2);

        final rowTop = tester.getRect(rows[0]).top;
        expect(
          tester.renderObject(rows[0]),
          paints..something((method, arguments) {
            if (method != #drawRect) {
              return false;
            }
            final rect = arguments[0] as Rect;
            final deviceTop = (rowTop + rect.top) * ratio;
            return (rect.height * ratio - pixels).abs() < 1e-6 &&
                (deviceTop - deviceTop.roundToDouble()).abs() < 1e-6;
          }),
        );
      },
    );
  }

  testWidgets('a scroll that stops between device pixels repaints the lines', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 2;
    addTearDown(tester.view.reset);
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      TestApp(
        child: Scaffold(
          body: ListView(
            controller: controller,
            children: [
              generateSectionV3(
                items: [
                  for (var index = 0; index < 3; index++)
                    DecorationListItem(
                      title: Text('row $index'),
                      onPressed: () {},
                    ),
                ],
              ),
              const SizedBox(height: 2000),
            ],
          ),
        ),
      ),
    );
    Layer? picture() {
      RenderObject? node = tester.renderObject(find.text('row 0'));
      while (node != null && !node.isRepaintBoundary) {
        node = node.parent;
      }
      return node!.debugLayer!.firstChild;
    }

    Future<void> scrollTo(double offset) async {
      controller.jumpTo(offset);
      for (
        var frame = 0;
        frame < 5 && tester.binding.hasScheduledFrame;
        frame++
      ) {
        await tester.pump();
      }
      await tester.pump();
    }

    final settled = picture();
    await scrollTo(1);
    expect(picture(), same(settled));

    await scrollTo(1.25);
    expect(picture(), isNot(same(settled)));
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('a row repainted on its way into the keep-alive bucket settles', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    late StateSetter rebuild;
    await tester.pumpWidget(
      TestApp(
        child: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              rebuild = setState;
              return CustomScrollView(
                controller: controller,
                slivers: [
                  SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        KeepAlive(
                          keepAlive: true,
                          child: RepaintBoundary(
                            child: DecorationListItem(
                              title: const Text('row 0'),
                              onPressed: () {},
                            ),
                          ),
                        ),
                        const SizedBox(height: 5000),
                      ],
                      addAutomaticKeepAlives: false,
                      addRepaintBoundaries: false,
                      addSemanticIndexes: false,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );

    rebuild(() {});
    controller.jumpTo(4000);
    await tester.pump();
    for (
      var frame = 0;
      frame < 5 && tester.binding.hasScheduledFrame;
      frame++
    ) {
      await tester.pump();
    }

    expect(tester.takeException(), isNull);
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('a flat section runs its separators from the title to the edge', (
    tester,
  ) async {
    await tester.pumpWidget(
      TestApp(
        child: Scaffold(
          body: ListView(
            children: generateSection(
              items: [
                for (var index = 0; index < 3; index++)
                  ListItem(
                    leading: const Icon(Icons.language),
                    title: Text('row $index'),
                    onTap: () {},
                  ),
              ],
            ),
          ),
        ),
      ),
    );
    final rows = [
      for (var index = 0; index < 3; index++)
        find.ancestor(
          of: find.text('row $index'),
          matching: find.byType(ListTile),
        ),
    ];
    RenderObject separatorOf(Finder row) {
      RenderObject node = tester.renderObject(row);
      while (node.runtimeType.toString() != '_RenderListRowSeparator') {
        node = node.parent!;
      }
      return node;
    }

    final row = tester.getRect(rows[0]);
    final title = tester.getRect(find.text('row 0'));
    final thickness = 2 / tester.view.devicePixelRatio;
    expect(
      separatorOf(rows[0]),
      separator(
        tester,
        rows[0],
        rect: Rect.fromLTRB(
          title.left - row.left,
          row.height - thickness,
          row.width,
          row.height,
        ),
      ),
    );
    expect(separatorOf(rows[2]), isNot(separator(tester, rows[2])));

    final gesture = await tester.startGesture(tester.getCenter(rows[1]));
    await tester.pump(kPressTimeout);
    expect(separatorOf(rows[0]), isNot(separator(tester, rows[0])));
    expect(separatorOf(rows[1]), isNot(separator(tester, rows[1])));
    await gesture.up();
    await tester.pumpAndSettle();
  });
}
