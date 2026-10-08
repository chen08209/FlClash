import 'dart:async';

import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/database.g.dart';

Future<void> withRollback<T>({
  required T snapshot,
  required FutureOr<void> Function() action,
  required void Function(T snapshot) rollback,
}) async {
  try {
    await action();
  } catch (e, s) {
    rollback(snapshot);
    Error.throwWithStackTrace(e, s);
  }
}

Future<void> _persistOptimistically<T>(
  T previous,
  T next,
  T Function() read,
  void Function(T value) write,
  FutureOr<void> Function() action,
) async {
  write(next);
  try {
    await action();
  } catch (e, s) {
    if (identical(read(), next)) {
      write(previous);
    }
    Error.throwWithStackTrace(e, s);
  }
}

void _reportReread(Object error, StackTrace stackTrace) {
  commonPrint.log(
    'Database read-back failed: ${compactError(error)}, $stackTrace',
    logLevel: LogLevel.warning,
  );
}

void _reportOptimisticFailure(Object error, StackTrace stackTrace) {
  commonPrint.log(
    'Optimistic database write failed: ${compactError(error)}, $stackTrace',
    logLevel: LogLevel.warning,
  );
  dialogs.showNotifier(
    currentAppLocalizations.databaseWriteFailedTip,
    level: MessageLevel.error,
  );
}

/// Read-backs landing while a write is in flight can predate the write and
/// would briefly undo its optimistic value, so they wait for [idle]. One
/// turned away may carry a write made outside the notifier, so the rows are
/// read again once the writes settle.
class _Writes {
  final void Function() _reread;
  var _pending = 0;
  var _missed = false;

  _Writes(this._reread);

  bool get idle => _pending == 0;

  bool admit() {
    _missed |= !idle;
    return idle;
  }

  Future<void> track(Future<void> Function() write) async {
    _pending++;
    try {
      await write();
    } finally {
      _pending--;
      if (idle && _missed) {
        _missed = false;
        _reread();
      }
    }
  }
}

mixin OptimisticMixin<T> on AsyncNotifierMixin<T> {
  late final _writes = _Writes(_reread);
  Future<T> Function()? _query;

  Stream<T> settled(Stream<T> rows, Future<T> Function() query) {
    _query = query;
    return rows.where((_) => _writes.admit());
  }

  void _reread() {
    _query?.call().then((rows) {
      if (ref.mounted && _writes.admit()) {
        value = rows;
      }
    }, onError: _reportReread);
  }

  void optimistic(T next, FutureOr<void> Function() action) {
    unawaited(
      optimisticAsync(next, action).catchError(_reportOptimisticFailure),
    );
  }

  Future<void> optimisticAsync(T next, FutureOr<void> Function() action) {
    return _writes.track(
      () => _persistOptimistically(
        value,
        next,
        () => value,
        (v) => value = v,
        action,
      ),
    );
  }
}

@riverpod
Stream<List<Profile>> profilesStream(Ref ref) {
  return database.profilesDao.query().watch();
}

@riverpod
Stream<List<Rule>> addedRulesStream(Ref ref, int profileId) {
  return database.rulesDao.queryAddedRules(profileId).watch();
}

@riverpod
Stream<Set<String>> customGroupNames(Ref ref) {
  return database.proxyGroupsDao.names().watch().map(Set.of);
}

@riverpod
Stream<int> proxyGroupsCount(Ref ref, int profileId) {
  return database.proxyGroupsDao.count(profileId).watchSingle();
}

@Riverpod(keepAlive: true)
class Profiles extends _$Profiles {
  late final _writes = _Writes(_reread);

  @override
  List<Profile> build() {
    ref.listen(profilesStreamProvider, (_, next) {
      if (_writes.admit()) {
        state = next.value ?? [];
      }
    });
    return ref.read(profilesStreamProvider).value ?? [];
  }

  void _reread() {
    database.profilesDao.query().get().then((rows) {
      if (ref.mounted && _writes.admit()) {
        state = rows;
      }
    }, onError: _reportReread);
  }

  void _optimistic(List<Profile> next, FutureOr<void> Function() action) {
    unawaited(
      _optimisticAsync(next, action).catchError(_reportOptimisticFailure),
    );
  }

  var _queue = Future<void>.value();

