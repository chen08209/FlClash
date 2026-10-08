import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

const portableDirectoryName = 'config';

/// The sqlite sidecars travel with the database: a legacy install that did not
/// shut down cleanly still holds committed rows in its write-ahead log.
const _migratedFiles = [
  'shared_preferences.json',
  'database.sqlite',
  'database.sqlite-wal',
  'database.sqlite-shm',
  'config.yaml',
];

/// The Core's own `<home>/providers` rule cache is left behind: it is a cache,
/// and the Core downloads every rule set again on the first portable run.
const _migratedDirectories = [profilesDirectoryName, 'scripts'];

class AppPath {
  static AppPath? _instance;
  Completer<Directory> dataDir = Completer();
  late final Future<Directory?> _downloadDir = downloadDirectory();
  Completer<Directory> tempDir = Completer();
  Completer<Directory> cacheDir = Completer();
  late String appDirPath;

  /// Whether a `config` directory sits beside the executable. This is a single
  /// stat rather than an awaited lookup because `Preferences` reads it while
  /// picking its store, and a real filesystem round trip there would stall
  /// every widget test, whose fake clock never advances one.
  late final bool isPortable = _detectPortable();

  @visibleForTesting
  static Future<Directory> Function() supportDirectory =
      getApplicationSupportDirectory;

  @visibleForTesting
  static Future<Directory> Function() temporaryDirectory =
      getTemporaryDirectory;

  @visibleForTesting
  static Future<Directory> Function() cacheDirectory =
      getApplicationCacheDirectory;

  @visibleForTesting
  static Future<Directory?> Function() downloadDirectory =
      getDownloadsDirectory;

  @visibleForTesting
  static String Function() executableDirectory =
      () => dirname(Platform.resolvedExecutable);

  AppPath._internal() {
    appDirPath = executableDirectory();
    temporaryDirectory().then((value) {
      tempDir.complete(value);
    });
    cacheDirectory().then((value) {
      cacheDir.complete(value);
    });
    unawaited(_initDataDir());
  }

  factory AppPath() {
    _instance ??= AppPath._internal();
    return _instance!;
  }

  @visibleForTesting
  factory AppPath.forTest() => AppPath._internal();

  bool _detectPortable() {
    return system.isDesktop &&
        Directory(join(appDirPath, portableDirectoryName)).existsSync();
  }

  /// A `config` directory beside the executable makes the build portable, and
  /// the Windows zip ships an empty one; the first run copies the data in.
  ///
  /// Nothing here may reject or leave [dataDir] pending: every path getter
  /// awaits it, so a rejected [dataDir] would take the whole app down and a
  /// pending one would hang it silently on the splash.
  Future<void> _initDataDir() async {
    final portableConfigDir = Directory(
      join(appDirPath, portableDirectoryName),
    );
    if (isPortable) {
      try {
        final systemDir = await supportDirectory();
        if (!equals(systemDir.path, portableConfigDir.path)) {
          await _migrateSystemData(systemDir, portableConfigDir);
        }
        dataDir.complete(portableConfigDir);
        return;
      } catch (e) {
        // Every copy below guards itself and only logs, so this is the one
        // place a portable folder can be abandoned: losing its contents must
        // never cost the user their settings.
        commonPrint.log(
          'Falling back to the system data directory: $e',
          logLevel: LogLevel.warning,
        );
      }
    }
    try {
      dataDir.complete(await supportDirectory());
    } catch (e) {
      commonPrint.log(
        'Failed to resolve the application support directory: $e',
        logLevel: LogLevel.warning,
      );
      dataDir.completeError(e, StackTrace.current);
    }
  }

  Future<void> _migrateSystemData(Directory from, Directory to) async {
    if (!await from.exists()) return;
    for (final name in _migratedFiles) {
      await _copyMissingFile(name, from, to);
    }
    for (final name in _migratedDirectories) {
      await _copyMissingDirectory(name, from, to);
    }
  }

