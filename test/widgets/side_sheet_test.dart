import 'package:fl_clash/widgets/side_sheet.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('SideSheet applies defaults and custom presentation values', (
    tester,
  ) async {
    final controller = SideSheet.createAnimationController(tester);
    addTearDown(controller.dispose);
    var closed = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SideSheet(
            animationController: controller,
            onClosing: () {
              closed = true;
            },
            enableDrag: false,
            showDragHandle: true,
            backgroundColor: Colors.red,
            shadowColor: Colors.blue,
            elevation: 4,
            shape: const RoundedRectangleBorder(),
            clipBehavior: Clip.hardEdge,
            constraints: const BoxConstraints(minWidth: 240, maxWidth: 240),
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
    expect(material.shadowColor, Colors.blue);
    expect(material.elevation, 4);
    expect(tester.getSize(find.byType(SideSheet)).width, 240);
    expect(controller.duration, const Duration(milliseconds: 300));
    expect(controller.reverseDuration, const Duration(milliseconds: 200));
    expect(closed, isFalse);
  });

  testWidgets(
    'modal side sheet animates, returns a value, and uses a barrier',
    (tester) async {
      String? result;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return FilledButton(
                  onPressed: () async {
                    result = await showModalSideSheet<String>(
                      context: context,
                      useSafeArea: true,
                      isScrollControlled: true,
                      barrierColor: Colors.black45,
                      backgroundColor: Colors.green,
                      elevation: 3,
                      shape: const RoundedRectangleBorder(),
                      clipBehavior: Clip.antiAlias,
                      constraints: const BoxConstraints(maxWidth: 280),
                      routeSettings: const RouteSettings(name: 'side-sheet'),
                      anchorPoint: Offset.zero,
                      builder: (context) {
                        return SizedBox(
                          width: 280,
                          child: TextButton(
                            onPressed: () => Navigator.pop(context, 'done'),
                            child: const Text('Close sheet'),
                          ),
                        );
                      },
                    );
                  },
                  child: const Text('Open sheet'),
                );
              },
            ),
          ),
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

  testWidgets(
    'transparent modal side sheet uses supplied controller and dismisses',
    (tester) async {
      final controller = AnimationController(
        vsync: tester,
        duration: const Duration(milliseconds: 20),
        reverseDuration: const Duration(milliseconds: 20),
      );
      addTearDown(controller.dispose);
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
                      transitionAnimationController: controller,
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
    },
  );
}