  /// Writes run in turn and each writes the rows as the state holds them then,
  /// so a put issued before a rewrite landed writes it along, not over it.
  Future<void> _serial(Future<void> Function() write) {
    final run = _queue.then((_) => write());
    _queue = run.then<void>((_) {}, onError: (Object _) {});
    return run;
  }

  Future<void> _putLatest(Iterable<int> ids) async {
    for (final id in ids) {
      if (state.getProfile(id) case final profile?) {
        await database.profiles.put(profile.toCompanion());
      }
    }
  }

  Future<void> _optimisticAsync(
    List<Profile> next,
    FutureOr<void> Function() action,
  ) {
    return _writes.track(
      () => _persistOptimistically(
        state,
        next,
        () => state,
        (v) => state = v,
        action,
      ),
    );
  }

  Profile labeled(Profile profile) => state.optimizeLabel(profile);

  /// A new provider label follows into custom profiles whatever path set it.
  void put(Profile profile) {
    final newProfile = labeled(profile);
    final previousLabel = state.getProfile(profile.id)?.realLabel;
    var next = state.copyAndPut(newProfile, (item) => item.id == newProfile.id);
    if (newProfile.type == ProfileType.custom ||
        previousLabel == null ||
        previousLabel == newProfile.realLabel) {
      _optimistic(next, () => _serial(() => _putLatest([newProfile.id])));
      return;
    }
    final names = {previousLabel: newProfile.realLabel};
    final users = [
      for (final item in next)
        if (item.type == ProfileType.custom)
          if (item.copyWith(
                overrides: item.overrides.renamedProxyProviders(names),
              )
              case final user when user != item)
            user,
    ];
    for (final user in users) {
      next = next.copyAndPut(user, (item) => item.id == user.id);
    }
    _optimistic(
      next,
      () => _serial(
        () => database.transaction(() async {
          await database.proxyGroupsDao.renameUse(
            await database.profilesDao.customIds().get(),
            oldName: previousLabel,
            newName: newProfile.realLabel,
          );
          await _putLatest([for (final user in users) user.id, newProfile.id]);
        }),
      ),
    );
  }

  /// Applies the changes [body] returns to the state too, so a put landing
  /// before the rows read back writes them rather than the profile as it was.
  Future<void> rewriteCustom(
    Future<Map<int, Profile Function(Profile profile)>> Function() body,
  ) {
    return _writes.track(() async {
      (List<Profile>, List<Profile>)? applied;
      try {
        await _serial(
          () => database.transaction(() async {
            final changes = await body();
            final current = state;
            final next = [
              for (final item in current) changes[item.id]?.call(item) ?? item,
            ];
            applied = (current, next);
            state = next;
            for (final (index, item) in next.indexed) {
              if (item != current[index]) {
                await database.profiles.put(item.toCompanion());
              }
            }
            for (final MapEntry(key: id, value: change) in changes.entries) {
              if (current.getProfile(id) != null) {
                continue;
              }
              if (await database.profilesDao.get(id) case final row?) {
                if (change(row) case final changed when changed != row) {
                  await database.profiles.put(changed.toCompanion());
                }
              }
            }
          }),
        );
      } catch (e, s) {
        if (applied case (
          final previous,
          final next,
        ) when identical(state, next)) {
          state = previous;
        }
        Error.throwWithStackTrace(e, s);
      }
    });
  }

  Future<void> del(int id) {
    return _optimisticAsync(
      state.where((e) => e.id != id).toList(),
      () => _serial(() => database.deleteProfile(id)),
    );
  }

  void updateProfile(int profileId, Profile Function(Profile profile) builder) {
    final index = state.indexWhere((element) => element.id == profileId);
    if (index == -1) return;
    final newProfile = builder(state[index]);
    if (newProfile == state[index]) return;
    final next = List<Profile>.from(state);
    next[index] = newProfile;
    _optimistic(next, () => _serial(() => _putLatest([profileId])));
  }

  void reorder(List<Profile> profiles) {
    final next = List<Profile>.from(profiles);
    final moved = <int>[];
    next.forEachIndexed((index, item) {
      if (item.order != index) {
        next[index] = item.copyWith(order: index);
        moved.add(item.id);
      }
    });
    _optimistic(
      next,
      () => _serial(() => database.transaction(() => _putLatest(moved))),
    );
  }

