part of 'database.dart';

@DataClassName('RawRule')
class Rules extends Table {
  @override
  String get tableName => 'rules';

  IntColumn get id => integer()();

  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftAccessor(tables: [Rules, ProfileRuleLinks])
class RulesDao extends DatabaseAccessor<Database> with _$RulesDaoMixin {
  RulesDao(super.attachedDatabase);

  Selectable<Rule> allGlobalAddedRules() {
    return _get();
  }

  Selectable<Rule> allProfileAddedRules(int profileId) {
    return _get(profileId: profileId, scene: RuleScene.added);
  }

  Selectable<Rule> allProfileDisabledRules(int profileId) {
    return _get(profileId: profileId, scene: RuleScene.disabled);
  }

  Selectable<Rule> allAddedRules(int profileId) {
    final disabledIdsQuery = selectOnly(profileRuleLinks)
      ..addColumns([profileRuleLinks.ruleId])
      ..where(
        profileRuleLinks.profileId.equals(profileId) &
            profileRuleLinks.scene.equalsValue(RuleScene.disabled),
      );

    final query = select(rules).join([
      innerJoin(profileRuleLinks, profileRuleLinks.ruleId.equalsExp(rules.id)),
    ]);

    query.where(
      (profileRuleLinks.profileId.isNull() |
              (profileRuleLinks.profileId.equals(profileId) &
                  profileRuleLinks.scene.equalsValue(RuleScene.added))) &
          profileRuleLinks.ruleId.isNotInQuery(disabledIdsQuery),
    );

    query.orderBy([
      OrderingTerm.desc(
        profileRuleLinks.profileId.isNull().caseMatch<int>(
          when: {const Constant(true): const Constant(1)},
          orElse: const Constant(0),
        ),
      ),
      OrderingTerm.desc(profileRuleLinks.order),
    ]);

    return query.map((row) {
      final ruleData = row.readTable(rules);
      final order = row.read(profileRuleLinks.order);
      return ruleData.toRule(order);
    });
  }

  void restoreWithBatch(
    Batch batch,
    Iterable<Rule> rules,
    Iterable<ProfileRuleLink> links,
  ) {
    batch.insertAllOnConflictUpdate(
      this.rules,
      rules.map((item) => item.toCompanion()),
    );
    final ruleIds = rules.map((item) => item.id);
    batch.deleteWhere(this.rules, (t) => t.id.isNotIn(ruleIds));
    batch.insertAllOnConflictUpdate(
      profileRuleLinks,
      links.map((item) => item.toCompanion()),
    );
    final linkKeys = links.map((item) => item.key);
    batch.deleteWhere(profileRuleLinks, (t) => t.id.isNotIn(linkKeys));
  }

  Future<void> delRules(Iterable<int> ruleIds) {
    return _delAll(ruleIds);
  }

  Future<void> putGlobalRule(Rule rule) {
    return _put(rule);
  }

  Future<void> putProfileAddedRule(int profileId, Rule rule) {
    return _put(rule, profileId: profileId, scene: RuleScene.added);
  }

  Future<void> putProfileDisabledRule(int profileId, Rule rule) {
    return _put(rule, profileId: profileId, scene: RuleScene.added);
  }

  Future<void> putGlobalRules(Iterable<Rule> rules) {
    return _putAll(rules);
  }

  Future<void> setGlobalRules(Iterable<Rule> rules) {
    return _set(rules);
  }

  Future<int> putDisabledLink(int profileId, int ruleId) async {
    return await profileRuleLinks.insertOnConflictUpdate(
      ProfileRuleLink(
        ruleId: ruleId,
        profileId: profileId,
        scene: RuleScene.disabled,
      ).toCompanion(),
    );
  }

  Future<bool> delDisabledLink(int profileId, int ruleId) async {
    return await profileRuleLinks.deleteOne(
      ProfileRuleLink(
        profileId: profileId,
        ruleId: ruleId,
        scene: RuleScene.disabled,
      ).toCompanion(),
    );
  }

