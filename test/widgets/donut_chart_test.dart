import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/donut_chart.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

const _up = Color(0xFF3366FF);
const _down = Color(0xFF33AA66);
const _track = Color(0xFFDDDDDD);

Widget _chart(double up, double down) {
  return TestApp(
    child: Center(
      child: SizedBox.square(
        dimension: 96,
        child: DonutChart(
          trackColor: _track,
          data: [
            DonutChartData(value: up, color: _up),
            DonutChartData(value: down, color: _down),
          ],
        ),
      ),
    ),
  );
}

RenderObject _painter(WidgetTester tester) {
  return tester.renderObject(
    find.descendant(
      of: find.byType(DonutChart),
      matching: find.byType(CustomPaint),
    ),
  );
}

void main() {
  testWidgets('an all-zero ring shows only the full track', (tester) async {
    await tester.pumpWidget(_chart(0, 0));

    expect(
      _painter(tester),
      paints..circle(color: _track, style: PaintingStyle.stroke),
    );
    expect(_painter(tester), isNot(paints..arc()));
  });

  testWidgets('segments replace the track and a small share stays an arc', (
    tester,
  ) async {
    await tester.pumpWidget(_chart(3, 97));

    expect(
      _painter(tester),
      paints
        ..arc(color: _up, strokeCap: StrokeCap.round)
        ..arc(color: _down, strokeCap: StrokeCap.round),
    );
    expect(_painter(tester), isNot(paints..circle()));
  });

  testWidgets('a changed share animates and a negligible one snaps', (
    tester,
  ) async {
    await tester.pumpWidget(_chart(30, 70));

    await tester.pumpWidget(_chart(40, 60));
    await tester.pump();
    expect(tester.hasRunningAnimations, isTrue);
    await tester.pump(commonDuration * 2);
    expect(tester.hasRunningAnimations, isFalse);

    await tester.pumpWidget(_chart(40.01, 59.99));
    await tester.pump();
    expect(tester.hasRunningAnimations, isFalse);
  });
}
