import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/database/database.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';

Future<T> decodeJSONTask<T>(String data) async {
  return compute<String, T>(_decodeJSON, data);
}

Future<T> _decodeJSON<T>(String content) async {
  return json.decode(content);
}

Future<String> encodeJSONTask<T>(T data) async {
  return compute<T, String>(_encodeJSON, data);
}

Future<String> _encodeJSON<T>(T content) async {
  return json.encode(content);
}

Future<String> encodeYamlTask<T>(T data) async {
  return compute<T, String>(_encodeYaml, data);
}

Future<String> _encodeYaml<T>(T content) async {
  return yaml.encode(content);
}

Future<String> encodeMD5Task(String data) async {
  return compute<String, String>(_encodeMD5, data);
}

Future<String> _encodeMD5<T>(String content) async {
  return content.toMd5();
}

Future<List<Group>> toGroupsTask(ComputeGroupsState data) async {
  return compute<ComputeGroupsState, List<Group>>(buildGroups, data);
}

@visibleForTesting
Future<List<Group>> buildGroups(ComputeGroupsState state) async {
  final proxiesData = state.proxiesData;
  final all = proxiesData.all;
  final sortType = state.sortType;
  final delayMap = state.delayMap;
  final selectedMap = state.selectedMap;
  final defaultTestUrl = state.defaultTestUrl;
  final proxies = proxiesData.proxies;
  if (proxies.isEmpty) return [];
  final groups = <Group>[];
  for (final groupName in all) {
    final raw = proxies[groupName];
    if (raw is! Map) continue;
    if (!GroupTypeExtension.valueList.contains(raw['type'])) continue;
    final memberNames = raw['all'];
    final group = Map<String, dynamic>.from(raw);
    group['all'] = memberNames is List
        ? memberNames.map((name) => proxies[name]).nonNulls.toList()
        : const [];
    groups.add(Group.fromJson(group));
  }
  return computeSort(
    groups: groups,
    sortType: sortType,
    delayMap: delayMap,
    selectedMap: selectedMap,
    defaultTestUrl: defaultTestUrl,
  );
}

Future<ClashConfig> clashConfigTask(Map<String, dynamic> data) async {
  return compute<Map<String, dynamic>, ClashConfig>(buildClashConfig, data);
}

@visibleForTesting
ClashConfig buildClashConfig(Map<String, dynamic> configMap) {
  final clashConfig = ClashConfig.fromJson(configMap);
  final proxyTypeMap = <String, String>{};
  for (final proxy in clashConfig.proxies) {
    proxyTypeMap[proxy.name] = proxy.type;
  }
  for (final proxyGroup in clashConfig.proxyGroups) {
    proxyTypeMap[proxyGroup.name] = proxyGroup.type.value;
  }
  return clashConfig.copyWith(proxyTypeMap: proxyTypeMap);
}

Future<({String yaml, String md5})> makeRealProfileTask(
  MakeRealProfileState data,
) async {
  return compute<MakeRealProfileState, ({String yaml, String md5})>(
    _makeRealProfileTask,
    data,
  );
}

