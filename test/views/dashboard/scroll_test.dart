import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/dashboard.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer(
      overrides: [profilesProvider.overrideWith(TestProfiles.new)],
    );
    globalState.container = container;
  });

  tearDown(() => container.dispose());

  Future<ScrollPosition> pumpDashboard(
    WidgetTester tester,
    Size size,
    SupportPlatform platform,
  ) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    container.read(viewSizeProvider.notifier).value = size;
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(child: DashboardView(platform: platform)),
      ),
    );
    await tester.pump();
    return tester
        .state<ScrollableState>(find.byType(Scrollable).first)
        .position;
  }

  Future<void> teardown(WidgetTester tester) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 5));
  }

  testWidgets('the phone cards keep their scroll end while scrolling', (
    tester,
  ) async {
    final position = await pumpDashboard(
      tester,
      const Size(412, 700),
      SupportPlatform.Android,
    );
    final end = position.maxScrollExtent;
    expect(end, greaterThan(0));

    final gesture = await tester.startGesture(const Offset(200, 500));
    while (position.pixels < end) {
      await gesture.moveBy(const Offset(0, -40));
      await tester.pump(const Duration(milliseconds: 16));
      expect(position.maxScrollExtent, end);
    }
    await gesture.up();
    await tester.pump(const Duration(seconds: 2));
    expect(position.pixels, end);

    await teardown(tester);
  });

  testWidgets('the desktop grid bounces when it fits the window', (
    tester,
  ) async {
    final position = await pumpDashboard(
      tester,
      const Size(1220, 900),
      SupportPlatform.MacOS,
    );
    expect(position.maxScrollExtent, 0);

    final gesture = await tester.startGesture(const Offset(600, 450));
    await gesture.moveBy(const Offset(0, 20));
    await gesture.moveBy(const Offset(0, 80));
    await tester.pump(const Duration(milliseconds: 16));
    expect(position.pixels, lessThan(0));

    await gesture.up();
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    expect(position.pixels, closeTo(0, 1));

    await teardown(tester);
  }, variant: TargetPlatformVariant.only(TargetPlatform.macOS));
}
