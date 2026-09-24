import 'package:fl_clash/widgets/line_chart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _color = Color(0xFF3366FF);

final _canvas = find.descendant(
  of: find.byType(LineChart),
  matching: find.byType(CustomPaint),
);

Widget _chart(List<double> values, {required int revision}) {
  return Center(
    child: SizedBox(
      width: 290,
      height: 100,
      child: LineChart(
        values: values,
        revision: revision,
        capacity: 30,
        minScale: 1,
        color: _color,
      ),
    ),
  );
}

Rect _lineBounds(WidgetTester tester) {
  late Rect bounds;
  expect(
    tester.renderObject(_canvas),
    paints..something((method, arguments) {
      if (method != #drawPath ||
          (arguments[1] as Paint).style != PaintingStyle.stroke) {
        return false;
      }
      bounds = (arguments[0] as Path).getBounds();
      return true;
    }),
  );
  return bounds;
}

void main() {
  testWidgets('a new sample redraws the chart and leaves nothing animating', (
    tester,
  ) async {
    await tester.pumpWidget(_chart(const [1, 2, 3], revision: 3));
    await tester.pumpWidget(_chart(const [1, 2, 3, 40], revision: 4));

    expect(
      tester.hasRunningAnimations,
      isFalse,
      reason: 'an animation here repaints the whole window on every vsync',
    );
    expect(
      tester.renderObject(_canvas),
      paints
        ..path(style: PaintingStyle.fill)
        ..path(color: _color, style: PaintingStyle.stroke),
    );
  });

  testWidgets('a spike stays below the top', (tester) async {
    final idle = List.filled(20, 0.0);
    await tester.pumpWidget(_chart([...idle, 10], revision: 21));
    expect(_lineBounds(tester).top, greaterThan(0));

    await tester.pumpWidget(_chart([...idle, 10, 0], revision: 22));
    expect(_lineBounds(tester).top, greaterThan(0));
  });

  testWidgets('a clear starts the chart over', (tester) async {
    await tester.pumpWidget(_chart(const [1, 2, 3], revision: 3));
    expect(_lineBounds(tester).height, greaterThan(0));

    await tester.pumpWidget(_chart(const [], revision: 0));
    expect(_lineBounds(tester).height, 0);
  });
}
