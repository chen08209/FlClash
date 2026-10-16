import 'package:fl_clash/ui/table_layout.dart';
import 'package:flutter_test/flutter_test.dart';

const _columns = [
  TableColumn('time', 'Time', width: 80),
  TableColumn('target', 'Target', flex: 2),
  TableColumn('rule', 'Rule', flex: 1),
  TableColumn('exit', 'Exit', width: 120),
];

double _sum(List<double> widths) => widths.fold(0, (sum, w) => sum + w);

void main() {
  test('flexible columns share what the fixed ones leave', () {
    expect(tableColumnWidths(_columns, 500), [80, 200, 100, 120]);
  });

  test('a dragged column keeps its width and the other flexible ones '
      'take up the rest', () {
    final widths = tableColumnWidths(_columns, 500, {'target': 150});

    expect(widths, [80, 150, 150, 120]);
  });

  test('dragged widths scale to fit once the table is narrower than them', () {
    final widths = tableColumnWidths(_columns, 400, {
      'target': 300,
      'rule': 200,
    });

    expect(_sum(widths), closeTo(400, 0.001));
    expect(widths[1] / widths[2], closeTo(1.5, 0.001));
  });

  test('dragged widths scale to fill when no flexible column is left', () {
    final widths = tableColumnWidths(_columns, 700, {
      'target': 150,
      'rule': 150,
    });

    expect(_sum(widths), closeTo(700, 0.001));
    expect(widths[0] / widths[3], closeTo(80 / 120, 0.001));
  });

  test('a drag moves one edge and leaves the other columns in place', () {
    final widths = tableColumnWidths(_columns, 500);
    final overrides = resizedTableColumns(_columns, widths, const {}, 1, 30);
    final resized = tableColumnWidths(_columns, 500, overrides);

    expect(overrides, {'target': 230, 'rule': 70});
    expect(resized, [80, 230, 70, 120]);
  });

  test('widening a column squeezes the ones after it in turn', () {
    final widths = tableColumnWidths(_columns, 500);

    expect(resizedTableColumns(_columns, widths, const {}, 1, 80), {
      'target': 280,
      'rule': tableColumnMinWidth,
      'exit': 120 - (80 - (100 - tableColumnMinWidth)),
    });
    expect(resizedTableColumns(_columns, widths, const {}, 1, 500), {
      'target': 200 + (100 - tableColumnMinWidth) + (120 - tableColumnMinWidth),
      'rule': tableColumnMinWidth,
      'exit': tableColumnMinWidth,
    });
  });

  test('narrowing a column gives its space to the next one only', () {
    final widths = tableColumnWidths(_columns, 500);

    expect(resizedTableColumns(_columns, widths, const {}, 0, -500), {
      'time': tableColumnMinWidth,
      'target': 200 + 80 - tableColumnMinWidth,
    });
  });

  test('a column that cannot be resized is never squeezed', () {
    const columns = [
      TableColumn('target', 'Target', flex: 1),
      TableColumn('action', '', width: 44, resizable: false),
      TableColumn('exit', 'Exit', width: 120),
    ];
    final widths = tableColumnWidths(columns, 400);

    expect(resizedTableColumns(columns, widths, const {}, 0, 50), {
      'target': 286,
      'exit': 70,
    });
  });
}
