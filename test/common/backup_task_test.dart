import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drift/native.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/database/database.dart' as db;
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/l10n/l10n.dart';
import 'package:fl_clash/models/models.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

class _FakePathProvider extends PathProviderPlatform {
  final String root;

  _FakePathProvider(this.root);

  @override
  Future<String?> getTemporaryPath() async => root;

  @override
  Future<String?> getApplicationSupportPath() async => root;

  @override
  Future<String?> getApplicationCachePath() async => root;
}

/// Covers the backup, restore and legacy-migration half of `common/task.dart`.
///
/// The public entry points hand their work to a background isolate, which
/// cannot reach the mocked platform channels, so the tests drive the worker
/// functions the isolate calls. Those take every path as an argument, so each
/// test runs against its own temporary tree.
void main() {
  late Directory root;

  setUpAll(() async {
    root = Directory.systemTemp.createTempSync('backup_task_test');
    // File.copy does not create parent directories; in production these are the
    // already-existing temp and cache dirs the platform hands out.
    Directory(join(root.path, 'tmp')).createSync(recursive: true);
    Directory(join(root.path, 'archive')).createSync(recursive: true);
    PathProviderPlatform.instance = _FakePathProvider(root.path);
    // readBackupArchive reports an unusable archive through the localizations.
    await AppLocalizations.load(const Locale('en'));
  });

  tearDownAll(() {
    try {
      root.deleteSync(recursive: true);
    } catch (_) {}
  });

  Directory makeDir(String name) =>
      Directory(join(root.path, name, uniqueId))..createSync(recursive: true);

  File writeFile(String path, String content) => File(path)
    ..createSync(recursive: true)
    ..writeAsStringSync(content);

  group('shakeOrphanFiles', () {
    test('reports only the files whose name is not a live id', () {
      final profiles = makeDir('profiles');
      final scripts = makeDir('scripts');
      final providers = makeDir('providers');
      writeFile(join(profiles.path, '1.yaml'), 'keep');
      writeFile(join(profiles.path, '2.yaml'), 'drop');
      writeFile(join(scripts.path, '10.js'), 'keep');
      writeFile(join(scripts.path, '20.js'), 'drop');
      writeFile(join(providers.path, '1', 'proxies', 'abc'), 'keep');
      writeFile(join(providers.path, '2', 'proxies', 'abc'), 'drop');

      final orphans = shakeOrphanFiles(
        profileIds: [1],
        scriptIds: [10],
        profilesDirPath: profiles.path,
        providersDirPath: providers.path,
        scriptsDirPath: scripts.path,
      );

      expect(orphans.map(basename), unorderedEquals(['2.yaml', '20.js', '2']));
      expect(
        orphans.singleWhere((path) => basename(path) == '2'),
        join(providers.path, '2'),
      );
    });

    test('reports the whole provider directory a dead profile left behind', () {
      final providers = makeDir('providers');
      writeFile(join(providers.path, '3', 'proxies', 'abc'), 'drop');
      writeFile(join(providers.path, '3', 'rules', 'def'), 'drop');
      writeFile(join(providers.path, 'stray'), 'drop');

      final orphans = shakeOrphanFiles(
        profileIds: const [],
        scriptIds: const [],
        profilesDirPath: join(root.path, 'missing'),
        providersDirPath: providers.path,
        scriptsDirPath: join(root.path, 'missing'),
      );

      expect(
        orphans,
        unorderedEquals([
          join(providers.path, '3'),
          join(providers.path, 'stray'),
        ]),
      );
    });

    test('treats an unparsable file name as an orphan', () {
      final profiles = makeDir('profiles');
      writeFile(join(profiles.path, 'stray.yaml'), 'drop');

      final orphans = shakeOrphanFiles(
        profileIds: [1],
        scriptIds: const [],
        profilesDirPath: profiles.path,
        providersDirPath: join(root.path, 'missing'),
        scriptsDirPath: join(root.path, 'missing'),
      );

      expect(orphans.map(basename), ['stray.yaml']);
    });

    test('does not descend into the nested providers folder', () {
      final profiles = makeDir('profiles');
      final nested = Directory(join(profiles.path, 'providers'))
        ..createSync(recursive: true);
      writeFile(join(nested.path, '99.yaml'), 'not scanned here');

      final orphans = shakeOrphanFiles(
        profileIds: [1],
        scriptIds: const [],
        profilesDirPath: profiles.path,
        providersDirPath: join(root.path, 'missing'),
        scriptsDirPath: join(root.path, 'missing'),
      );

      expect(orphans, isEmpty);
    });

    test('ignores directories that do not exist', () {
      expect(
        shakeOrphanFiles(
          profileIds: const [],
          scriptIds: const [],
          profilesDirPath: join(root.path, 'nope'),
          providersDirPath: join(root.path, 'nope'),
          scriptsDirPath: join(root.path, 'nope'),
        ),
        isEmpty,
      );
    });
  });

  group('migrateLegacyConfig', () {
    late Directory source;
    late Directory target;

    setUp(() {
      source = makeDir('legacy_source');
      target = makeDir('legacy_target');
    });

    Map<String, Object?> legacyConfig({
      List<Object?> scripts = const [],
      List<Object?> rules = const [],
      List<Object?> profiles = const [],
      Map<String, Object?> extra = const {},
    }) => {'scripts': scripts, 'rules': rules, 'profiles': profiles, ...extra};

    test(
      'rewrites script ids and writes the content into the target',
      () async {
        final data = await migrateLegacyConfig(
          configMap: legacyConfig(
            scripts: [
              {'id': 'script-a', 'label': 'A', 'content': 'export default 1;'},
            ],
          ),
          sourcePath: source.path,
          targetPath: target.path,
        );

        final script = data.scripts.single;
        expect(script.label, 'A');
        expect(
          File(
            join(target.path, 'scripts', '${script.id}.js'),
          ).readAsStringSync(),
          'export default 1;',
        );
      },
    );

    test('skips a script entry that is missing a required field', () async {
      final data = await migrateLegacyConfig(
        configMap: legacyConfig(
          scripts: [
            {'id': 'no-content', 'label': 'A'},
            {'id': 'ok', 'label': 'B', 'content': 'body'},
          ],
        ),
        sourcePath: source.path,
        targetPath: target.path,
      );

      expect(data.scripts.map((item) => item.label), ['B']);
    });

    test('falls back to scriptProps when the scripts list is empty', () async {
      final data = await migrateLegacyConfig(
        configMap: legacyConfig(
          extra: {
            'scriptProps': {
              'scripts': [
                {'id': 'nested', 'label': 'Nested', 'content': 'body'},
              ],
            },
          },
        ),
        sourcePath: source.path,
        targetPath: target.path,
      );

      expect(data.scripts.map((item) => item.label), ['Nested']);
    });

    test('copies the profile file under its new id', () async {
      writeFile(join(source.path, 'profiles', 'old-1.yaml'), 'proxies: []');

      final data = await migrateLegacyConfig(
        configMap: legacyConfig(
          profiles: [
            {'id': 'old-1', 'label': 'Legacy', 'autoUpdateDuration': 0},
          ],
        ),
        sourcePath: source.path,
        targetPath: target.path,
      );

      final profile = data.profiles.single;
      expect(profile.label, 'Legacy');
      expect(
        File(
          join(target.path, 'profiles', '${profile.id}.yaml'),
        ).readAsStringSync(),
        'proxies: []',
      );
    });

    test('links added rules to the profile that declared them', () async {
      writeFile(join(source.path, 'profiles', 'p1.yaml'), '');

      final data = await migrateLegacyConfig(
        configMap: legacyConfig(
          profiles: [
            {
              'id': 'p1',
              'autoUpdateDuration': 0,
              'overwrite': {
                'type': 'standard',
                'standardOverwrite': {
                  'addedRules': [
                    {'id': 'r1', 'value': 'DOMAIN,example.com,DIRECT'},
                  ],
                },
              },
            },
          ],
        ),
        sourcePath: source.path,
        targetPath: target.path,
      );

      final profile = data.profiles.single;
      final rule = data.rules.single;
      expect(rule.content, 'example.com');
      final link = data.links.single;
      expect(link.profileId, profile.id);
      expect(link.ruleId, rule.id);
      expect(link.scene, RuleScene.added);
    });

    test(
      'keeps a disabled link only for a rule id it has already seen',
      () async {
        writeFile(join(source.path, 'profiles', 'p1.yaml'), '');

        final data = await migrateLegacyConfig(
          configMap: legacyConfig(
            profiles: [
              {
                'id': 'p1',
                'autoUpdateDuration': 0,
                'overwrite': {
                  'type': 'standard',
                  'standardOverwrite': {
                    'addedRules': [
                      {'id': 'r1', 'value': 'DOMAIN,example.com,DIRECT'},
                    ],
                    'disabledRuleIds': ['r1', 'never-seen'],
                  },
                },
              },
            ],
          ),
          sourcePath: source.path,
          targetPath: target.path,
        );

        final disabled = data.links
            .where((link) => link.scene == RuleScene.disabled)
            .toList();
        expect(disabled, hasLength(1));
        expect(disabled.single.ruleId, data.rules.single.id);
      },
    );

    test('points the profile at its remapped script id', () async {
      writeFile(join(source.path, 'profiles', 'p1.yaml'), '');

      final data = await migrateLegacyConfig(
        configMap: legacyConfig(
          scripts: [
            {'id': 's1', 'label': 'S', 'content': 'body'},
          ],
          profiles: [
            {
              'id': 'p1',
              'autoUpdateDuration': 0,
              'overwrite': {
                'type': 'script',
                'scriptOverwrite': {'scriptId': 's1'},
              },
            },
          ],
        ),
        sourcePath: source.path,
        targetPath: target.path,
      );

      expect(data.profiles.single.scriptId, data.scripts.single.id);
      expect(data.profiles.single.overwriteType, OverwriteType.script);
    });

    test('remaps currentProfileId and nulls it when there is none', () async {
      writeFile(join(source.path, 'profiles', 'p1.yaml'), '');
      final configMap = legacyConfig(
        profiles: [
          {'id': 'p1', 'autoUpdateDuration': 0},
        ],
        extra: {'currentProfileId': 'p1'},
      );

      final data = await migrateLegacyConfig(
        configMap: configMap,
        sourcePath: source.path,
        targetPath: target.path,
      );

      expect(data.configMap?['currentProfileId'], data.profiles.single.id);

      final without = await migrateLegacyConfig(
        configMap: legacyConfig(),
        sourcePath: source.path,
        targetPath: target.path,
      );
      expect(without.configMap?['currentProfileId'], isNull);
    });

    test('renames the config keys the current schema expects', () async {
      final data = await migrateLegacyConfig(
        configMap: legacyConfig(
          extra: {
            'accessControl': <String, Object?>{'acceptList': <String>[]},
            'isAccessControl': true,
            'vpnProps': <String, Object?>{},
            'dav': {'uri': 'https://dav.example'},
            'appSetting': {'recoveryStrategy': 'compatible'},
            'proxiesStyle': {'cardType': 'expand'},
          },
        ),
        sourcePath: source.path,
        targetPath: target.path,
      );

      final configMap = data.configMap!;
      final vpnProps = configMap['vpnProps']! as Map;
      expect((vpnProps['accessControl'] as Map)['enable'], isTrue);
      expect(vpnProps['accessControlProps'], vpnProps['accessControl']);
      expect((configMap['davProps'] as Map)['uri'], 'https://dav.example');
      expect(
        (configMap['appSettingProps'] as Map)['restoreStrategy'],
        'compatible',
      );
      expect(configMap['proxiesStyleProps'], configMap['proxiesStyle']);
    });

    test('skips a profile entry without an id', () async {
      final data = await migrateLegacyConfig(
        configMap: legacyConfig(
          profiles: [
            {'label': 'no id', 'autoUpdateDuration': 0},
          ],
        ),
        sourcePath: source.path,
        targetPath: target.path,
      );

      expect(data.profiles, isEmpty);
    });
  });

  group('backup and restore', () {
    late Directory home;
    late Directory restore;
    late String databasePath;

    setUp(() async {
      home = makeDir('home');
      restore = makeDir('restore');
      databasePath = join(home.path, 'database.sqlite');
    });

    /// Seeds a real database file with one row per table the restore reads.
    Future<void> seedDatabase() async {
      final database = db.Database(NativeDatabase(File(databasePath)));
      await database.profilesDao.putAll([
        const Profile(
          id: 1,
          label: 'Backed up',
          autoUpdateDuration: Duration.zero,
        ).toCompanion(),
      ]);
      await database.scriptsDao.setAll([
        Script(id: 2, label: 'Script', lastUpdateTime: DateTime(2026)),
      ]);
      await database.rulesDao.putProfileAddedRule(
        1,
        const Rule(id: 3, content: 'example.com', order: 'a'),
      );
      await database.close();
    }

    Future<String> backup({
      Map<String, dynamic> configMap = const {'version': 1},
      Iterable<String> fileNames = const ['1.yaml', '2.js'],
    }) {
      return writeBackupArchive(
        configMap: configMap,
        fileNames: fileNames,
        databasePath: databasePath,
        profilesDirPath: join(home.path, 'profiles'),
        scriptsDirPath: join(home.path, 'scripts'),
        zipFilePath: join(root.path, 'archive', '$uniqueId.zip'),
        tempDatabasePath: join(root.path, 'tmp', '$uniqueId.sqlite'),
        tempConfigPath: join(root.path, 'tmp', '$uniqueId.json'),
      );
    }

    test('the archive carries the database, the config and only the listed '
        'files', () async {
      await seedDatabase();
      writeFile(join(home.path, 'profiles', '1.yaml'), 'proxies: []');
      writeFile(join(home.path, 'profiles', '9.yaml'), 'not listed');
      writeFile(join(home.path, 'scripts', '2.js'), 'body');

      final archivePath = await backup();

      final names = ZipDecoder()
          .decodeStream(InputFileStream(archivePath))
          .files
          .map((file) => basename(file.name))
          .toSet();
      expect(names, containsAll([backupDatabaseName, configJsonName]));
      expect(names, contains('1.yaml'));
      expect(names, contains('2.js'));
      expect(names, isNot(contains('9.yaml')));
    });

    test('the temporary database and config copies are cleaned up', () async {
      await seedDatabase();
      final before = Directory(join(root.path, 'tmp'));

      await backup();

      final leftovers = before.existsSync()
          ? before.listSync().map((entity) => basename(entity.path))
          : <String>[];
      expect(leftovers, isEmpty);
    });

    test('restoring returns the rows and copies the files home', () async {
      await seedDatabase();
      writeFile(join(home.path, 'profiles', '1.yaml'), 'proxies: []');
      writeFile(join(home.path, 'scripts', '2.js'), 'body');
      final archivePath = await backup();
      final target = makeDir('restore_target');

      final data = await readBackupArchive(
        backupFilePath: archivePath,
        restoreDirPath: restore.path,
        homeDirPath: target.path,
      );

      expect(data.profiles.single.label, 'Backed up');
      expect(data.scripts.single.label, 'Script');
      expect(data.rules.single.content, 'example.com');
      expect(data.links.single.ruleId, 3);
      expect(data.configMap?['version'], 1);
      expect(
        File(join(target.path, 'profiles', '1.yaml')).readAsStringSync(),
        'proxies: []',
      );
      expect(
        File(join(target.path, 'scripts', '2.js')).readAsStringSync(),
        'body',
      );
    });

    test('a version 0 archive goes through the legacy migration', () async {
      await seedDatabase();
      writeFile(join(home.path, 'profiles', 'legacy.yaml'), 'proxies: []');
      final archivePath = await backup(
        configMap: {
          'version': 0,
          'profiles': [
            {'id': 'legacy', 'label': 'Old', 'autoUpdateDuration': 0},
          ],
        },
        fileNames: const ['legacy.yaml'],
      );
      final target = makeDir('restore_target');

      final data = await readBackupArchive(
        backupFilePath: archivePath,
        restoreDirPath: restore.path,
        homeDirPath: target.path,
      );

      final profile = data.profiles.single;
      expect(profile.label, 'Old');
      expect(
        profile.id,
        isNot(0),
        reason: 'the legacy string id must be replaced by a snowflake id',
      );
      expect(
        File(
          join(target.path, 'profiles', '${profile.id}.yaml'),
        ).readAsStringSync(),
        'proxies: []',
      );
    });

    test('an archive without a config document is rejected', () async {
      final archivePath = join(root.path, 'archive', '$uniqueId.zip');
      final encoder = ZipFileEncoder();
      encoder.create(archivePath);
      await encoder.addFile(
        writeFile(join(root.path, 'tmp', '$uniqueId.txt'), 'nothing'),
        'unrelated.txt',
      );
      unawaited(encoder.close());

      await expectLater(
        readBackupArchive(
          backupFilePath: archivePath,
          restoreDirPath: makeDir('restore').path,
          homeDirPath: makeDir('home').path,
        ),
        throwsA(
          isA<MessageException>().having(
            (error) => error.message,
            'message',
            currentAppLocalizations.invalidBackupFile,
          ),
        ),
      );
    });

    test('an archive without a database yields just the config', () async {
      final archivePath = join(root.path, 'archive', '$uniqueId.zip');
      final encoder = ZipFileEncoder();
      encoder.create(archivePath);
      await encoder.addFile(
        writeFile(
          join(root.path, 'tmp', '$uniqueId.json'),
          json.encode({'version': 1}),
        ),
        configJsonName,
      );
      unawaited(encoder.close());

      final data = await readBackupArchive(
        backupFilePath: archivePath,
        restoreDirPath: makeDir('restore').path,
        homeDirPath: makeDir('home').path,
      );

      expect(data.configMap?['version'], 1);
      expect(data.profiles, isEmpty);
      expect(data.scripts, isEmpty);
    });
  });
}