  @override
  bool updateShouldNotify(List<Profile> previous, List<Profile> next) {
    return !profileListEquality.equals(previous, next);
  }
}

@riverpod
class Scripts extends _$Scripts with AsyncNotifierMixin, OptimisticMixin {
  @override
  Stream<List<Script>> build() {
    final query = database.scriptsDao.query();
    return settled(query.watch(), query.get);
  }

  @override
  List<Script> get value => state.value ?? [];

  void put(Script script) {
    final next = List<Script>.from(value);
    final index = next.indexWhere((item) => item.id == script.id);
    if (index != -1) {
      next[index] = script;
    } else {
      next.add(script);
    }
    optimistic(next, () => database.scripts.put(script.toCompanion()));
  }

  void del(int id) {
    final next = List<Script>.from(value);
    final index = next.indexWhere((item) => item.id == id);
    if (index == -1) return;
    next.removeAt(index);
    optimistic(next, () => database.scripts.remove((t) => t.id.equals(id)));
  }

  void order(int oldIndex, int newIndex) {
    final next = value.copyAndReorder(oldIndex, newIndex);
    final changed = <ScriptsCompanion>[];
    next.forEachIndexed((index, item) {
      if (item.order != index) {
        next[index] = item.copyWith(order: index);
        changed.add(item.toCompanion(index));
      }
    });
    optimistic(next, () => database.scriptsDao.putAll(changed));
  }

  @override
  bool updateShouldNotify(
    AsyncValue<List<Script>> previous,
    AsyncValue<List<Script>> next,
  ) {
    return !scriptListEquality.equals(previous.value, next.value);
  }
}

@riverpod
class ClashProviders extends _$ClashProviders
    with AsyncNotifierMixin, OptimisticMixin {
  @override
  Stream<List<ClashProvider>> build() {
    final query = database.clashProvidersDao.query();
    return settled(query.watch(), query.get);
  }

  @override
  List<ClashProvider> get value => state.value ?? [];

  void put(ClashProvider provider) {
    final next = List<ClashProvider>.from(value);
    final index = next.indexWhere((item) => item.id == provider.id);
    final renamedFrom = index != -1 && next[index].label != provider.label
        ? next[index].label
        : null;
    if (index != -1) {
      next[index] = provider;
    } else {
      next.add(provider);
    }
    if (renamedFrom == null) {
      optimistic(
        next,
        () => database.clashProviders.put(provider.toCompanion()),
      );
      return;
    }
    final names = {renamedFrom: provider.label};
    optimistic(
      next,
      () => ref.read(profilesProvider.notifier).rewriteCustom(() async {
        final profileIds = await database.profilesDao.customIds().get();
        await database.rulesDao.renameRuleProvider(
          profileIds,
          oldName: renamedFrom,
          newName: provider.label,
        );
        await database.clashProviders.put(provider.toCompanion());
        return {
          for (final id in profileIds)
            id: (profile) => profile.copyWith(
              overrides: profile.overrides.renamedRuleSets(names),
            ),
        };
      }),
    );
  }

  void del(int id) {
    final next = List<ClashProvider>.from(value);
    final index = next.indexWhere((item) => item.id == id);
    if (index == -1) return;
    next.removeAt(index);
    optimistic(
      next,
      () => database.clashProviders.remove((t) => t.id.equals(id)),
    );
  }

  void order(int oldIndex, int newIndex) {
    final next = value.copyAndReorder(oldIndex, newIndex);
    final changed = <ClashProvidersCompanion>[];
    next.forEachIndexed((index, item) {
      if (item.order != index) {
        next[index] = item.copyWith(order: index);
        changed.add(item.toCompanion(index));
      }
    });
    optimistic(next, () => database.clashProvidersDao.putAll(changed));
  }

  @override
  bool updateShouldNotify(
    AsyncValue<List<ClashProvider>> previous,
    AsyncValue<List<ClashProvider>> next,
  ) {
    return !clashProviderListEquality.equals(previous.value, next.value);
  }
}

@Riverpod(keepAlive: true)
class IconSets extends _$IconSets with AsyncNotifierMixin, OptimisticMixin {
  @override
  Stream<List<IconSet>> build() {
    final query = database.iconSetsDao.query();
    return settled(query.watch(), query.get);
  }

