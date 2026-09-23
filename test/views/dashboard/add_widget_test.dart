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
    expect(find.byGlyph(AppGlyphs.add), findsNothing);
    expect(tester.takeException(), null);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 10));
  });
}
