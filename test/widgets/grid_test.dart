import 'package:fl_clash/widgets/grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

typedef _Spec = ({int crossAxisCellCount, double height});

const _specs = <_Spec>[
  (crossAxisCellCount: 8, height: 100),
  (crossAxisCellCount: 4, height: 60),
  (crossAxisCellCount: 4, height: 90),
  (crossAxisCellCount: 4, height: 50),
  (crossAxisCellCount: 2, height: 40),
];

Widget _buildGrid() {
  return MaterialApp(
    home: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        width: 800,
        child: Grid(
          crossAxisCount: 8,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            for (var i = 0; i < _specs.length; i++)
              GridItem(
                crossAxisCellCount: _specs[i].crossAxisCellCount,
                child: SizedBox(key: ValueKey(i), height: _specs[i].height),
              ),
          ],
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('Grid sizes children from their cell count', (tester) async {
    await tester.pumpWidget(_buildGrid());

    // stride = (800 + 16) / 8 = 102
    expect(tester.getSize(find.byKey(const ValueKey(0))).width, 800);
    expect(tester.getSize(find.byKey(const ValueKey(1))).width, 392);
    expect(tester.getSize(find.byKey(const ValueKey(4))).width, 188);
  });

  testWidgets('packGridSlots agrees with the rendered grid', (tester) async {
    await tester.pumpWidget(_buildGrid());

    final geometry = packGridSlots(
      crossAxisCellCounts: [for (final spec in _specs) spec.crossAxisCellCount],
      mainAxisExtents: [for (final spec in _specs) spec.height],
      crossAxisCount: 8,
      crossAxisExtent: 800,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
    );

    final origin = tester.getTopLeft(find.byType(Grid));
    for (var i = 0; i < _specs.length; i++) {
      final slot = geometry.slots[i];
      expect(
        tester.getTopLeft(find.byKey(ValueKey(i))) - origin,
        Offset(slot.crossAxisIndex * geometry.stride, slot.mainAxisOffset),
        reason: 'child $i',
      );
    }
    expect(tester.getSize(find.byType(Grid)).height, geometry.mainAxisExtent);
  });

  test('packGridSlots stacks a row under the shortest column', () {
    final geometry = packGridSlots(
      crossAxisCellCounts: const [8, 4, 4, 4],
      mainAxisExtents: const [100, 60, 90, 50],
      crossAxisCount: 8,
      crossAxisExtent: 800,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
    );

    expect(geometry.stride, 102);
    expect(geometry.slots[0].crossAxisIndex, 0);
    expect(geometry.slots[0].mainAxisOffset, 0);
    expect(geometry.slots[1].mainAxisOffset, 116);
    expect(geometry.slots[2].crossAxisIndex, 4);
    // The left column ends at 176 and the right one at 206.
    expect(geometry.slots[3].crossAxisIndex, 0);
    expect(geometry.slots[3].mainAxisOffset, 192);
    expect(geometry.mainAxisExtent, 242);
  });

  test('packGridSlots is empty for no children', () {
    final geometry = packGridSlots(
      crossAxisCellCounts: const [],
      mainAxisExtents: const [],
      crossAxisCount: 8,
      crossAxisExtent: 800,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
    );

    expect(geometry.slots, isEmpty);
    expect(geometry.mainAxisExtent, 0);
  });
}
