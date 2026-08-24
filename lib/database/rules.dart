part of 'database.dart';

@DataClassName('RawRule')
@TableIndex(name: 'idx_rule_target', columns: {#ruleTarget})
class Rules extends Table {
  @override
  String get tableName => 'rules';

  IntColumn get id => integer()();

  TextColumn get ruleAction => textEnum<RuleAction>()();

  TextColumn get content => text().nullable()();

  TextColumn get ruleTarget => text().nullable()();

  TextColumn get ruleProvider => text().nullable()();

  TextColumn get subRule => text().nullable()();

  BoolColumn get noResolve => boolean().withDefault(const Constant(false))();

  BoolColumn get src => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftAccessor(tables: [Rules, ProfileRuleLinks])
class RulesDao extends DatabaseAccessor<Database> with _$RulesDaoMixin {
  RulesDao(super.attachedDatabase);

  Selectable<Rule> queryGlobalAddedRules() {
    return _query();
  }

  Selectable<Rule> queryProfileAddedRules(int profileId) {
    return _query(profileId: profileId, scene: RuleScene.added);
  }

  Selectable<Rule> queryProfileDisabledRules(int profileId) {
    return _query(profileId: profileId, scene: RuleScene.disabled);
  }

  Selectable<Rule> queryProfileCustomRules(int profileId) {
    return _query(profileId: profileId, scene: RuleScene.custom);
  }

  Selectable<int> profileCustomRulesCount(int profileId) {
    final query = _getSelectStatement(
      profileId: profileId,
      scene: RuleScene.custom,
    );
    return query.count;
  }

  Selectable<Rule> queryAddedRules(int profileId) {
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
      OrderingTerm.asc(
        profileRuleLinks.profileId.isNull().caseMatch<int>(
          when: {const Constant(true): const Constant(1)},
          orElse: const Constant(0),
        ),
      ),
      OrderingTerm.asc(profileRuleLinks.order),
    ]);

    return query.map((row) {
      final ruleData = row.readTable(rules);
      final order = row.read(profileRuleLinks.order);
      return ruleData.toRule(order);
    });
  }

  Future<void> resetOrders() async {
    final stmt = profileRuleLinks.select();

    stmt.orderBy([
      (t) => OrderingTerm.asc(t.scene),
      (t) => OrderingTerm.desc(t.order),
      (t) => OrderingTerm.desc(t.id),
    ]);

    final links = await stmt.map((item) => item.toLink()).get();
    final keys = indexing.generateNKeys(links.length);
    await batch((b) {
      b.insertAllOnConflictUpdate(
        profileRuleLinks,
        links.mapIndexed((index, item) => item.toCompanion(keys[index])),
      );
    });
  }

  void _putRulesWithBatch(Batch batch, Iterable<Rule> rules) {
    batch.insertAllOnConflictUpdate(
      this.rules,
      rules.map((item) => item.toCompanion()),
    );
  }

  void _putLinksWithBatch(Batch batch, Iterable<ProfileRuleLink> links) {
    final keys = indexing.generateNKeys(links.length);
    batch.insertAllOnConflictUpdate(
      profileRuleLinks,
      links.mapIndexed((index, item) => item.toCompanion(keys[index])),
    );
  }

  void mergeWithBatch(
    Batch batch,
    Iterable<Rule> rules,
    Iterable<ProfileRuleLink> links,
  ) {
    _putRulesWithBatch(batch, rules);
    _putLinksWithBatch(batch, links);
  }

  void restoreWithBatch(
    Batch batch,
    Iterable<Rule> rules,
    Iterable<ProfileRuleLink> links,
  ) {
    _putRulesWithBatch(batch, rules);
    final ruleIds = rules.map((item) => item.id);
    batch.deleteWhere(this.rules, (t) => t.id.isNotIn(ruleIds));
    _putLinksWithBatch(batch, links);
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

  Future<void> putProfileCustomRule(int profileId, Rule rule) {
    return _put(rule, profileId: profileId, scene: RuleScene.custom);
  }

  Future<void> putProfileDisabledRule(int profileId, Rule rule) {
    return _put(rule, profileId: profileId, scene: RuleScene.added);
  }

  void setCustomRulesWithBatch(int profileId, Batch b, Iterable<Rule> rules) {
    _setWithBatch(b, rules, profileId: profileId, scene: RuleScene.custom);
  }

  Future<int> putDisabledLink(int profileId, int ruleId) async {
    return profileRuleLinks.insertOnConflictUpdate(
      ProfileRuleLink(
        ruleId: ruleId,
        profileId: profileId,
        scene: RuleScene.disabled,
      ).toCompanion(),
    );
  }

  Future<bool> delDisabledLink(int profileId, int ruleId) async {
    return profileRuleLinks.deleteOne(
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
    return _order(ruleId: ruleId, order: order);
  }

  Future<int> orderProfileAddedRule(
    int profileId, {
    required int ruleId,
    required String order,
  }) async {
    return _order(
      ruleId: ruleId,
      order: order,
      profileId: profileId,
      scene: RuleScene.added,
    );
  }

  Future<int> orderProfileCustomRule(
    int profileId, {
    required int ruleId,
    required String order,
  }) async {
    return _order(
      ruleId: ruleId,
      order: order,
      profileId: profileId,
      scene: RuleScene.custom,
    );
  }

  Future<int> renameCustomRuleTarget(
    int profileId, {
    required String oldName,
    required String newName,
  }) {
    final stmt = rules.update()
      ..where((t) => t.ruleTarget.equals(oldName))
      ..where(
        (t) => t.id.isInQuery(
          selectOnly(profileRuleLinks)
            ..addColumns([profileRuleLinks.ruleId])
            ..where(
              profileRuleLinks.profileId.equals(profileId) &
                  profileRuleLinks.scene.equalsValue(RuleScene.custom),
            ),
        ),
      );
    return stmt.write(RulesCompanion(ruleTarget: Value(newName)));
  }

  JoinedSelectStatement<HasResultSet, dynamic> _getSelectStatement({
    int? profileId,
    RuleScene? scene,
  }) {
    final query = select(rules).join([
      innerJoin(profileRuleLinks, profileRuleLinks.ruleId.equalsExp(rules.id)),
    ]);

    query.where(
      profileId == null
          ? profileRuleLinks.profileId.isNull()
          : profileRuleLinks.profileId.equals(profileId) &
                profileRuleLinks.scene.equalsValue(scene),
    );

    query.orderBy([OrderingTerm.asc(profileRuleLinks.order)]);

    return query;
  }

  Selectable<Rule> _query({int? profileId, RuleScene? scene}) {
    final query = _getSelectStatement(profileId: profileId, scene: scene);

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
    return stmt.write(ProfileRuleLinksCompanion(order: Value(order)));
  }

  Future<int> _put(Rule rule, {int? profileId, RuleScene? scene}) async {
    return transaction(() async {
      final row = await rules.insertOnConflictUpdate(rule.toCompanion());
      if (row == 0) {
        return 0;
      }
      return profileRuleLinks.insertOnConflictUpdate(
        ProfileRuleLink(
          ruleId: rule.id,
          profileId: profileId,
          scene: scene,
          order: rule.order,
        ).toCompanion(),
      );
    });
  }

  Future<void> _delAll(Iterable<int> ruleIds) async {
    await rules.deleteWhere((t) => t.id.isIn(ruleIds));
  }

  void _setWithBatch(
    Batch b,
    Iterable<Rule> rules, {
    int? profileId,
    RuleScene? scene,
  }) async {
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

    final keys = indexing.generateNKeys(rules.length);

    b.insertAllOnConflictUpdate(
      profileRuleLinks,
      rules.mapIndexed(
        (index, item) => ProfileRuleLink(
          ruleId: item.id,
          profileId: profileId,
          scene: scene,
        ).toCompanion(keys[index]),
      ),
    );

    b.deleteWhere(this.rules, (r) {
      final linkedIds = selectOnly(profileRuleLinks);
      linkedIds.addColumns([profileRuleLinks.ruleId]);
      return r.id.isNotInQuery(linkedIds);
    });
  }
}

extension RawRuleExt on RawRule {
  Rule toRule([String? order]) {
    return Rule(
      id: id,
      ruleAction: ruleAction,
      content: content,
      ruleTarget: ruleTarget,
      ruleProvider: ruleProvider,
      subRule: subRule,
      noResolve: noResolve,
      src: src,
      order: order,
    );
  }
}

extension RulesCompanionExt on Rule {
  RulesCompanion toCompanion() {
    return RulesCompanion.insert(
      id: Value(id),
      ruleAction: ruleAction,
      content: Value(content),
      ruleTarget: Value(ruleTarget),
      ruleProvider: Value(ruleProvider),
      subRule: Value(subRule),
      noResolve: Value(noResolve),
      src: Value(src),
    );
  }
}
