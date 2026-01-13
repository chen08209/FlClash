import 'package:collection/collection.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/models/models.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'generated/database.g.dart';

@riverpod
Stream<List<Profile>> profilesStream(Ref ref) {
  return database.profilesDao.all().watch();
}

@riverpod
Stream<List<Script>> scriptsStream(Ref ref) {
  return database.scriptsDao.all().watch();
}

@riverpod
Stream<List<Rule>> rulesStream(Ref ref) {
  return database.rulesDao.allGlobalAddedRules().watch();
}

@riverpod
Stream<List<Rule>> addedRuleStream(Ref ref, int profileId) {
  return database.rulesDao.allAddedRules(profileId).watch();
}

@riverpod
class Profiles extends _$Profiles {
  @override
  List<Profile> build() {
    return ref.watch(profilesStreamProvider).value ?? [];
  }

  void put(Profile profile) {
    final vm2 = state.copyAndAddProfile(profile);
    final nextProfiles = vm2.a;
    final newProfile = vm2.b;
    state = nextProfiles;
    database.put(database.profiles, newProfile.toCompanion());
  }

  void del(int id) {
    final newProfiles = state.where((element) => element.id != id).toList();
    state = newProfiles;
    database.remove(database.profiles, (t) => t.id.equals(id));
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
    database.put(database.profiles, newProfile.toCompanion());
  }

  void setAndReorder(List<Profile> profiles) {
    final newProfiles = List<Profile>.from(profiles);
    state = newProfiles;
    final ids = newProfiles.map((item) => item.id);
    database.setAll(
      database.profiles,
      newProfiles.mapIndexed((index, profile) => profile.toCompanion(index)),
      deleteFilter: (t) => t.id.isNotIn(ids),
    );
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
    return ref.watch(scriptsStreamProvider).value ?? [];
  }

  void setAll(List<Script> scripts) {
    state = scripts;
    final ids = scripts.map((item) => item.id);
    database.setAll(
      database.scripts,
      scripts.map((item) => item.toCompanion()),
      deleteFilter: (t) => t.id.isNotIn(ids),
    );
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
    database.put(database.scripts, script.toCompanion());
  }

  void del(int id) {
    final index = state.indexWhere((item) => item.id == id);
    if (index == -1) {
      return;
    }
    final list = List<Script>.from(state);
    list.removeAt(index);
    state = list;
    database.remove(database.scripts, (t) => t.id.equals(id));
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
class Rules extends _$Rules {
  @override
  List<Rule> build() {
    return ref.watch(rulesStreamProvider).value ?? [];
  }

  @override
  bool updateShouldNotify(List<Rule> previous, List<Rule> next) {
    return !ruleListEquality.equals(previous, next);
  }

  void delAll(Iterable<int> ruleIds) {
    state = List<Rule>.from(state.where((item) => !ruleIds.contains(item.id)));
    database.rulesDao.delRules(ruleIds);
  }

  void put(Rule rule) {
    state = state.copyAndUpdate(rule);
    database.rulesDao.putRule(rule);
  }

  void setAll(Iterable<Rule> rules) {
    state = rules.toList();
    database.rulesDao.setRules(rules);
  }

  void order(int oldIndex, int newIndex) {
    int insertIndex = newIndex;
    if (oldIndex < newIndex) {
      insertIndex -= 1;
    }
    final nextItems = List<Rule>.from(state);
    final item = nextItems.removeAt(oldIndex);
    nextItems.insert(insertIndex, item);
    state = nextItems;
    final preOrder = nextItems.safeGet(insertIndex - 1)?.order;
    final nextOrder = nextItems.safeGet(insertIndex + 1)?.order;
    final newOrder = indexing.generateKeyBetween(nextOrder, preOrder)!;
    database.rulesDao.orderRule(ruleId: item.id, order: newOrder);
  }
}
