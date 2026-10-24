import 'dart:async';

import 'package:drift/native.dart';
import 'package:fl_clash/common/application_proxy.dart';
import 'package:fl_clash/database/database.dart' as db;
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/application_proxy.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/layout.dart';
import 'package:fl_clash/views/dashboard/widgets/connections_table.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../helpers/test_app.dart';
import '../../helpers/test_profiles.dart';

class _SetupAction extends SetupAction {
  Completer<bool>? pending;
  int applyCalls = 0;

  @override
  void build() {}

  @override
  Future<bool> applyProfile({
    bool silence = false,
    bool force = false,
    Future<void> Function()? preloadInvoke,
  }) {
    applyCalls++;
    return pending?.future ?? Future.value(true);
  }
}

final _time = DateTime.utc(2026, 10, 22);

TrackerInfo _connection(String id, {String outbound = 'Proxy'}) => TrackerInfo(
  id: id,
  start: _time,
  metadata: const Metadata(process: 'browser', processPath: '/apps/browser'),
  chains: [outbound],
  rule: 'MATCH',
  rulePayload: '',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late db.Database database;
  late db.Database previousDatabase;
  late ProviderContainer container;
  late _SetupAction action;

  setUp(() async {
    previousDatabase = db.database;
    database = db.Database(NativeDatabase.memory());
    db.database = database;
    const profile = Profile(id: 1, autoUpdateDuration: Duration.zero);
    await database.profilesDao.putAll([profile.toCompanion()]);
    action = _SetupAction();
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(() => TestProfiles(const [profile])),
        currentProfileIdProvider.overrideWithBuild((_, _) => 1),
        coreStatusProvider.overrideWithBuild((_, _) => CoreStatus.connected),
        patchClashConfigProvider.overrideWithBuild(
          (_, _) => const PatchClashConfig(findProcessMode: FindProcessMode.always),
        ),
        setupActionProvider.overrideWith(() => action),
        applicationProxyAggregatorProvider.overrideWithValue(
          (input) async => aggregateApplicationProxies(input),
        ),
      ],
    );
    globalState.container = container;
    container.listen(currentProfileIdProvider, (_, _) {});
    container.listen(profilesProvider, (_, _) {});
    container.listen(patchClashConfigProvider, (_, _) {});
    container.listen(coreStatusProvider, (_, _) {});
  });

  tearDown(() async {
    final pending = action.pending;
    if (pending != null && !pending.isCompleted) {
      pending.complete(true);
    }
    container.dispose();
    db.database = previousDatabase;
    await database.close();
  });

  Future<void> pumpPanel(
    WidgetTester tester, {
    List<TrackerInfo>? connections,
    bool stale = false,
    double width = 900,
    Widget? child,
  }) async {
    tester.view.physicalSize = Size(width, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: TestApp(
          child: Scaffold(
            body: DashboardDensityScope(
              density: DashboardDensity.standard,
              scale: 1,
              child: child ?? ApplicationProxyPanel(
                connections: connections ?? [_connection('1')],
                sampledAt: _time,
                stale: stale,
                rowHeight: 44,
                isWindows: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> waitForApply(WidgetTester tester) async {
    for (var frame = 0; frame < 100 && action.applyCalls == 0; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(action.applyCalls, 1);
  }

  Future<void> chooseDirect(WidgetTester tester) async {
    await tester.tap(find.widgetWithText(TextButton, 'Follow rules'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Direct'));
    await waitForApply(tester);
  }

  testWidgets('actual mixed routing and an idle configured policy stay separate', (tester) async {
    await database.rulesDao.putRule(
      const Rule(
        id: 1,
        ruleAction: RuleAction.PROCESS_PATH,
        content: '/apps/idle',
        ruleTarget: 'DIRECT',
      ),
      profileId: 1,
    );
    await pumpPanel(tester, connections: [
      _connection('1'),
      _connection('2', outbound: 'DIRECT'),
    ]);

    expect(find.text('browser'), findsOneWidget);
    expect(find.text('Mixed'), findsOneWidget);
    expect(find.text('Follow rules'), findsOneWidget);
    expect(find.text('idle'), findsOneWidget);
    expect(find.text('No active connections'), findsOneWidget);
    expect(find.text('Direct'), findsOneWidget);
  });

  testWidgets('a failed apply releases the control and can return to following rules', (tester) async {
    action.pending = Completer<bool>();
    await pumpPanel(tester);
    await chooseDirect(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    action.pending!.completeError(StateError('apply failed'));
    await tester.pumpAndSettle();

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(
      find.text('The rule was saved, but could not be applied. Apply the current profile to retry.'),
      findsOneWidget,
    );
    expect(find.text('Proxies'), findsOneWidget);
    expect(find.widgetWithText(TextButton, 'Direct'), findsOneWidget);

    action.pending = null;
    await tester.tap(find.widgetWithText(TextButton, 'Direct'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Follow rules'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextButton, 'Follow rules'), findsOneWidget);
    expect(await database.rulesDao.queryApplicationRules(1).get(), isEmpty);
  });

  testWidgets('a save completing after disposal does not update the removed panel', (tester) async {
    action.pending = Completer<bool>();
    await pumpPanel(tester);
    await chooseDirect(tester);
    await tester.pumpWidget(const SizedBox.shrink());

    action.pending!.complete(true);
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('script extensions show traffic while policy editing is disabled', (tester) async {
    container.read(profilesProvider.notifier).updateProfile(
      1,
      (profile) => profile.copyWith(extendType: ExtendType.script),
    );
    await pumpPanel(tester);

    expect(find.text('browser'), findsOneWidget);
    expect(find.textContaining('Script extensions are read-only here.'), findsOneWidget);
    expect(
      tester.widget<TextButton>(find.widgetWithText(TextButton, 'Follow rules')).onPressed,
      isNull,
    );
  });

  testWidgets('a narrow panel shows both speeds and marks a failed refresh', (tester) async {
    await pumpPanel(tester, width: 400, stale: true);

    expect(find.text('↓ —'), findsOneWidget);
    expect(find.text('↑ —'), findsOneWidget);
    expect(find.text('Refresh failed. Showing the last received connections.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('configured apps beyond the preview limit remain reachable', (tester) async {
    for (var index = 0; index < 120; index++) {
      await database.rulesDao.putRule(
        Rule(
          id: index + 1,
          ruleAction: RuleAction.PROCESS_NAME,
          content: 'app-${index.toString().padLeft(3, '0')}',
          ruleTarget: 'DIRECT',
        ),
        profileId: 1,
      );
    }
    await pumpPanel(tester);
    expect(find.text('app-119'), findsNothing);

    await tester.scrollUntilVisible(
      find.text('app-119'),
      400,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('app-119'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('the app tab follows DNS and opens the application panel', (tester) async {
    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    await pumpPanel(tester, child: const ConnectionsTableCard());
    final dns = find.text('DNS queries');
    final apps = find.text('App proxy');
    expect(tester.getCenter(apps).dx, greaterThan(tester.getCenter(dns).dx));

    await tester.tap(apps);
    await tester.pumpAndSettle();
    expect(find.byType(ApplicationProxyPanel), findsOneWidget);
    expect(find.text('No active connections'), findsOneWidget);
  });
}
