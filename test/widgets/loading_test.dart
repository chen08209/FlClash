import 'package:fl_clash/ui/loading.dart';
import 'package:flutter/scheduler.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Size loadingSize(WidgetTester tester) => tester.getSize(
    find.descendant(
      of: find.byType(CommonCircleLoading),
      matching: find.byType(CustomPaint),
    ),
  );

  testWidgets('CommonCircleLoading takes the ambient icon size', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: IconTheme(
            data: IconThemeData(size: 20),
            child: CommonCircleLoading(),
          ),
        ),
      ),
    );

    expect(loadingSize(tester), const Size.square(20));
  });

  testWidgets('CommonCircleLoading takes an explicit or page size', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CommonCircleLoading(size: 16),
              CommonCircleLoading.page(),
            ],
          ),
        ),
      ),
    );

    final sizes = tester
        .widgetList<CommonCircleLoading>(find.byType(CommonCircleLoading))
        .map((loading) => tester.getSize(find.byWidget(loading)));
    expect(sizes, [const Size.square(16), const Size.square(48)]);
  });

  testWidgets('CommonCircleLoading fills a tight slot', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox.square(
            dimension: 32,
            child: CommonCircleLoading(size: 24),
          ),
        ),
      ),
    );

    expect(loadingSize(tester), const Size.square(32));
  });

  testWidgets('CommonCircleLoading keeps turning until disposed', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(home: Center(child: CommonCircleLoading())),
    );
    await tester.pump(const Duration(milliseconds: 2500));

    expect(SchedulerBinding.instance.transientCallbackCount, 1);

    await tester.pumpWidget(const SizedBox.shrink());

    expect(SchedulerBinding.instance.transientCallbackCount, 0);
  });

  testWidgets('CommonCircleLoading exposes an optional label', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CommonCircleLoading(semanticLabel: 'Loading profiles'),
      ),
    );

    expect(find.bySemanticsLabel('Loading profiles'), findsOneWidget);
  });
}
