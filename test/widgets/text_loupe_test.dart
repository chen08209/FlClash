import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:prism_ui/prism_ui.dart';
import '../helpers/test_app.dart';

MagnifierInfo _infoAt(double x) => MagnifierInfo(
  globalGesturePosition: Offset(x, 100),
  caretRect: Rect.fromLTWH(x, 90, 0, 20),
  fieldBounds: const Rect.fromLTWH(0, 0, 400, 400),
  currentLineBoundaries: const Rect.fromLTWH(0, 90, 400, 20),
);

void main() {
  late MagnifierController controller;
  late ValueNotifier<MagnifierInfo> info;

  Future<void> showLoupe(WidgetTester tester) async {
    controller = MagnifierController();
    info = ValueNotifier(_infoAt(100));
    addTearDown(info.dispose);
    await tester.pumpWidget(const HostApp(home: SizedBox()));
    controller.show(
      context: tester.element(find.byType(SizedBox)),
      builder: (_) => TextLoupe(controller: controller, magnifierInfo: info),
    );
    await tester.pumpAndSettle();
    expect(controller.shown, isTrue);
  }

  for (final (platform, overEmpty) in [
    (TargetPlatform.android, false),
    (TargetPlatform.iOS, true),
  ]) {
    testWidgets('a long press on an empty field on $platform', (tester) async {
      debugDefaultTargetPlatformOverride = platform;
      addTearDown(() => debugDefaultTargetPlatformOverride = null);
      final text = TextEditingController();
      addTearDown(text.dispose);
      await tester.pumpWidget(
        HostApp(
          home: Center(
            child: SizedBox(width: 300, child: SearchField(controller: text)),
          ),
        ),
      );
      final center = tester.getCenter(find.byType(EditableText));

      Future<bool> loupeOnLongPress() async {
        final gesture = await tester.startGesture(center);
        await tester.pump(const Duration(milliseconds: 600));
        await tester.pump();
        final shown = find.byType(TextLoupe).evaluate().isNotEmpty;
        await gesture.up();
        await tester.pumpAndSettle();
        return shown;
      }

      expect(await loupeOnLongPress(), overEmpty);
      text.text = 'some words to look at';
      await tester.pump();
      expect(await loupeOnLongPress(), isTrue);
      debugDefaultTargetPlatformOverride = null;
    });
  }

  testWidgets('a long press lets go of the press around the field', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    addTearDown(() => debugDefaultTargetPlatformOverride = null);
    final text = TextEditingController(text: 'some words to look at');
    addTearDown(text.dispose);
    await tester.pumpWidget(
      HostApp(
        home: Center(
          child: SizedBox(
            width: 300,
            child: ElasticPress(child: SearchField(controller: text)),
          ),
        ),
      ),
    );
    final field = find.byType(EditableText);
    final gesture = await tester.startGesture(tester.getCenter(field));
    double lift() => ElasticPress.liftOf(tester.renderObject<RenderBox>(field));

    await tester.pump(const Duration(milliseconds: 300));
    await tester.pump(const Duration(milliseconds: 100));
    expect(lift(), greaterThan(0.5));

    await tester.pump(const Duration(milliseconds: 200));
    for (var i = 0; i < 60; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(find.byType(TextLoupe), findsOneWidget);
    expect(lift(), moreOrLessEquals(0, epsilon: 0.01));

    await gesture.up();
    await tester.pumpAndSettle();
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('a layout change while the loupe hides lets it go', (
    tester,
  ) async {
    await showLoupe(tester);

    controller.hide();
    await tester.pump(const Duration(milliseconds: 50));
    tester.view.physicalSize = const Size(1000, 800);
    addTearDown(tester.view.resetPhysicalSize);
    await tester.pumpAndSettle();

    expect(controller.overlayEntry, isNull);
    expect(find.byType(TextLoupe), findsNothing);
  });

  testWidgets('a new position while the loupe hides brings it back', (
    tester,
  ) async {
    await showLoupe(tester);

    controller.hide();
    await tester.pump(const Duration(milliseconds: 50));
    info.value = _infoAt(200);
    await tester.pumpAndSettle();

    expect(controller.shown, isTrue);
    expect(find.byType(TextLoupe), findsOneWidget);
  });
}
