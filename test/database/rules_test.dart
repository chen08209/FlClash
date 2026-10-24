import 'package:drift/native.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Database database;

  setUp(() async {
    database = Database(NativeDatabase.memory());
    await database.profilesDao.putAll([
      const Profile(id: 1, autoUpdateDuration: Duration.zero).toCompanion(),
    ]);
  });

  tearDown(() async {
    await database.close();
  });

  test('added rules follow profile then global UI order', () async {
    await database.rulesDao.putRule(
      const Rule(id: 4, content: 'global second', order: 'b'),
    );
    await database.rulesDao.putRule(
      const Rule(id: 2, content: 'profile second', order: 'b'),
      profileId: 1,
    );
    await database.rulesDao.putRule(
      const Rule(id: 3, content: 'global first', order: 'a'),
    );
    await database.rulesDao.putRule(
      const Rule(id: 1, content: 'profile first', order: 'a'),
      profileId: 1,
    );

    final rules = await database.rulesDao.queryAddedRules(1).get();

    expect(rules.map((rule) => rule.id), [1, 2, 3, 4]);
  });

  test('application rules are ordered and limited to their owning profile', () async {
    await database.profilesDao.putAll([
      const Profile(id: 2, autoUpdateDuration: Duration.zero).toCompanion(),
    ]);
    const path = Rule(
      id: 1,
      ruleAction: RuleAction.PROCESS_PATH,
      content: '/apps/browser',
      ruleTarget: 'DIRECT',
      order: 'a0',
    );
    await database.rulesDao.putRule(path, profileId: 1);
    await database.rulesDao.putRule(
      path.copyWith(id: 2, ruleAction: RuleAction.PROCESS_NAME, order: 'Zz'),
      profileId: 1,
    );
    await database.rulesDao.putRule(path.copyWith(id: 3, src: true), profileId: 1);
    await database.rulesDao.putRule(path.copyWith(id: 4));
    await database.rulesDao.putRule(path.copyWith(id: 5), profileId: 2);
    await database.rulesDao.putRule(
      const Rule(id: 6, ruleAction: RuleAction.MATCH, ruleTarget: 'Proxy'),
      profileId: 1,
    );

    final rules = await database.rulesDao.queryApplicationRules(1).get();
    expect(rules.map((rule) => rule.id), [2, 1]);
    expect(await database.rulesDao.firstProfileRuleOrder(1), 'Zz');
    expect(await database.rulesDao.firstProfileRuleOrder(99), isNull);
  });
}
