import 'package:drift/native.dart';
import 'package:fl_clash/database/database.dart' as fl;
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';

/// Rebuilds [raw] into the shape schema version 1 left behind: no
/// `proxy_groups`, no `icon_records`, and a `rules` table that still stores the
/// whole rule in one `value` column.
///
/// Drift creates the current schema outright on a fresh database, so walking a
/// real database back to v1 and reopening it is the only way to run the real
/// `onUpgrade` against a real SQLite file.
void _downgradeToV1(Database raw) {
  raw.execute('DROP TABLE IF EXISTS proxy_groups');
  raw.execute('DROP TABLE IF EXISTS icon_records');
  raw.execute('DROP INDEX IF EXISTS idx_rule_target');
  raw.execute('DROP TABLE IF EXISTS rules');
  raw.execute('''
    CREATE TABLE rules (
      id INTEGER NOT NULL PRIMARY KEY,
      value TEXT NOT NULL
    )
  ''');
  raw.execute('PRAGMA user_version = 1');
}

Set<String> _columnsOf(Database raw, String table) => {
  for (final row in raw.select('PRAGMA table_info($table)'))
    row['name'] as String,
};

bool _hasTable(Database raw, String name) => raw.select(
  "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
  [name],
).isNotEmpty;

int _userVersion(Database raw) =>
    raw.select('PRAGMA user_version').single['user_version'] as int;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Database raw;

  setUp(() async {
    raw = sqlite3.openInMemory();
    final seed = fl.Database(
      NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
    );
    await seed.customSelect('SELECT 1').get();
    await seed.close();
  });

  tearDown(() => raw.close());

  Future<fl.Database> openAndMigrate() async {
    final database = fl.Database(
      NativeDatabase.opened(raw, closeUnderlyingOnClose: false),
    );
    addTearDown(database.close);
    await database.customSelect('SELECT 1').get();
    return database;
  }

  test('a v1 database is left at schema version 2', () async {
    _downgradeToV1(raw);
    expect(_userVersion(raw), 1);

    await openAndMigrate();

    expect(_userVersion(raw), 2);
  });

  test('the upgrade creates the tables v2 added', () async {
    _downgradeToV1(raw);
    expect(_hasTable(raw, 'proxy_groups'), isFalse);
    expect(_hasTable(raw, 'icon_records'), isFalse);

    await openAndMigrate();

    expect(_hasTable(raw, 'proxy_groups'), isTrue);
    expect(_hasTable(raw, 'icon_records'), isTrue);
  });

  test('the upgrade splits the rules value column into parsed ones', () async {
    _downgradeToV1(raw);
    expect(_columnsOf(raw, 'rules'), {'id', 'value'});

    await openAndMigrate();

    expect(
      _columnsOf(raw, 'rules'),
      containsAll(<String>[
        'rule_action',
        'content',
        'rule_target',
        'rule_provider',
        'sub_rule',
        'no_resolve',
        'src',
      ]),
    );
    expect(_columnsOf(raw, 'rules'), isNot(contains('value')));
  });

  test('every v1 rule row is parsed into the new columns', () async {
    _downgradeToV1(raw);
    raw.execute(
      'INSERT INTO rules (id, value) '
      "VALUES (1, 'DOMAIN-SUFFIX,example.com,DIRECT')",
    );
    raw.execute(
      'INSERT INTO rules (id, value) '
      "VALUES (2, 'IP-CIDR,10.0.0.0/8,REJECT,no-resolve')",
    );

    final database = await openAndMigrate();
    final rows = await database
        .customSelect(
          'SELECT id, rule_action, content, rule_target, no_resolve '
          'FROM rules ORDER BY id',
        )
        .get();

    expect(rows, hasLength(2));
    expect(rows[0].read<String>('rule_action'), RuleAction.DOMAIN_SUFFIX.name);
    expect(rows[0].read<String>('content'), 'example.com');
    expect(rows[0].read<String>('rule_target'), 'DIRECT');
    expect(rows[0].read<int>('no_resolve'), 0);
    expect(rows[1].read<String>('rule_action'), RuleAction.IP_CIDR.name);
    expect(rows[1].read<String>('content'), '10.0.0.0/8');
    expect(rows[1].read<String>('rule_target'), 'REJECT');
    expect(
      rows[1].read<int>('no_resolve'),
      1,
      reason: 'the no-resolve modifier has to survive the column split',
    );
  });

  test('an empty v1 rules table still reaches v2', () async {
    _downgradeToV1(raw);

    final database = await openAndMigrate();

    expect(_userVersion(raw), 2);
    expect(await database.customSelect('SELECT * FROM rules').get(), isEmpty);
  });

  test('opening a database already at v2 changes nothing', () async {
    final before = _columnsOf(raw, 'rules');

    await openAndMigrate();

    expect(_columnsOf(raw, 'rules'), before);
    expect(_userVersion(raw), 2);
    expect(_hasTable(raw, 'proxy_groups'), isTrue);
  });
}