  @override
  List<IconSet> get value => state.value ?? [];

  void put(IconSet iconSet) {
    final next = List<IconSet>.from(value);
    final index = next.indexWhere((item) => item.id == iconSet.id);
    if (index != -1) {
      next[index] = iconSet;
    } else {
      next.add(iconSet);
    }
    optimistic(next, () => database.iconSets.put(iconSet.toCompanion()));
  }

  void del(int id) {
    optimistic(
      value.where((item) => item.id != id).toList(),
      () => database.iconSets.remove((t) => t.id.equals(id)),
    );
  }

  void order(int oldIndex, int newIndex) {
    final next = value.copyAndReorder(oldIndex, newIndex);
    final changed = <IconSetsCompanion>[];
    next.forEachIndexed((index, item) {
      if (item.order != index) {
        next[index] = item.copyWith(order: index);
        changed.add(item.toCompanion(index));
      }
    });
    optimistic(next, () => database.iconSetsDao.putAll(changed));
  }

  @override
  bool updateShouldNotify(
    AsyncValue<List<IconSet>> previous,
    AsyncValue<List<IconSet>> next,
  ) {
    return !iconSetListEquality.equals(previous.value, next.value);
  }
}

@riverpod
Future<Script?> script(Ref ref, int? scriptId) async {
  final script = ref.watch(
    scriptsProvider.future.select((state) async {
      final scripts = await state;
      return scripts.get(scriptId);
    }),
  );
  return script;
}

mixin RuleListMixin on OptimisticMixin<List<Rule>> {
  Future<void> persistRule(Rule rule);

  @override
  List<Rule> get value => state.value ?? [];

  @override
  bool updateShouldNotify(
    AsyncValue<List<Rule>> previous,
    AsyncValue<List<Rule>> next,
  ) {
    return !ruleListEquality.equals(previous.value, next.value);
  }

  void put(Rule rule) {
    final newRule = rule.autoOrder(rule, null, value.firstOrNull?.order);
    optimistic(
      value.copyAndPut(newRule, (rule) => rule.id == newRule.id),
      () => persistRule(newRule),
    );
  }

  void putAll(List<Rule> rules) {
    if (rules.isEmpty) {
      return;
    }
    final orders = indexing.generateNKeysBetween(
      null,
      value.firstOrNull?.order,
      rules.length,
    );
    final newRules = [
      for (final (index, rule) in rules.indexed)
        rule.copyWith(order: orders[index]),
    ];
    optimistic(
      [...newRules, ...value],
      () => database.transaction(() async {
        for (final rule in newRules) {
          await persistRule(rule);
        }
      }),
    );
  }

  void delAll(Iterable<int> ruleIds) {
    final ids = ruleIds.toSet();
    optimistic(
      value.where((item) => !ids.contains(item.id)).toList(),
      () => database.rulesDao.delRules(ids),
    );
  }

  void insertAfterEach(Map<int, Rule> copies) {
    final previous = value;
    final next = <Rule>[];
    final inserted = <Rule>[];
    for (final (index, rule) in previous.indexed) {
      next.add(rule);
      if (copies[rule.id] case final copy?) {
        final placed = copy.copyWith(
          order: indexing.generateKeyBetween(
            rule.order,
            previous.safeGet(index + 1)?.order,
          ),
        );
        next.add(placed);
        inserted.add(placed);
      }
    }
    if (inserted.isEmpty) {
      return;
    }
    optimistic(
      next,
      () => database.transaction(() async {
        for (final rule in inserted) {
          await persistRule(rule);
        }
      }),
    );
  }

  void order(int oldIndex, int newIndex) {
    final item = value[oldIndex];
    final nextItems = value.copyAndReorder(oldIndex, newIndex);
    final newOrder = indexing.generateKeyBetween(
      nextItems.safeGet(newIndex - 1)?.order,
      nextItems.safeGet(newIndex + 1)?.order,
    )!;
    nextItems[newIndex] = item.copyWith(order: newOrder);
    optimistic(
      nextItems,
      () => database.rulesDao.order(ruleId: item.id, order: newOrder),
    );
  }
}

