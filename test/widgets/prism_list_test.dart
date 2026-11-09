import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_ui/prism_list.dart';
import '../helpers/host_scaffold.dart';
import '../helpers/test_app.dart';

void main() {
  Widget buildList({
    required int itemCount,
    required void Function(int from, int to) onReorderItem,
    ScrollController? controller,
    void Function(int index)? onBuild,
  }) {
    return HostApp(
      home: HostScaffold(
        body: CustomScrollView(
          controller: controller,
          slivers: [
            SliverPrismReorderableList(
              itemCount: itemCount,
              onReorderItem: onReorderItem,
              itemBuilder: (_, index) {
                onBuild?.call(index);
                return ReorderableDragStartListener(
                  key: ValueKey(index),
                  index: index,
                  child: SizedBox(height: 50, child: Text('item $index')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  testWidgets('dragging a row reports the move', (tester) async {
    final moves = <(int, int)>[];
    await tester.pumpWidget(
      buildList(
        itemCount: 5,
        onReorderItem: (from, to) => moves.add((from, to)),
      ),
    );

    final drag = await tester.startGesture(
      tester.getCenter(find.text('item 0')),
    );
    await tester.pump();
    await drag.moveBy(const Offset(0, 170));
    await tester.pump();
    await drag.up();
    await tester.pumpAndSettle();

    expect(moves, [(0, 2)]);
  });

  testWidgets('a far jump builds only the rows it lands on', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    final built = <int>{};
    await tester.pumpWidget(
      buildList(
        itemCount: 3000,
        controller: controller,
        onReorderItem: (_, _) {},
        onBuild: built.add,
      ),
    );

    built.clear();
    controller.jumpTo(controller.position.maxScrollExtent / 2);
    await tester.pump();

    expect(built, isNotEmpty);
    expect(built.length, lessThan(100));
  });

  testWidgets('a far jump lays out only the rows it lands on', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    final built = <int>{};
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: PrismListView(
          controller: controller,
          itemCount: 10000,
          gap: 8,
          estimatedItemExtent: 100,
          itemBuilder: (_, index) {
            built.add(index);
            return SizedBox(
              height: index.isEven ? 80 : 120,
              child: Text('$index'),
            );
          },
        ),
      ),
    );

    built.clear();
    controller.jumpTo(controller.position.maxScrollExtent / 2);
    await tester.pump();

    expect(built, isNotEmpty);
    expect(built.length, lessThan(100));
  });

  testWidgets('the gaps between rows do not misjudge the list', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: PrismListView(
          controller: controller,
          itemCount: 200,
          gap: 8,
          estimatedItemExtent: 100,
          itemBuilder: (_, index) =>
              SizedBox(height: 100, child: Text('$index')),
        ),
      ),
    );
    final viewport = controller.position.viewportDimension;
    const extent = 200 * 100 + 199 * 8;

    expect(controller.position.maxScrollExtent, extent - viewport);

    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();

    expect(controller.position.maxScrollExtent, extent - viewport);
    expect(controller.offset, controller.position.maxScrollExtent);
  });

  testWidgets('a fixed row extent places a jump exactly', (tester) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: PrismListView(
          controller: controller,
          itemCount: 10000,
          itemExtent: 50,
          itemBuilder: (_, index) => Text('row $index'),
        ),
      ),
    );

    controller.jumpTo(5000 * 50);
    await tester.pump();

    expect(tester.getTopLeft(find.text('row 5000')).dy, 0);
  });

  testWidgets('the reorderable view lays its header and footer around the '
      'rows and reports a move', (tester) async {
    final moves = <(int, int)>[];
    await tester.pumpWidget(
      HostApp(
        home: HostScaffold(
          body: PrismReorderableListView(
            header: const SizedBox(height: 40, child: Text('header')),
            footer: const SizedBox(height: 40, child: Text('footer')),
            itemCount: 3,
            onReorderItem: (from, to) => moves.add((from, to)),
            proxyDecorator: (child, _, _) => child,
            itemBuilder: (_, index) => ReorderableDragStartListener(
              key: ValueKey(index),
              index: index,
              child: SizedBox(height: 50, child: Text('item $index')),
            ),
          ),
        ),
      ),
    );

    expect(tester.getTopLeft(find.text('item 0')).dy, 40);
    expect(tester.getTopLeft(find.text('footer')).dy, 40 + 3 * 50);

    final drag = await tester.startGesture(
      tester.getCenter(find.text('item 0')),
    );
    await tester.pump();
    await drag.moveBy(const Offset(0, 170));
    await tester.pump();
    await drag.up();
    await tester.pumpAndSettle();

    expect(moves, [(0, 2)]);
  });
}
