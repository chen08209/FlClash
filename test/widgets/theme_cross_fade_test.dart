import 'package:fl_clash/ui/theme_cross_fade.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

const _red = Color(0xFFFF0000);
const _blue = Color(0xFF0000FF);
const _green = Color(0xFF00FF00);

void main() {
  final shotKey = GlobalKey();
  late ValueNotifier<Color> background;

  setUp(() => background = ValueNotifier(_red));
  tearDown(() => background.dispose());

  Future<void> pumpApp(WidgetTester tester, {double opacity = 1}) async {
    tester.view.physicalSize = const Size(40, 40);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      RepaintBoundary(
        key: shotKey,
        child: ValueListenableBuilder(
          valueListenable: background,
          builder: (_, color, _) => MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: ThemeData(scaffoldBackgroundColor: color),
            themeAnimationStyle: AnimationStyle.noAnimation,
            builder: (_, child) => ThemeCrossFade(child: child!),
            home: Builder(
              builder: (context) => ColoredBox(
                color: Theme.of(
                  context,
                ).scaffoldBackgroundColor.withValues(alpha: opacity),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<Color> pixel(WidgetTester tester) async {
    final boundary =
        shotKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
    late Color color;
    await tester.runAsync(() async {
      final image = await boundary.toImage();
      final data = (await image.toByteData())!;
      image.dispose();
      color = Color.fromARGB(
        data.getUint8(3),
        data.getUint8(0),
        data.getUint8(1),
        data.getUint8(2),
      );
    });
    return color;
  }

  List<double> channels(Color color) => [color.a, color.r, color.g, color.b];

  Matcher isColor(Color expected) => isA<Color>().having(
    channels,
    'channels',
    pairwiseCompare<double, double>(
      channels(expected),
      (expected, actual) => (expected - actual).abs() <= 2 / 255,
      'within 2/255 of',
    ),
  );

  testWidgets('shows the last frame over a new theme until the fade ends', (
    tester,
  ) async {
    await pumpApp(tester);

    background.value = _blue;
    await tester.pump();
    expect(await pixel(tester), isColor(_red));

    await tester.pump(const Duration(milliseconds: 100));
    expect(await pixel(tester), isColor(Color.lerp(_red, _blue, 0.5)!));

    await tester.pumpAndSettle();
    expect(await pixel(tester), isColor(_blue));
  });

  testWidgets('keeps a translucent pixel as opaque as it was', (tester) async {
    await pumpApp(tester, opacity: 0.5);
    final alpha = (await pixel(tester)).a;

    background.value = _blue;
    for (var frame = 0; frame < 14; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      expect(
        (await pixel(tester)).a,
        moreOrLessEquals(alpha, epsilon: 1 / 255),
      );
    }
  });

  testWidgets('a second change mid-fade starts from what is on screen', (
    tester,
  ) async {
    await pumpApp(tester);
    background.value = _blue;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    final onScreen = await pixel(tester);

    background.value = _green;
    await tester.pump();
    expect(await pixel(tester), isColor(onScreen));

    await tester.pumpAndSettle();
    expect(await pixel(tester), isColor(_green));
  });

  testWidgets('switches at once when animations are disabled', (tester) async {
    tester.platformDispatcher.accessibilityFeaturesTestValue =
        const FakeAccessibilityFeatures(disableAnimations: true);
    addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
    await pumpApp(tester);

    background.value = _blue;
    await tester.pump();

    expect(await pixel(tester), isColor(_blue));
    expect(tester.hasRunningAnimations, isFalse);
  });
}
