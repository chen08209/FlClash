import 'dart:async';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class AppPath {
  static AppPath? _instance;
  late ResolveOnce<Directory> _dataDir;
  late ResolveOnce<Directory?> _downloadDir;
  late ResolveOnce<Directory> _tempDir;
  Completer<Directory> cacheDir = Completer();

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

  AppPath._internal() {
    _bind();
  }

  @visibleForTesting
  Future<void> rebind() async {
    cacheDir = Completer();
    _bind();
    await Future.wait([_dataDir.value, _downloadDir.value, _tempDir.value]);
  }

  void _bind() {
    _dataDir = ResolveOnce(supportDirectory);
    _downloadDir = ResolveOnce(downloadDirectory);
    _tempDir = ResolveOnce(temporaryDirectory);
    cacheDirectory().then(cacheDir.complete);
  }

  factory AppPath() {
    _instance ??= AppPath._internal();
    return _instance!;
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
    final directory = await _downloadDir.value;
    return directory?.path ?? await homeDirPath;
  }

  Future<String> get homeDirPath async {
    final directory = await _dataDir.value;
    return directory.path;
  }

  Future<String> get databasePath async {
    final mHomeDirPath = await homeDirPath;
    return join(mHomeDirPath, 'database.sqlite');
  }

  Future<String> get tempFilePath async {
    final mTempDir = await _tempDir.value;
    return join(mTempDir.path, 'temp$uniqueId');
  }

  /// On Android the app's external downloads directory, the one the system
  /// download manager can write to.
  Future<String> get updateDirPath async {
    final directory = system.isAndroid
        ? await downloadDirPath
        : (await cacheDir.future).path;
    return join(directory, 'update');
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
    final directory = await _dataDir.value;
    return join(directory.path, 'shared_preferences.json');
  }

  Future<String> get profilesPath async {
    final directory = await _dataDir.value;
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
    return scriptPathIn(await scriptsDirPath, fileName);
  }

  static String scriptPathIn(String scriptsDir, String fileName) {
    return join(scriptsDir, '$fileName.js');
  }

  Future<String> get mitmModulesDirPath async {
    return join(await homeDirPath, mitmDirectoryName, mitmModulesDirectoryName);
  }

  Future<String> get mitmResourcesDirPath async {
    return join(
      await homeDirPath,
      mitmDirectoryName,
      mitmResourcesDirectoryName,
    );
  }

  Future<String> get providerCacheRootPath async {
    final directory = await homeDirPath;
    return join(directory, providersDirectoryName);
  }

  Future<String> get ruleProviderCacheDirPath async {
    return join(await providerCacheRootPath, rulesProviderDirectoryName);
  }

  Future<String> getProviderCachePath(String fileName) async {
    return join(await ruleProviderCacheDirPath, fileName);
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
    final directory = await _tempDir.value;
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
