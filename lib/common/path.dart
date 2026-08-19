import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class AppPath {
  static AppPath? _instance;

  @visibleForTesting
  static String? appDirPathOverride;

  @visibleForTesting
  static Directory? legacyDataDirOverride;

  Completer<Directory> dataDir = Completer();
  late final Future<Directory?> _downloadDir = getDownloadsDirectory();
  Completer<Directory> tempDir = Completer();
  Completer<Directory> cacheDir = Completer();
  late String appDirPath;
  bool isPortable = false;

  @visibleForTesting
  static void resetInstanceForTest({String? appDirPath, Directory? legacyDir}) {
    _instance = null;
    appDirPathOverride = appDirPath;
    legacyDataDirOverride = legacyDir;
  }

  AppPath._internal() {
    appDirPath = appDirPathOverride ?? join(dirname(Platform.resolvedExecutable));
    _initDataDir();
    _initTempDir();
    _initCacheDir();
  }

  factory AppPath() {
    _instance ??= AppPath._internal();
    return _instance!;
  }

  Future<void> _initDataDir() async {
    if (Platform.isWindows || Platform.isMacOS || Platform.isLinux) {
      final portableConfigDir = Directory(join(appDirPath, 'config'));
      if (await portableConfigDir.exists()) {
        isPortable = true;
        await _migrateLegacyData(portableConfigDir);
        dataDir.complete(portableConfigDir);
        return;
      }
    }
    final dir = await getApplicationSupportDirectory();
    dataDir.complete(dir);
  }

  Future<void> _initCacheDir() async {
    await dataDir.future;
    if (isPortable) {
      cacheDir.complete(Directory(join(await homeDirPath, '.cache')));
      return;
    }
    final dir = await getApplicationCacheDirectory();
    cacheDir.complete(dir);
  }

  Future<void> _initTempDir() async {
    await dataDir.future;
    if (isPortable) {
      final portableTmpDir = Directory(join(await homeDirPath, 'tmp'));
      if (await portableTmpDir.exists()) {
        tempDir.complete(portableTmpDir);
        return;
      }
    }
    final dir = await getTemporaryDirectory();
    tempDir.complete(dir);
  }

  Future<void> _migrateLegacyData(Directory portableConfigDir) async {
    final legacyDir = _legacyDataDir();
    if (legacyDir == null || legacyDir.path == portableConfigDir.path) return;
    if (!await legacyDir.exists()) return;
    await _copyMissingFile('shared_preferences.json', legacyDir, portableConfigDir);
    await _copyMissingFile('database.sqlite', legacyDir, portableConfigDir);
    await _copyMissingFile('config.yaml', legacyDir, portableConfigDir);
    await _copyMissingFile('shared.json', legacyDir, portableConfigDir);
    await _copyMissingDir('profiles', legacyDir, portableConfigDir);
    await _copyMissingDir('scripts', legacyDir, portableConfigDir);
  }

  Directory? _legacyDataDir() {
    if (legacyDataDirOverride != null) {
      return legacyDataDirOverride;
    }
    if (Platform.isWindows) {
      final appData = Platform.environment['APPDATA'];
      if (appData == null || appData.isEmpty) return null;
      return Directory(join(appData, 'com.follow', 'clash'));
    }
    if (Platform.isMacOS) {
      final home = Platform.environment['HOME'];
      if (home == null || home.isEmpty) return null;
      return Directory(
        join(home, 'Library', 'Application Support', 'com.follow.clash'),
      );
    }
    if (Platform.isLinux) {
      final dataHome = Platform.environment['XDG_DATA_HOME'];
      if (dataHome != null && dataHome.isNotEmpty) {
        return Directory(join(dataHome, 'com.follow.clash'));
      }
      final home = Platform.environment['HOME'];
      if (home == null || home.isEmpty) return null;
      return Directory(join(home, '.local', 'share', 'com.follow.clash'));
    }
    return null;
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
      await target.create(recursive: true);
      await source.copy(target.path);
    } catch (e) {
      commonPrint.log(
        'Failed to migrate legacy file $name: $e',
        logLevel: LogLevel.warning,
      );
    }
  }

  Future<void> _copyMissingDir(
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
        final relativePath = relative(entity.path, from: source.path);
        final destinationPath = join(target.path, relativePath);
        if (entity is Directory) {
          await Directory(destinationPath).create(recursive: true);
        } else if (entity is File) {
          final destination = File(destinationPath);
          await destination.parent.create(recursive: true);
          await entity.copy(destinationPath);
        }
      }
    } catch (e) {
      commonPrint.log(
        'Failed to migrate legacy directory $name: $e',
        logLevel: LogLevel.warning,
      );
    }
  }

  String get executableExtension {
    return system.isWindows ? '.exe' : '';
  }

  String get executableDirPath {
    final currentExecutablePath = Platform.resolvedExecutable;
    return dirname(currentExecutablePath);
  }

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

  Future<String> get backupFilePath async {
    final mHomeDirPath = await homeDirPath;
    return join(mHomeDirPath, 'backup.zip');
  }

  Future<String> get restoreDirPath async {
    final mHomeDirPath = await homeDirPath;
    return join(mHomeDirPath, 'restore');
  }

  Future<String> get tempFilePath async {
    final mTempDir = await tempDir.future;
    return join(mTempDir.path, 'temp${utils.id}');
  }

  Future<String> get lockFilePath async {
    final homeDirPath = await appPath.homeDirPath;
    return join(homeDirPath, 'FlClash.lock');
  }

  Future<String> get configFilePath async {
    final mHomeDirPath = await homeDirPath;
    return join(mHomeDirPath, 'config.yaml');
  }

  Future<String> get sharedFilePath async {
    final mHomeDirPath = await homeDirPath;
    return join(mHomeDirPath, 'shared.json');
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

  Future<String> getIconsCacheDir() async {
    final directory = await cacheDir.future;
    return join(directory.path, 'icons');
  }

  Future<String> getProvidersRootPath() async {
    final directory = await profilesPath;
    return join(directory, 'providers');
  }

  Future<String> getProvidersDirPath(String id) async {
    final directory = await profilesPath;
    return join(directory, 'providers', id);
  }

  Future<String> getProvidersFilePath(
    String id,
    String type,
    String url,
  ) async {
    final directory = await profilesPath;
    return join(directory, 'providers', id, type, url.toMd5());
  }

  Future<String> get tempPath async {
    final directory = await tempDir.future;
    return directory.path;
  }
}

final appPath = AppPath();
