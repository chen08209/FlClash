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

mixin OptimisticMixin<T> on AsyncNotifierMixin<T> {
  void optimistic(T next, FutureOr<void> Function() action) {
    unawaited(
      optimisticAsync(next, action).catchError(_reportOptimisticFailure),
    );
  }

  Future<void> optimisticAsync(T next, FutureOr<void> Function() action) {
    return _persistOptimistically(
      value,
      next,
      () => value,
      (v) => value = v,
      action,
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
Stream<int> customRulesCount(Ref ref, int profileId) {
  return database.rulesDao.profileCustomRulesCount(profileId).watchSingle();
}

@riverpod
Stream<int> proxyGroupsCount(Ref ref, int profileId) {
  return database.proxyGroupsDao.count(profileId).watchSingle();
}

@riverpod
Stream<int> customProxiesCount(Ref ref, int profileId) {
  return database.customProxiesDao.count(profileId).watchSingle();
}

@Riverpod(keepAlive: true)
class Profiles extends _$Profiles {
  @override
  List<Profile> build() {
    ref.listen(clashProvidersProvider(ProviderKind.proxy), (_, _) {});
    return ref.watch(profilesStreamProvider).value ?? [];
  }

  Set<String> get _reservedLabels => {
    for (final provider
        in ref.read(clashProvidersProvider(ProviderKind.proxy)).value ??
            const <ClashProvider>[])
      provider.label,
  };

  void _optimistic(List<Profile> next, FutureOr<void> Function() action) {
    unawaited(
      _optimisticAsync(next, action).catchError(_reportOptimisticFailure),
    );
  }

  Future<void> _optimisticAsync(
    List<Profile> next,
    FutureOr<void> Function() action,
  ) {
    return _persistOptimistically(
      state,
      next,
      () => state,
      (v) => state = v,
      action,
    );
  }

  void put(Profile profile) {
    final newProfile = state.optimizeLabel(profile, reserved: _reservedLabels);
    _optimistic(
      state.copyAndPut(newProfile, (item) => item.id == newProfile.id),
      () => database.profiles.put(newProfile.toCompanion()),
    );
  }

  Future<void> del(int id) {
    return _optimisticAsync(
      state.where((e) => e.id != id).toList(),
      () => database.deleteProfile(id),
    );
  }

  void updateProfile(int profileId, Profile Function(Profile profile) builder) {
    final index = state.indexWhere((element) => element.id == profileId);
    if (index == -1) return;
    final newProfile = builder(state[index]);
    final next = List<Profile>.from(state);
    next[index] = newProfile;
    _optimistic(next, () => database.profiles.put(newProfile.toCompanion()));
  }

  void setAndReorder(List<Profile> profiles) {
    _optimistic(
      List<Profile>.from(profiles),
      () => database.profilesDao.setAll(profiles),
    );
  }

  void reorder(List<Profile> profiles) {
    final next = List<Profile>.from(profiles);
    final needUpdate = <ProfilesCompanion>[];
    next.forEachIndexed((index, item) {
      if (item.order != index) {
        needUpdate.add(item.toCompanion(index));
      }
    });
    _optimistic(next, () => database.profilesDao.putAll(needUpdate));
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
    return database.scriptsDao.query().watch();
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
  Stream<List<ClashProvider>> build(ProviderKind kind) {
    return database.clashProvidersDao.query(kind).watch();
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
    optimistic(
      next,
      () => database.transaction(() async {
        if (renamedFrom != null) {
          switch (provider.kind) {
            case ProviderKind.proxy:
              await database.proxyGroupsDao.renameUse(
                oldName: renamedFrom,
                newName: provider.label,
              );
            case ProviderKind.rule:
              await database.rulesDao.renameCustomRuleProvider(
                oldName: renamedFrom,
                newName: provider.label,
              );
          }
        }
        await database.clashProviders.put(provider.toCompanion());
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

  Future<void> persistOrder({required int ruleId, required String order});

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

  void delAll(Iterable<int> ruleIds) {
    final ids = ruleIds.toSet();
    optimistic(
      value.where((item) => !ids.contains(item.id)).toList(),
      () => database.rulesDao.delRules(ids),
    );
  }

  void order(int oldIndex, int newIndex) {
    final item = value[oldIndex];
    final nextItems = value.copyAndReorder(oldIndex, newIndex);
    final newOrder = indexing.generateKeyBetween(
      nextItems.safeGet(newIndex - 1)?.order,
      nextItems.safeGet(newIndex + 1)?.order,
    )!;
    optimistic(nextItems, () => persistOrder(ruleId: item.id, order: newOrder));
  }
}

@riverpod
class GlobalRules extends _$GlobalRules
    with AsyncNotifierMixin, OptimisticMixin, RuleListMixin {
  @override
  Stream<List<Rule>> build() {
    return database.rulesDao.queryGlobalAddedRules().watch();
  }

  @override
  Future<void> persistRule(Rule rule) => database.rulesDao.putGlobalRule(rule);

  @override
  Future<void> persistOrder({required int ruleId, required String order}) =>
      database.rulesDao.orderGlobalRule(ruleId: ruleId, order: order);
}

@riverpod
class ProfileAddedRules extends _$ProfileAddedRules
    with AsyncNotifierMixin, OptimisticMixin, RuleListMixin {
  @override
  Stream<List<Rule>> build(int profileId) {
    return database.rulesDao.queryProfileAddedRules(profileId).watch();
  }

  @override
  Future<void> persistRule(Rule rule) =>
      database.rulesDao.putProfileAddedRule(profileId, rule);

  @override
  Future<void> persistOrder({required int ruleId, required String order}) =>
      database.rulesDao.orderProfileAddedRule(
        profileId,
        ruleId: ruleId,
        order: order,
      );
}

@riverpod
class ProfileCustomRules extends _$ProfileCustomRules
    with AsyncNotifierMixin, OptimisticMixin, RuleListMixin {
  @override
  Stream<List<Rule>> build(int profileId) {
    return database.rulesDao.queryProfileCustomRules(profileId).watch();
  }

  @override
  Future<void> persistRule(Rule rule) =>
      database.rulesDao.putProfileCustomRule(profileId, rule);

  @override
  Future<void> persistOrder({required int ruleId, required String order}) =>
      database.rulesDao.orderProfileCustomRule(
        profileId,
        ruleId: ruleId,
        order: order,
      );
}

@riverpod
class ProxyGroups extends _$ProxyGroups
    with AsyncNotifierMixin, OptimisticMixin {
  @override
  Stream<List<ProxyGroup>> build(int profileId) {
    return database.proxyGroupsDao.query(profileId).watch();
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
    final next = List<ProxyGroup>.from(previous);
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
    optimistic(
      next,
      () => database.transaction(() async {
        if (renamedFrom != null) {
          await database.rulesDao.renameCustomRuleTarget(
            profileId,
            oldName: renamedFrom,
            newName: nextProxyGroup.name,
          );
          await database.proxyGroupsDao.renameProxies(
            profileId,
            oldName: renamedFrom,
            newName: nextProxyGroup.name,
          );
        }
        if (icon != null) {
          await database.iconRecordsDao.put(icon);
        }
        await database.proxyGroups.put(nextProxyGroup.toCompanion(profileId));
      }),
    );
    return true;
  }

  void order(int oldIndex, int newIndex) {
    final item = value[oldIndex];
    final nextItems = value.copyAndReorder(oldIndex, newIndex);
    final newOrder = indexing.generateKeyBetween(
      nextItems.safeGet(newIndex - 1)?.order,
      nextItems.safeGet(newIndex + 1)?.order,
    )!;
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
  Stream<List<CustomProxy>> build(int profileId) {
    return database.customProxiesDao.query(profileId).watch();
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

  /// A rename carries over to the groups and rules that name the proxy, the
  /// same way a group rename does.
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
      () => database.transaction(() async {
        if (renamedFrom != null) {
          await database.rulesDao.renameCustomRuleTarget(
            profileId,
            oldName: renamedFrom,
            newName: nextProxy.name,
          );
          await database.proxyGroupsDao.renameProxies(
            profileId,
            oldName: renamedFrom,
            newName: nextProxy.name,
          );
        }
        await database.customProxies.put(nextProxy.toCompanion(profileId));
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
    optimistic(
      nextItems,
      () => database.customProxiesDao.order(
        profileId,
        proxy: item,
        order: newOrder,
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
    return database.rulesDao
        .queryProfileDisabledRules(profileId)
        .map((item) => item.id)
        .watch();
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
      () => database.rulesDao.delDisabledLink(profileId, ruleId),
    );
  }

  void put(int ruleId) {
    final next = List<int>.from(value);
    if (!next.contains(ruleId)) {
      next.insert(0, ruleId);
    }
    optimistic(
      next,
      () => database.rulesDao.putDisabledLink(profileId, ruleId),
    );
  }
}
