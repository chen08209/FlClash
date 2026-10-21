import 'package:drift/native.dart';
import 'package:fl_clash/database/database.dart' as fl;
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
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

/// Schema version 9 had no `custom_proxies` table.
void _downgradeToV9(Database raw) {
  _downgradeToV10(raw);
  raw.execute('DROP TABLE IF EXISTS custom_proxies');
  raw.execute('PRAGMA user_version = 9');
}

/// Schema version 8 ran with foreign keys off, so its deletes left orphans.
void _downgradeToV8(Database raw) {
  _downgradeToV9(raw);
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

/// Schema version 20 had no `ip_qualities`.
void _downgradeToV20(Database raw) {
  raw.execute('DROP TABLE IF EXISTS ip_qualities');
  raw.execute('PRAGMA user_version = 20');
}

/// Schema version 19 had no `empty_options` on `custom_proxies`.
void _downgradeToV19(Database raw) {
  _downgradeToV20(raw);
  raw.execute('ALTER TABLE custom_proxies DROP COLUMN empty_options');
  raw.execute('PRAGMA user_version = 19');
}

/// Schema version 18 had no `age_secret_key` on `profiles`.
void _downgradeToV18(Database raw) {
  _downgradeToV19(raw);
  raw.execute('ALTER TABLE profiles DROP COLUMN age_secret_key');
  raw.execute('PRAGMA user_version = 18');
}

/// Schema version 17 kept each group option in a column of its own.
void _downgradeToV17(Database raw) {
  _downgradeToV18(raw);
  raw.execute('DROP TABLE proxy_groups');
  raw.execute('''
    CREATE TABLE "proxy_groups" (
      "id" INTEGER NOT NULL,
      "profile_id" INTEGER NOT NULL REFERENCES profiles (id) ON DELETE CASCADE,
      "name" TEXT NOT NULL,
      "type" TEXT NOT NULL,
      "proxies" TEXT NULL,
      "use" TEXT NULL,
      "url" TEXT NULL,
      "interval" INTEGER NULL,
      "timeout" INTEGER NULL,
      "max_failed_times" INTEGER NULL,
      "lazy" INTEGER NULL,
      "disable_u_d_p" INTEGER NULL,
      "filter" TEXT NULL,
      "exclude_filter" TEXT NULL,
      "exclude_type" TEXT NULL,
      "expected_status" TEXT NULL,
      "tolerance" INTEGER NULL,
      "strategy" TEXT NULL,
      "hash_key" TEXT NULL,
      "default_selected" TEXT NULL,
      "empty_fallback" TEXT NULL,
      "include_all" INTEGER NULL,
      "include_all_proxies" INTEGER NULL,
      "include_all_providers" INTEGER NULL,
      "hidden" INTEGER NULL,
      "icon" TEXT NULL,
      "order" TEXT NULL,
      PRIMARY KEY ("id")
    )
  ''');
  raw.execute(
    'CREATE INDEX idx_proxy_groups_profile_order '
    'ON proxy_groups (profile_id, "order")',
  );
  raw.execute('PRAGMA user_version = 17');
}

/// Schema version 10 is the shape the last release left behind.
void _downgradeToV10(Database raw) {
  _downgradeToV17(raw);
  raw.execute('PRAGMA foreign_keys = OFF');
  raw.execute(
    'ALTER TABLE profiles RENAME COLUMN extend_type TO overwrite_type',
  );
  raw.execute('ALTER TABLE profiles DROP COLUMN overrides');
  raw.execute('ALTER TABLE profiles DROP COLUMN type');
  raw.execute('DROP TABLE IF EXISTS icon_sets');
  raw.execute('DROP TABLE IF EXISTS proxy_dialers');
  raw.execute('DROP TABLE disabled_rules');
  raw.execute('DROP TABLE rules');
  raw.execute('''
    CREATE TABLE rules (
      id INTEGER NOT NULL PRIMARY KEY,
      rule_action TEXT NOT NULL,
      content TEXT NULL,
      rule_target TEXT NULL,
      rule_provider TEXT NULL,
      sub_rule TEXT NULL,
      no_resolve INTEGER NOT NULL DEFAULT 0,
      src INTEGER NOT NULL DEFAULT 0
    )
  ''');
  raw.execute('CREATE INDEX idx_rule_target ON rules (rule_target)');
  raw.execute('''
    CREATE TABLE profile_rule_mapping (
      id TEXT NOT NULL PRIMARY KEY,
      profile_id INTEGER NULL REFERENCES profiles (id) ON DELETE CASCADE,
      rule_id INTEGER NOT NULL REFERENCES rules (id) ON DELETE CASCADE,
      scene TEXT NULL,
      "order" TEXT NULL
    )
  ''');
  raw.execute(
    'CREATE INDEX idx_profile_scene_order '
    'ON profile_rule_mapping (profile_id, scene, "order")',
  );
  final groupsSql =
      raw.select(
            "SELECT sql FROM sqlite_master WHERE type='table' AND name=?",
            ['proxy_groups'],
          ).single['sql']
          as String;
  raw.execute('DROP TABLE proxy_groups');
  raw.execute(
    groupsSql.replaceFirst(
      '"profile_id" INTEGER NOT NULL',
      '"profile_id" INTEGER NULL',
    ),
  );
  raw.execute('ALTER TABLE proxy_groups DROP COLUMN hash_key');
  raw.execute('ALTER TABLE proxy_groups DROP COLUMN default_selected');
  raw.execute('ALTER TABLE proxy_groups DROP COLUMN empty_fallback');
  raw.execute(
    'CREATE INDEX idx_profile_name_order '
    'ON proxy_groups (profile_id, name, "order")',
  );
  raw.execute('DROP TABLE custom_proxies');
  raw.execute('''
    CREATE TABLE custom_proxies (
      id INTEGER NOT NULL PRIMARY KEY,
      profile_id INTEGER NULL REFERENCES profiles (id) ON DELETE CASCADE,
      definition TEXT NOT NULL,
      "order" TEXT NULL
    )
  ''');
  raw.execute(
    'CREATE INDEX idx_custom_proxies_profile_order '
    'ON custom_proxies (profile_id, "order")',
  );
  raw.execute('PRAGMA user_version = 10');
}

void _insertV10Profile(
  Database raw,
  int id, {
  String url = '',
  String overwriteType = 'standard',
}) {
  raw.execute(
    'INSERT INTO profiles (id, label, url, overwrite_type, '
    'auto_update_duration_millis, auto_update, selected_map, unfold_set) '
    "VALUES (?, ?, ?, ?, 0, 0, '{}', '[]')",
    [id, 'Profile $id', url, overwriteType],
  );
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

    expect(_userVersion(raw), 21);
  });

  test('the v3 upgrade adds match_target to profiles', () async {
    _downgradeToV2(raw);
    expect(_columnsOf(raw, 'profiles'), isNot(contains('match_target')));

    await openAndMigrate();

    expect(_columnsOf(raw, 'profiles'), contains('match_target'));
    expect(_userVersion(raw), 21);
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
    expect(_userVersion(raw), 21);
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
    expect(_userVersion(raw), 21);
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
      expect(_userVersion(raw), 21);
    },
  );

  test('the v6 upgrade creates clash_providers', () async {
    _downgradeToV5(raw);
    expect(_hasTable(raw, 'clash_providers'), isFalse);

    final database = await openAndMigrate();

    expect(_hasTable(raw, 'clash_providers'), isTrue);
    expect(_userVersion(raw), 21);
    expect(await database.clashProvidersDao.query().get(), isEmpty);
  });

  test(
    'a v5 user_version with clash_providers already present still opens',
    () async {
      raw.execute('PRAGMA user_version = 5');
      expect(_hasTable(raw, 'clash_providers'), isTrue);

      await openAndMigrate();

      expect(_hasTable(raw, 'clash_providers'), isTrue);
      expect(_userVersion(raw), 21);
    },
  );

  test('a v6 proxy_groups without tolerance reaches definition', () async {
    _downgradeToV6(raw);
    expect(_columnsOf(raw, 'proxy_groups'), isNot(contains('tolerance')));

    await openAndMigrate();

    expect(_columnsOf(raw, 'proxy_groups'), contains('definition'));
    expect(_userVersion(raw), 21);
  });

  test('a v6 user_version on the current proxy_groups still opens', () async {
    raw.execute('PRAGMA user_version = 6');
    expect(_columnsOf(raw, 'proxy_groups'), contains('definition'));

    await openAndMigrate();

    expect(_columnsOf(raw, 'proxy_groups'), contains('definition'));
    expect(_userVersion(raw), 21);
  });

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
      expect(_userVersion(raw), 21);
      expect(
        (await database.clashProvidersDao.query().get()).single.label,
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

  test('the upgrade drops rows orphaned by earlier deletes', () async {
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

    await openAndMigrate();

    expect(
      [for (final row in raw.select('SELECT id FROM rules')) row['id']],
      [1],
    );
    expect(raw.select('PRAGMA foreign_keys').single['foreign_keys'], 1);
  });

  test('the v10 upgrade creates custom_proxies', () async {
    _downgradeToV9(raw);
    expect(_hasTable(raw, 'custom_proxies'), isFalse);

    final database = await openAndMigrate();

    expect(_hasTable(raw, 'custom_proxies'), isTrue);
    expect(_userVersion(raw), 21);
    expect(await database.customProxiesDao.query().get(), isEmpty);
  });

  test('the upgrade gives proxy_groups the definition column', () async {
    _downgradeToV10(raw);

    await openAndMigrate();

    expect(_columnsOf(raw, 'proxy_groups'), contains('definition'));
    expect(_columnsOf(raw, 'proxy_groups'), isNot(contains('url')));
    expect(_userVersion(raw), 21);
  });

  test('the v17 upgrade renames overwrite_type and adds overrides', () async {
    _downgradeToV10(raw);
    _insertV10Profile(raw, 1, overwriteType: 'script');

    final database = await openAndMigrate();

    expect(
      _columnsOf(raw, 'profiles'),
      allOf(
        containsAll(['extend_type', 'overrides']),
        isNot(contains('overwrite_type')),
      ),
    );
    expect(
      (await database.profilesDao.query().get()).single.extendType,
      ExtendType.script,
    );
  });

  test('the v17 upgrade keeps only the app-level custom proxies', () async {
    _downgradeToV10(raw);
    raw.execute('PRAGMA foreign_keys = OFF');
    raw.execute(
      'INSERT INTO custom_proxies (id, profile_id, definition) VALUES '
      '''(1, NULL, '{"name":"App","type":"ss"}'), '''
      '''(2, 7, '{"name":"Profile","type":"ss"}')''',
    );

    final database = await openAndMigrate();

    expect(_columnsOf(raw, 'custom_proxies'), isNot(contains('profile_id')));
    expect(
      raw.select(
        "SELECT name FROM sqlite_master WHERE type='index' AND name=?",
        ['idx_custom_proxies_profile_order'],
      ),
      isEmpty,
    );
    expect(
      (await database.customProxiesDao.query().get()).single.definition['name'],
      'App',
    );
  });

  test('the v17 upgrade moves rules onto their owners', () async {
    _downgradeToV10(raw);
    _insertV10Profile(raw, 1, url: 'https://example.com/sub');
    _insertV10Profile(raw, 2, overwriteType: 'custom');
    raw.execute(
      'INSERT INTO rules (id, rule_action, content, rule_target) VALUES '
      "(10, 'DOMAIN', 'global.com', 'DIRECT'), "
      "(11, 'DOMAIN', 'disabled.com', 'DIRECT'), "
      "(20, 'DOMAIN', 'added.com', 'REJECT'), "
      "(30, 'MATCH', NULL, 'Custom'), "
      "(40, 'DOMAIN', 'unlinked.com', 'DIRECT')",
    );
    raw.execute(
      'INSERT INTO profile_rule_mapping (id, profile_id, rule_id, scene, '
      '"order") VALUES '
      "('10', NULL, 10, NULL, 'a0'), ('11', NULL, 11, NULL, 'a1'), "
      "('1_20_added', 1, 20, 'added', 'a0'), "
      "('1_11_disabled', 1, 11, 'disabled', NULL), "
      "('2_30_custom', 2, 30, 'custom', 'a0')",
    );

    final database = await openAndMigrate();

    expect(_userVersion(raw), 21);
    expect(_hasTable(raw, 'profile_rule_mapping'), isFalse);
    expect(
      {
        for (final row in raw.select(
          'SELECT id, type, extend_type FROM profiles',
        ))
          row['id']: (row['type'], row['extend_type']),
      },
      {1: ('url', 'standard'), 2: ('file', 'standard')},
    );
    expect(
      {
        for (final row in raw.select('SELECT id, profile_id FROM rules'))
          row['id']: row['profile_id'],
      },
      {10: null, 11: null, 20: 1},
    );
    expect(
      {
        for (final row in raw.select(
          'SELECT profile_id, rule_id FROM disabled_rules',
        ))
          (row['profile_id'], row['rule_id']),
      },
      {(1, 11), (2, 10), (2, 11)},
    );
    expect(
      (await database.rulesDao.queryAddedRules(1).get()).map((rule) => rule.id),
      [20, 10],
    );
    expect(await database.rulesDao.queryProfileRules(2).get(), isEmpty);
  });

  test('a custom overwrite runs its subscription as it is', () async {
    _downgradeToV10(raw);
    _insertV10Profile(raw, 2, overwriteType: 'custom');
    raw.execute("UPDATE profiles SET match_target = 'Proxy' WHERE id = 2");
    raw.execute(
      'INSERT INTO rules (id, rule_action, content, rule_target) VALUES '
      "(10, 'DOMAIN', 'global.com', 'DIRECT'), "
      "(20, 'DOMAIN', 'added.com', 'REJECT')",
    );
    raw.execute(
      'INSERT INTO profile_rule_mapping (id, profile_id, rule_id, scene, '
      '"order") VALUES '
      "('10', NULL, 10, NULL, 'a0'), "
      "('2_20_added', 2, 20, 'added', 'a0')",
    );

    final database = await openAndMigrate();

    expect(await database.rulesDao.queryAddedRules(2).get(), isEmpty);
    expect(
      (await database.profilesDao.query().get()).single.matchTarget,
      isNull,
    );
    expect(raw.select('SELECT id FROM rules').map((row) => row['id']), [10]);
  });

  test('a failed upgrade leaves the v10 database as it was', () async {
    _downgradeToV10(raw);
    raw.execute(
      'INSERT INTO custom_proxies (id, profile_id, definition) '
      '''VALUES (2, 7, '{"name":"Profile","type":"ss"}')''',
    );
    raw.execute('ALTER TABLE rules DROP COLUMN src');

    await expectLater(openAndMigrate(), throwsA(anything));

    expect(_userVersion(raw), 10);
    expect(_columnsOf(raw, 'profiles'), contains('overwrite_type'));
    expect(raw.select('SELECT id FROM custom_proxies'), hasLength(1));
  });

  test('the v17 upgrade drops what custom overwrites kept', () async {
    _downgradeToV10(raw);
    _insertV10Profile(raw, 2, overwriteType: 'custom');
    raw.execute(
      'INSERT INTO custom_proxies (id, definition) '
      '''VALUES (5, '{"name":"App","type":"ss"}')''',
    );
    raw.execute(
      'INSERT INTO proxy_groups (id, profile_id, name, type) '
      "VALUES (1, 2, 'Proxy', 'select'), (2, NULL, 'Loose', 'select')",
    );

    final database = await openAndMigrate();

    expect(raw.select('SELECT * FROM proxy_groups'), isEmpty);
    expect(
      (await database.customProxiesDao.query().get()).single.definition['name'],
      'App',
    );
    final indexes = {
      for (final row in raw.select(
        "SELECT name FROM sqlite_master WHERE type='index'",
      ))
        row['name'],
    };
    expect(
      indexes,
      containsAll([
        'idx_rule_target',
        'idx_rules_profile_order',
        'idx_proxy_groups_profile_order',
      ]),
    );
    expect(
      indexes,
      isNot(
        anyOf(
          contains('idx_profile_name_order'),
          contains('idx_profile_scene_order'),
        ),
      ),
    );
  });

  test(
    'a v10 user_version on the current schema keeps its custom profiles',
    () async {
      raw.execute(
        'INSERT INTO profiles (id, type, label, url, extend_type, '
        'auto_update_duration_millis, auto_update, selected_map, unfold_set) '
        "VALUES (3, 'custom', 'Mine', '', 'standard', 0, 0, '{}', '[]')",
      );
      raw.execute(
        'INSERT INTO proxy_groups (id, profile_id, name, type) '
        "VALUES (1, 3, 'Proxy', 'select')",
      );
      raw.execute(
        'INSERT INTO rules (id, profile_id, rule_action, rule_target) '
        "VALUES (1, 3, 'MATCH', 'Proxy')",
      );
      raw.execute('PRAGMA user_version = 10');

      final database = await openAndMigrate();

      expect(
        (await database.profilesDao.query().get()).single.type,
        ProfileType.custom,
      );
      expect(
        (await database.proxyGroupsDao.query(3).get()).single.name,
        'Proxy',
      );
      expect(
        (await database.rulesDao.queryProfileRules(3).get()).single.ruleTarget,
        'Proxy',
      );
    },
  );

  test('the v17 upgrade creates proxy_dialers', () async {
    _downgradeToV10(raw);
    expect(_hasTable(raw, 'proxy_dialers'), isFalse);

    final database = await openAndMigrate();

    expect(_hasTable(raw, 'proxy_dialers'), isTrue);
    expect(_userVersion(raw), 21);
    expect(await database.proxyDialersDao.query(1).get(), isEmpty);
  });

  test('the v17 upgrade creates icon_sets', () async {
    _downgradeToV10(raw);
    expect(_hasTable(raw, 'icon_sets'), isFalse);

    final database = await openAndMigrate();

    expect(_hasTable(raw, 'icon_sets'), isTrue);
    expect(_columnsOf(raw, 'icon_sets'), contains('last_update_time'));
    expect(_userVersion(raw), 21);
    expect(await database.iconSetsDao.query().get(), isEmpty);
  });

  test(
    'the v17 upgrade adds last_update_time to an existing icon_sets',
    () async {
      raw.execute('ALTER TABLE icon_sets DROP COLUMN last_update_time');
      raw.execute('PRAGMA user_version = 16');

      final database = await openAndMigrate();

      expect(_columnsOf(raw, 'icon_sets'), contains('last_update_time'));
      expect(_userVersion(raw), 21);
      expect(await database.iconSetsDao.query().get(), isEmpty);
    },
  );

  test('the v18 upgrade moves group options into definition', () async {
    _downgradeToV17(raw);
    raw.execute(
      'INSERT INTO profiles (id, type, label, url, extend_type, '
      'auto_update_duration_millis, auto_update, selected_map, unfold_set) '
      "VALUES (3, 'custom', 'Mine', '', 'standard', 0, 0, '{}', '[]')",
    );
    raw.execute(
      'INSERT INTO proxy_groups (id, profile_id, name, type, proxies, use, '
      'url, interval, lazy, disable_u_d_p, strategy, empty_fallback, "order") '
      "VALUES (1, 3, 'Auto', 'load-balance', '[\"HK\"]', '[\"sub\"]', "
      "'https://cp.example', 300, 0, 1, 'round-robin', 'REJECT', 'a0'), "
      "(2, 3, 'Plain', 'select', NULL, NULL, NULL, NULL, NULL, NULL, NULL, "
      "NULL, 'a1')",
    );

    final database = await openAndMigrate();

    expect(_columnsOf(raw, 'proxy_groups'), isNot(contains('url')));
    expect(
      raw
          .select('SELECT definition FROM proxy_groups WHERE id = 2')
          .single['definition'],
      '{}',
    );
    final [auto, plain] = await database.proxyGroupsDao.query(3).get();
    expect(
      auto,
      const ProxyGroup(
        profileId: 3,
        id: 1,
        name: 'Auto',
        type: GroupType.LoadBalance,
        proxies: ['HK'],
        use: ['sub'],
        url: 'https://cp.example',
        interval: 300,
        lazy: false,
        disableUDP: true,
        strategy: LoadBalanceStrategy.roundRobin,
        emptyFallback: 'REJECT',
        order: 'a0',
      ),
    );
    expect(
      plain,
      const ProxyGroup(
        profileId: 3,
        id: 2,
        name: 'Plain',
        type: GroupType.Selector,
        order: 'a1',
      ),
    );
    expect(
      raw.select(
        "SELECT name FROM sqlite_master WHERE type='index' AND name=?",
        ['idx_proxy_groups_profile_order'],
      ),
      hasLength(1),
    );
  });

  test('the v19 upgrade adds age_secret_key to profiles', () async {
    _downgradeToV18(raw);
    raw.execute(
      'INSERT INTO profiles (id, type, label, url, extend_type, '
      'auto_update_duration_millis, auto_update, selected_map, unfold_set) '
      "VALUES (3, 'url', 'Sub', 'https://example.com/sub', 'standard', 0, 0, "
      "'{}', '[]')",
    );
    expect(_columnsOf(raw, 'profiles'), isNot(contains('age_secret_key')));

    final database = await openAndMigrate();

    expect(_columnsOf(raw, 'profiles'), contains('age_secret_key'));
    expect(_userVersion(raw), 21);
    expect(
      (await database.profilesDao.query().get()).single.ageSecretKey,
      isEmpty,
    );
  });

  test('the v20 upgrade adds empty_options to custom_proxies', () async {
    _downgradeToV19(raw);
    raw.execute(
      'INSERT INTO custom_proxies (id, definition) '
      '''VALUES (1, '{"name":"App","type":"ss"}')''',
    );
    expect(_columnsOf(raw, 'custom_proxies'), isNot(contains('empty_options')));

    final database = await openAndMigrate();

    expect(_columnsOf(raw, 'custom_proxies'), contains('empty_options'));
    expect(_userVersion(raw), 21);
    expect(
      (await database.customProxiesDao.query().get()).single.emptyOptions,
      isEmpty,
    );
  });

  test('the v21 upgrade creates ip_qualities', () async {
    _downgradeToV20(raw);
    expect(_hasTable(raw, 'ip_qualities'), isFalse);

    final database = await openAndMigrate();

    expect(_hasTable(raw, 'ip_qualities'), isTrue);
    expect(_userVersion(raw), 21);
    expect(await database.ipQualities.count.getSingle(), 0);
  });

  test(
    'a v17 user_version with definition already present still opens',
    () async {
      raw.execute(
        'INSERT INTO profiles (id, type, label, url, extend_type, '
        'auto_update_duration_millis, auto_update, selected_map, unfold_set) '
        "VALUES (3, 'custom', 'Mine', '', 'standard', 0, 0, '{}', '[]')",
      );
      raw.execute(
        'INSERT INTO proxy_groups (id, profile_id, name, type, definition) '
        '''VALUES (1, 3, 'Proxy', 'select', '{"hidden":true}')''',
      );
      raw.execute('PRAGMA user_version = 17');

      final database = await openAndMigrate();

      expect(_userVersion(raw), 21);
      expect(
        (await database.proxyGroupsDao.query(3).get()).single.hidden,
        isTrue,
      );
    },
  );

  test('an empty v1 rules table still reaches v2', () async {
    _downgradeToV1(raw);

    final database = await openAndMigrate();

    expect(_userVersion(raw), 21);
    expect(await database.customSelect('SELECT * FROM rules').get(), isEmpty);
  });

  test('opening a database already at v2 changes nothing', () async {
    final before = _columnsOf(raw, 'rules');

    await openAndMigrate();

    expect(_columnsOf(raw, 'rules'), before);
    expect(_userVersion(raw), 21);
    expect(_hasTable(raw, 'proxy_groups'), isTrue);
  });
}
