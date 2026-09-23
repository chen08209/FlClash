import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/common/migration.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';

enum BackupFailure { invalid, newerVersion }

final class BackupException implements Exception {
  final BackupFailure failure;

  const BackupException(this.failure);

  @override
  String toString() => 'BackupException(${failure.name})';
}

/// Archive entries mirror the data directory, so an entry name is also the
/// file's path relative to the home directory.
abstract final class BackupEntries {
  static String profile(Object id) => '$profilesDirectoryName/$id.yaml';

  static String script(Object id) => 'scripts/$id.js';

  static String provider(ClashProvider provider) =>
      '$providersDirectoryName/${providerCacheDirectoryName(provider.kind)}/'
      '${provider.fileName}';

  /// A remote provider's cache belongs to the Core and downloads again.
  static List<String> of({
    required Iterable<int> profileIds,
    required Iterable<int> scriptIds,
    required Iterable<ClashProvider> providers,
  }) {
    return [
      ...profileIds.map(profile),
      ...scriptIds.map(script),
      ...providers.where((item) => !item.isRemote).map(provider),
    ];
  }

  static List<String> ofData(MigrationData data) {
    return of(
      profileIds: data.profiles.map((item) => item.id),
      scriptIds: data.scripts.map((item) => item.id),
      providers: data.clashProviders,
    );
  }

  static String resolve(String root, String entry) {
    return joinAll([root, ...posix.split(entry)]);
  }
}

typedef BackupArchiveRequest = ({
  String archivePath,
  Map<String, Object?> configMap,
  String databaseSnapshotPath,
  String homeDirPath,
  List<String> entries,
});

typedef RestoreArchiveRequest = ({String archivePath, String stagingDirPath});

Future<void> backupTask(BackupArchiveRequest request) {
  return compute(_backupTask, request);
}

Future<void> _backupTask(BackupArchiveRequest request) {
  return writeBackupArchive(
    archivePath: request.archivePath,
    configMap: request.configMap,
    databaseSnapshotPath: request.databaseSnapshotPath,
    homeDirPath: request.homeDirPath,
    entries: request.entries,
  );
}

Future<MigrationData> restoreTask(RestoreArchiveRequest request) {
  return compute(_restoreTask, request);
}

Future<MigrationData> _restoreTask(RestoreArchiveRequest request) {
  return readBackupArchive(
    archivePath: request.archivePath,
    stagingDirPath: request.stagingDirPath,
  );
}

@visibleForTesting
Future<void> writeBackupArchive({
  required String archivePath,
  required Map<String, Object?> configMap,
  required String databaseSnapshotPath,
  required String homeDirPath,
  required Iterable<String> entries,
}) async {
  final encoder = ZipFileEncoder()..create(archivePath);
  try {
    encoder.addArchiveFile(
      ArchiveFile.string(configJsonName, json.encode(configMap)),
    );
    await encoder.addFile(File(databaseSnapshotPath), backupDatabaseName);
    for (final entry in entries) {
      final file = File(BackupEntries.resolve(homeDirPath, entry));
      if (await file.exists()) {
        await encoder.addFile(file, entry);
      }
    }
  } finally {
    await encoder.close();
  }
}