Future<({String yaml, String md5})> _makeRealProfileTask(
  MakeRealProfileState data,
) async {
  final rawConfig = Map.from(data.rawConfig);
  final realPatchConfig = data.realPatchConfig;
  final profilesPath = data.profilesPath;
  final profileId = data.profileId;
  final overrideDns = data.overrideDns;
  final addedRules = data.addedRules;
  final appendSystemDns = data.appendSystemDns;
  final defaultUA = data.defaultUA;
  String getProvidersFilePathInner(String type, String url) {
    return join(
      profilesPath,
      providersDirectoryName,
      profileId.toString(),
      type,
      url.toMd5(),
    );
  }

  void confineProviders(String section, String type) {
    final providers = rawConfig[section];
    if (providers is! Map) {
      return;
    }
    for (final name in providers.keys) {
      final provider = providers[name];
      if (provider is! Map || provider['type'] == 'inline') {
        continue;
      }
      final url = provider['url'];
      provider['path'] = getProvidersFilePathInner(
        type,
        url is String && url.isNotEmpty ? url : '$section/$name',
      );
    }
  }

  rawConfig['external-controller'] = realPatchConfig.externalController.value;
  rawConfig['external-ui'] = '';
  rawConfig['interface-name'] = '';
  rawConfig['external-ui-url'] = '';
  rawConfig['tcp-concurrent'] = realPatchConfig.tcpConcurrent;
  rawConfig['unified-delay'] = realPatchConfig.unifiedDelay;
  rawConfig['ipv6'] = realPatchConfig.ipv6;
  rawConfig['log-level'] = realPatchConfig.logLevel.name;
  rawConfig['port'] = 0;
  rawConfig['socks-port'] = 0;
  rawConfig['keep-alive-interval'] = realPatchConfig.keepAliveInterval;
  rawConfig['mixed-port'] = realPatchConfig.mixedPort;
  rawConfig['port'] = realPatchConfig.port;
  rawConfig['socks-port'] = realPatchConfig.socksPort;
  rawConfig['redir-port'] = realPatchConfig.redirPort;
  rawConfig['tproxy-port'] = realPatchConfig.tproxyPort;
  rawConfig['find-process-mode'] = realPatchConfig.findProcessMode.name;
  rawConfig['allow-lan'] = realPatchConfig.allowLan;
  rawConfig['mode'] = realPatchConfig.mode.name;
  if (rawConfig['tun'] == null) {
    rawConfig['tun'] = {};
  }
  rawConfig['tun']['enable'] = realPatchConfig.tun.enable;
  rawConfig['tun']['device'] = realPatchConfig.tun.device;
  rawConfig['tun']['dns-hijack'] = realPatchConfig.tun.dnsHijack;
  rawConfig['tun']['stack'] = realPatchConfig.tun.stack.name;
  rawConfig['tun']['route-address'] = realPatchConfig.tun.routeAddress;
  rawConfig['tun']['auto-route'] = realPatchConfig.tun.autoRoute;
  rawConfig['geodata-loader'] = realPatchConfig.geodataLoader.name;
  rawConfig['geo-auto-update'] = realPatchConfig.geoAutoUpdate;
  rawConfig['geo-update-interval'] = realPatchConfig.geoUpdateInterval;
  if (rawConfig['sniffer']?['sniff'] != null) {
    for (final value in (rawConfig['sniffer']?['sniff'] as Map).values) {
      if (value['ports'] != null && value['ports'] is List) {
        value['ports'] =
            value['ports']?.map((item) => item.toString()).toList() ?? [];
      }
    }
  }
  if (rawConfig['profile'] == null) {
    rawConfig['profile'] = {};
  }
  confineProviders('proxy-providers', proxiesProviderDirectoryName);
  confineProviders('rule-providers', rulesProviderDirectoryName);
  rawConfig['profile']['store-selected'] = false;
  rawConfig['geox-url'] = realPatchConfig.geoXUrl.raw;
  rawConfig['global-ua'] = realPatchConfig.globalUa ?? defaultUA;
  if (rawConfig['hosts'] == null) {
    rawConfig['hosts'] = {};
  }
  for (final host in realPatchConfig.hosts.entries) {
    rawConfig['hosts'][host.key] = host.value.splitByMultipleSeparators;
  }
  if (rawConfig['dns'] == null) {
    rawConfig['dns'] = {};
  }
  final isEnableDns = rawConfig['dns']['enable'] == true;
  const systemDns = 'system://';
  if (overrideDns || !isEnableDns) {
    final dns = switch (!isEnableDns) {
      true => realPatchConfig.dns.copyWith(
        nameserver: [...realPatchConfig.dns.nameserver, systemDns],
      ),
      false => realPatchConfig.dns,
    };
    rawConfig['dns'] = dns.toJson();
    rawConfig['dns']['nameserver-policy'] = {};
    for (final entry in dns.nameserverPolicy.entries) {
      rawConfig['dns']['nameserver-policy'][entry.key] =
          entry.value.splitByMultipleSeparators;
    }
  }
  if (appendSystemDns) {
    final List<String> nameserver = List<String>.from(
      rawConfig['dns']['nameserver'] ?? [],
    );
    if (!nameserver.contains(systemDns)) {
      rawConfig['dns']['nameserver'] = [...nameserver, systemDns];
    }
  }
  List<String> rules = [];
  if (data.rules.isEmpty) {
    if (rawConfig['rules'] != null) {
      rules = List<String>.from(rawConfig['rules']);
    }
    if (addedRules.isNotEmpty) {
      final hasMatchPlaceholder = addedRules.any(
        (item) => item.ruleTarget?.toUpperCase() == 'MATCH',
      );
      String? replacementTarget;

      if (hasMatchPlaceholder) {
        for (int i = rules.length - 1; i >= 0; i--) {
          final parsed = Rule.parse(rules[i]);
          if (parsed.ruleAction == RuleAction.MATCH) {
            final target = parsed.ruleTarget;
            if (target != null && target.isNotEmpty) {
              replacementTarget = target;
              break;
            }
          }
        }
      }
      final List<String> finalAddedRules;

      if (replacementTarget?.isNotEmpty == true) {
        finalAddedRules = [];
        for (int i = 0; i < addedRules.length; i++) {
          final parsed = addedRules[i];
          if (parsed.ruleTarget?.toUpperCase() == 'MATCH') {
            finalAddedRules.add(
              parsed.copyWith(ruleTarget: replacementTarget).rawValue,
            );
          } else {
            finalAddedRules.add(addedRules[i].rawValue);
          }
        }
      } else {
        finalAddedRules = addedRules.map((e) => e.rawValue).toList();
      }
      rules = [...finalAddedRules, ...rules];
    }
  } else {
    rules = data.rules.map((item) => item.rawValue).toList();
  }
  if (data.proxyGroups.isNotEmpty) {
    rawConfig['proxy-groups'] = data.proxyGroups;
  }
  rawConfig['rules'] = rules;
  final yaml = await _encodeYaml(Map<String, dynamic>.from(rawConfig));
  return (yaml: yaml, md5: yaml.toMd5());
}

