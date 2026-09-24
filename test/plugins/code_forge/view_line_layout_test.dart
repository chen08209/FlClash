import 'dart:math';

import 'package:code_forge/code_forge/view_line_layout.dart';
import 'package:flutter_test/flutter_test.dart';

class _LineModel {
  _LineModel(this.rowHeight, int count)
    : rows = List.filled(count, 1.0, growable: true),
      measured = List.filled(count, false, growable: true),
      hidden = List.filled(count, false, growable: true);

  final double rowHeight;
  final List<double> rows;
  final List<bool> measured;
  final List<bool> hidden;
  double estimate = 1;

  int get count => rows.length;

  double height(int line) => hidden[line] ? 0 : rows[line] * rowHeight;

  double top(int line) {
    var y = 0.0;
    for (var i = 0; i < line && i < count; i++) {
      y += height(i);
    }
    return y;
  }

  int lineAt(double y) {
    var top = 0.0;
    var last = -1;
    for (var i = 0; i < count; i++) {
      if (hidden[i]) continue;
      last = i;
      if (y < top + height(i)) return i;
      top += height(i);
    }
    return max(last, 0);
  }
}

void main() {
  test('ViewLineLayout matches a line-by-line model under random edits', () {
    final random = Random(7);
    const rowHeight = 19.2;
    for (var round = 0; round < 40; round++) {
      final count = 1 + random.nextInt(60);
      final layout = ViewLineLayout(rowHeight: rowHeight)..reset(count);
      final model = _LineModel(rowHeight, count);
      for (var step = 0; step < 200; step++) {
        final count = model.count;
        switch (random.nextInt(6)) {
          case 0:
            final line = random.nextInt(count);
            final rows = 1 + random.nextInt(4);
            layout.setRows(line, rows);
            model.rows[line] = rows.toDouble();
            model.measured[line] = true;
          case 1:
            final start = random.nextInt(count);
            final removed = random.nextInt(min(4, count - start) + 1);
            final inserted = random.nextInt(4);
            if (count - removed + inserted == 0) break;
            layout.splice(start, removed, inserted);
            model.rows.replaceRange(
              start,
              start + removed,
              List.filled(inserted, model.estimate),
            );
            model.measured.replaceRange(
              start,
              start + removed,
              List.filled(inserted, false),
            );
            model.hidden.replaceRange(
              start,
              start + removed,
              List.filled(inserted, false),
            );
          case 2:
            final ranges = <({int start, int end})>[
              for (var k = random.nextInt(3); k > 0; k--)
                (() {
                  final start = 1 + random.nextInt(count);
                  return (start: start, end: start + random.nextInt(8));
                })(),
            ];
            layout.setHiddenRanges(ranges);
            for (var i = 0; i < count; i++) {
              model.hidden[i] = ranges.any((r) => i >= r.start && i < r.end);
            }
          case 3:
            final estimate = 1 + random.nextInt(3) + random.nextDouble();
            layout.setEstimate(estimate);
            model.estimate = estimate;
            for (var i = 0; i < count; i++) {
              if (!model.measured[i]) model.rows[i] = estimate;
            }
          case 4:
            final line = random.nextInt(count);
            layout.invalidate(line);
            model.rows[line] = model.estimate;
            model.measured[line] = false;
          case 5:
            break;
        }
        final lines = model.count;
        expect(layout.lineCount, lines);
        for (var i = 0; i <= lines; i++) {
          expect(
            layout.lineTop(i),
            closeTo(model.top(i), 1e-6),
            reason: 'top of line $i',
          );
        }
        expect(layout.totalHeight, closeTo(model.top(lines), 1e-6));
        for (var k = 0; k < 20; k++) {
          final y = random.nextDouble() * (model.top(lines) + 40) - 10;
          expect(layout.lineAt(y), model.lineAt(y), reason: 'line at y=$y');
        }
      }
    }
  });

  test('hidden lines take no height and are skipped by lineAt', () {
    final layout = ViewLineLayout(rowHeight: 10)..reset(6);
    layout.setRows(0, 2);
    layout.setHiddenRanges([(start: 2, end: 4)]);
    expect(layout.isHidden(2), isTrue);
    expect(layout.lineTop(2), 30);
    expect(layout.lineTop(4), 30);
    expect(layout.lineAt(35), 4);
    expect(layout.totalHeight, 20 + 10 + 10 + 10);
    expect(layout.nextVisible(2), 4);
  });
}
