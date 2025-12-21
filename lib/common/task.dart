import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:fl_clash/state.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart';

Future<T> decodeJSONTask<T>(String data) async {
  return await compute<String, T>(_decodeJSON, data);
}

Future<T> _decodeJSON<T>(String content) async {
  return json.decode(content);
}

Future<String> encodeJSONTask<T>(T data) async {
  return await compute<T, String>(_encodeJSON, data);
}

Future<String> _encodeJSON<T>(T content) async {
  return json.encode(content);
}

Future<List<Script>> oldScriptsToScriptsTask(List<OldScript> oldScripts) async {
  return await compute<List<OldScript>, List<Script>>(
    _oldScriptsToScriptsTask,
    oldScripts,
  );
}

Future<List<Script>> _oldScriptsToScriptsTask(
  List<OldScript> oldScripts,
) async {
  final List<Script> scripts = [];
  for (final oldScript in oldScripts) {
    final path = await appPath.getScriptPath(oldScript.id);
    final file = File(path);
    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString(oldScript.content);
      scripts.add(
        Script(
          id: oldScript.id,
          label: oldScript.label,
          lastUpdateTime: DateTime.now(),
        ),
      );
    }
  }
  return scripts;
}

Future<String> encodeYamlTask<T>(T data) async {
  return await compute<T, String>(_encodeYaml, data);
}

Future<String> _encodeYaml<T>(T content) async {
  return yaml.encode(content);
}

Future<List<Group>> toGroupsTask(ComputeGroupsState data) async {
  return await compute<ComputeGroupsState, List<Group>>(_toGroupsTask, data);
}

Future<List<Group>> _toGroupsTask(ComputeGroupsState state) async {
  final proxies = state.proxies;
  final sortType = state.sortType;
  final delayMap = state.delayMap;
  final selectedMap = state.selectedMap;
  final defaultTestUrl = state.defaultTestUrl;
  if (proxies.isEmpty) return [];
  final groupNames = [
    UsedProxy.GLOBAL.name,
    ...(proxies[UsedProxy.GLOBAL.name]['all'] as List).where((e) {
      final proxy = proxies[e] ?? {};
      return GroupTypeExtension.valueList.contains(proxy['type']);
    }),
  ];
  final groupsRaw = groupNames.map((groupName) {
    final group = proxies[groupName];
    group['all'] = ((group['all'] ?? []) as List)
        .map((name) => proxies[name])
        .where((proxy) => proxy != null)
        .toList();
    return group;
  }).toList();
  final groups = groupsRaw.map((e) => Group.fromJson(e)).toList();
  return computeSort(
    groups: groups,
    sortType: sortType,
    delayMap: delayMap,
    selectedMap: selectedMap,
    defaultTestUrl: defaultTestUrl,
  );
}

Future<Map<String, dynamic>> makeRealProfileTask(
  MakeRealProfileState data,
) async {
  return await compute<MakeRealProfileState, Map<String, dynamic>>(
    _makeRealProfileTask,
    data,
  );
}