Future<List<String>> shakingProfileTask(
  ({Iterable<int> profileIds, Iterable<int> scriptIds}) data,
) async {
  return compute<
    ({
      Iterable<int> profileIds,
      Iterable<int> scriptIds,
      RootIsolateToken token,
    }),
    List<String>
  >(_shakingProfileTask, (
    profileIds: data.profileIds,
    scriptIds: data.scriptIds,
    token: RootIsolateToken.instance!,
  ));
}

Future<List<String>> _shakingProfileTask(
  ({Iterable<int> profileIds, Iterable<int> scriptIds, RootIsolateToken token})
  data,
) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(data.token);
  return shakeOrphanFiles(
    profileIds: data.profileIds,
    scriptIds: data.scriptIds,
    profilesDirPath: await appPath.profilesPath,
    providersDirPath: await appPath.getProvidersRootPath(),
    scriptsDirPath: await appPath.scriptsDirPath,
  );
}

@visibleForTesting
List<String> shakeOrphanFiles({
  required Iterable<int> profileIds,
  required Iterable<int> scriptIds,
  required String profilesDirPath,
  required String providersDirPath,
  required String scriptsDirPath,
}) {
  final List<String> targets = [];
  void scanDirectory(
    Directory dir,
    Iterable<int> baseNames, {
    bool includeDirectories = false,
  }) {
    if (!dir.existsSync()) return;
    final entities = dir.listSync(recursive: false, followLinks: false);

    for (final entity in entities) {
      final selected =
          entity is File || (includeDirectories && entity is Directory);
      if (!selected) {
        continue;
      }
      final id = basenameWithoutExtension(entity.path);
      if (!baseNames.contains(int.tryParse(id))) {
        targets.add(entity.path);
      }
    }
  }

  scanDirectory(Directory(profilesDirPath), profileIds);
  scanDirectory(
    Directory(providersDirPath),
    profileIds,
    includeDirectories: true,
  );
  scanDirectory(Directory(scriptsDirPath), scriptIds);
  return targets;
}

Future<String> encodeLogsTask(List<Log> data) async {
  return compute<List<Log>, String>(_encodeLogsTask, data);
}

Future<String> _encodeLogsTask(List<Log> data) async {
  final logsRaw = data.map((item) => item.toString());
  final logsRawString = logsRaw.join('\n');
  return logsRawString;
}

Future<MigrationData> oldToNowTask(Map<String, Object?> data) async {
  final homeDir = await appPath.homeDirPath;
  return compute<
    ({Map<String, Object?> configMap, String sourcePath, String targetPath}),
    MigrationData
  >(_oldToNowTask, (configMap: data, sourcePath: homeDir, targetPath: homeDir));
}

Future<MigrationData> _oldToNowTask(
  ({Map<String, Object?> configMap, String sourcePath, String targetPath}) data,
) {
  return migrateLegacyConfig(
    configMap: data.configMap,
    sourcePath: data.sourcePath,
    targetPath: data.targetPath,
  );
}