/// Writes nothing outside [stagingDirPath]; the files the result names are left
/// there at their [BackupEntries] paths.
@visibleForTesting
Future<MigrationData> readBackupArchive({
  required String archivePath,
  required String stagingDirPath,
}) async {
  await _extract(archivePath, stagingDirPath);
  final configFile = File(join(stagingDirPath, configJsonName));
  if (!await configFile.exists()) {
    throw const BackupException(BackupFailure.invalid);
  }
  final configMap = _decodeConfig(await configFile.readAsString());
  final version = configMap['version'] ?? 0;
  if (version is! int) {
    throw const BackupException(BackupFailure.invalid);
  }
  if (version > Migration.currentVersion) {
    throw const BackupException(BackupFailure.newerVersion);
  }
  if (version == 0) {
    return migrateLegacyConfig(
      configMap: configMap,
      sourcePath: stagingDirPath,
      targetPath: stagingDirPath,
    );
  }
  final databaseFile = File(join(stagingDirPath, backupDatabaseName));
  if (!await databaseFile.exists()) {
    return MigrationData(configMap: configMap);
  }
  final schemaVersion = await _readSchemaVersion(databaseFile);
  final database = Database(
    driftDatabase(
      name: basenameWithoutExtension(backupDatabaseName),
      // Left unset, drift asks path_provider for a temp directory, and this
      // isolate has no platform channel to answer it.
      native: DriftNativeOptions(
        databaseDirectory: () async => Directory(stagingDirPath),
        tempDirectoryPath: () async => stagingDirPath,
      ),
    ),
  );
  try {
    if (schemaVersion > database.schemaVersion) {
      throw const BackupException(BackupFailure.newerVersion);
    }
    final results = await Future.wait([
      database.profilesDao.query().get(),
      database.scriptsDao.query().get(),
      database.rules.all().map((item) => item.toRule()).get(),
      database.profileRuleLinks.all().map((item) => item.toLink()).get(),
      database.proxyGroups.all().map((item) => item.toProxyGroup()).get(),
      database.clashProvidersDao.queryAll().get(),
      database.customProxies.all().map((item) => item.toCustomProxy()).get(),
    ]);
    return MigrationData(
      configMap: configMap,
      profiles: results[0].cast<Profile>(),
      scripts: results[1].cast<Script>(),
      rules: results[2].cast<Rule>(),
      links: results[3].cast<ProfileRuleLink>(),
      proxyGroups: results[4].cast<ProxyGroup>(),
      clashProviders: results[5].cast<ClashProvider>(),
      customProxies: results[6].cast<CustomProxy>(),
    );
  } finally {
    await database.close();
  }
}

Future<void> _extract(String archivePath, String stagingDirPath) async {
  await Directory(stagingDirPath).create(recursive: true);
  final input = InputFileStream(archivePath);
  try {
    final Archive archive;
    try {
      archive = ZipDecoder().decodeStream(input);
    } on Exception {
      throw const BackupException(BackupFailure.invalid);
    }
    for (final file in archive.files) {
      if (!file.isFile) {
        continue;
      }
      final outPath = _stagedEntryPath(stagingDirPath, file.name);
      if (outPath == null) {
        continue;
      }
      await Directory(dirname(outPath)).create(recursive: true);
      final output = OutputFileStream(outPath);
      try {
        file.writeContent(output);
      } finally {
        await output.close();
      }
    }
  } finally {
    await input.close();
  }
}

/// `posix.normalize` collapses `a/../b`, but a name that starts with `../`
/// normalizes to itself and an absolute one stays absolute, so either would
/// write wherever the archive asks. A backup file is untrusted input.
String? _stagedEntryPath(String stagingDirPath, String name) {
  final normalized = posix.normalize(name.replaceAll('\\', '/'));
  if (normalized.isEmpty ||
      posix.isAbsolute(normalized) ||
      normalized == '..' ||
      normalized.startsWith('../')) {
    return null;
  }
  final outPath = normalize(BackupEntries.resolve(stagingDirPath, normalized));
  if (!isWithin(stagingDirPath, outPath)) {
    return null;
  }
  return outPath;
}

Map<String, Object?> _decodeConfig(String source) {
  final Object? decoded;
  try {
    decoded = json.decode(source);
  } on FormatException {
    throw const BackupException(BackupFailure.invalid);
  }
  if (decoded is! Map<String, Object?>) {
    throw const BackupException(BackupFailure.invalid);
  }
  return decoded;
}

/// Opening the database through drift would already run its migrations, so the
/// version is read from the file header: SQLite keeps `user_version` as a
/// big-endian integer at byte 60.
Future<int> _readSchemaVersion(File databaseFile) async {
  final handle = await databaseFile.open();
  try {
    final header = await handle.read(64);
    if (header.length < 64) {
      throw const BackupException(BackupFailure.invalid);
    }
    return ByteData.sublistView(header).getInt32(60);
  } finally {
    await handle.close();
  }
}
