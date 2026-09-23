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
  _downgradeToV2(raw);
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

/// Schema version 2 had no `match_target` on `profiles`.
void _downgradeToV2(Database raw) {
  _downgradeToV3(raw);
  raw.execute('ALTER TABLE profiles DROP COLUMN match_target');
  raw.execute('PRAGMA user_version = 2');
}

/// Schema version 3 had no `url` on `scripts`.
void _downgradeToV3(Database raw) {
  _downgradeToV4(raw);
  raw.execute('ALTER TABLE scripts DROP COLUMN url');
  raw.execute('PRAGMA user_version = 3');
}

/// Schema version 4 had no `order` on `scripts`.
void _downgradeToV4(Database raw) {
  _downgradeToV5(raw);
  raw.execute('ALTER TABLE scripts DROP COLUMN "order"');
  raw.execute('PRAGMA user_version = 4');
}

/// Schema version 5 had no `clash_providers` table.
void _downgradeToV5(Database raw) {
  _downgradeToV6(raw);
  raw.execute('DROP TABLE IF EXISTS clash_providers');
  raw.execute('PRAGMA user_version = 5');
}

/// Schema version 6 had no `tolerance` or `strategy` on `proxy_groups`.
void _downgradeToV6(Database raw) {
  _downgradeToV7(raw);
  raw.execute('ALTER TABLE proxy_groups DROP COLUMN tolerance');
  raw.execute('ALTER TABLE proxy_groups DROP COLUMN strategy');
  raw.execute('PRAGMA user_version = 6');
}

/// Schema version 8 ran with foreign keys off, so its deletes left orphans.
void _downgradeToV8(Database raw) {
  raw.execute('PRAGMA user_version = 8');
}

