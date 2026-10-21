import 'package:fl_clash/ui/ui.dart';
import 'package:flutter/gestures.dart';
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
    test('scrolls by dragging with a mouse too, as on an Android TV', () {
      final devices = const BaseScrollBehavior().dragDevices;
      expect(devices, contains(PointerDeviceKind.touch));
      expect(devices, contains(PointerDeviceKind.trackpad));
      expect(devices, contains(PointerDeviceKind.mouse));
    });

    testWidgets('leaves horizontal scrollables unwrapped', (tester) async {
      final result = await _buildScrollbar(
        tester,
        const BaseScrollBehavior(),
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
        const BaseScrollBehavior(),
        axis: Axis.vertical,
        platform: TargetPlatform.macOS,
      );
      expect(result, isA<CommonScrollBar>());
    });

    testWidgets('leaves vertical mobile scrollables unwrapped', (tester) async {
      final result = await _buildScrollbar(
        tester,
        const BaseScrollBehavior(),
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
        const HiddenBarScrollBehavior(),
        axis: Axis.vertical,
        platform: TargetPlatform.macOS,
      );
      expect(result.key, const ValueKey('child'));
    });

    testWidgets('ShowBarScrollBehavior wraps vertical scrollables on mobile', (
      tester,
    ) async {
      final result = await _buildScrollbar(
        tester,
        const ShowBarScrollBehavior(),
        axis: Axis.vertical,
        platform: TargetPlatform.android,
      );
      expect(result, isA<CommonScrollBar>());
    });

    testWidgets('ShowBarScrollBehavior leaves horizontal scrollables alone', (
      tester,
    ) async {
      final result = await _buildScrollbar(
        tester,
        const ShowBarScrollBehavior(),
        axis: Axis.horizontal,
        platform: TargetPlatform.android,
      );
      expect(result.key, const ValueKey('child'));
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

    test('carries no momentum into the next fling under iOS physics', () {
      const bouncing = BouncingScrollPhysics();
      expect(bouncing.carriedMomentum(3000), greaterThan(3000));
      expect(physics.applyTo(bouncing).carriedMomentum(3000), 0);
    });
  });

  group('FollowEndScrollPhysics', () {
    var following = true;
    final physics = FollowEndScrollPhysics(isFollowing: () => following);

    setUp(() => following = true);

    double adjust({required double oldPixels, double newMax = 160}) {
      return physics.adjustPositionForNewDimensions(
        oldPosition: _metrics(pixels: oldPixels),
        newPosition: _metrics(pixels: oldPixels, maxScrollExtent: newMax),
        isScrolling: false,
        velocity: 0,
      );
    }

    test('moves a following position at its end to the new end', () {
      expect(adjust(oldPixels: 100), 160);
      expect(adjust(oldPixels: 100, newMax: 40), 40);
    });

    test('counts a position past its end as at the end', () {
      expect(adjust(oldPixels: double.maxFinite), 160);
    });

    test('leaves a position off its end where it is', () {
      expect(adjust(oldPixels: 60), 60);
    });

    test('leaves a position that stopped following where it is', () {
      following = false;
      expect(adjust(oldPixels: 100), 100);
    });

    test('applyTo keeps following', () {
      final applied = physics.applyTo(const ClampingScrollPhysics());
      expect(applied, isA<FollowEndScrollPhysics>());
      expect(
        applied.adjustPositionForNewDimensions(
          oldPosition: _metrics(pixels: 100),
          newPosition: _metrics(pixels: 100, maxScrollExtent: 160),
          isScrolling: false,
          velocity: 0,
        ),
        160,
      );
    });
  });
}