Future<Map<String, dynamic>> _makeRealProfileTask(
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
    return join(profilesPath, 'providers', profileId, type, url.toMd5());
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
  if (rawConfig['proxy-providers'] != null) {
    final proxyProviders = rawConfig['proxy-providers'] as Map;
    for (final key in proxyProviders.keys) {
      final proxyProvider = proxyProviders[key];
      if (proxyProvider['type'] != 'http') {
        continue;
      }
      if (proxyProvider['url'] != null) {
        proxyProvider['path'] = getProvidersFilePathInner(
          'proxies',
          proxyProvider['url'],
        );
      }
    }
  }
  if (rawConfig['rule-providers'] != null) {
    final ruleProviders = rawConfig['rule-providers'] as Map;
    for (final key in ruleProviders.keys) {
      final ruleProvider = ruleProviders[key];
      if (ruleProvider['type'] != 'http') {
        continue;
      }
      if (ruleProvider['url'] != null) {
        ruleProvider['path'] = getProvidersFilePathInner(
          'rules',
          ruleProvider['url'],
        );
      }
    }
  }
  rawConfig['profile']['store-selected'] = false;
  rawConfig['geox-url'] = realPatchConfig.geoXUrl.toJson();
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
  final systemDns = 'system://';
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
  if (rawConfig['rules'] != null) {
    rules = List<String>.from(rawConfig['rules']);
  }
  rawConfig.remove('rules');
  if (addedRules.isNotEmpty) {
    final parsedNewRules = addedRules
        .map((item) => ParsedRule.parseString(item.value))
        .toList();
    final hasMatchPlaceholder = parsedNewRules.any(
      (item) => item.ruleTarget?.toUpperCase() == 'MATCH',
    );
    String? replacementTarget;

    if (hasMatchPlaceholder) {
      for (int i = rules.length - 1; i >= 0; i--) {
        final parsed = ParsedRule.parseString(rules[i]);
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
      for (int i = 0; i < parsedNewRules.length; i++) {
        final parsed = parsedNewRules[i];
        if (parsed.ruleTarget?.toUpperCase() == 'MATCH') {
          finalAddedRules.add(
            parsed.copyWith(ruleTarget: replacementTarget).value,
          );
        } else {
          finalAddedRules.add(addedRules[i].value);
        }
      }
    } else {
      finalAddedRules = addedRules.map((e) => e.value).toList();
    }
    rules = [...finalAddedRules, ...rules];
  }
  rawConfig['rules'] = rules;
  return Map<String, dynamic>.from(rawConfig);
}

Future<List<String>> shakingProfileTask(
  VM2<List<String>, List<String>> data,
) async {
  return await compute<
    VM3<List<String>, List<String>, RootIsolateToken>,
    List<String>
  >(
    _shakingProfileTask,
    VM3(a: data.a, b: data.b, c: RootIsolateToken.instance!),
  );
}

Future<List<String>> _shakingProfileTask(
  VM3<List<String>, List<String>, RootIsolateToken> data,
) async {
  final profileIds = data.a;
  final scriptIds = data.b;
  final token = data.c;
  BackgroundIsolateBinaryMessenger.ensureInitialized(token);
  final profilesDir = Directory(await appPath.profilesPath);
  final scriptsDir = Directory(await appPath.scriptsPath);
  final providersDir = Directory(await appPath.getProvidersRootPath());
  final List<String> targets = [];
  void scanDirectory(
    Directory dir,
    List<String> baseNames, {
    bool skipProvidersFolder = false,
  }) {
    if (!dir.existsSync()) return;
    final entities = dir.listSync(recursive: false, followLinks: false);

    for (final entity in entities) {
      if (entity is File) {
        final id = basenameWithoutExtension(entity.path);
        if (!baseNames.contains(id)) {
          targets.add(entity.path);
        }
      } else if (skipProvidersFolder && entity is Directory) {
        if (basename(entity.path) == 'providers') {
          continue;
        }
      }
    }
  }

  scanDirectory(profilesDir, profileIds, skipProvidersFolder: true);
  scanDirectory(providersDir, profileIds);
  scanDirectory(scriptsDir, scriptIds);
  return targets;
}

Future<String> encodeLogsTask(List<Log> data) async {
  return await compute<List<Log>, String>(_encodeLogsTask, data);
}

Future<String> _encodeLogsTask(List<Log> data) async {
  final logsRaw = data.map((item) => item.toString());
  final logsRawString = logsRaw.join('\n');
  return logsRawString;
}

Future<MigrationData> oldToNowTask(Map<String, Object?> data) async {
  return await compute<Map<String, Object?>, MigrationData>(
    _oldToNowTask,
    data,
  );
}

Future<MigrationData> _oldToNowTask(Map<String, Object?> configMap) async {
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
  configMap['appSettingProps'] = configMap['appSetting'];
  configMap['proxiesStyleProps'] = configMap['proxiesStyle'];
  configMap['proxiesStyleProps'] = configMap['proxiesStyle'];
  List<Map<String, Object?>> rawScripts =
      configMap['scripts'] as List<Map<String, Object?>>? ?? [];
  if (rawScripts.isEmpty) {
    final scriptPropsJson = configMap['scriptProps'] as Map<String, Object?>?;
    if (scriptPropsJson != null) {
      rawScripts =
          scriptPropsJson['scripts'] as List<Map<String, Object?>>? ?? [];
    }
  }
  List<Map<String, Object?>> rawProfiles =
      configMap['profiles'] as List<Map<String, Object?>>? ?? [];
  final profiles = rawProfiles.map((item) => Profile.fromJson(item)).toList();
  List<Map<String, Object?>> rawRules =
      configMap['rules'] as List<Map<String, Object?>>? ?? [];
  final rules = rawRules.map((item) => Rule.fromJson(item)).toList();
  final scripts = rawScripts.map((item) => OldScript.fromJson(item)).toList();
  return MigrationData(
    configMap: configMap,
    profiles: profiles,
    rules: rules,
    oldScripts: scripts,
  );
}

Future<String> backupTask(Map<String, dynamic> configMap) async {
  return await compute<VM2<Map<String, dynamic>, RootIsolateToken>, String>(
    _backupTask,
    VM2(a: configMap, b: RootIsolateToken.instance!),
  );
}

Future<String> _backupTask<T>(
  VM2<Map<String, dynamic>, RootIsolateToken> args,
) async {
  final configMap = args.a;
  final token = args.b;
  BackgroundIsolateBinaryMessenger.ensureInitialized(token);
  final isar = await globalState.openIsar();
  final configStr = json.encode(configMap);
  final profilesDir = Directory(await appPath.profilesPath);
  final scriptsDir = Directory(await appPath.scriptsPath);
  final tempZipFilePath = await appPath.tempFilePath;
  final tempDBFile = File(await appPath.tempFilePath);
  final tempConfigFile = File(await appPath.tempFilePath);
  await isar.copyToFile(tempDBFile.path);
  final encoder = ZipFileEncoder();
  encoder.create(tempZipFilePath);
  await tempConfigFile.writeAsString(configStr);
  await encoder.addFile(tempDBFile, backupIsarName);
  await encoder.addFile(tempConfigFile, configJsonName);
  if (await profilesDir.exists()) {
    await encoder.addDirectory(
      profilesDir,
      filter: (file, _) {
        if (file.parent.path != profilesDir.path || file is Directory) {
          return ZipFileOperation.skip;
        }
        return ZipFileOperation.include;
      },
    );
  }
  if (await scriptsDir.exists()) {
    await encoder.addDirectory(
      scriptsDir,
      filter: (file, _) {
        if (file.parent.path != scriptsDir.path || file is Directory) {
          return ZipFileOperation.skip;
        }
        return ZipFileOperation.include;
      },
    );
  }
  encoder.close();
  await tempConfigFile.safeDelete();
  await tempDBFile.safeDelete();
  return tempZipFilePath;
}

Future<MigrationData> restoreTask() async {
  return await compute<RootIsolateToken, MigrationData>(
    _restoreTask,
    RootIsolateToken.instance!,
  );
}

Future<MigrationData> _restoreTask(RootIsolateToken token) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(token);
  final backupFilePath = await appPath.backupFilePath;
  final restoreDirPath = await appPath.restoreDirPath;
  final zipDecoder = ZipDecoder();
  final input = InputFileStream(backupFilePath);
  final archive = zipDecoder.decodeStream(input);
  final dir = Directory(restoreDirPath);
  await dir.create(recursive: true);
  for (final file in archive.files) {
    final outPath = join(restoreDirPath, posix.normalize(file.name));
    final outputStream = OutputFileStream(outPath);
    file.writeContent(outputStream);
    await outputStream.close();
  }
  await input.close();
  final restoreConfigFile = File(join(restoreDirPath, configJsonName));
  if (!await restoreConfigFile.exists()) {
    throw '无效备份文件';
  }
  final restoreConfigMap = json.decode(await restoreConfigFile.readAsString());
  final version = restoreConfigMap['version'] ?? 0;
  MigrationData migrationData = MigrationData(configMap: restoreConfigMap);
  if (version == 0 && restoreConfigMap != null) {
    migrationData = await _oldToNowTask(restoreConfigMap);
    return migrationData;
  }
  final backupIsarFile = File(join(restoreDirPath, backupIsarName));
  if (!await backupIsarFile.exists()) {
    return migrationData;
  }
  final isar = await globalState.openIsar(
    directory: restoreDirPath,
    name: 'backup',
  );
  final profileCollections = await isar.profileCollections.where().findAll();
  final ruleCollections = await isar.ruleCollections.where().findAll();
  final scriptCollections = await isar.scriptCollections.where().findAll();
  migrationData = migrationData.copyWith(
    profiles: profileCollections.map((item) => item.toProfile()).toList(),
    rules: ruleCollections.map((item) => item.toRule()).toList(),
    scripts: scriptCollections.map((item) => item.toScript()).toList(),
  );
  await isar.close();
  return migrationData;

  // if (file.name == 'config.json') {
  //   configArchiveFile = file;
  // } else if (file.name == 'backup.db') {
  //   isarArchiveFile = file;
  // } else {
  //   others.add(file);
  // }
  // if (configArchiveFile == null) {
  //   return;
  // }
  // final configMap = json.decode(utf8.decode(configArchiveFile.content));
  // final version = configMap['version'] ?? 0;
  // if (version == 0 && version != migration.currentVersion) {
  //   final data = await _oldToNowTask(configMap);
  // }
  // await input.close();
}