@visibleForTesting
Future<MigrationData> migrateLegacyConfig({
  required Map<String, Object?> configMap,
  required String sourcePath,
  required String targetPath,
}) async {
  final accessControlMap = configMap['accessControl'];
  final isAccessControl = configMap['isAccessControl'];
  if (accessControlMap != null) {
    (accessControlMap as Map)['enable'] = isAccessControl;
    if (configMap['vpnProps'] != null) {
      final vpnPropsRaw = configMap['vpnProps'] as Map;
      vpnPropsRaw['accessControl'] = accessControlMap;
    }
  }
  if (configMap['vpnProps'] != null) {
    final vpnPropsRaw = configMap['vpnProps'] as Map;
    vpnPropsRaw['accessControlProps'] = vpnPropsRaw['accessControl'];
  }
  configMap['davProps'] = configMap['dav'];
  final appSettingProps =
      configMap['appSetting'] as Map<String, dynamic>? ?? {};
  appSettingProps['restoreStrategy'] = appSettingProps['recoveryStrategy'];
  configMap['appSettingProps'] = appSettingProps;
  configMap['proxiesStyleProps'] = configMap['proxiesStyle'];
  List rawScripts = configMap['scripts'] as List<dynamic>? ?? [];
  if (rawScripts.isEmpty) {
    final scriptPropsJson = configMap['scriptProps'] as Map<String, dynamic>?;
    if (scriptPropsJson != null) {
      rawScripts = scriptPropsJson['scripts'] as List<dynamic>? ?? [];
    }
  }
  final Map<String, int> idMap = {};
  final List<Script> scripts = [];
  for (final rawScript in rawScripts) {
    final id = rawScript['id'] as String?;
    final content = rawScript['content'] as String?;
    final label = rawScript['label'] as String?;
    if (id == null || content == null || label == null) {
      continue;
    }
    final newId = idMap.updateCacheValue(rawScript['id'], () => snowflake.id);
    final path = _getScriptPath(targetPath, newId.toString());
    final file = File(path);
    await file.safeWriteAsString(content);
    scripts.add(
      Script(id: newId, label: label, lastUpdateTime: DateTime.now()),
    );
  }
  final List rawRules = configMap['rules'] as List<dynamic>? ?? [];
  final List<Rule> rules = [];
  final List<ProfileRuleLink> links = [];
  for (final rawRule in rawRules) {
    final id = idMap.updateCacheValue(rawRule['id'], () => snowflake.id);
    rawRule['id'] = id;
    final value = rawRule['value'] ?? '';
    rules.add(Rule.parse(value, id: id));
    links.add(ProfileRuleLink(ruleId: id));
  }
  final List rawProfiles = configMap['profiles'] as List<dynamic>? ?? [];
  final List<Profile> profiles = [];
  for (final rawProfile in rawProfiles) {
    final rawId = rawProfile['id'] as String?;
    if (rawId == null) {
      continue;
    }
    final profileId = idMap.updateCacheValue(rawId, () => snowflake.id);
    rawProfile['id'] = profileId;
    final overwrite = rawProfile['overwrite'] as Map?;
    if (overwrite != null) {
      final standardOverwrite = overwrite['standardOverwrite'] as Map?;
      if (standardOverwrite != null) {
        final addedRules = standardOverwrite['addedRules'] as List? ?? [];
        for (final addRule in addedRules) {
          final id = idMap.updateCacheValue(addRule['id'], () => snowflake.id);
          final value = addRule['value'] ?? '';
          rules.add(Rule.parse(value, id: id));
          links.add(
            ProfileRuleLink(
              profileId: profileId,
              ruleId: id,
              scene: RuleScene.added,
            ),
          );
        }
        final disabledRuleIds = standardOverwrite['disabledRuleIds'] as List?;
        if (disabledRuleIds != null) {
          for (final disabledRuleId in disabledRuleIds) {
            final newDisabledRuleId = idMap[disabledRuleId];
            if (newDisabledRuleId != null) {
              links.add(
                ProfileRuleLink(
                  profileId: profileId,
                  ruleId: newDisabledRuleId,
                  scene: RuleScene.disabled,
                ),
              );
            }
          }
        }
      }
      final scriptOverwrite = overwrite['scriptOverwrite'] as Map?;
      if (scriptOverwrite != null) {
        final scriptId = scriptOverwrite['scriptId'] as String?;
        rawProfile['scriptId'] = scriptId != null ? idMap[scriptId] : null;
      }
      rawProfile['overwriteType'] = overwrite['type'];
    }

    final sourceFile = File(_getProfilePath(sourcePath, rawId));
    final targetFilePath = _getProfilePath(targetPath, profileId.toString());
    await sourceFile.safeCopy(targetFilePath);
    profiles.add(Profile.fromJson(rawProfile));
  }
  final currentProfileId = configMap['currentProfileId'];
  configMap['currentProfileId'] = currentProfileId != null
      ? idMap[currentProfileId]
      : null;
  return MigrationData(
    configMap: configMap,
    profiles: profiles,
    rules: rules,
    scripts: scripts,
    links: links,
  );
}

