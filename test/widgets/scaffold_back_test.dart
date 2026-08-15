import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/theme.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/access.dart';
import 'package:fl_clash/views/dashboard/dashboard.dart';
import 'package:fl_clash/views/logs.dart';
import 'package:fl_clash/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('back layers are consumed from inner to outer', (tester) async {
    var innerActive = true;
    var outerActive = true;
    var innerBackCount = 0;
    var outerBackCount = 0;
    var rootBackCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: CommonPopScope(
          onPop: (_) {
            rootBackCount++;
            return false;
          },
          child: StatefulBuilder(
            builder: (context, setState) {
              Widget child = const SizedBox();
              if (innerActive) {
                child = BackLayerScope(
                  onBack: () {
                    innerBackCount++;
                    setState(() {
                      innerActive = false;
                    });
                  },
                  child: child,
                );
              }
              if (outerActive) {
                child = BackLayerScope(
                  onBack: () {
                    outerBackCount++;
                    setState(() {
                      outerActive = false;
                    });
                  },
                  child: child,
                );
              }
              return child;
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect((innerBackCount, outerBackCount, rootBackCount), (1, 0, 0));

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect((innerBackCount, outerBackCount, rootBackCount), (1, 1, 0));

    await tester.binding.handlePopRoute();
    await tester.pump();
    expect((innerBackCount, outerBackCount, rootBackCount), (1, 1, 1));
  });

  testWidgets(
    'a pending inactive sync is cancelled when the page reactivates',
    (tester) async {
      final isActive = ValueNotifier(true);
      addTearDown(isActive.dispose);
      final pendingCallbacks = <void Function(Duration)>[];
      var backCount = 0;
      var rootBackCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: CommonPopScope(
            onPop: (_) {
              rootBackCount++;
              return false;
            },
            child: _PageActivityTestScope(
              isActive: isActive,
              child: BackLayerScope(
                onBack: () {
                  backCount++;
                },
                schedulePostFrameCallback: pendingCallbacks.add,
                child: const SizedBox(),
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      expect(pendingCallbacks, hasLength(1));
      pendingCallbacks.removeAt(0)(Duration.zero);
      await tester.pump();

      isActive.value = false;
      await tester.pump();
      isActive.value = true;
      await tester.pump();
      expect(pendingCallbacks, hasLength(2));

      for (final callback in pendingCallbacks.toList()) {
        callback(Duration.zero);
      }
      pendingCallbacks.clear();
      await tester.pump();
      expect(backCount, 0);

      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(backCount, 1);
      expect(rootBackCount, 0);

      await tester.binding.handlePopRoute();
      await tester.pump();
      expect(backCount, 1);
      expect(rootBackCount, 1);
    },
  );

  testWidgets('disposing a back layer does not invoke its callback', (
    tester,
  ) async {
    final showLayer = ValueNotifier(true);
    addTearDown(showLayer.dispose);
    var backCount = 0;

    await tester.pumpWidget(
      MaterialApp(
        home: ValueListenableBuilder(
          valueListenable: showLayer,
          builder: (_, value, _) {
            if (!value) {
              return const SizedBox();
            }
            return BackLayerScope(
              onBack: () {
                backCount++;
              },
              child: const SizedBox(),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    showLayer.value = false;
    await tester.pumpAndSettle();

    expect(backCount, 0);
  });

  testWidgets('system back exits search without reaching the root fallback', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    var rootBackCount = 0;

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.delegate.supportedLocales,
          home: CommonPopScope(
            onPop: (_) {
              rootBackCount++;
              return false;
            },
            child: CommonScaffold(
              title: 'Logs',
              searchState: AppBarSearchState(onSearch: (_) {}),
              body: const SizedBox(),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pump();

    expect(find.byType(TextField), findsNothing);
    expect(rootBackCount, 0);
  });

  testWidgets('inactive page scope exits the kept search layer', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    final isActive = ValueNotifier(true);
    addTearDown(isActive.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.delegate.supportedLocales,
          home: _PageActivityTestScope(
            isActive: isActive,
            child: const LogsView(),
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    isActive.value = false;
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('inactive page scope exits dashboard edit layer', (tester) async {
    final container = ProviderContainer(
      overrides: [
        dashboardStateProvider.overrideWithValue(
          const DashboardState(dashboardWidgets: []),
        ),
      ],
    );
    addTearDown(container.dispose);
    globalState.container = container;
    final isActive = ValueNotifier(true);
    addTearDown(isActive.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _DashboardTestApp(
          child: _PageActivityTestScope(
            isActive: isActive,
            child: const DashboardView(),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('edit-icon')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const ValueKey('save-icon')), findsOneWidget);

    isActive.value = false;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const ValueKey('edit-icon')), findsOneWidget);
  });

  testWidgets('inactive page scope exits access search layer', (tester) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    globalState.container = container;
    final isActive = ValueNotifier(true);
    addTearDown(isActive.dispose);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: _DashboardTestApp(
          child: _PageActivityTestScope(
            isActive: isActive,
            child: const AccessView(),
          ),
        ),
      ),
    );
    await tester.pump(const Duration(milliseconds: 301));

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();
    expect(find.byType(TextField), findsOneWidget);

    isActive.value = false;
    await tester.pumpAndSettle();

    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('save and system back cannot re-enter dashboard edit mode', (
    tester,
  ) async {
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
        child: const _DashboardTestApp(),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('edit-icon')));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const ValueKey('save-icon')), findsOneWidget);

    tester.widget<IconButton>(find.byKey(const ValueKey(true))).onPressed!();
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const ValueKey('edit-icon')), findsOneWidget);
  });

  testWidgets('system back preserves a pending dashboard deletion', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        dashboardStateProvider.overrideWithValue(
          const DashboardState(
            dashboardWidgets: [
              DashboardWidget.networkSpeed,
              DashboardWidget.outboundModeV2,
            ],
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

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const _DashboardTestApp(),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('edit-icon')));
    await tester.pump(const Duration(milliseconds: 500));

    final deleteButton = find.ancestor(
      of: find.byIcon(Icons.close).first,
      matching: find.byType(IconButton),
    );
    tester.widget<IconButton>(deleteButton).onPressed!();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 301));
    await tester.pump();
    expect(
      tester.state<SuperGridState>(find.byType(SuperGrid)).snapshotChildren,
      [DashboardWidget.outboundModeV2.widget],
    );
    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const ValueKey('edit-icon')), findsOneWidget);
    expect(container.read(appSettingProvider).dashboardWidgets, [
      DashboardWidget.outboundModeV2,
    ]);
  });
}

class _DashboardTestApp extends StatelessWidget {
  final Widget child;

  const _DashboardTestApp({this.child = const DashboardView()});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.delegate.supportedLocales,
      builder: (context, child) {
        globalState.measure = Measure.of(context, 1);
        globalState.theme = CommonTheme.of(context, 1);
        return child!;
      },
      home: child,
    );
  }
}

class _PageActivityTestScope extends StatelessWidget {
  final ValueNotifier<bool> isActive;
  final Widget child;

  const _PageActivityTestScope({required this.isActive, required this.child});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isActive,
      builder: (_, value, child) {
        return PageActivityScope(isActive: value, child: child!);
      },
      child: child,
    );
  }
}