  Future<int> orderGlobalRule({
    required int ruleId,
    required String order,
  }) async {
    return await _order(ruleId: ruleId, order: order);
  }

  Future<int> orderProfileAddedRule(
    int profileId, {
    required int ruleId,
    required String order,
  }) async {
    return await _order(
      ruleId: ruleId,
      order: order,
      profileId: profileId,
      scene: RuleScene.added,
    );
  }

  Selectable<Rule> _get({int? profileId, RuleScene? scene}) {
    final query = select(rules).join([
      innerJoin(profileRuleLinks, profileRuleLinks.ruleId.equalsExp(rules.id)),
    ]);

    query.where(
      profileId == null
          ? profileRuleLinks.profileId.isNull()
          : profileRuleLinks.profileId.equals(profileId) &
                profileRuleLinks.scene.equalsValue(scene),
    );

    query.orderBy([
      OrderingTerm.desc(profileRuleLinks.order),
      OrderingTerm.desc(profileRuleLinks.id),
    ]);

    return query.map((row) {
      return row.readTable(rules).toRule(row.read(profileRuleLinks.order));
    });
  }

  Future<int> _order({
    required int ruleId,
    required String order,
    int? profileId,
    RuleScene? scene,
  }) async {
    final stmt = profileRuleLinks.update();
    stmt.where((t) {
      return (profileId == null
              ? t.profileId.isNull()
              : t.profileId.equals(profileId)) &
          t.ruleId.equals(ruleId) &
          t.scene.equalsValue(scene);
    });
    return await stmt.write(ProfileRuleLinksCompanion(order: Value(order)));
  }

  Future<int> _put(Rule rule, {int? profileId, RuleScene? scene}) async {
    return transaction(() async {
      final row = await rules.insertOnConflictUpdate(rule.toCompanion());
      if (row == 0) {
        return 0;
      }
      return await profileRuleLinks.insertOnConflictUpdate(
        ProfileRuleLink(
          ruleId: rule.id,
          profileId: profileId,
          scene: scene,
        ).toCompanion(),
      );
    });
  }

  Future<void> _delAll(Iterable<int> ruleIds) async {
    await rules.deleteWhere((t) => t.id.isIn(ruleIds));
  }

  Future<void> _putAll(
    Iterable<Rule> rules, {
    int? profileId,
    RuleScene? scene,
  }) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(
        this.rules,
        rules.map((item) => item.toCompanion()),
      );
      b.insertAllOnConflictUpdate(
        profileRuleLinks,
        rules.map(
          (item) => ProfileRuleLink(
            ruleId: item.id,
            profileId: profileId,
            scene: scene,
          ).toCompanion(),
        ),
      );
    });
  }

  Future<void> _set(
    Iterable<Rule> rules, {
    int? profileId,
    RuleScene? scene,
  }) async {
    await batch((b) {
      b.insertAllOnConflictUpdate(
        this.rules,
        rules.map((item) => item.toCompanion()),
      );

      b.deleteWhere(
        profileRuleLinks,
        (t) =>
            (profileId == null
                ? t.profileId.isNull()
                : t.profileId.equals(profileId)) &
            (scene == null ? const Constant(true) : t.scene.equalsValue(scene)),
      );

      b.insertAllOnConflictUpdate(
        profileRuleLinks,
        rules.map(
          (item) => ProfileRuleLink(
            ruleId: item.id,
            profileId: profileId,
            scene: scene,
          ).toCompanion(),
        ),
      );

      b.deleteWhere(this.rules, (r) {
        final linkedIds = selectOnly(profileRuleLinks);
        linkedIds.addColumns([profileRuleLinks.ruleId]);
        return r.id.isNotInQuery(linkedIds);
      });
    });
  }
}

extension RawRuleExt on RawRule {
  Rule toRule([String? order]) {
    return Rule(id: id, value: value, order: order);
  }
}

extension RulesCompanionExt on Rule {
  RulesCompanion toCompanion() {
    return RulesCompanion.insert(id: Value(id), value: value);
  }
}
