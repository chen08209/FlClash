import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('following the system picks up a font scale changed while the '
      'app runs', (tester) async {
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    double? scaled;
    await tester.pumpWidget(
      PrismApp(
        home: Builder(
          builder: (context) {
            scaled = MediaQuery.textScalerOf(context).scale(10);
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(scaled, 10);

    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    await tester.pump();

    expect(scaled, closeTo(13, 1e-9));
  });
}
