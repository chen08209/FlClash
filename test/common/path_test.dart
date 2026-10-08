import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:yaml/yaml.dart';

class _FakePathProvider extends PathProviderPlatform {
  _FakePathProvider(this.root);

  final String root;

  @override
  Future<String?> getTemporaryPath() async => root;

  @override
  Future<String?> getApplicationSupportPath() async => root;

  @override
  Future<String?> getApplicationCachePath() async => root;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory root;

  setUpAll(() {
    root = Directory.systemTemp.createTempSync('path_test');
    PathProviderPlatform.instance = _FakePathProvider(root.path);
  });

  tearDownAll(() {
    if (root.existsSync()) {
      root.deleteSync(recursive: true);
    }
  });

  test('provider directories match the paths handed to the core', () async {
    const proxiesUrl = 'https://example.com/a.yaml';
    const rulesUrl = 'https://example.com/b.yaml';
    final proxiesDir = await appPath.getProviderDirPath(
      7,
      proxiesProviderDirectoryName,
    );
    final rulesDir = await appPath.getProviderDirPath(
      7,
      rulesProviderDirectoryName,
    );

    final result = await makeRealProfileTask(
      MakeRealProfileState(
        profilesPath: await appPath.profilesPath,
        profileId: 7,
        rawConfig: {
          'proxy-providers': {
            'a': {'type': 'http', 'url': proxiesUrl},
          },
          'rule-providers': {
            'b': {'type': 'http', 'url': rulesUrl},
          },
        },
        realPatchConfig: const PatchClashConfig(),
        overrideDns: false,
        overrideNtp: false,
        appendSystemDns: false,
        proxyGroups: const [],
        rules: const [],
        addedRules: const [],
        defaultUA: 'FlClash',
      ),
    );
    final config = loadYaml(result.yaml) as YamlMap;

    expect(
      config['proxy-providers']['a']['path'],
      join(proxiesDir, 'a@$proxiesUrl'.toMd5()),
    );
    expect(
      config['rule-providers']['b']['path'],
      join(rulesDir, 'b@$rulesUrl'.toMd5()),
    );
  });

  test('confines a provider path the profile tried to choose', () async {
    final proxiesDir = await appPath.getProviderDirPath(
      7,
      proxiesProviderDirectoryName,
    );
    final rulesDir = await appPath.getProviderDirPath(
      7,
      rulesProviderDirectoryName,
    );

    final result = await makeRealProfileTask(
      MakeRealProfileState(
        profilesPath: await appPath.profilesPath,
        profileId: 7,
        rawConfig: {
          'proxy-providers': {
            'escape': {'type': 'file', 'path': '../../../../config.yaml'},
            'urlless': {'type': 'http', 'path': 'cache.db'},
            'literal': {
              'type': 'inline',
              'payload': ['DIRECT'],
            },
          },
          'rule-providers': {
            'sneak': {'type': 'file', 'path': '/etc/hosts'},
          },
        },
        realPatchConfig: const PatchClashConfig(),
        overrideDns: false,
        overrideNtp: false,
        appendSystemDns: false,
        proxyGroups: const [],
        rules: const [],
        addedRules: const [],
        defaultUA: 'FlClash',
      ),
    );
    final config = loadYaml(result.yaml) as YamlMap;

    expect(
      config['proxy-providers']['escape']['path'],
      join(proxiesDir, 'proxy-providers/escape'.toMd5()),
    );
    expect(
      config['proxy-providers']['urlless']['path'],
      join(proxiesDir, 'proxy-providers/urlless'.toMd5()),
    );
    expect(config['proxy-providers']['literal']['path'], isNull);
    expect(
      config['rule-providers']['sneak']['path'],
      join(rulesDir, 'rule-providers/sneak'.toMd5()),
    );
  });

  test('survives a provider section that is not a map', () async {
    final result = await makeRealProfileTask(
      MakeRealProfileState(
        profilesPath: await appPath.profilesPath,
        profileId: 7,
        rawConfig: {
          'proxy-providers': ['not-a-map'],
          'rule-providers': {
            'broken': ['also-not-a-map'],
          },
        },
        realPatchConfig: const PatchClashConfig(),
        overrideDns: false,
        overrideNtp: false,
        appendSystemDns: false,
        proxyGroups: const [],
        rules: const [],
        addedRules: const [],
        defaultUA: 'FlClash',
      ),
    );

    expect(result.yaml, isNotEmpty);
  });

  test('ensureProviderDirs creates both provider directories', () async {
    await appPath.ensureProviderDirs(9);

    for (final type in const [
      proxiesProviderDirectoryName,
      rulesProviderDirectoryName,
    ]) {
      expect(
        Directory(await appPath.getProviderDirPath(9, type)).existsSync(),
        isTrue,
      );
    }

    await expectLater(appPath.ensureProviderDirs(9), completes);
  });