Future<String> backupTask(
  Map<String, dynamic> configMap,
  Iterable<String> fileNames,
) async {
  return compute<
    ({
      Map<String, dynamic> configMap,
      Iterable<String> fileNames,
      RootIsolateToken token,
    }),
    String
  >(_backupTask, (
    configMap: configMap,
    fileNames: fileNames,
    token: RootIsolateToken.instance!,
  ));
}

Future<String> _backupTask<T>(
  ({
    Map<String, dynamic> configMap,
    Iterable<String> fileNames,
    RootIsolateToken token,
  })
  args,
) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(args.token);
  final tempPath = await appPath.tempPath;
  final prefix = 'backup$uniqueId';
  return writeBackupArchive(
    configMap: args.configMap,
    fileNames: args.fileNames,
    databasePath: await appPath.databasePath,
    profilesDirPath: await appPath.profilesPath,
    scriptsDirPath: await appPath.scriptsDirPath,
    zipFilePath: join(tempPath, '$prefix.zip'),
    tempDatabasePath: join(tempPath, '$prefix.db'),
    tempConfigPath: join(tempPath, '$prefix.json'),
  );
}

@visibleForTesting
Future<String> writeBackupArchive({
  required Map<String, dynamic> configMap,
  required Iterable<String> fileNames,
  required String databasePath,
  required String profilesDirPath,
  required String scriptsDirPath,
  required String zipFilePath,
  required String tempDatabasePath,
  required String tempConfigPath,
}) async {
  final configStr = json.encode(configMap);
  final profilesDir = Directory(profilesDirPath);
  final scriptsDir = Directory(scriptsDirPath);
  final tempDBFile = File(tempDatabasePath);
  final tempConfigFile = File(tempConfigPath);
  final dbFile = File(databasePath);
  if (await dbFile.exists()) {
    await dbFile.copy(tempDBFile.path);
  }
  final encoder = ZipFileEncoder();
  encoder.create(zipFilePath);
  await tempConfigFile.writeAsString(configStr);
  await encoder.addFile(tempDBFile, backupDatabaseName);
  await encoder.addFile(tempConfigFile, configJsonName);
  ZipFileOperation keepListed(FileSystemEntity entity, double _) {
    if (!fileNames.contains(basename(entity.path))) {
      return ZipFileOperation.skip;
    }
    return ZipFileOperation.include;
  }

  if (await profilesDir.exists()) {
    await encoder.addDirectory(profilesDir, filter: keepListed);
  }
  if (await scriptsDir.exists()) {
    await encoder.addDirectory(scriptsDir, filter: keepListed);
  }
  await encoder.close();
  await tempConfigFile.safeDelete();
  await tempDBFile.safeDelete();
  return zipFilePath;
}

Future<MigrationData> restoreTask() async {
  return compute<RootIsolateToken, MigrationData>(
    _restoreTask,
    RootIsolateToken.instance!,
  );
}

Future<MigrationData> _restoreTask(RootIsolateToken token) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(token);
  return readBackupArchive(
    backupFilePath: await appPath.backupFilePath,
    restoreDirPath: await appPath.restoreDirPath,
    homeDirPath: await appPath.homeDirPath,
  );
}

