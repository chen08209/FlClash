import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('a rebuild in the body repaints neither the bar nor the page', (
    tester,
  ) async {
    final count = ValueNotifier(0);
    addTearDown(count.dispose);
    const pageKey = Key('page');
    await tester.pumpWidget(
      TestApp(
        wrapInProviderScope: true,
        child: RepaintBoundary(
          key: pageKey,
          child: CommonScaffold(
            title: 'Page',
            body: Column(
              children: [
                ValueListenableBuilder(
                  valueListenable: count,
                  builder: (_, value, _) =>
                      RepaintBoundary(child: Text('$value')),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    final page = tester.renderObject<RenderRepaintBoundary>(
      find.byKey(pageKey),
    );
    page.debugResetMetrics();

    count.value++;
    await tester.pump();

    expect(find.text('1'), findsOneWidget);
    expect(page.debugSymmetricPaintCount + page.debugAsymmetricPaintCount, 0);
  });
}
