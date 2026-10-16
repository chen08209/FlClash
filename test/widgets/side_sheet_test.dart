import 'package:fl_clash/ui/side_sheet.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _opener({required ValueSetter<BuildContext> onPressed}) {
  return MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) {
          return FilledButton(
            onPressed: () => onPressed(context),
            child: const Text('Open sheet'),
          );
        },
      ),
    ),
  );
}

void main() {
  testWidgets('SideSheet paints the given background', (tester) async {
    final controller = SideSheet.createAnimationController(tester);
    addTearDown(controller.dispose);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SideSheet(
            backgroundColor: Colors.red,
            builder: (_) => const Text('Content'),
          ),
        ),
      ),
    );

    final material = tester.widget<Material>(
      find
          .ancestor(of: find.text('Content'), matching: find.byType(Material))
          .first,
    );
    expect(material.color, Colors.red);
    expect(controller.duration, const Duration(milliseconds: 300));
    expect(controller.reverseDuration, const Duration(milliseconds: 200));
  });

  testWidgets(
    'modal side sheet animates, returns a value, and uses a barrier',
    (tester) async {
      String? result;

      await tester.pumpWidget(
        _opener(
          onPressed: (context) async {
            result = await showModalSideSheet<String>(
              context: context,
              barrierColor: Colors.black45,
              backgroundColor: Colors.green,
              builder: (context) {
                return TextButton(
                  onPressed: () => Navigator.pop(context, 'done'),
                  child: const Text('Close sheet'),
                );
              },
            );
          },
        ),
      );

      await tester.tap(find.text('Open sheet'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(SideSheet), findsOneWidget);
      expect(find.byType(AnimatedModalBarrier), findsOneWidget);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Close sheet'));
      await tester.pumpAndSettle();

      expect(result, 'done');
      expect(find.byType(SideSheet), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('a tap on a transparent barrier dismisses the side sheet', (
    tester,
  ) async {
    var completed = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(platform: TargetPlatform.iOS),
        home: Scaffold(
          body: Builder(
            builder: (context) {
              return FilledButton(
                onPressed: () async {
                  await showModalSideSheet<void>(
                    context: context,
                    barrierColor: Colors.transparent,
                    builder: (_) =>
                        const SizedBox(width: 200, child: Text('Dismiss me')),
                  );
                  completed = true;
                },
                child: const Text('Open transparent'),
              );
            },
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open transparent'));
    await tester.pumpAndSettle();
    expect(find.byType(ModalBarrier), findsWidgets);

    await tester.tapAt(const Offset(20, 300));
    await tester.pumpAndSettle();

    expect(completed, isTrue);
    expect(find.text('Dismiss me'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('a screen reader reaches the barrier beside the side sheet', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      _opener(
        onPressed: (context) => showModalSideSheet<void>(
          context: context,
          builder: (_) => const Text('Side'),
        ),
      ),
    );
    await tester.tap(find.text('Open sheet'));
    await tester.pumpAndSettle();

    final sheet = tester.getRect(find.byType(SideSheet));
    final barrier = tester.getSemantics(find.bySemanticsLabel('Scrim')).rect;
    expect(barrier.width, closeTo(sheet.left, 0.1));
    expect(
      barrier.height,
      tester.view.physicalSize.height / tester.view.devicePixelRatio,
    );
    semantics.dispose();
  });
}
