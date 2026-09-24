import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

ShapeBorder? _shapeOf(WidgetTester tester, Finder button) => tester
    .widget<Material>(
      find.descendant(of: button, matching: find.byType(Material)).first,
    )
    .shape;

void main() {
  testWidgets('pill buttons take the superellipse capsule, not the stadium', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(useMaterial3: true).withAppShapes,
        home: Scaffold(
          body: Column(
            children: [
              TextButton(onPressed: () {}, child: const Text('text')),
              OutlinedButton(onPressed: () {}, child: const Text('outlined')),
              CommonMinFilledButtonTheme(
                child: FilledButton(
                  onPressed: () {},
                  child: const Text('filled'),
                ),
              ),
            ],
          ),
        ),
      ),
    );

    for (final type in [TextButton, OutlinedButton, FilledButton]) {
      expect(
        _shapeOf(tester, find.byType(type)),
        isA<RoundedSuperellipseBorder>().having(
          (shape) => shape.borderRadius,
          'borderRadius',
          AppRadius.full,
        ),
        reason: '$type',
      );
    }
  });
}
