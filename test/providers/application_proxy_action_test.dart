import 'dart:async';

import 'package:drift/native.dart';
import 'package:fl_clash/common/application_proxy.dart';
import 'package:fl_clash/common/exception.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/database/database.dart' as db;
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/providers.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../helpers/test_profiles.dart';

class _MockCore extends Mock implements CoreHandlerInterface {}

class _SetupAction extends SetupAction {
  int applyCalls = 0;
  bool applied = true;
  Error? applyError;
  Future<bool> Function()? onApply;

  @override
  void build() {}

  @override
  Future<bool> applyProfile({
    bool silence = false,
    bool force = false,
    Future<void> Function()? preloadInvoke,
  }) async {
    applyCalls++;
    final error = applyError;
    if (error != null) throw error;
    return onApply == null ? applied : await onApply!();
  }
}

const _application = ApplicationIdentity(
  action: RuleAction.PROCESS_PATH,
  content: r'C:\Apps\browser.exe',
  windows: true,
);

TrackerInfo _connection(String id, {String path = r'C:\Apps\browser.exe'}) =>
    TrackerInfo(
      id: id,
      start: DateTime.utc(2026, 10, 24),
      metadata: Metadata(process: 'browser.exe', processPath: path),
      chains: const ['DIRECT'],
      rule: 'MATCH',
      rulePayload: '',
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late db.Database previousDatabase;
  late db.Database database;
  late ProviderContainer container;
  late _SetupAction action;
  late _MockCore core;

  setUpAll(() => AppLocalizations.load(const Locale('en')));

  setUp(() async {
    previousDatabase = db.database;
    database = db.Database(NativeDatabase.memory());
    db.database = database;
    const profiles = [
      Profile(id: 1, autoUpdateDuration: Duration.zero),
      Profile(id: 2, autoUpdateDuration: Duration.zero),
    ];
    await database.profilesDao.putAll([
      for (final profile in profiles) profile.toCompanion(),
    ]);
    action = _SetupAction();
    core = _MockCore();
    when(core.getConnections).thenAnswer((_) async => []);
    when(() => core.closeConnection(any())).thenAnswer((_) async => true);
    container = ProviderContainer(
      overrides: [
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
        profilesProvider.overrideWith(() => TestProfiles(profiles)),
        currentProfileIdProvider.overrideWithBuild((_, _) => 1),
        setupActionProvider.overrideWith(() => action),
        coreStatusProvider.overrideWithBuild((_, _) => CoreStatus.connected),
        patchClashConfigProvider.overrideWithBuild(
          (_, _) => const PatchClashConfig(),
        ),
        groupsProvider.overrideWithBuild(
          (_, _) => const [Group(name: 'Proxy', type: GroupType.Selector)],
        ),
      ],
    );
    globalState.container = container;
    container.listen(currentProfileIdProvider, (_, _) {});
    container.listen(patchClashConfigProvider, (_, _) {});
    container.listen(profilesProvider, (_, _) {});
    container.listen(coreStatusProvider, (_, _) {});
    container.read(setupActionProvider.notifier);
  });

  tearDown(() async {
    container.dispose();
    db.database = previousDatabase;
    await database.close();
  });

  test('policy changes apply before closing only the selected application', () async {
    var applied = false;
    action.onApply = () async {
      verifyNever(core.getConnections);
      applied = true;
      return true;
    };
    when(core.getConnections).thenAnswer((_) async {
      expect(applied, isTrue);
      return [
        _connection('browser-1'),
        _connection('browser-2', path: 'c:/apps/BROWSER.exe'),
        _connection('other-install', path: r'D:\Apps\browser.exe'),
        _connection('editor', path: r'C:\Apps\editor.exe'),
      ];
    });

    expect(await action.setApplicationProxy(
      profileId: 1,
      application: _application,
      target: 'DIRECT',
    ), isTrue);

    verify(() => core.closeConnection('browser-1')).called(1);
    verify(() => core.closeConnection('browser-2')).called(1);
    verifyNever(() => core.closeConnection('other-install'));
    verifyNever(() => core.closeConnection('editor'));
    verifyNever(core.closeConnections);
  });

  test('returning to follow rules also closes the application connections', () async {
    when(core.getConnections).thenAnswer((_) async => [_connection('browser')]);
    await action.setApplicationProxy(
      profileId: 1,
      application: _application,
      target: 'DIRECT',
    );
    clearInteractions(core);

    await action.setApplicationProxy(
      profileId: 1,
      application: _application,
      target: null,
    );

    expect(await database.rulesDao.queryApplicationRules(1).get(), isEmpty);
    verify(() => core.closeConnection('browser')).called(1);
  });

  test('failed applies preserve existing connections', () async {
    action.applied = false;
    expect(await action.setApplicationProxy(
      profileId: 1,
      application: _application,
      target: 'DIRECT',
    ), isFalse);
    verifyNever(core.getConnections);
    verifyNever(() => core.closeConnection(any()));
  });

  test('switching profiles away and back cancels stale connection termination', () async {
    final entered = Completer<void>();
    final apply = Completer<bool>();
    action.onApply = () {
      entered.complete();
      return apply.future;
    };
    final save = action.setApplicationProxy(
      profileId: 1,
      application: _application,
      target: 'DIRECT',
    );
    await entered.future;
    container.read(currentProfileIdProvider.notifier).value = 2;
    container.read(currentProfileIdProvider.notifier).value = 1;
    apply.complete(true);

    expect(await save, isTrue);
    verifyNever(core.getConnections);
    verifyNever(() => core.closeConnection(any()));
  });

  test('a superseded application edit cannot terminate connections again', () async {
    final entered = Completer<void>();
    final firstApply = Completer<bool>();
    action.onApply = () {
      if (action.applyCalls == 1) {
        entered.complete();
        return firstApply.future;
      }
      return Future.value(true);
    };
    when(core.getConnections).thenAnswer((_) async => [_connection('browser')]);
    final first = action.setApplicationProxy(
      profileId: 1,
      application: _application,
      target: 'DIRECT',
    );
    await entered.future;
    await action.setApplicationProxy(
      profileId: 1,
      application: _application,
      target: 'Proxy',
    );
    firstApply.complete(true);
    expect(await first, isTrue);

    verify(() => core.closeConnection('browser')).called(1);
    expect(
      (await database.rulesDao.queryApplicationRules(1).get()).single.ruleTarget,
      'Proxy',
    );
  });

  test('connections that expired before close are already complete', () async {
    var lists = 0;
    when(core.getConnections).thenAnswer((_) async {
      return lists++ == 0 ? [_connection('expired')] : [];
    });
    when(() => core.closeConnection('expired')).thenAnswer((_) async => false);

    expect(await action.setApplicationProxy(
      profileId: 1,
      application: _application,
      target: 'DIRECT',
    ), isTrue);
  });

  test('connection-close failures keep the saved rule and report the failure', () async {
    when(core.getConnections).thenAnswer((_) async => [_connection('browser')]);
    when(() => core.closeConnection('browser')).thenAnswer((_) async => false);

    final l = AppLocalizations.current;
    await expectLater(
      action.setApplicationProxy(
        profileId: 1,
        application: _application,
        target: 'DIRECT',
      ),
      throwsA(isA<MessageException>().having(
        (error) => error.message,
        'message',
        l.failedItem(l.closeConnections, l.error),
      )),
    );
    expect(
      (await database.rulesDao.queryApplicationRules(1).get()).single.ruleTarget,
      'DIRECT',
    );
  });

  test('subscription metadata updates preserve per-profile application rules', () async {
    await action.setApplicationProxy(
      profileId: 1,
      application: _application,
      target: 'DIRECT',
    );
    final saved = (await database.rulesDao.queryApplicationRules(1).get()).single;
    final profile = (await database.profilesDao.get(1))!.copyWith(
      type: ProfileType.url,
      url: 'https://example.invalid/subscription',
    );
    await database.profilesDao.putAll([
      profile.copyWith(
        label: 'Updated subscription',
        lastUpdateDate: DateTime.utc(2026, 10, 24),
      ).toCompanion(),
    ]);

    final retained = (await database.rulesDao.queryApplicationRules(1).get()).single;
    expect(retained.id, saved.id);
    expect(retained.content, saved.content);
    expect(retained.ruleTarget, 'DIRECT');
    expect(
      (await database.rulesDao.queryAddedRules(1).get()).single.ruleTarget,
      'DIRECT',
    );
    expect(await database.rulesDao.queryApplicationRules(2).get(), isEmpty);
  });

  test('the app rule precedes catch-all and global rules in the current profile', () async {
    await database.rulesDao.putRule(
      const Rule(id: 10, ruleAction: RuleAction.MATCH, ruleTarget: 'Proxy', order: 'a0'),
      profileId: 1,
    );
    await database.rulesDao.putRule(
      const Rule(id: 20, content: 'global.test', ruleTarget: 'Proxy', order: 'a0'),
    );

    expect(await action.setApplicationProxy(
      profileId: 1,
      application: _application,
      target: 'DIRECT',
    ), isTrue);

    final rules = await database.rulesDao.queryAddedRules(1).get();
    expect(rules.first.ruleAction, RuleAction.PROCESS_PATH);
    expect(rules.first.content, _application.content);
    expect(rules.first.ruleTarget, 'DIRECT');
    expect(rules.skip(1).map((rule) => rule.id), [10, 20]);
    expect(await database.rulesDao.queryProfileRules(2).get(), isEmpty);
    expect(
      container.read(patchClashConfigProvider).findProcessMode,
      FindProcessMode.always,
    );
    expect(action.applyCalls, 1);
  });

  test('updating replaces duplicates; following rules removes only that app', () async {
    const rule = Rule(
      id: 1,
      ruleAction: RuleAction.PROCESS_PATH,
      content: 'c:/apps/browser.exe',
      ruleTarget: 'DIRECT',
      order: 'a0',
    );
    await database.rulesDao.putRule(rule, profileId: 1);
    await database.rulesDao.putRule(rule.copyWith(id: 2, order: 'a1'), profileId: 1);
    await database.rulesDao.putRule(
      rule.copyWith(id: 3, content: r'C:\Other\browser.exe'),
      profileId: 1,
    );
    await database.rulesDao.putRule(rule.copyWith(id: 4));

    await action.setApplicationProxy(
      profileId: 1,
      application: _application,
      target: 'Proxy',
    );
    final updated = await database.rulesDao.queryApplicationRules(1).get();
    expect(updated, hasLength(2));
    expect(updated.first.id, 1);
    expect(updated.first.ruleTarget, 'Proxy');

    await action.setApplicationProxy(
      profileId: 1,
      application: _application,
      target: null,
    );
    expect(
      (await database.rulesDao.queryApplicationRules(1).get()).single.id,
      3,
    );
    expect((await database.rulesDao.queryGlobalRules().get()).single.id, 4);
  });

  test('custom profiles accept application rules without a standard extension', () async {
    container.read(profilesProvider.notifier).updateProfile(
      1,
      (profile) => profile.copyWith(
        type: ProfileType.custom,
        extendType: ExtendType.script,
      ),
    );

    expect(await action.setApplicationProxy(
      profileId: 1,
      application: _application,
      target: 'Proxy',
    ), isTrue);
    expect(
      (await database.rulesDao.queryProfileRules(1).get()).single.ruleTarget,
      'Proxy',
    );
  });

  test('a stopped core saves the rule and process detection without applying', () async {
    container.read(coreStatusProvider.notifier).value = CoreStatus.disconnected;
    await action.setApplicationProxy(
      profileId: 1,
      application: _application,
      target: 'DIRECT',
    );

    expect(await database.rulesDao.queryApplicationRules(1).get(), hasLength(1));
    expect(action.applyCalls, 0);
    expect(
      container.read(patchClashConfigProvider).findProcessMode,
      FindProcessMode.always,
    );
  });

  test('apply failures keep the saved rule and report a retryable result', () async {
    action.applied = false;
    expect(await action.setApplicationProxy(
      profileId: 1,
      application: _application,
      target: 'DIRECT',
    ), isFalse);
    expect(await database.rulesDao.queryApplicationRules(1).get(), hasLength(1));

    action.applyError = StateError('core failed');
    await expectLater(
      action.setApplicationProxy(
        profileId: 1,
        application: _application,
        target: 'Proxy',
      ),
      throwsA(isA<MessageException>().having(
        (error) => error.message,
        'message',
        AppLocalizations.current.applicationProxyApplyFailed,
      )),
    );
    expect(
      (await database.rulesDao.queryApplicationRules(1).get()).single.ruleTarget,
      'Proxy',
    );
  });

  test('stale profiles, script extensions and invalid processes cannot write', () async {
    await expectLater(
      action.setApplicationProxy(
        profileId: 2,
        application: _application,
        target: 'DIRECT',
      ),
      throwsA(isA<MessageException>()),
    );
    container.read(profilesProvider.notifier).updateProfile(
      1,
      (profile) => profile.copyWith(extendType: ExtendType.script),
    );
    await expectLater(
      action.setApplicationProxy(
        profileId: 1,
        application: _application,
        target: 'DIRECT',
      ),
      throwsA(isA<MessageException>()),
    );
    container.read(profilesProvider.notifier).updateProfile(
      1,
      (profile) => profile.copyWith(extendType: ExtendType.standard),
    );
    for (final target in ['missing', 'Proxy,DIRECT']) {
      await expectLater(
        action.setApplicationProxy(
          profileId: 1,
          application: _application,
          target: target,
        ),
        throwsA(isA<MessageException>()),
      );
    }
    await expectLater(
      action.setApplicationProxy(
        profileId: 1,
        application: const ApplicationIdentity(
          action: RuleAction.PROCESS_NAME,
          content: 'bad,process',
          windows: false,
        ),
        target: 'DIRECT',
      ),
      throwsA(isA<MessageException>()),
    );
    expect(await database.rulesDao.queryProfileRules(1).get(), isEmpty);
    expect(action.applyCalls, 0);
  });

  test('database write errors leave process detection and the core unchanged', () async {
    await database.customStatement('DROP TABLE rules');

    await expectLater(
      action.setApplicationProxy(
        profileId: 1,
        application: _application,
        target: 'DIRECT',
      ),
      throwsA(isA<Exception>()),
    );
    expect(action.applyCalls, 0);
    expect(
      container.read(patchClashConfigProvider).findProcessMode,
      FindProcessMode.off,
    );
  });
}
