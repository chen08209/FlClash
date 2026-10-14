import 'package:fl_clash/manager/theme_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  testWidgets('following the system picks up a font scale changed while the '
      'app runs', (tester) async {
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    double? scaled;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: ThemeManager(
            child: Builder(
              builder: (context) {
                scaled = MediaQuery.textScalerOf(context).scale(10);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      ),
    );

    expect(scaled, 10);

    tester.platformDispatcher.textScaleFactorTestValue = 1.3;
    await tester.pump();

    expect(scaled, closeTo(13, 1e-9));
  });
}
