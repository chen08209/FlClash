import 'package:fl_clash/common/shape.dart';
import 'package:fl_clash/widgets/loading.dart';
import 'package:material_new_shapes/material_new_shapes.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('CommonCircleLoading uses the M3E default size', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Center(child: CommonCircleLoading())),
    );

    final customPaint = find.descendant(
      of: find.byType(CommonCircleLoading),
      matching: find.byType(CustomPaint),
    );

    expect(tester.getSize(customPaint), const Size.square(48));
  });

  testWidgets('CommonCircleLoading shrink-wraps when constraints are loose', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 100, maxHeight: 32),
            child: const CommonCircleLoading(),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byType(CommonCircleLoading)),
      const Size.square(32),
    );
  });

  testWidgets('CommonCircleLoading paints within the shortest constraint', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox(
            width: 100,
            child: SizedBox.square(dimension: 32, child: CommonCircleLoading()),
          ),
        ),
      ),
    );

    final customPaint = find.descendant(
      of: find.byType(CommonCircleLoading),
      matching: find.byType(CustomPaint),
    );

    expect(tester.getSize(customPaint), const Size.square(32));
  });

  testWidgets('CommonCircleLoading continuously rotates and morphs', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: SizedBox.square(dimension: 48, child: CommonCircleLoading()),
        ),
      ),
    );

    final loading = find.byType(CommonCircleLoading);
    final transform = find.descendant(
      of: loading,
      matching: find.byType(Transform),
    );
    final customPaint = find.descendant(
      of: loading,
      matching: find.byType(CustomPaint),
    );
    final initialTransform = tester.widget<Transform>(transform).transform;
    final initialPainter = tester.widget<CustomPaint>(customPaint).painter!;

    await tester.pump(const Duration(milliseconds: 325));

    final animatedTransform = tester.widget<Transform>(transform).transform;
    final animatedPainter = tester.widget<CustomPaint>(customPaint).painter!;

    expect(animatedTransform.storage, isNot(equals(initialTransform.storage)));
    expect(animatedPainter.shouldRepaint(initialPainter), isTrue);

    for (var i = 0; i < 7; i++) {
      await tester.pump(const Duration(milliseconds: 650));
    }

    expect(tester.takeException(), isNull);
  });

  testWidgets('CommonCircleLoading exposes optional loading semantics', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: CommonCircleLoading(
          semanticLabel: 'Loading profiles',
          semanticValue: 'In progress',
        ),
      ),
    );

    expect(find.bySemanticsLabel('Loading profiles'), findsOneWidget);
  });

  testWidgets('CommonCircleLoading supports the contained M3E API variant', (
    tester,
  ) async {
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.blue);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(colorScheme: colorScheme),
        home: Center(
          child: CommonCircleLoading(
            variant: LoadingIndicatorM3EVariant.contained,
            constraints: const BoxConstraints.tightFor(width: 32, height: 32),
            padding: const EdgeInsets.all(4),
            polygons: [
              RoundedPolygon.star(numVerticesPerRadius: 6),
              RoundedPolygon.star(numVerticesPerRadius: 8),
            ],
          ),
        ),
      ),
    );

    final decoratedBox = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(CommonCircleLoading),
        matching: find.byType(DecoratedBox),
      ),
    );
    final decoration = decoratedBox.decoration as BoxDecoration;
    final customPaint = find.descendant(
      of: find.byType(CommonCircleLoading),
      matching: find.byType(CustomPaint),
    );

    expect(decoration.color, colorScheme.primaryContainer);
    expect(decoration.borderRadius, AppRadius.full);
    expect(tester.getSize(customPaint), const Size.square(32));
    expect(
      tester.getSize(find.byType(CommonCircleLoading)),
      const Size.square(40),
    );
  });
}