@riverpod
class GlobalRules extends _$GlobalRules
    with AsyncNotifierMixin, OptimisticMixin, RuleListMixin {
  @override
  Stream<List<Rule>> build() {
    final query = database.rulesDao.queryGlobalRules();
    return settled(query.watch(), query.get);
  }

  @override
  Future<void> persistRule(Rule rule) => database.rulesDao.putRule(rule);
}

/// What the standard extension adds to a profile, or a custom profile's rules.
@riverpod
class ProfileRules extends _$ProfileRules
    with AsyncNotifierMixin, OptimisticMixin, RuleListMixin {
  @override
  Stream<List<Rule>> build(int profileId) {
    final query = database.rulesDao.queryProfileRules(profileId);
    return settled(query.watch(), query.get);
  }

  @override
  Future<void> persistRule(Rule rule) =>
      database.rulesDao.putRule(rule, profileId: profileId);

  void setAll(List<Rule> rules) {
    final orders = indexing.generateNKeys(rules.length);
    optimistic(
      [
        for (final (index, rule) in rules.indexed)
          rule.copyWith(order: orders[index]),
      ],
      () => database.batch(
        (b) => database.rulesDao.setProfileRulesWithBatch(profileId, b, rules),
      ),
    );
  }
}

/// Unless [group] says the name is a group's, a profile whose own group takes
/// either name is left alone: there the name stands for that group.
Future<Profile Function(Profile profile)?> _renameProxyIn(
  int profileId, {
  required String oldName,
  required String newName,
  bool group = false,
}) async {
  final groups = await database.proxyGroupsDao.query(profileId).get();
  if (!group &&
      groups.any((item) => item.name == oldName || item.name == newName)) {
    return null;
  }
  final names = {oldName: newName};
  await database.proxyGroupsDao.rewrite(
    groups,
    (item) => item.renamedProxies(names),
  );
  await database.rulesDao.renameRuleTarget(
    profileId,
    oldName: oldName,
    newName: newName,
  );
  await database.proxyDialersDao.renameTarget(
    profileId,
    oldName: oldName,
    newName: newName,
  );
  final members = {
    for (final item in groups) item.name: item.proxies ?? const <String>[],
  };
  return (Profile profile) => profile
      .copyWith(overrides: profile.overrides.renamedProxies(names))
      .renamedPicks(names, members: members, groups: group);
}