/// Resolves the archive entry [name] against the directory it is unpacked into,
/// or returns null when the entry would land outside it.
///
/// `posix.normalize` was doing this on its own and it does not: it collapses
/// `a/../b`, but a name that starts with `../` normalizes to itself and an
/// absolute one stays absolute, so either writes wherever the archive asks. A
/// backup file is untrusted input — it is whatever the user picked off disk.
String? _restoreEntryPath(String restoreDirPath, String name) {
  final normalized = posix.normalize(name.replaceAll('\\', '/'));
  if (normalized.isEmpty ||
      posix.isAbsolute(normalized) ||
      normalized == '..' ||
      normalized.startsWith('../')) {
    return null;
  }
  final outPath = normalize(join(restoreDirPath, normalized));
  if (!isWithin(restoreDirPath, outPath)) {
    return null;
  }
  return outPath;
}

@visibleForTesting
Future<MigrationData> readBackupArchive({
  required String backupFilePath,
  required String restoreDirPath,
  required String homeDirPath,
}) async {
  final zipDecoder = ZipDecoder();
  final input = InputFileStream(backupFilePath);
  final archive = zipDecoder.decodeStream(input);
  final dir = Directory(restoreDirPath);
  await dir.create(recursive: true);
  for (final file in archive.files) {
    final outPath = _restoreEntryPath(restoreDirPath, file.name);
    if (outPath == null) {
      continue;
    }
    final outputStream = OutputFileStream(outPath);
    file.writeContent(outputStream);
    await outputStream.close();
  }
  await input.close();
  final restoreConfigFile = File(join(restoreDirPath, configJsonName));
  if (!await restoreConfigFile.exists()) {
    throw MessageException(currentAppLocalizations.invalidBackupFile);
  }
  final restoreConfigMap =
      json.decode(await restoreConfigFile.readAsString())
          as Map<String, Object?>?;
  final version = restoreConfigMap?['version'] ?? 0;
  MigrationData migrationData = MigrationData(configMap: restoreConfigMap);
  if (version == 0 && restoreConfigMap != null) {
    migrationData = await migrateLegacyConfig(
      configMap: restoreConfigMap,
      sourcePath: restoreDirPath,
      targetPath: homeDirPath,
    );
    return migrationData;
  }
  final backupDatabaseFile = File(join(restoreDirPath, backupDatabaseName));
  if (!await backupDatabaseFile.exists()) {
    return migrationData;
  }
  final database = Database(
    driftDatabase(
      name: 'database',
      native: DriftNativeOptions(
        databaseDirectory: () async => Directory(restoreDirPath),
      ),
    ),
  );
  try {
    final results = await Future.wait([
      database.profilesDao.query().get(),
      database.scriptsDao.query().get(),
      database.rules.all().map((item) => item.toRule()).get(),
      database.profileRuleLinks.all().map((item) => item.toLink()).get(),
      database.proxyGroups.all().map((item) => item.toProxyGroup()).get(),
    ]);
    final profiles = results[0].cast<Profile>();
    final scripts = results[1].cast<Script>();
    final profilesMigration = profiles.map(
      (item) => (
        from: _getProfilePath(restoreDirPath, item.id.toString()),
        to: _getProfilePath(homeDirPath, item.id.toString()),
      ),
    );
    final scriptsMigration = scripts.map(
      (item) => (
        from: _getScriptPath(restoreDirPath, item.id.toString()),
        to: _getScriptPath(homeDirPath, item.id.toString()),
      ),
    );
    await _copyWithMapList([...profilesMigration, ...scriptsMigration]);
    return migrationData.copyWith(
      profiles: profiles,
      scripts: scripts,
      rules: results[2].cast<Rule>(),
      links: results[3].cast<ProfileRuleLink>(),
      proxyGroups: results[4].cast<ProxyGroup>(),
    );
  } finally {
    await database.close();
  }
}

Future<void> _copyWithMapList(
  List<({String from, String to})> copyMapList,
) async {
  await Future.wait(
    copyMapList.map((item) => File(item.from).safeCopy(item.to)).toList(),
  );
}

String _getScriptPath(String root, String fileName) {
  return join(root, 'scripts', '$fileName.js');
}

String _getProfilePath(String root, String fileName) {
  return join(root, 'profiles', '$fileName.yaml');
}

Future<List<T>> mapListTask<T, S>(List<S> results, T Function(S) mapper) async {
  return compute<({List<S> results, T Function(S) mapper}), List<T>>(
    _mapListTask,
    (results: results, mapper: mapper),
  );
}

Future<List<T>> _mapListTask<T, S>(
  ({List<S> results, T Function(S) mapper}) args,
) async {
  return args.results.map((item) => args.mapper(item)).toList();
}
