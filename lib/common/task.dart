import 'dart:convert';
import 'dart:io';

import 'package:archive/archive_io.dart';
import 'package:fl_clash/common/path.dart';
import 'package:fl_clash/common/yaml.dart';
import 'package:fl_clash/enum/enum.dart';
import 'package:fl_clash/models/models.dart';
import 'package:flutter/foundation.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart';

import 'compute.dart';
import 'string.dart';

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
  final rawConfig = data.rawConfig;
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
  VM3<List<String>, String, String> data,
) async {
  return await compute<VM3<List<String>, String, String>, List<String>>(
    _shakingProfileTask,
    data,
  );
}

List<String> _shakingProfileTask(VM3<List<String>, String, String> data) {
  final profileIds = data.a;
  final profilesRootPath = data.b;
  final providersRootPath = data.c;
  final profilesDir = Directory(profilesRootPath);
  final providersDir = Directory(providersRootPath);
  final List<String> targets = [];
  void scanDirectory(Directory dir, {bool skipProvidersFolder = false}) {
    if (!dir.existsSync()) return;
    final entities = dir.listSync(recursive: false, followLinks: false);

    for (final entity in entities) {
      if (entity is File) {
        final id = basenameWithoutExtension(entity.path);
        if (!profileIds.contains(id)) {
          targets.add(entity.path);
        }
      } else if (skipProvidersFolder && entity is Directory) {
        if (basename(entity.path) == 'providers') {
          continue;
        }
      }
    }
  }

  scanDirectory(profilesDir, skipProvidersFolder: true);
  scanDirectory(providersDir);
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

Future<Map<String, Object?>> oldToV1Task(
  VM2<Map<String, Object?>, Isar> data,
) async {
  return await compute<VM2<Map<String, Object?>, Isar>, Map<String, Object?>>(
    _oldToV1Task,
    data,
  );
}

Future<Map<String, Object?>> _oldToV1Task(
  VM2<Map<String, Object?>, Isar> data,
) async {
  final configMap = data.a;
  final isar = data.b;
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
  final profileCollections = rawProfiles
      .map((item) => ProfileCollection.fromProfile(Profile.fromJson(item)))
      .toList();
  List<Map<String, Object?>> rawRules =
      configMap['rules'] as List<Map<String, Object?>>? ?? [];
  final List<RuleCollection> ruleCollections = [];
  for (final rule in rawRules) {
    final id = rule['id'] as String?;
    final value = rule['value'] as String?;
    if (id == null || value == null) {
      continue;
    }
    ruleCollections.add(RuleCollection.formRule(Rule(id: id, value: value)));
  }
  final List<ScriptCollection> scriptCollections = [];
  for (final script in rawScripts) {
    final id = script['id'] as String?;
    final label = script['label'] as String?;
    final content = script['content'] as String?;
    if (id == null || content == null) {
      continue;
    }
    final path = await appPath.getScriptPath(id);
    final file = await File(path).create(recursive: true);
    await file.writeAsString(content);
    scriptCollections.add(
      ScriptCollection.formScript(
        Script(id: id, label: label ?? id, lastUpdateTime: DateTime.now()),
      ),
    );
  }
  await isar.writeTxn(() async {
    await isar.profileCollections.clear();
    await isar.ruleCollections.clear();
    await isar.scriptCollections.clear();
    await isar.scriptCollections.putAll(scriptCollections);
    await isar.ruleCollections.putAll(ruleCollections);
    await isar.profileCollections.putAll(profileCollections);
  });
  return configMap;
}

Future<String> backupTask(VM2<Config, Isar> data) async {
  return await compute<VM2<Config, Isar>, String>(_backupTask, data);
}

Future<String> _backupTask<T>(VM2<Config, Isar> data) async {
  final config = data.a;
  final isar = data.b;
  final configStr = json.encode(config);
  final profilesPath = await appPath.profilesPath;
  final tempZipFilePath = await appPath.tempFilePath;
  final tempDBFile = File(await appPath.tempFilePath);
  final tempConfigFile = File(await appPath.tempFilePath);
  await isar.copyToFile(tempDBFile.path);
  final encoder = ZipFileEncoder();
  encoder.create(tempZipFilePath);
  await tempConfigFile.writeAsString(configStr);
  await encoder.addFile(tempDBFile, 'isar.db');
  await encoder.addFile(tempConfigFile, 'config.json');
  await encoder.addDirectory(
    Directory(profilesPath),
    filter: (file, _) {
      if (file is Directory) {
        return ZipFileOperation.skip;
      }
      return ZipFileOperation.include;
    },
  );
  encoder.close();
  await tempConfigFile.delete();
  await tempDBFile.delete();
  return tempZipFilePath;
}