  Future<void> _copyMissingFile(
    String name,
    Directory from,
    Directory to,
  ) async {
    try {
      final source = File(join(from.path, name));
      if (!await source.exists()) return;
      final target = File(join(to.path, name));
      if (await target.exists()) return;
      await source.safeCopy(target.path);
    } catch (e) {
      commonPrint.log(
        'Failed to migrate $name into the portable directory: $e',
        logLevel: LogLevel.warning,
      );
    }
  }

  Future<void> _copyMissingDirectory(
    String name,
    Directory from,
    Directory to,
  ) async {
    try {
      final source = Directory(join(from.path, name));
      if (!await source.exists()) return;
      final target = Directory(join(to.path, name));
      if (await target.exists()) return;
      await target.create(recursive: true);
      await for (final entity in source.list(
        recursive: true,
        followLinks: false,
      )) {
        final destination = join(
          target.path,
          relative(entity.path, from: source.path),
        );
        if (entity is Directory) {
          await Directory(destination).create(recursive: true);
        } else if (entity is File) {
          await entity.safeCopy(destination);
        }
      }
    } catch (e) {
      commonPrint.log(
        'Failed to migrate the $name directory into the portable directory: $e',
        logLevel: LogLevel.warning,
      );
    }
  }

  String get executableExtension {
    return system.isWindows ? '.exe' : '';
  }

  String get executableDirPath => appDirPath;

  String get corePath {
    return join(executableDirPath, 'FlClashCore$executableExtension');
  }

  String get helperPath {
    return join(executableDirPath, '$appHelperService$executableExtension');
  }

  Future<String> get downloadDirPath async {
    final directory = await _downloadDir;
    return directory?.path ?? await homeDirPath;
  }

  Future<String> get homeDirPath async {
    final directory = await dataDir.future;
    return directory.path;
  }

  Future<String> get databasePath async {
    final mHomeDirPath = await homeDirPath;
    return join(mHomeDirPath, 'database.sqlite');
  }

  Future<String> get tempFilePath async {
    final mTempDir = await tempDir.future;
    return join(mTempDir.path, 'temp$uniqueId');
  }

  Future<String> get lockFilePath async {
    final homeDirPath = await appPath.homeDirPath;
    return join(homeDirPath, 'FlClash.lock');
  }

  Future<String> get configFilePath async {
    final mHomeDirPath = await homeDirPath;
    return join(mHomeDirPath, 'config.yaml');
  }

  Future<String> get sharedPreferencesPath async {
    final directory = await dataDir.future;
    return join(directory.path, 'shared_preferences.json');
  }

  Future<String> get profilesPath async {
    final directory = await dataDir.future;
    return join(directory.path, profilesDirectoryName);
  }

  Future<String> getProfilePath(String fileName) async {
    return join(await profilesPath, '$fileName.yaml');
  }

  Future<String> get scriptsDirPath async {
    final path = await homeDirPath;
    return join(path, 'scripts');
  }

  Future<String> getScriptPath(String fileName) async {
    final path = await scriptsDirPath;
    return join(path, '$fileName.js');
  }

  Future<String> get providerCacheRootPath async {
    final directory = await homeDirPath;
    return join(directory, providersDirectoryName);
  }

  Future<String> getProviderCachePath(
    ProviderKind kind,
    String fileName,
  ) async {
    return join(
      await providerCacheRootPath,
      providerCacheDirectoryName(kind),
      fileName,
    );
  }

  Future<String> getProvidersRootPath() async {
    final directory = await profilesPath;
    return join(directory, providersDirectoryName);
  }

  Future<String> getProviderDirPath(int profileId, String type) async {
    final directory = await getProvidersRootPath();
    return join(directory, profileId.toString(), type);
  }

  Future<void> ensureProviderDirs(int profileId) async {
    for (final type in const [
      proxiesProviderDirectoryName,
      rulesProviderDirectoryName,
    ]) {
      final directory = Directory(await getProviderDirPath(profileId, type));
      if (await directory.exists()) {
        continue;
      }
      await directory.create(recursive: true);
    }
  }

  Future<String> get tempPath async {
    final directory = await tempDir.future;
    return directory.path;
  }
}

final appPath = AppPath();

String getBackupFileName() {
  return '${appName}_backup_${DateTime.now().show}.zip';
}

String get logFileName {
  return '${appName}_${DateTime.now().show}.log';
}
