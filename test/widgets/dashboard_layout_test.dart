import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/dashboard.dart';
import 'package:fl_clash/views/dashboard/widget_metrics.dart';
import 'package:fl_clash/widgets/super_grid.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../helpers/test_app.dart';

void main() {
  testWidgets('dashboard uses 12 columns from 480 logical pixels', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(511, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        dashboardStateProvider.overrideWithValue(
          const DashboardState(dashboardWidgets: []),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: DashboardView()),
      ),
    );
    await tester.pump();

    final grid = find.byType(SuperGrid);
    expect(tester.getSize(grid).width, 479);
    expect(tester.widget<SuperGrid>(grid).crossAxisCount, 8);

    tester.view.physicalSize = const Size(512, 1000);
    await tester.pump();

    expect(tester.getSize(grid).width, 480);
    expect(tester.widget<SuperGrid>(grid).crossAxisCount, 12);
    expect(tester.takeException(), null);
  });

  testWidgets('dashboard limits a wide grid to 16 centered columns', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1600, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        dashboardStateProvider.overrideWithValue(
          const DashboardState(dashboardWidgets: []),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: DashboardView()),
      ),
    );
    await tester.pump();

    final grid = find.byType(SuperGrid);
    expect(tester.widget<SuperGrid>(grid).crossAxisCount, 16);
    expect(tester.getSize(grid).width, 1120);
    expect(tester.getTopLeft(grid).dx, 240);
    expect(tester.takeException(), null);
  });

  testWidgets('dashboard cards grow once the grid passes the default window', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final container = ProviderContainer(
      overrides: [
        dashboardStateProvider.overrideWithValue(
          const DashboardState(dashboardWidgets: []),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const TestApp(child: DashboardView()),
      ),
    );
    await tester.pump();

    final metrics = find.byType(DashboardWidgetMetrics);
    double unitHeight() =>
        tester.widget<DashboardWidgetMetrics>(metrics).unitHeight;
    expect(unitHeight(), 80);

    tester.view.physicalSize = const Size(511, 1000);
    await tester.pump();

    expect(tester.widget<SuperGrid>(find.byType(SuperGrid)).crossAxisCount, 8);
    expect(unitHeight(), 80);

    tester.view.physicalSize = const Size(632, 1000);
    await tester.pump();

    expect(tester.widget<SuperGrid>(find.byType(SuperGrid)).crossAxisCount, 12);
    expect(unitHeight(), 80);

    tester.view.physicalSize = const Size(872, 1000);
    await tester.pump();

    expect(tester.widget<SuperGrid>(find.byType(SuperGrid)).crossAxisCount, 12);
    final beforeBreakpoint = unitHeight();
    expect(beforeBreakpoint, closeTo(98.5, 0.1));

    tester.view.physicalSize = const Size(873, 1000);
    await tester.pump();

    expect(tester.widget<SuperGrid>(find.byType(SuperGrid)).crossAxisCount, 16);
    expect(unitHeight(), closeTo(beforeBreakpoint, 0.1));

    tester.view.physicalSize = const Size(892, 1000);
    await tester.pump();

    expect(unitHeight(), 100);

    tester.view.physicalSize = const Size(1600, 1000);
    await tester.pump();

    expect(tester.widget<DashboardWidgetMetrics>(metrics).unitHeight, 120);
    expect(tester.takeException(), null);
  });

  testWidgets('dashboard metrics survive capture into an overlay', (
    tester,
  ) async {
    double? captured;
    await tester.pumpWidget(
      TestApp(
        child: DashboardWidgetMetrics(
          unitHeight: 110,
          child: Builder(
            builder: (context) {
              return Overlay(
                initialEntries: [
                  OverlayEntry(
                    builder: (_) => InheritedTheme.captureAll(
                      context,
                      Builder(
                        builder: (context) {
                          captured = DashboardWidgetMetrics.heightOf(
                            context,
                            1,
                          );
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
    expect(captured, 110);
  });

  testWidgets('dashboard card radius scales with the unit height', (
    tester,
  ) async {
    double? radius;
    await tester.pumpWidget(
      TestApp(
        child: DashboardWidgetMetrics(
          unitHeight: 120,
          child: Builder(
            builder: (context) {
              radius = DashboardWidgetMetrics.radiusOf(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
    expect(radius, 30);
  });

  testWidgets('dashboard text grows with the unit height', (tester) async {
    Future<(double, double?)> measure(double unitHeight) async {
      double? scale;
      double? fontSize;
      await tester.pumpWidget(
        TestApp(
          child: DashboardWidgetMetrics(
            unitHeight: unitHeight,
            child: Builder(
              builder: (context) {
                scale = DashboardWidgetMetrics.textScaleOf(context);
                fontSize = Theme.of(context).textTheme.bodyMedium?.fontSize;
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      return (scale!, fontSize);
    }

    expect(await measure(80), (1.0, 14.0));
    final (mediumScale, mediumFontSize) = await measure(100);
    expect(mediumScale, closeTo(1.075, 0.001));
    expect(mediumFontSize, closeTo(15.05, 0.01));
    final (wideScale, wideFontSize) = await measure(120);
    expect(wideScale, closeTo(1.15, 0.001));
    expect(wideFontSize, closeTo(16.1, 0.01));
  });

  testWidgets('dashboard card inset grows gently with the unit height', (
    tester,
  ) async {
    Future<(double, double)> measure(double unitHeight) async {
      double? inset;
      double? verticalInset;
      await tester.pumpWidget(
        TestApp(
          child: DashboardWidgetMetrics(
            unitHeight: unitHeight,
            child: Builder(
              builder: (context) {
                inset = DashboardWidgetMetrics.insetOf(context);
                verticalInset = DashboardWidgetMetrics.verticalInsetOf(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      return (inset!, verticalInset!);
    }

    expect(await measure(80), (16.0, 14.0));
    expect(await measure(100), (19.0, 18.0));
    expect(await measure(120), (22.0, 22.0));
    expect(await measure(140), (22.0, 22.0));
  });
}
