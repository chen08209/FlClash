import 'package:fl_clash/widgets/super_reorderable_list.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildList({
    required int itemCount,
    required void Function(int from, int to) onReorderItem,
    ScrollController? controller,
    void Function(int index)? onBuild,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: CustomScrollView(
          controller: controller,
          slivers: [
            SuperSliverReorderableList(
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
}