@riverpod
class ProxyGroups extends _$ProxyGroups
    with AsyncNotifierMixin, OptimisticMixin {
  @override
  Stream<List<ProxyGroup>> build(int profileId) {
    final query = database.proxyGroupsDao.query(profileId);
    return settled(query.watch(), query.get);
  }

  @override
  bool updateShouldNotify(
    AsyncValue<List<ProxyGroup>> previous,
    AsyncValue<List<ProxyGroup>> next,
  ) {
    return !proxyGroupsEquality.equals(previous.value, next.value);
  }

  void delAll(Iterable<int> proxyGroupIds) {
    final ids = proxyGroupIds.toSet();
    optimistic(
      value.where((item) => !ids.contains(item.id)).toList(),
      () => database.proxyGroupsDao.delAll(ids),
    );
  }

  bool put(ProxyGroup proxyGroup) {
    final previous = value;
    final index = previous.indexWhere((item) => item.id == proxyGroup.id);
    if (previous.any(
      (item) => item.name == proxyGroup.name && item.id != proxyGroup.id,
    )) {
      return false;
    }
    final renamedFrom = index != -1 && previous[index].name != proxyGroup.name
        ? previous[index].name
        : null;
    final icon = proxyGroup.icon?.value;
    final next = [
      for (final item in previous)
        renamedFrom == null
            ? item
            : item.renamedProxies({renamedFrom: proxyGroup.name}),
    ];
    final ProxyGroup nextProxyGroup;
    if (index != -1) {
      nextProxyGroup = proxyGroup;
      next[index] = nextProxyGroup;
    } else {
      final lastOrder = previous.map((item) => item.order).nonNulls.lastOrNull;
      nextProxyGroup = proxyGroup.copyWith(
        order: indexing.generateKeyBetween(lastOrder, null),
      );
      next.add(nextProxyGroup);
    }
    Future<void> write() async {
      if (icon != null) {
        await database.iconRecordsDao.put(icon);
      }
      await database.proxyGroups.put(nextProxyGroup.toCompanion(profileId));
    }

    optimistic(
      next,
      renamedFrom == null
          ? () => database.transaction(write)
          : () => ref.read(profilesProvider.notifier).rewriteCustom(() async {
              final change = await _renameProxyIn(
                profileId,
                oldName: renamedFrom,
                newName: nextProxyGroup.name,
                group: true,
              );
              await write();
              return {profileId: ?change};
            }),
    );
    return true;
  }

  void setAll(List<ProxyGroup> proxyGroups) {
    final orders = indexing.generateNKeys(proxyGroups.length);
    final next = [
      for (final (index, proxyGroup) in proxyGroups.indexed)
        proxyGroup.copyWith(profileId: profileId, order: orders[index]),
    ];
    optimistic(
      next,
      () => database.batch(
        (b) => database.proxyGroupsDao.setProfileGroupsWithBatch(
          profileId,
          b,
          next,
        ),
      ),
    );
  }

  void insertAfterEach(Map<int, ProxyGroup> copies) {
    final previous = value;
    final next = <ProxyGroup>[];
    final inserted = <ProxyGroup>[];
    for (final (index, proxyGroup) in previous.indexed) {
      next.add(proxyGroup);
      if (copies[proxyGroup.id] case final copy?) {
        final placed = copy.copyWith(
          order: indexing.generateKeyBetween(
            proxyGroup.order,
            previous.safeGet(index + 1)?.order,
          ),
        );
        next.add(placed);
        inserted.add(placed);
      }
    }
    if (inserted.isEmpty) {
      return;
    }
    optimistic(
      next,
      () => database.transaction(() async {
        for (final proxyGroup in inserted) {
          await database.proxyGroups.put(proxyGroup.toCompanion(profileId));
        }
      }),
    );
  }

  void order(int oldIndex, int newIndex) {
    final item = value[oldIndex];
    final nextItems = value.copyAndReorder(oldIndex, newIndex);
    final newOrder = indexing.generateKeyBetween(
      nextItems.safeGet(newIndex - 1)?.order,
      nextItems.safeGet(newIndex + 1)?.order,
    )!;
    nextItems[newIndex] = item.copyWith(order: newOrder);
    optimistic(
      nextItems,
      () => database.proxyGroupsDao.order(
        profileId,
        proxyGroup: item,
        order: newOrder,
      ),
    );
  }

  @override
  List<ProxyGroup> get value => state.value ?? [];
}

@riverpod
class CustomProxies extends _$CustomProxies
    with AsyncNotifierMixin, OptimisticMixin {
  @override
  Stream<List<CustomProxy>> build() {
    final query = database.customProxiesDao.query();
    return settled(query.watch(), query.get);
  }

  @override
  bool updateShouldNotify(
    AsyncValue<List<CustomProxy>> previous,
    AsyncValue<List<CustomProxy>> next,
  ) {
    return !customProxiesEquality.equals(previous.value, next.value);
  }

  @override
  List<CustomProxy> get value => state.value ?? [];

  void delAll(Iterable<int> ids) {
    final idSet = ids.toSet();
    optimistic(
      value.where((item) => !idSet.contains(item.id)).toList(),
      () => database.customProxiesDao.delAll(idSet),
    );
  }

  void put(CustomProxy proxy) {
    final previous = value;
    final index = previous.indexWhere((item) => item.id == proxy.id);
    final renamedFrom = index != -1 && previous[index].name != proxy.name
        ? previous[index].name
        : null;
    final next = List<CustomProxy>.from(previous);
    final CustomProxy nextProxy;
    if (index != -1) {
      nextProxy = proxy;
      next[index] = nextProxy;
    } else {
      final lastOrder = previous.map((item) => item.order).nonNulls.lastOrNull;
      nextProxy = proxy.copyWith(
        order: indexing.generateKeyBetween(lastOrder, null),
      );
      next.add(nextProxy);
    }
    optimistic(
      next,
      renamedFrom == null
          ? () => database.customProxies.put(nextProxy.toCompanion())
          : () => ref.read(profilesProvider.notifier).rewriteCustom(() async {
              final changes = <int, Profile Function(Profile profile)>{};
              for (final profileId
                  in await database.profilesDao.customIds().get()) {
                if (await _renameProxyIn(
                      profileId,
                      oldName: renamedFrom,
                      newName: nextProxy.name,
                    )
                    case final change?) {
                  changes[profileId] = change;
                }
              }
              await database.customProxies.put(nextProxy.toCompanion());
              return changes;
            }),
    );
  }

  void putAll(List<CustomProxy> proxies) {
    if (proxies.isEmpty) {
      return;
    }
    final previous = value;
    final orders = indexing.generateNKeysBetween(
      previous.map((item) => item.order).nonNulls.lastOrNull,
      null,
      proxies.length,
    );
    final added = [
      for (final (index, proxy) in proxies.indexed)
        proxy.copyWith(order: orders[index]),
    ];
    optimistic(
      [...previous, ...added],
      () => database.batch(
        (b) => database.customProxiesDao.putAllWithBatch(b, added),
      ),
    );
  }

  /// Upserts the kept rows, since a deleted one takes its dialers with it.
  void setAll(List<CustomProxy> proxies) {
    final orders = indexing.generateNKeys(proxies.length);
    final next = [
      for (final (index, proxy) in proxies.indexed)
        proxy.copyWith(order: orders[index]),
    ];
    final ids = {for (final proxy in next) proxy.id};
    final removed = {
      for (final proxy in value)
        if (!ids.contains(proxy.id)) proxy.id,
    };
    optimistic(
      next,
      () => database.transaction(() async {
        await database.batch(
          (b) => database.customProxiesDao.putAllWithBatch(b, next),
        );
        await database.customProxiesDao.delAll(removed);
      }),
    );
  }

  void order(int oldIndex, int newIndex) {
    final item = value[oldIndex];
    final nextItems = value.copyAndReorder(oldIndex, newIndex);
    final newOrder = indexing.generateKeyBetween(
      nextItems.safeGet(newIndex - 1)?.order,
      nextItems.safeGet(newIndex + 1)?.order,
    )!;
    nextItems[newIndex] = item.copyWith(order: newOrder);
    optimistic(
      nextItems,
      () => database.customProxiesDao.order(proxy: item, order: newOrder),
    );
  }
}