/// Schema version 7 still carried the per-use options on `clash_providers`.
void _downgradeToV7(Database raw) {
  _downgradeToV8(raw);
  raw.execute('ALTER TABLE clash_providers ADD COLUMN interval INTEGER');
  raw.execute('ALTER TABLE clash_providers ADD COLUMN filter TEXT');
  raw.execute('ALTER TABLE clash_providers ADD COLUMN exclude_filter TEXT');
  raw.execute('PRAGMA user_version = 7');
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

  test('a v1 database is left at the current schema version', () async {
    _downgradeToV1(raw);
    expect(_userVersion(raw), 1);

    await openAndMigrate();

    expect(_userVersion(raw), 9);
  });

  test('the v3 upgrade adds match_target to profiles', () async {
    _downgradeToV2(raw);
    expect(_columnsOf(raw, 'profiles'), isNot(contains('match_target')));

    await openAndMigrate();

    expect(_columnsOf(raw, 'profiles'), contains('match_target'));
    expect(_userVersion(raw), 9);
  });

  test('the v4 upgrade adds url to scripts', () async {
    _downgradeToV3(raw);
    raw.execute(
      'INSERT INTO scripts (id, label, last_update_time) '
      "VALUES (1, 'Local', 0)",
    );
    expect(_columnsOf(raw, 'scripts'), isNot(contains('url')));

    final database = await openAndMigrate();

    expect(_columnsOf(raw, 'scripts'), contains('url'));
    expect(_userVersion(raw), 9);
    final scripts = await database.scriptsDao.query().get();
    expect(scripts.single.label, 'Local');
    expect(scripts.single.url, isNull);
  });

  test('the v5 upgrade adds order to scripts and keeps id order', () async {
    _downgradeToV4(raw);
    raw.execute(
      'INSERT INTO scripts (id, label, last_update_time) '
      "VALUES (2, 'Second', 0), (1, 'First', 0)",
    );
    expect(_columnsOf(raw, 'scripts'), isNot(contains('order')));

    final database = await openAndMigrate();

    expect(_columnsOf(raw, 'scripts'), contains('order'));
    expect(_userVersion(raw), 9);
    final scripts = await database.scriptsDao.query().get();
    expect(scripts.map((item) => item.label), ['First', 'Second']);
    expect(scripts.map((item) => item.order), [null, null]);
  });

  test(
    'a v2 user_version with match_target already present still opens',
    () async {
      raw.execute('PRAGMA user_version = 2');
      expect(_columnsOf(raw, 'profiles'), contains('match_target'));

      await openAndMigrate();

      expect(_columnsOf(raw, 'profiles'), contains('match_target'));
      expect(_userVersion(raw), 9);
    },
  );

  test('the v6 upgrade creates clash_providers', () async {
    _downgradeToV5(raw);
    expect(_hasTable(raw, 'clash_providers'), isFalse);

    final database = await openAndMigrate();

    expect(_hasTable(raw, 'clash_providers'), isTrue);
    expect(_userVersion(raw), 9);
    expect(
      await database.clashProvidersDao.query(ProviderKind.proxy).get(),
      isEmpty,
    );
  });

  test(
    'a v5 user_version with clash_providers already present still opens',
    () async {
      raw.execute('PRAGMA user_version = 5');
      expect(_hasTable(raw, 'clash_providers'), isTrue);

      await openAndMigrate();

      expect(_hasTable(raw, 'clash_providers'), isTrue);
      expect(_userVersion(raw), 9);
    },
  );

  test('the v7 upgrade adds tolerance and strategy to proxy_groups', () async {
    _downgradeToV6(raw);
    expect(_columnsOf(raw, 'proxy_groups'), isNot(contains('tolerance')));

    await openAndMigrate();

    expect(
      _columnsOf(raw, 'proxy_groups'),
      containsAll(['tolerance', 'strategy']),
    );
    expect(_userVersion(raw), 9);
  });

  test(
    'a v6 user_version with the v7 columns already present still opens',
    () async {
      raw.execute('PRAGMA user_version = 6');
      expect(_columnsOf(raw, 'proxy_groups'), contains('strategy'));

      await openAndMigrate();

      expect(_columnsOf(raw, 'proxy_groups'), contains('strategy'));
      expect(_userVersion(raw), 9);
    },
  );

  test(
    'the v8 upgrade drops the per-use columns from clash_providers',
    () async {
      _downgradeToV7(raw);
      raw.execute(
        'INSERT INTO clash_providers '
        '(id, kind, label, url, behavior, format, "order", interval, filter, '
        'exclude_filter) '
        "VALUES (1, 'rule', 'Kept', '', 'classical', 'yaml', 0, 300, 'a', 'b')",
      );
      expect(
        _columnsOf(raw, 'clash_providers'),
        containsAll(['interval', 'filter', 'exclude_filter']),
      );

      final database = await openAndMigrate();

      expect(
        _columnsOf(raw, 'clash_providers'),
        isNot(anyOf(contains('interval'), contains('filter'))),
      );
      expect(_userVersion(raw), 9);
      expect(
        (await database.clashProvidersDao.queryAll().get()).single.label,
        'Kept',
      );
    },
  );

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
    raw.execute(
      'INSERT INTO profile_rule_mapping (id, rule_id) '
      "VALUES ('1', 1), ('2', 2)",
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

  test('the v9 upgrade drops rows orphaned by earlier deletes', () async {
    _downgradeToV8(raw);
    raw.execute('PRAGMA foreign_keys = OFF');
    raw.execute(
      "INSERT INTO rules (id, rule_action) VALUES (1, 'DOMAIN'), "
      "(2, 'DOMAIN'), (3, 'DOMAIN')",
    );
    raw.execute(
      'INSERT INTO profile_rule_mapping (id, profile_id, rule_id) '
      "VALUES ('global', NULL, 1), ('gone_profile', 99, 2), "
      "('gone_rule', NULL, 404)",
    );
    raw.execute(
      'INSERT INTO proxy_groups (id, profile_id, name, type) '
      "VALUES (1, NULL, 'Global', 'select'), (2, 99, 'Gone', 'select')",
    );

    await openAndMigrate();

    List<Object?> ids(String table) => [
      for (final row in raw.select('SELECT id FROM $table ORDER BY id'))
        row['id'],
    ];
    expect(ids('rules'), [1]);
    expect(ids('profile_rule_mapping'), ['global']);
    expect(ids('proxy_groups'), [1]);
    expect(raw.select('PRAGMA foreign_keys').single['foreign_keys'], 1);
  });

  test('an empty v1 rules table still reaches v2', () async {
    _downgradeToV1(raw);

    final database = await openAndMigrate();

    expect(_userVersion(raw), 9);
    expect(await database.customSelect('SELECT * FROM rules').get(), isEmpty);
  });

  test('opening a database already at v2 changes nothing', () async {
    final before = _columnsOf(raw, 'rules');

    await openAndMigrate();

    expect(_columnsOf(raw, 'rules'), before);
    expect(_userVersion(raw), 9);
    expect(_hasTable(raw, 'proxy_groups'), isTrue);
  });
}
