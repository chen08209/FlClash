import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/boot_record.dart';
import 'package:fl_clash/common/constant.dart';
import 'package:fl_clash/common/path.dart';
import 'package:fl_clash/common/preferences.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _sharedState = SharedState(
  stopTip: 'stop',
  startTip: 'start',
  localNetworkTip: 'local',
  currentProfileName: 'profile',
  stopText: 'stopped',
  onlyStatisticsProxy: true,
  crashlytics: false,
);

const _bootRecord = BootRecord(
  stage: BootStage.starting,
  profileId: 5,
  startedAt: 111,
  failureCount: 1,
  lastFailedProfileId: 4,
  handledExitAt: 99,
);

const _config = Config(
  themeProps: defaultThemeProps,
  currentProfileId: 42,
  overrideDns: true,
  excludeSSIDs: ['home'],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final savedSupportDirectory = AppPath.supportDirectory;
  final savedExecutableDirectory = AppPath.executableDirectory;
  final savedTemporaryDirectory = AppPath.temporaryDirectory;
  final savedCacheDirectory = AppPath.cacheDirectory;
  late Directory hostDir;

  setUpAll(() {
    hostDir = Directory.systemTemp.createTempSync('preferences_host');
    AppPath.supportDirectory = () async => hostDir;
    AppPath.executableDirectory = () => hostDir.path;
    // Constructing AppPath starts every directory lookup, and an unmocked one
    // rejects after the test that built it has already finished.
    AppPath.temporaryDirectory = () async => hostDir;
    AppPath.cacheDirectory = () async => hostDir;
  });

  tearDownAll(() {
    AppPath.supportDirectory = savedSupportDirectory;
    AppPath.executableDirectory = savedExecutableDirectory;
    AppPath.temporaryDirectory = savedTemporaryDirectory;
    AppPath.cacheDirectory = savedCacheDirectory;
    if (hostDir.existsSync()) {
      hostDir.deleteSync(recursive: true);
    }
  });

  group('the file a portable build keeps its settings in', () {
    late Directory dir;
    late String storagePath;

    setUp(() {
      dir = Directory.systemTemp.createTempSync('preferences_file_test');
      storagePath = join(dir.path, 'shared_preferences.json');
    });

    tearDown(() {
      if (dir.existsSync()) {
        dir.deleteSync(recursive: true);
      }
    });

    Future<void> writeStorage(Map<String, Object?> data) {
      return File(storagePath).writeAsString(jsonEncode(data));
    }

    Map<String, Object?> readStorage() {
      final content = File(storagePath).readAsStringSync();
      return jsonDecode(content) as Map<String, Object?>;
    }

    test('starts empty when the file is not there yet', () async {
      final prefs = Preferences.createForTest(path: storagePath);

      expect(await prefs.isInit, isTrue);
      expect(await prefs.getVersion(), 0);
      expect(await prefs.getConfig(), isNull);
    });

    test('round-trips a version and a config through the file', () async {
      final prefs = Preferences.createForTest(path: storagePath);

      expect(await prefs.saveConfig(_config), isTrue);
      await prefs.setVersion(7);

      final reloaded = Preferences.createForTest(path: storagePath);
      final restored = await reloaded.getConfig();

      expect(await reloaded.getVersion(), 7);
      expect(restored, isNotNull);
      expect(restored!.currentProfileId, 42);
      expect(restored.overrideDns, isTrue);
      expect(restored.excludeSSIDs, ['home']);
    });

    test('reads a file the platform plugin wrote', () async {
      await writeStorage({
        'flutter.version': 2,
        'flutter.config': jsonEncode(_config),
      });

      final prefs = Preferences.createForTest(path: storagePath);

      expect(await prefs.getVersion(), 2);
      expect(await prefs.getConfig(), isNotNull);
    });

    test('keeps writing the format the plugin reads', () async {
      await writeStorage({'flutter.version': 2});
      final prefs = Preferences.createForTest(path: storagePath);

      await prefs.setVersion(3);

      expect(readStorage(), {'flutter.version': 3});
    });

    test('reports an unreadable file as a store that never opened', () async {
      await File(storagePath).writeAsString('not json');

      expect(
        await Preferences.createForTest(path: storagePath).isInit,
        isFalse,
      );
    });

    test('returns null for a config that is not a map', () async {
      await writeStorage({configKey: '123'});

      expect(
        await Preferences.createForTest(path: storagePath).getConfigMap(),
        isNull,
      );
    });

    test('clears only the clash config entry', () async {
      await writeStorage({
        configKey: jsonEncode(_config),
        clashConfigKey: jsonEncode({'mode': 'rule'}),
        'version': 3,
      });
      final prefs = Preferences.createForTest(path: storagePath);

      expect(await prefs.getClashConfigMap(), {'mode': 'rule'});

      await prefs.clearClashConfig();

      expect(await prefs.getClashConfigMap(), isNull);
      expect(await prefs.getVersion(), 3);
      expect(await prefs.getConfig(), isNotNull);
    });

    test('writes every entry back as one JSON object', () async {
      final prefs = Preferences.createForTest(path: storagePath);

      await prefs.setVersion(9);
      await prefs.saveBootRecord(_bootRecord);

      expect(readStorage(), {
        'flutter.version': 9,
        'flutter.$bootRecordKey': jsonEncode(_bootRecord),
      });
    });

    test('empties every entry it holds', () async {
      final prefs = Preferences.createForTest(path: storagePath);
      await prefs.setVersion(9);
      await prefs.saveBootRecord(_bootRecord);
      expect(await prefs.getBootRecord(), _bootRecord);

      await prefs.clearPreferences();

      final cleared = Preferences.createForTest(path: storagePath);
      expect(await cleared.getVersion(), 0);
      expect(await cleared.getBootRecord(), isNull);
    });

    test('returns null for a boot record that is not JSON', () async {
      await writeStorage({bootRecordKey: 'not json'});

      expect(
        await Preferences.createForTest(path: storagePath).getBootRecord(),
        isNull,
      );
    });
  });

  group('the store every other install uses', () {
    late SharedPreferences store;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      store = await SharedPreferences.getInstance();
      await store.clear();
    });

    test('an empty store still counts as open', () async {
      expect(await Preferences.createForTest().isInit, isTrue);
    });

    test('writes a version through to the plugin', () async {
      final prefs = Preferences.createForTest();

      await prefs.setVersion(5);

      expect(store.getInt('version'), 5);
      expect(await Preferences.createForTest().getVersion(), 5);
    });

    test('writes the shared state the android side reads back', () async {
      final prefs = Preferences.createForTest();

      await prefs.saveShareState(_sharedState);

      final raw = store.getString('sharedState');
      expect(raw, isNotNull);
      expect(
        SharedState.fromJson(json.decode(raw!) as Map<String, Object?>),
        _sharedState,
      );
    });

    test('empties every entry it loaded', () async {
      final prefs = Preferences.createForTest();
      await prefs.setVersion(4);

      await prefs.clearPreferences();

      expect(await prefs.getVersion(), 0);
      expect(store.getInt('version'), isNull);
    });

    test('leaves a key written behind its back alone', () async {
      final prefs = Preferences.createForTest();
      await prefs.setVersion(4);
      await store.setString('foreign', 'value');

      await prefs.clearPreferences();

      expect(store.getString('foreign'), 'value');
      expect(store.getInt('version'), isNull);
    });
  });

  test('the app singleton round-trips a config', () async {
    SharedPreferences.setMockInitialValues({});
    await preferences.clearPreferences();

    expect(await preferences.saveConfig(_config), isTrue);
    expect((await preferences.getConfig())?.currentProfileId, 42);
  });
}
