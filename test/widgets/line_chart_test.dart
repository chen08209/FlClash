import 'package:fl_clash/widgets/line_chart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _color = Color(0xFF3366FF);

Widget _chart(
  List<double> values, {
  required int revision,
  bool disableAnimations = false,
}) {
  return MediaQuery(
    data: MediaQueryData(disableAnimations: disableAnimations),
    child: Center(
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
    ),
  );
}

void main() {
  testWidgets('a new sample scrolls in over one interval', (tester) async {
    await tester.pumpWidget(_chart(const [1, 2, 3], revision: 3));
    expect(tester.hasRunningAnimations, isFalse);

    await tester.pumpWidget(_chart(const [1, 2, 3, 4], revision: 4));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 900));
    expect(tester.hasRunningAnimations, isTrue);
    expect(
      tester.renderObject(
        find.descendant(
          of: find.byType(LineChart),
          matching: find.byType(CustomPaint),
        ),
      ),
      paints
        ..path(style: PaintingStyle.fill)
        ..path(color: _color, style: PaintingStyle.stroke),
    );

    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('a spike scrolling in stays below the top', (tester) async {
    final idle = List.filled(20, 0.0);
    await tester.pumpWidget(_chart([...idle, 10], revision: 21));
    await tester.pumpWidget(_chart([...idle, 10, 0], revision: 22));
    await tester.pump();

    final chart = find.descendant(
      of: find.byType(LineChart),
      matching: find.byType(CustomPaint),
    );
    for (var frame = 0; frame < 11; frame++) {
      expect(
        tester.renderObject(chart),
        paints..something((method, arguments) {
          if (method != #drawPath ||
              (arguments[1] as Paint).style != PaintingStyle.stroke) {
            return false;
          }
          expect((arguments[0] as Path).getBounds().top, greaterThan(0));
          return true;
        }),
      );
      await tester.pump(const Duration(milliseconds: 100));
    }
  });

  testWidgets('a rebuild without a new sample keeps the scroll going', (
    tester,
  ) async {
    await tester.pumpWidget(_chart(const [1, 2, 3], revision: 3));
    await tester.pumpWidget(_chart(const [1, 2, 3, 4], revision: 4));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    await tester.pumpWidget(_chart([1, 2, 3, 4], revision: 4));
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.hasRunningAnimations, isTrue);

    await tester.pump(const Duration(milliseconds: 200));
    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('a clear redraws without scrolling', (tester) async {
    await tester.pumpWidget(_chart(const [1, 2, 3], revision: 3));
    await tester.pumpWidget(_chart(const [], revision: 0));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('an idle window does not animate', (tester) async {
    await tester.pumpWidget(_chart(const [0, 0], revision: 2));
    await tester.pumpWidget(_chart(const [0, 0, 0], revision: 3));
    await tester.pump();

    expect(tester.hasRunningAnimations, isFalse);
  });

  testWidgets('reduced motion jumps straight to the new sample', (
    tester,
  ) async {
    await tester.pumpWidget(
      _chart(const [1, 2, 3], revision: 3, disableAnimations: true),
    );
    await tester.pumpWidget(
      _chart(const [1, 2, 3, 40], revision: 4, disableAnimations: true),
    );
    await tester.pump();

    expect(tester.hasRunningAnimations, isFalse);
  });
}
