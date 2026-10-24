import 'dart:async';

import 'package:drift/native.dart';
import 'package:fl_clash/common/application_proxy.dart';
import 'package:fl_clash/database/database.dart' as db;
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/providers/application_proxy.dart';
import 'package:fl_clash/state.dart';
import 'package:fl_clash/views/dashboard/layout.dart';
import 'package:fl_clash/views/dashboard/widgets/connections_table.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/scheduler.dart';
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
    print('>>> applyProfile called, applyCalls=$applyCalls pending=$pending');
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

  testWidgets('debug', (tester) async {
    action.pending = Completer<bool>();
    tester.view.physicalSize = const Size(900, 600);
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
              child: ApplicationProxyPanel(
                connections: [_connection('1')],
                sampledAt: _time,
                stale: false,
                rowHeight: 44,
                isWindows: false,
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    print('>>> follow rules buttons: ${find.widgetWithText(TextButton, 'Follow rules').evaluate().length}');
    await tester.tap(find.widgetWithText(TextButton, 'Follow rules'));
    await tester.pumpAndSettle();
    print('>>> Direct texts: ${find.text('Direct').evaluate().length}');
    await tester.tap(find.text('Direct'));
    for (var frame = 0; frame < 5; frame++) {
      await tester.pump(const Duration(milliseconds: 16));
      print(
        '>>> frame $frame applyCalls=${action.applyCalls} '
        'hasScheduledFrame=${SchedulerBinding.instance.hasScheduledFrame}',
      );
    }
    print('>>> applyCalls=${action.applyCalls}');
    print('>>> spinners: ${find.byType(CircularProgressIndicator).evaluate().length}');
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 16));
    }
    print('>>> after extra pumps spinners: ${find.byType(CircularProgressIndicator).evaluate().length}');
    for (final e in find.byType(TextButton).evaluate()) {
      final b = e.widget as TextButton;
      print('>>> button onPressed=${b.onPressed} child=${b.child}');
      if (b.child is Row) {
        print('>>>   row children=${(b.child as Row).children}');
      }
    }
    // Dump the error text if any
    final texts = find.byType(Text).evaluate().map((e) => (e.widget as Text).data).toList();
    print('>>> texts: $texts');
    final rules = await database.rulesDao.queryApplicationRules(1).get();
    print('>>> rules: ${rules.map((r) => (r.content, r.ruleTarget)).toList()}');
  });
}
