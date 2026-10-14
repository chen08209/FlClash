import 'dart:async';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/core/controller.dart';
import 'package:fl_clash/core/interface.dart';
import 'package:fl_clash/core/method.dart';
import 'package:fl_clash/database/database.dart' as db;
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/providers/action.dart';
import 'package:fl_clash/providers/config.dart';
import 'package:fl_clash/providers/core.dart';
import 'package:fl_clash/providers/database.dart';
import 'package:fl_clash/providers/state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';

import '../helpers/test_profiles.dart';

class _MockCoreHandlerInterface extends Mock implements CoreHandlerInterface {}

class _RecordingSetupAction extends SetupAction {
  final forced = <bool>[];

  int get applies => forced.length;

  @override
  void applyProfileDebounce({bool silence = false, bool force = false}) {
    forced.add(force);
  }
}

/// Only a change the current custom profile can see is worth a reapply.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const profileId = 1;
  const standardProfileId = 2;
  const otherCustomId = 4;
  const rules = ClashProvider(
    id: 11,
    label: 'Ad block',
    behavior: RuleProviderBehavior.domain,
    format: RuleProviderFormat.text,
  );

  late Directory home;
  late db.Database testDatabase;
  late ProviderContainer container;
  late _RecordingSetupAction setup;
  late RuleSetInfo compiled;
  late Exception? compileError;
  late Completer<void>? compileGate;
  late List<({String name, String url})> compiles;

  setUpAll(() {
    home = Directory.systemTemp.createTempSync('flclash-providers-action-');
    AppPath.supportDirectory = () async => home;
    AppPath.temporaryDirectory = () async => home;
    AppPath.cacheDirectory = () async => home;
    AppPath.downloadDirectory = () async => home;
  });

  tearDownAll(() {
    if (home.existsSync()) home.deleteSync(recursive: true);
  });

  setUp(() async {
    testDatabase = db.Database(NativeDatabase.memory());
    db.database = testDatabase;
    setup = _RecordingSetupAction();
    const profile = Profile(
      id: profileId,
      label: 'Custom',
      type: ProfileType.custom,
      autoUpdateDuration: Duration.zero,
    );
    const standardProfile = Profile(
      id: standardProfileId,
      label: 'Standard',
      autoUpdateDuration: Duration.zero,
    );
    const otherCustom = Profile(
      id: otherCustomId,
      label: 'Other custom',
      type: ProfileType.custom,
      autoUpdateDuration: Duration.zero,
    );
    for (final item in [profile, standardProfile, otherCustom]) {
      await testDatabase.profiles.put(item.toCompanion());
    }
    compiled = (
      behavior: RuleProviderBehavior.domain,
      format: RuleProviderFormat.text,
    );
    compileError = null;
    compileGate = null;
    compiles = [];
    final cacheRoot = Directory(await appPath.providerCacheRootPath);
    if (cacheRoot.existsSync()) cacheRoot.deleteSync(recursive: true);
    final core = _MockCoreHandlerInterface();
    when(() => core.compileRuleSet(any(), url: any(named: 'url'))).thenAnswer((
      invocation,
    ) async {
      final name = invocation.positionalArguments.single as String;
      final url = invocation.namedArguments[#url] as String;
      await compileGate?.future;
      compiles.add((name: name, url: url));
      if (compileError case final error?) throw error;
      final source = File(await appPath.getProviderCachePath(name));
      if (url.isNotEmpty) {
        source
          ..createSync(recursive: true)
          ..writeAsStringSync('downloaded');
      }
      if (compiled.behavior != RuleProviderBehavior.classical &&
          compiled.format != RuleProviderFormat.mrs) {
        File(
          '${source.path}.mrs',
        ).writeAsStringSync('mrs of ${source.readAsStringSync()}');
      }
      return compiled;
    });
    container = ProviderContainer(
      overrides: [
        profilesProvider.overrideWith(
          () => TestProfiles([profile, standardProfile, otherCustom]),
        ),
        setupActionProvider.overrideWith(() => setup),
        coreHandlerProvider.overrideWithValue(CoreController.scoped(core)),
      ],
    );
    container.listen(currentProfileProvider, (_, _) {});
    container.read(currentProfileIdProvider.notifier).value = profileId;
    container.listen(clashProvidersProvider, (_, _) {});
    await pumpEventQueue();
  });

  tearDown(() async {
    container.dispose();
    await testDatabase.close();
  });

  ClashProvidersAction action() =>
      container.read(clashProvidersActionProvider.notifier);

  Future<void> useIn(int owner, String name, {required int id}) async {
    await testDatabase.proxyGroups.put(
      ProxyGroup(
        id: id,
        name: 'Auto',
        type: GroupType.URLTest,
        use: [name],
        order: 'a',
      ).toCompanion(owner),
    );
  }

  Future<void> ruleSetIn(int owner, String name, {required int id}) async {
    await testDatabase.rulesDao.putRule(
      Rule(
        id: id,
        ruleAction: RuleAction.RULE_SET,
        ruleProvider: name,
        ruleTarget: 'DIRECT',
        order: 'a',
      ),
      profileId: owner,
    );
  }

  Future<String?> ruleSetOf(int owner) async =>
      (await testDatabase.rulesDao.queryProfileRules(owner).get())
          .single
          .ruleProvider;

  test('a rule set a rule references reapplies', () async {
    await ruleSetIn(profileId, 'Ad block', id: 30);

    await action().putProvider(rules);
    await pumpEventQueue();

    expect(setup.forced, [false]);
  });

  test('new content for a used rule set forces a reapply', () async {
    await ruleSetIn(profileId, 'Ad block', id: 30);

    await action().putProvider(rules, content: 'payload: []'.codeUnits);
    await pumpEventQueue();

    expect(setup.forced, [true]);
  });

  test('renaming a used rule set reapplies under its old name', () async {
    await ruleSetIn(profileId, 'Ad block', id: 30);

    await action().putProvider(
      rules.copyWith(label: 'Renamed'),
      previous: rules,
    );
    await pumpEventQueue();

    expect(setup.applies, 1);
  });

  test('a rule set a rule still references is deleted', () async {
    await ruleSetIn(profileId, 'Ad block', id: 30);
    await testDatabase.clashProvidersDao.putAll([rules.toCompanion()]);
    await pumpEventQueue();

    action().delProvider(rules);
    await pumpEventQueue();

    expect(await testDatabase.clashProvidersDao.query().get(), isEmpty);
    expect(setup.applies, 0);
  });

  test('a rule set names every custom profile whose rules use it', () async {
    await ruleSetIn(profileId, 'Ad block', id: 30);
    await ruleSetIn(standardProfileId, 'Ad block', id: 31);
    await ruleSetIn(otherCustomId, 'Ad block', id: 32);

    expect((await action().profilesUsing(rules)).map((profile) => profile.id), [
      profileId,
      otherCustomId,
    ]);
  });

  test('a rule set only a custom profile\'s DNS names is in use, and its '
      'changes reapply', () async {
    container
        .read(profilesProvider.notifier)
        .updateProfile(
          profileId,
          (profile) => profile.copyWith(
            overrides: const ProfileOverrides(
              dns: Dns(nameserverPolicy: {'rule-set:Ad block': '223.5.5.5'}),
              dnsOverrideKeys: {DnsOverrideKey.nameserverPolicy},
            ),
          ),
        );

    expect((await action().profilesUsing(rules)).map((profile) => profile.id), [
      profileId,
    ]);
    await action().putProvider(rules);
    await pumpEventQueue();
    expect(setup.forced, [false]);
  });

  test('renaming a rule set renames it in every custom profile', () async {
    await ruleSetIn(profileId, 'Ad block', id: 30);
    await ruleSetIn(otherCustomId, 'Ad block', id: 31);
    await ruleSetIn(standardProfileId, 'Ad block', id: 32);
    container
        .read(profilesProvider.notifier)
        .updateProfile(
          otherCustomId,
          (profile) => profile.copyWith(
            overrides: const ProfileOverrides(
              sniffer: Sniffer(forceDomain: ['rule-set:Ad block']),
              snifferOverrideKeys: {SnifferOverrideKey.forceDomain},
            ),
          ),
        );
    await testDatabase.clashProvidersDao.putAll([rules.toCompanion()]);
    await pumpEventQueue();

    await action().putProvider(
      rules.copyWith(label: 'Renamed'),
      previous: rules,
    );
    await pumpEventQueue();

    expect(await ruleSetOf(profileId), 'Renamed');
    expect(await ruleSetOf(otherCustomId), 'Renamed');
    expect(await ruleSetOf(standardProfileId), 'Ad block');
    expect(
      container
          .read(profilesProvider)
          .getProfile(otherCustomId)!
          .overrides
          .sniffer
          .forceDomain,
      ['rule-set:Renamed'],
    );
  });

  group('what a delete names', () {
    ProfilesAction profiles() =>
        container.read(profilesActionProvider.notifier);

    Future<void> targetIn(int owner, String target, {required int id}) =>
        testDatabase.rulesDao.putRule(
          Rule(id: id, content: 'x', ruleTarget: target, order: 'a'),
          profileId: owner,
        );

    test('a local proxy is used by the custom profiles naming it where no '
        'group of theirs takes the name', () async {
      await targetIn(profileId, 'HK', id: 30);
      await targetIn(standardProfileId, 'HK', id: 31);
      await targetIn(otherCustomId, 'HK', id: 32);
      await testDatabase.proxyGroups.put(
        const ProxyGroup(
          id: 40,
          name: 'HK',
          type: GroupType.Selector,
          proxies: ['DIRECT'],
        ).toCompanion(otherCustomId),
      );

      expect(
        (await profiles().proxyUsers({'HK'})).map((profile) => profile.id),
        [profileId],
      );
      expect(await profiles().proxyUsers({'US'}), isEmpty);
    });

    test('a group is in use while the rest of its profile names it', () async {
      Future<void> group(int id, String name, List<String> proxies) =>
          testDatabase.proxyGroups.put(
            ProxyGroup(
              id: id,
              name: name,
              type: GroupType.Selector,
              proxies: proxies,
            ).toCompanion(profileId),
          );
      await group(40, 'Auto', ['DIRECT']);
      await group(41, 'Parent', ['Auto']);
      await group(42, 'Ruled', ['DIRECT']);
      await targetIn(profileId, 'Ruled', id: 30);

      expect(await profiles().groupsInUse(profileId, {40}), {'Auto'});
      expect(await profiles().groupsInUse(profileId, {40, 41}), isEmpty);
      expect(await profiles().groupsInUse(profileId, {42}), {'Ruled'});
      expect(await profiles().groupsInUse(otherCustomId, {40}), isEmpty);
    });
  });

  test('a rule set no rule references does not reapply', () async {
    await action().putProvider(rules);
    await pumpEventQueue();

    expect(setup.applies, 0);
  });

  test('a subscription profile never reapplies for a provider', () async {
    await ruleSetIn(standardProfileId, 'Ad block', id: 30);
    container.read(currentProfileIdProvider.notifier).value = standardProfileId;

    await action().putProvider(rules);
    await pumpEventQueue();

    expect(setup.applies, 0);
  });

  test('a rename follows the custom profiles and leaves a standard extension '
      'naming its own set', () async {
    await testDatabase.clashProvidersDao.putAll([rules.toCompanion()]);
    await ruleSetIn(profileId, 'Ad block', id: 30);
    await ruleSetIn(standardProfileId, 'Ad block', id: 31);
    await pumpEventQueue();

    final saved = await action().putProvider(
      rules.copyWith(label: 'Renamed "rules"'),
      previous: rules,
    );
    await pumpEventQueue();

    expect(saved.label, 'Renamed "rules"');
    expect(await ruleSetOf(profileId), 'Renamed "rules"');
    expect(await ruleSetOf(standardProfileId), 'Ad block');
  });

  Future<ClashProvider> stored(int id) async =>
      (await testDatabase.clashProvidersDao.query().get()).singleWhere(
        (provider) => provider.id == id,
      );

  Future<String?> read(Future<String> path) async {
    final file = File(await path);
    return file.existsSync() ? file.readAsStringSync() : null;
  }

  test('saved content takes the behavior and format the Core reads', () async {
    compiled = (
      behavior: RuleProviderBehavior.ipcidr,
      format: RuleProviderFormat.yaml,
    );
    const local = ClashProvider(id: 40, label: 'Local');

    await action().putProvider(local, content: 'IP-CIDR,10.0.0.0/8'.codeUnits);
    await pumpEventQueue();

    expect(compiles.single, (name: '${local.fileName}.new', url: ''));
    final saved = await stored(local.id);
    expect(saved.behavior, RuleProviderBehavior.ipcidr);
    expect(saved.format, RuleProviderFormat.yaml);
    expect(await read(saved.path), 'IP-CIDR,10.0.0.0/8');
    expect(await read(saved.compiledPath), 'mrs of IP-CIDR,10.0.0.0/8');
    final staged = await appPath.getProviderCachePath('${local.fileName}.new');
    expect(File(staged).existsSync(), isFalse);
    expect(File('$staged.mrs').existsSync(), isFalse);
  });

  test('content the Core rejects leaves the saved set as it was', () async {
    await ruleSetIn(profileId, 'Ad block', id: 30);
    File(await rules.path)
      ..createSync(recursive: true)
      ..writeAsStringSync('example.com');
    compileError = const CoreMethodException(
      code: 'rule_set_mixed',
      message: 'mixed',
    );

    await expectLater(
      action().putProvider(rules, content: 'example.com\n10.0.0.0/8'.codeUnits),
      throwsA(isA<CoreMethodException>()),
    );
    await pumpEventQueue();

    expect(await read(rules.path), 'example.com');
    expect(await testDatabase.clashProvidersDao.query().get(), isEmpty);
    expect(setup.applies, 0);
    final staged = await appPath.getProviderCachePath('${rules.fileName}.new');
    expect(File(staged).existsSync(), isFalse);
  });

  test('a set that turns classical drops the mrs it had', () async {
    File(await rules.compiledPath)
      ..createSync(recursive: true)
      ..writeAsStringSync('old mrs');
    compiled = (
      behavior: RuleProviderBehavior.classical,
      format: RuleProviderFormat.text,
    );

    await action().putProvider(
      rules,
      previous: rules,
      content: 'DOMAIN-KEYWORD,ad'.codeUnits,
    );

    expect(await read(rules.path), 'DOMAIN-KEYWORD,ad');
    expect(File(await rules.compiledPath).existsSync(), isFalse);
  });

  test('a new remote set downloads, and a rename alone does not', () async {
    const remote = ClashProvider(
      id: 41,
      label: 'Remote',
      url: 'https://example.com/r.list',
    );
    await ruleSetIn(profileId, 'Remote', id: 30);

    await action().putProvider(remote);
    await pumpEventQueue();

    expect(compiles.single, (name: remote.fileName, url: remote.url));
    expect(setup.forced, [true]);
    final saved = await stored(remote.id);
    expect(saved.behavior, RuleProviderBehavior.domain);
    expect(await read(saved.compiledPath), 'mrs of downloaded');

    await action().putProvider(
      saved.copyWith(label: 'Renamed'),
      previous: saved,
    );
    await pumpEventQueue();

    expect(compiles, hasLength(1));
    expect(setup.forced, [true, false]);
  });

  group('a set changed while it downloads', () {
    const remote = ClashProvider(
      id: 41,
      label: 'Remote',
      url: 'https://example.com/r.list',
    );
    late ClashProvider saved;
    late Future<ClashProvider> updating;

    setUp(() async {
      await ruleSetIn(profileId, 'Remote', id: 30);
      await action().putProvider(remote);
      await pumpEventQueue();
      saved = await stored(remote.id);
      compileGate = Completer();
      updating = action().putProvider(saved, previous: saved, refresh: true);
      await pumpEventQueue();
    });

    Future<void> download() async {
      compileGate!.complete();
      await updating;
      await pumpEventQueue();
    }

    test('stays deleted, its cache too', () async {
      action().delProvider(saved);
      await pumpEventQueue();

      await download();

      expect(await testDatabase.clashProvidersDao.query().get(), isEmpty);
      expect(File(await saved.path).existsSync(), isFalse);
      expect(setup.forced, [true]);
    });

    test('keeps its new name', () async {
      container
          .read(clashProvidersProvider.notifier)
          .put(saved.copyWith(label: 'Renamed'));
      await pumpEventQueue();

      await download();

      expect((await stored(remote.id)).label, 'Renamed');
      expect(await ruleSetOf(profileId), 'Renamed');
    });

    test('drops the download of the url it no longer has', () async {
      final moved = saved.copyWith(url: 'https://example.com/moved.list');
      container.read(clashProvidersProvider.notifier).put(moved);
      await pumpEventQueue();

      await download();

      expect((await stored(remote.id)).url, moved.url);
      expect(File(await saved.path).existsSync(), isFalse);
    });
  });

  test('prepare builds a missing mrs and keeps what the Core found', () async {
    await testDatabase.clashProvidersDao.putAll([rules.toCompanion()]);
    File(await rules.path)
      ..createSync(recursive: true)
      ..writeAsStringSync('10.0.0.0/8');
    compiled = (
      behavior: RuleProviderBehavior.ipcidr,
      format: RuleProviderFormat.text,
    );

    final prepared = await action().prepare(rules);

    expect(compiles.single, (name: rules.fileName, url: ''));
    expect(prepared.behavior, RuleProviderBehavior.ipcidr);
    expect((await stored(rules.id)).behavior, RuleProviderBehavior.ipcidr);
    expect(await read(prepared.compiledPath), 'mrs of 10.0.0.0/8');

    expect(await action().prepare(prepared), prepared);
    expect(compiles, hasLength(1));
  });

  test('prepare downloads a remote set whose cache is gone', () async {
    const remote = ClashProvider(
      id: 42,
      label: 'Remote',
      url: 'https://example.com/r.list',
      behavior: RuleProviderBehavior.domain,
      format: RuleProviderFormat.text,
    );

    final prepared = await action().prepare(remote);

    expect(compiles.single, (name: remote.fileName, url: remote.url));
    expect(prepared, remote);
    expect(await read(remote.corePath), 'mrs of downloaded');
  });

  test('prepare leaves a set the Core cannot build to the Core', () async {
    compileError = const CoreMethodException(code: 'core_error', message: '');

    expect(await action().prepare(rules), rules);
  });

  test('a remote sync reloads in place unless the set changed shape', () async {
    const remote = ClashProvider(
      id: 43,
      label: 'Remote',
      url: 'https://example.com/r.list',
      behavior: RuleProviderBehavior.domain,
      format: RuleProviderFormat.text,
    );
    await testDatabase.clashProvidersDao.putAll([remote.toCompanion()]);
    await ruleSetIn(profileId, 'Remote', id: 30);

    expect(await action().syncRemote(remote), isTrue);
    await pumpEventQueue();
    expect(setup.applies, 0);

    compiled = (
      behavior: RuleProviderBehavior.classical,
      format: RuleProviderFormat.text,
    );
    expect(await action().syncRemote(remote), isFalse);
    await pumpEventQueue();

    expect(setup.forced, [true]);
    expect((await stored(remote.id)).behavior, RuleProviderBehavior.classical);
  });

  test('only an app-level remote set is found by the file it loads', () async {
    const remote = ClashProvider(
      id: 44,
      label: 'Remote',
      url: 'https://example.com/r.list',
      behavior: RuleProviderBehavior.domain,
      format: RuleProviderFormat.text,
    );
    await testDatabase.clashProvidersDao.putAll([
      remote.toCompanion(),
      rules.toCompanion(),
    ]);

    Future<ExternalProvider> loaded(
      Future<String> path, {
      String type = 'Rule',
      String vehicleType = 'File',
    }) async => ExternalProvider(
      name: 'Remote',
      type: type,
      path: await path,
      count: 1,
      vehicleType: vehicleType,
      updateAt: DateTime(2026),
    );

    expect(
      await action().remoteProviderOf(await loaded(remote.corePath)),
      remote,
    );
    expect(await action().remoteProviderOf(await loaded(remote.path)), isNull);
    expect(
      await action().remoteProviderOf(await loaded(rules.corePath)),
      isNull,
    );
    expect(
      await action().remoteProviderOf(
        await loaded(remote.corePath, vehicleType: 'HTTP'),
      ),
      isNull,
    );
  });

  group('a profile as a provider', () {
    const home = Profile(
      id: 3,
      label: 'Home',
      autoUpdateDuration: Duration.zero,
    );

    setUp(() async {
      container.read(profilesProvider.notifier).put(home);
      await useIn(profileId, 'Home', id: 20);
      await useIn(otherCustomId, 'Home', id: 21);
    });

    ProfilesAction profiles() =>
        container.read(profilesActionProvider.notifier);

    test('is used by the custom profiles its label reaches', () async {
      expect(
        (await profiles().providerUsers(home)).map((profile) => profile.id),
        [profileId, otherCustomId],
      );
    });

    test('a custom profile is never one, even under a label in use', () async {
      final custom = container
          .read(profilesProvider)
          .singleWhere((profile) => profile.id == profileId);
      await useIn(otherCustomId, custom.realLabel, id: 22);

      expect(await profiles().providerUsers(custom), isEmpty);
    });

    test('forces a reapply of the profile whose groups use it', () async {
      await action().applyIfReferenced(ProviderKind.proxy, {
        'Home',
      }, force: true);
      await action().applyIfReferenced(ProviderKind.proxy, {
        'Elsewhere',
      }, force: true);

      expect(setup.forced, [true]);
    });
  });
}
