import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/icons/icons.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/dashboard.dart';
import 'package:fl_clash/views/dashboard/widget_registry.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/glyph_finders.dart';
import '../../helpers/test_app.dart';

void main() {
  testWidgets('a widget added from the sheet flies into the dashboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final shown = DashboardWidget.values
        .where(
          (item) =>
              item != DashboardWidget.outboundMode &&
              item.platforms.contains(SupportPlatform.currentPlatform),
        )
        .toList();
    final container = ProviderContainer(
      overrides: [
        dashboardStateProvider.overrideWithValue(
          DashboardState(dashboardWidgets: shown),
        ),
      ],
    );
    addTearDown(container.dispose);
    final appSettingSubscription = container.listen(
      appSettingProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(appSettingSubscription.close);
    globalState.container = container;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: DashboardView()),
      ),
    );
    await tester.pump();
    final dashboardAdds = find.byGlyph(AppGlyphs.add).evaluate().length;

    await tester.tap(find.byKey(const ValueKey('edit-icon')));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byGlyph(AppGlyphs.addCircle));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    await tester.tap(find.byGlyph(AppGlyphs.add).last);
    await tester.pump();
    await tester.pump();

    final grid = tester.state<SuperGridState>(find.byType(SuperGrid));
    expect(grid.items.last, DashboardWidget.outboundMode.widget);
    expect(container.read(appSettingProvider).dashboardWidgets, [
      ...shown,
      DashboardWidget.outboundMode,
    ]);

    for (var i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    expect(find.byGlyph(AppGlyphs.add), findsNWidgets(dashboardAdds));
    expect(tester.takeException(), null);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 10));
  });

  Future<GridItem> openWithTwoLeft(WidgetTester tester, Size size) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final available = DashboardWidget.values
        .where(
          (item) => item.platforms.contains(SupportPlatform.currentPlatform),
        )
        .toList();
    final container = ProviderContainer(
      overrides: [
        dashboardStateProvider.overrideWithValue(
          DashboardState(
            dashboardWidgets: available.sublist(0, available.length - 2),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    final appSettingSubscription = container.listen(
      appSettingProvider,
      (_, _) {},
      fireImmediately: true,
    );
    addTearDown(appSettingSubscription.close);
    globalState.container = container;
    container.read(viewSizeProvider.notifier).value = size;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: DashboardView()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('edit-icon')));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byGlyph(AppGlyphs.addCircle));
    for (var i = 0; i < 10; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    return available[available.length - 2].widget;
  }

  Future<void> pumpFor(WidgetTester tester, int ms) async {
    for (var i = 0; i < ms ~/ 100; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets('the sheet drops out of the way of an add, then comes back', (
    tester,
  ) async {
    final added = await openWithTwoLeft(tester, const Size(400, 900));
    final openTop = tester.getTopLeft(find.byType(SheetDragHandle)).dy;
    expect(openTop, lessThan(200));

    await tester.tap(find.byGlyph(AppGlyphs.add).first);
    await pumpFor(tester, 500);

    final peekTop = tester.getTopLeft(find.byType(SheetDragHandle)).dy;
    expect(peekTop, greaterThan(700));
    final grid = tester.state<SuperGridState>(find.byType(SuperGrid));
    expect(grid.items.last, added);
    final slot = tester.getRect(
      find.descendant(
        of: find.byType(SuperGrid),
        matching: find.byKey(added.key!),
      ),
    );
    expect(slot.bottom, lessThanOrEqualTo(peekTop));
    expect(slot.top, greaterThanOrEqualTo(0));

    await pumpFor(tester, 2000);
    expect(
      tester.getTopLeft(find.byType(SheetDragHandle)).dy,
      closeTo(openTop, 1),
    );
    expect(tester.takeException(), null);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets('a drag cannot rest the sheet at its collapsed height', (
    tester,
  ) async {
    await openWithTwoLeft(tester, const Size(400, 900));
    final openTop = tester.getTopLeft(find.byType(SheetDragHandle)).dy;

    final gesture = await tester.startGesture(
      tester.getCenter(find.byType(SheetDragHandle)),
    );
    for (var i = 0; i < 20; i++) {
      await gesture.moveBy(const Offset(0, 18));
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(milliseconds: 500));
    await gesture.up();
    await pumpFor(tester, 1000);

    expect(
      tester.getTopLeft(find.byType(SheetDragHandle)).dy,
      closeTo(openTop, 1),
    );
    expect(tester.takeException(), null);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 10));
  });

  testWidgets('the side sheet slides off for an add, then comes back', (
    tester,
  ) async {
    await openWithTwoLeft(tester, const Size(1200, 900));
    final openLeft = tester.getTopLeft(find.byType(SideSheet)).dx;
    expect(openLeft, lessThan(1200));

    await tester.tap(find.byGlyph(AppGlyphs.add).first);
    await pumpFor(tester, 400);
    expect(
      tester.getTopLeft(find.byType(SideSheet)).dx,
      greaterThanOrEqualTo(1200),
    );

    await pumpFor(tester, 2000);
    expect(tester.getTopLeft(find.byType(SideSheet)).dx, closeTo(openLeft, 1));
    expect(tester.takeException(), null);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 10));
  });
}