@riverpod
class ProxyDialers extends _$ProxyDialers
    with AsyncNotifierMixin, OptimisticMixin {
  @override
  Stream<Map<int, String>> build(int profileId) {
    final query = database.proxyDialersDao.query(profileId);
    Map<int, String> targets(List<ProxyDialer> items) => {
      for (final item in items) item.proxyId: item.target,
    };
    return settled(query.watch().map(targets), () => query.get().then(targets));
  }

  @override
  bool updateShouldNotify(
    AsyncValue<Map<int, String>> previous,
    AsyncValue<Map<int, String>> next,
  ) {
    return !const MapEquality<int, String>().equals(previous.value, next.value);
  }

  @override
  Map<int, String> get value => state.value ?? const {};

  void set(int proxyId, String? target) {
    final next = Map<int, String>.from(value);
    if (target == null) {
      next.remove(proxyId);
    } else {
      next[proxyId] = target;
    }
    optimistic(
      next,
      () => database.proxyDialersDao.set(profileId, proxyId, target),
    );
  }

  void setAll(Map<int, String> dialers) {
    optimistic(
      dialers,
      () => database.batch(
        (b) => database.proxyDialersDao.setProfileDialersWithBatch(
          profileId,
          b,
          dialers,
        ),
      ),
    );
  }
}

@riverpod
class ProfileDisabledRuleIds extends _$ProfileDisabledRuleIds
    with AsyncNotifierMixin, OptimisticMixin {
  @override
  List<int> get value => state.value ?? [];

  @override
  Stream<List<int>> build(int profileId) {
    final query = database.rulesDao.queryDisabledRuleIds(profileId);
    return settled(query.watch(), query.get);
  }

  @override
  bool updateShouldNotify(
    AsyncValue<List<int>> previous,
    AsyncValue<List<int>> next,
  ) {
    return !intListEquality.equals(previous.value, next.value);
  }

  void del(int ruleId) {
    optimistic(
      value.where((item) => item != ruleId).toList(),
      () => database.rulesDao.delDisabled(profileId, ruleId),
    );
  }

  void put(int ruleId) {
    final next = List<int>.from(value);
    if (!next.contains(ruleId)) {
      next.insert(0, ruleId);
    }
    optimistic(next, () => database.rulesDao.putDisabled(profileId, ruleId));
  }
}
