import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/database.g.dart';

@riverpod
Stream<List<Rule>> addedRuleStream(Ref ref, int profileId) {
  return database.rulesDao.allAddedRules(profileId).watch();
}

@riverpod
class Profiles extends _$Profiles {
  @override
  List<Profile> build() {
    _initListen();
    return [];
  }

  void _initListen() {
    final subscription = database.profilesDao.all().watch().listen((value) {
      print('saddada===>');
      state = value;
    });

    ref.onDispose(() {
      subscription.cancel();
    });
  }

  void put(Profile profile) {
    final vm2 = state.copyAndAddProfile(profile);
    final nextProfiles = vm2.a;
    final newProfile = vm2.b;
    state = nextProfiles;
    database.profiles.put(newProfile.toCompanion());
  }

  void del(int id) {
    final newProfiles = state.where((element) => element.id != id).toList();
    state = newProfiles;
    database.profiles.remove((t) => t.id.equals(id));
  }

  void updateProfile(int profileId, Profile Function(Profile profile) builder) {
    final index = state.indexWhere((element) => element.id == profileId);
    if (index == -1) {
      return;
    }
    final List<Profile> profilesTemp = List.from(state);
    final newProfile = builder(profilesTemp[index]);
    profilesTemp[index] = newProfile;
    state = profilesTemp;
    database.profiles.put(newProfile.toCompanion());
  }

  void setAndReorder(List<Profile> profiles) {
    final newProfiles = List<Profile>.from(profiles);
    state = newProfiles;
    database.profilesDao.setAll(profiles);
  }

  void reorder(List<Profile> profiles) {
    final newProfiles = List<Profile>.from(profiles);
    state = newProfiles;
    database.batch((batch) {
      newProfiles.forEachIndexed((index, item) {
        if (item.order != index) {
          batch.update(
            database.profiles,
            item.toCompanion(index),
            where: (tbl) => tbl.id.equals(item.id),
          );
        }
      });
    });
  }

  @override
  bool updateShouldNotify(List<Profile> previous, List<Profile> next) {
    return !profileListEquality.equals(previous, next);
  }
}

@riverpod
class Scripts extends _$Scripts {
  @override
  List<Script> build() {
    _initListen();
    return [];
  }

  void _initListen() {
    final subscription = database.scriptsDao.all().watch().listen((value) {
      state = value;
    });

    ref.onDispose(() {
      subscription.cancel();
    });
  }

  void put(Script script) {
    final list = List<Script>.from(state);
    final index = state.indexWhere((item) => item.id == script.id);
    if (index != -1) {
      list[index] = script;
    } else {
      list.add(script);
    }
    state = list;
    database.scripts.put(script.toCompanion());
  }

  void del(int id) {
    final index = state.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }
    final list = List<Script>.from(state);
    list.removeAt(index);
    state = list;
    database.scripts.remove((t) => t.id.equals(id));
  }

  bool isExits(String label) {
    return state.indexWhere((item) => item.label == label) != -1;
  }

  @override
  bool updateShouldNotify(List<Script> previous, List<Script> next) {
    return !scriptListEquality.equals(previous, next);
  }
}

@riverpod
class GlobalRules extends _$GlobalRules with AsyncNotifierMixin {
  @override
  Stream<List<Rule>> build() {
    return database.rulesDao.allGlobalAddedRules().watch();
  }

  @override
  List<Rule> get value => state.value ?? [];

  @override
  bool updateShouldNotify(
    AsyncValue<List<Rule>> previous,
    AsyncValue<List<Rule>> next,
  ) {
    return !ruleListEquality.equals(previous.value, next.value);
  }

  void delAll(Iterable<int> ruleIds) {
    value = List<Rule>.from(value.where((item) => !ruleIds.contains(item.id)));
    database.rulesDao.delRules(ruleIds);
  }

  void put(Rule rule) {
    value = value.copyAndPut(rule);
    database.rulesDao.putGlobalRule(rule);
  }

  void order(int oldIndex, int newIndex) {
    int insertIndex = newIndex;
    if (oldIndex < newIndex) {
      insertIndex -= 1;
    }
    final nextItems = List<Rule>.from(value);
    final item = nextItems.removeAt(oldIndex);
    nextItems.insert(insertIndex, item);
    value = nextItems;
    final preOrder = nextItems.safeGet(insertIndex - 1)?.order;
    final nextOrder = nextItems.safeGet(insertIndex + 1)?.order;
    final newOrder = indexing.generateKeyBetween(nextOrder, preOrder)!;
    database.rulesDao.orderGlobalRule(ruleId: item.id, order: newOrder);
  }
}

@riverpod
class ProfileAddedRules extends _$ProfileAddedRules with AsyncNotifierMixin {
  @override
  Stream<List<Rule>> build(int profileId) {
    return database.rulesDao.allProfileAddedRules(profileId).watch();
  }

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
    value = value.copyAndPut(rule);
    database.rulesDao.putProfileAddedRule(profileId, rule);
  }

  void delAll(Iterable<int> ruleIds) {
    value = List<Rule>.from(value.where((item) => !ruleIds.contains(item.id)));
    database.rulesDao.delRules(ruleIds);
  }

  void order(int oldIndex, int newIndex) {
    int insertIndex = newIndex;
    if (oldIndex < newIndex) {
      insertIndex -= 1;
    }
    final nextItems = List<Rule>.from(value);
    final item = nextItems.removeAt(oldIndex);
    nextItems.insert(insertIndex, item);
    value = nextItems;
    final preOrder = nextItems.safeGet(insertIndex - 1)?.order;
    final nextOrder = nextItems.safeGet(insertIndex + 1)?.order;
    final newOrder = indexing.generateKeyBetween(nextOrder, preOrder)!;
    database.rulesDao.orderProfileAddedRule(
      profileId,
      ruleId: item.id,
      order: newOrder,
    );
  }
}

@riverpod
class ProfileDisabledRuleIds extends _$ProfileDisabledRuleIds
    with AsyncNotifierMixin {
  @override
  List<int> get value => state.value ?? [];

  @override
  Stream<List<int>> build(int profileId) {
    return database.rulesDao
        .allProfileDisabledRules(profileId)
        .map((item) => item.id)
        .watch();
  }

  void _put(int ruleId) {
    var newList = List<int>.from(value);
    final index = newList.indexWhere((item) => item == ruleId);
    if (index != -1) {
      newList[index] = ruleId;
    } else {
      newList.insert(0, ruleId);
    }
    value = newList;
  }

  void del(int ruleId) {
    List<int> newList = List.from(value);
    newList = newList.where((item) => item != ruleId).toList();
    value = newList;
    database.rulesDao.delDisabledLink(profileId, ruleId);
  }

  void put(int ruleId) {
    _put(ruleId);
    database.rulesDao.putDisabledLink(profileId, ruleId);
  }
}
