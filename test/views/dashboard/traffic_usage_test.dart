import 'package:fl_clash/views/dashboard/widget_metrics.dart';
import 'package:fl_clash/views/dashboard/widgets/traffic_usage.dart';
import 'package:fl_clash/widgets/donut_chart.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/test_app.dart';

void main() {
  Future<void> pumpCard(
    WidgetTester tester, {
    required double width,
    required double unitHeight,
  }) async {
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: width,
              child: DashboardWidgetMetrics(
                unitHeight: unitHeight,
                child: const TrafficUsage(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('a tall narrow card shrinks the chart to keep its legend', (
    tester,
  ) async {
    await pumpCard(tester, width: 260, unitHeight: 120);

    expect(find.text('Upload'), findsOneWidget);
    final chart = tester.getRect(find.byType(DonutChart));
    expect(chart.width, lessThan(96));
    expect(chart.right, lessThan(tester.getRect(find.text('Download')).left));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a card too narrow for both drops the legend', (tester) async {
    await pumpCard(tester, width: 173, unitHeight: 80);

    expect(find.text('Upload'), findsNothing);
    expect(tester.getSize(find.byType(DonutChart)).width, greaterThan(0));
    expect(tester.takeException(), isNull);
  });
}
