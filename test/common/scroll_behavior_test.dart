import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/widgets/scroll.dart';
import 'package:flutter/gestures.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:super_sliver_list/super_sliver_list.dart';

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
      final devices = const BaseScrollBehavior().dragDevices;
      expect(devices, contains(PointerDeviceKind.touch));
      expect(devices, contains(PointerDeviceKind.trackpad));
      expect(devices.contains(PointerDeviceKind.mouse), system.isDesktop);
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

  testWidgets('zero-height dividers do not lengthen a separated list', (
    tester,
  ) async {
    final controller = ScrollController();
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        home: SuperListView.separated(
          controller: controller,
          itemCount: 200,
          extentEstimation: zeroDividerExtentEstimation,
          separatorBuilder: (_, _) => const Divider(height: 0),
          itemBuilder: (_, index) =>
              SizedBox(height: 100, child: Text('$index')),
        ),
      ),
    );
    final viewport = controller.position.viewportDimension;

    expect(controller.position.maxScrollExtent, 200 * 100 - viewport);

    controller.jumpTo(controller.position.maxScrollExtent);
    await tester.pump();

    expect(controller.position.maxScrollExtent, 200 * 100 - viewport);
    expect(controller.offset, controller.position.maxScrollExtent);
  });

  group('RowSnapScrollPhysics', () {
    const extent = 48.0;

    Future<RowSnapScrollController> pumpList(
      WidgetTester tester, {
      RowSnapScrollController? controller,
      double itemExtent = extent,
    }) async {
      if (controller == null) {
        controller = RowSnapScrollController();
        addTearDown(controller.dispose);
      }
      controller.itemExtent = itemExtent;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              height: 300,
              child: ListView.builder(
                controller: controller,
                physics: const RowSnapScrollPhysics(),
                itemExtent: itemExtent,
                itemCount: 50,
                itemBuilder: (_, index) => Text('item $index'),
              ),
            ),
          ),
        ),
      );
      return controller;
    }

    const wheelRest = Duration(milliseconds: 250);

    bool onRow(double pixels) => pixels % extent == 0;

    testWidgets('a fling keeps its momentum and then rests on a row', (
      tester,
    ) async {
      final controller = await pumpList(tester);
      await tester.fling(find.byType(ListView), const Offset(0, -100), 3000);
      await tester.pumpAndSettle();

      expect(controller.offset, greaterThan(extent * 3));
      expect(onRow(controller.offset), isTrue, reason: '${controller.offset}');
    });

    testWidgets('a drag released without velocity settles on a row', (
      tester,
    ) async {
      final controller = await pumpList(tester);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListView)),
      );
      await gesture.moveBy(const Offset(0, -20));
      await gesture.moveBy(const Offset(0, -50));
      await tester.pump(const Duration(seconds: 1));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(onRow(controller.offset), isTrue, reason: '${controller.offset}');
    });

    testWidgets('a wheel tick shorter than a row still advances one', (
      tester,
    ) async {
      final controller = await pumpList(tester);
      final center = tester.getCenter(find.byType(ListView));
      await tester.sendEventToBinding(
        PointerScrollEvent(position: center, scrollDelta: const Offset(0, 10)),
      );
      await tester.pump(wheelRest);
      await tester.pumpAndSettle();
      expect(controller.offset, extent);

      await tester.sendEventToBinding(
        PointerScrollEvent(position: center, scrollDelta: const Offset(0, -10)),
      );
      await tester.pump(wheelRest);
      await tester.pumpAndSettle();
      expect(controller.offset, 0);
    });

    testWidgets('the wheel scrolls freely and settles once it rests', (
      tester,
    ) async {
      final controller = await pumpList(tester);
      final center = tester.getCenter(find.byType(ListView));
      for (var i = 1; i <= 7; i++) {
        await tester.sendEventToBinding(
          PointerScrollEvent(
            position: center,
            scrollDelta: const Offset(0, 10),
          ),
        );
        await tester.pump(const Duration(milliseconds: 50));
        expect(controller.offset, i * 10);
      }
      await tester.pump(wheelRest);
      await tester.pumpAndSettle();
      expect(controller.offset, extent * 2);
    });

    testWidgets('the end of the list is a stop of its own', (tester) async {
      final controller = await pumpList(tester);
      final max = controller.position.maxScrollExtent;
      controller.jumpTo(max);
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(ListView)),
      );
      await gesture.moveBy(const Offset(0, 20));
      await gesture.moveBy(const Offset(0, 20));
      await tester.pump(const Duration(seconds: 1));
      await gesture.up();
      await tester.pumpAndSettle();

      expect(controller.offset, (max / extent).floor() * extent);
      expect(onRow(controller.offset), isTrue);
    });

    testWidgets('a new row height moves the stops with it', (tester) async {
      const taller = 60.0;
      final controller = await pumpList(tester);
      controller.jumpTo(extent * 2);
      await pumpList(tester, controller: controller, itemExtent: taller);
      await tester.pumpAndSettle();
      expect(controller.offset, taller * 2);

      await tester.sendEventToBinding(
        PointerScrollEvent(
          position: tester.getCenter(find.byType(ListView)),
          scrollDelta: const Offset(0, 10),
        ),
      );
      await tester.pump(wheelRest);
      await tester.pumpAndSettle();
      expect(controller.offset, taller * 3);
    });

    testWidgets('the end of the list stays reachable', (tester) async {
      final controller = await pumpList(tester);
      controller.jumpTo(controller.position.maxScrollExtent - 30);
      await tester.fling(find.byType(ListView), const Offset(0, -300), 2000);
      await tester.pumpAndSettle();

      expect(controller.offset, controller.position.maxScrollExtent);
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
