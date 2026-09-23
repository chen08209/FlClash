import 'package:drift/native.dart';
import 'package:fl_clash/database/database.dart';
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
    await database.rulesDao.putGlobalRule(
      const Rule(id: 4, content: 'global second', order: 'b'),
    );
    await database.rulesDao.putProfileAddedRule(
      1,
      const Rule(id: 2, content: 'profile second', order: 'b'),
    );
    await database.rulesDao.putGlobalRule(
      const Rule(id: 3, content: 'global first', order: 'a'),
    );
    await database.rulesDao.putProfileAddedRule(
      1,
      const Rule(id: 1, content: 'profile first', order: 'a'),
    );

    final rules = await database.rulesDao.queryAddedRules(1).get();

    expect(rules.map((rule) => rule.id), [1, 2, 3, 4]);
  });
}