  group('portable mode', () {
    final savedExecutableDirectory = AppPath.executableDirectory;
    final savedSupportDirectory = AppPath.supportDirectory;
    final savedTemporaryDirectory = AppPath.temporaryDirectory;
    final savedCacheDirectory = AppPath.cacheDirectory;

    late Directory portableRoot;
    late Directory appDir;
    late Directory systemDir;

    setUp(() {
      portableRoot = Directory.systemTemp.createTempSync('portable_path_test');
      appDir = Directory(join(portableRoot.path, 'app'))
        ..createSync(recursive: true);
      systemDir = Directory(join(portableRoot.path, 'system'))
        ..createSync(recursive: true);
      AppPath.executableDirectory = () => appDir.path;
      AppPath.supportDirectory = () async => systemDir;
      AppPath.temporaryDirectory = () async => portableRoot;
      AppPath.cacheDirectory = () async => portableRoot;
    });

    tearDown(() {
      AppPath.executableDirectory = savedExecutableDirectory;
      AppPath.supportDirectory = savedSupportDirectory;
      AppPath.temporaryDirectory = savedTemporaryDirectory;
      AppPath.cacheDirectory = savedCacheDirectory;
      if (portableRoot.existsSync()) {
        portableRoot.deleteSync(recursive: true);
      }
    });

    Directory createPortableDir() {
      return Directory(join(appDir.path, portableDirectoryName))
        ..createSync(recursive: true);
    }

    test('a config directory beside the executable is portable', () async {
      final configDir = createPortableDir();
      final path = AppPath.forTest();

      expect(path.isPortable, isTrue);
      expect(await path.homeDirPath, configDir.path);
      expect(await path.databasePath, join(configDir.path, 'database.sqlite'));
      expect(
        await path.sharedPreferencesPath,
        join(configDir.path, 'shared_preferences.json'),
      );
    });

    test('without one it keeps the system data directory', () async {
      final path = AppPath.forTest();

      expect(path.isPortable, isFalse);
      expect(await path.homeDirPath, systemDir.path);
    });

    test('the first run brings the installed data along', () async {
      final configDir = createPortableDir();
      File(join(systemDir.path, 'database.sqlite')).writeAsBytesSync([1, 2, 3]);
      File(join(systemDir.path, 'database.sqlite-wal')).writeAsBytesSync([4]);
      File(join(systemDir.path, 'config.yaml')).writeAsStringSync('mode: rule');
      File(join(systemDir.path, 'shared_preferences.json')).writeAsStringSync(
        '{"flutter.version":1}',
      );
      Directory(join(systemDir.path, 'profiles')).createSync();
      File(join(systemDir.path, 'profiles', 'default.yaml')).writeAsStringSync(
        'proxies: []',
      );
      Directory(join(systemDir.path, 'scripts')).createSync();
      File(join(systemDir.path, 'scripts', 'patch.js')).writeAsStringSync('//');

      final path = AppPath.forTest();
      expect(path.isPortable, isTrue);
      // The copy runs behind dataDir, so wait for the directory it resolves to.
      await path.homeDirPath;

      expect(
        File(join(configDir.path, 'database.sqlite')).readAsBytesSync(),
        [1, 2, 3],
        reason: 'a legacy install that crashed still holds rows in its log',
      );
      expect(
        File(join(configDir.path, 'database.sqlite-wal')).readAsBytesSync(),
        [4],
      );
      expect(File(join(configDir.path, 'config.yaml')).existsSync(), isTrue);
      expect(
        File(join(configDir.path, 'shared_preferences.json')).existsSync(),
        isTrue,
      );
      expect(
        File(join(configDir.path, 'profiles', 'default.yaml')).existsSync(),
        isTrue,
      );
      expect(
        File(join(configDir.path, 'scripts', 'patch.js')).existsSync(),
        isTrue,
      );
    });

    test('a later run keeps what the folder already holds', () async {
      final configDir = createPortableDir();
      File(join(configDir.path, 'database.sqlite')).writeAsBytesSync([9, 9]);
      File(join(systemDir.path, 'database.sqlite')).writeAsBytesSync([1, 2, 3]);

      expect(AppPath.forTest().isPortable, isTrue);

      expect(
        File(join(configDir.path, 'database.sqlite')).readAsBytesSync(),
        [9, 9],
      );
    });

    test('an unusable system directory fails the path, not the app', () async {
      createPortableDir();
      AppPath.supportDirectory = () async => throw const FileSystemException(
        'no support directory',
      );

      final path = AppPath.forTest();

      // The directory beside the executable decides this on its own, so it
      // never depends on the system one resolving.
      expect(path.isPortable, isTrue);
      await expectLater(path.homeDirPath, throwsA(isA<FileSystemException>()));
    });
  });
}
