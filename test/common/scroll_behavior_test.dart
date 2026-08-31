import 'dart:ui';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/scroll.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';

const _metricsAxis = AxisDirection.down;

FixedScrollMetrics _metrics({
  required double pixels,
  double minScrollExtent = 0,
  double maxScrollExtent = 100,
}) {
  return FixedScrollMetrics(
    minScrollExtent: minScrollExtent,
    maxScrollExtent: maxScrollExtent,
    pixels: pixels,
    viewportDimension: 50,
    axisDirection: _metricsAxis,
    devicePixelRatio: 1,
  );
}

Future<Widget> _buildScrollbar(
  WidgetTester tester,
  ScrollBehavior behavior, {
  required Axis axis,
  required TargetPlatform platform,
}) async {
  late Widget result;
  final controller = ScrollController();
  addTearDown(controller.dispose);

  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(platform: platform),
      home: Builder(
        builder: (context) {
          result = behavior.buildScrollbar(
            context,
            const SizedBox(key: ValueKey('child')),
            ScrollableDetails(
              direction: axis == Axis.vertical
                  ? AxisDirection.down
                  : AxisDirection.right,
              controller: controller,
            ),
          );
          return const SizedBox.shrink();
        },
      ),
    ),
  );
  return result;
}

void main() {
  group('BaseScrollBehavior', () {
    test('enables mouse dragging only on desktop', () {
      final devices = BaseScrollBehavior().dragDevices;
      expect(devices, contains(PointerDeviceKind.touch));
      expect(devices, contains(PointerDeviceKind.trackpad));
      expect(devices.contains(PointerDeviceKind.mouse), system.isDesktop);
    });

    testWidgets('leaves horizontal scrollables unwrapped', (tester) async {
      final result = await _buildScrollbar(
        tester,
        BaseScrollBehavior(),
        axis: Axis.horizontal,
        platform: TargetPlatform.macOS,
      );
      expect(result.key, const ValueKey('child'));
    });

    testWidgets('wraps vertical desktop scrollables in a scrollbar', (
      tester,
    ) async {
      final result = await _buildScrollbar(
        tester,
        BaseScrollBehavior(),
        axis: Axis.vertical,
        platform: TargetPlatform.macOS,
      );
      expect(result, isA<CommonScrollBar>());
    });

    testWidgets('leaves vertical mobile scrollables unwrapped', (tester) async {
      final result = await _buildScrollbar(
        tester,
        BaseScrollBehavior(),
        axis: Axis.vertical,
        platform: TargetPlatform.android,
      );
      expect(result.key, const ValueKey('child'));
    });
  });

  group('scroll behavior variants', () {
    testWidgets('HiddenBarScrollBehavior never wraps', (tester) async {
      final result = await _buildScrollbar(
        tester,
        HiddenBarScrollBehavior(),
        axis: Axis.vertical,
        platform: TargetPlatform.macOS,
      );
      expect(result.key, const ValueKey('child'));
    });

    testWidgets('ShowBarScrollBehavior always wraps', (tester) async {
      final result = await _buildScrollbar(
        tester,
        ShowBarScrollBehavior(),
        axis: Axis.horizontal,
        platform: TargetPlatform.android,
      );
      expect(result, isA<CommonScrollBar>());
    });
  });

  group('NextClampingScrollPhysics', () {
    const physics = NextClampingScrollPhysics();

    test('applyTo preserves the subclass', () {
      expect(
        physics.applyTo(const BouncingScrollPhysics()),
        isA<NextClampingScrollPhysics>(),
      );
    });

    test('springs back when scrolled past the end', () {
      final simulation = physics.createBallisticSimulation(
        _metrics(pixels: 150),
        0,
      );
      expect(simulation, isA<ScrollSpringSimulation>());
    });

    test('springs back when scrolled before the start', () {
      final simulation = physics.createBallisticSimulation(
        _metrics(pixels: -20),
        0,
      );
      expect(simulation, isA<ScrollSpringSimulation>());
    });

    test('does not simulate a negligible velocity in range', () {
      expect(
        physics.createBallisticSimulation(_metrics(pixels: 50), 0),
        isNull,
      );
    });

    test('does not simulate a fling past either edge', () {
      expect(
        physics.createBallisticSimulation(_metrics(pixels: 100), 500),
        isNull,
      );
      expect(
        physics.createBallisticSimulation(_metrics(pixels: 0), -500),
        isNull,
      );
    });

    test('clamps a real fling inside the range', () {
      expect(
        physics.createBallisticSimulation(_metrics(pixels: 50), 500),
        isA<ClampingScrollSimulation>(),
      );
    });
  });

  group('ReverseScrollController', () {
    testWidgets('starts scrolled to the bottom of the content', (tester) async {
      final controller = ReverseScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 300,
              child: ListView.builder(
                controller: controller,
                itemCount: 50,
                itemBuilder: (_, index) =>
                    SizedBox(height: 50, child: Text('item $index')),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(controller.position, isA<ReverseScrollPosition>());
      expect(controller.position.pixels, controller.position.maxScrollExtent);
      expect(controller.position.pixels, greaterThan(0));
    });

    testWidgets('keeps the user position after the first layout', (
      tester,
    ) async {
      final controller = ReverseScrollController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 300,
              child: ListView.builder(
                controller: controller,
                itemCount: 50,
                itemBuilder: (_, index) =>
                    SizedBox(height: 50, child: Text('item $index')),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      controller.jumpTo(0);
      await tester.pumpAndSettle();

      expect(controller.position.pixels, 0, reason: 'no second correction');
    });
  });
}
