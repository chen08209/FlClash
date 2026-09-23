import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:fl_clash/common/common.dart';
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
  final overrideNtp = data.overrideNtp;
  final addedRules = data.addedRules;
  final appendSystemDns = data.appendSystemDns;
  final defaultUA = data.defaultUA;
  String getProvidersFilePathInner(String type, String key) {
    return join(
      profilesPath,
      providersDirectoryName,
      profileId.toString(),
      type,
      key.toMd5(),
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
      // Two providers may share a URL and differ only by header.
      final url = provider['url'];
      final hasUrl = url is String && url.isNotEmpty;
      final path = getProvidersFilePathInner(
        type,
        hasUrl ? '$name@$url' : '$section/$name',
      );
      if (hasUrl) {
        _migrateLegacyProviderFile(
          legacyPath: getProvidersFilePathInner(type, url),
          newPath: path,
        );
      }
      provider['path'] = path;
    }
  }

  rawConfig['external-controller'] = realPatchConfig.externalController.value;
  rawConfig['external-ui'] = '';
  switch (realPatchConfig.interfaceNameMode) {
    case InterfaceNameMode.clear:
      rawConfig['interface-name'] = '';
    case InterfaceNameMode.follow:
      break;
    case InterfaceNameMode.custom:
      rawConfig['interface-name'] = realPatchConfig.interfaceName;
  }
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
  // The app owns local inbound authentication; a profile-provided
  // skip-auth-prefixes could silently exempt loopback and defeat it.
  rawConfig['authentication'] = data.authentication;
  rawConfig['skip-auth-prefixes'] = [];
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
  void injectUnconfinedProviders(
    String section,
    Map<String, dynamic> injected,
  ) {
    if (injected.isEmpty) {
      return;
    }
    final providers = rawConfig[section];
    rawConfig[section] = {
      if (providers is Map) ...providers.cast<String, dynamic>(),
      ...injected,
    };
  }

  confineProviders('proxy-providers', proxiesProviderDirectoryName);
  confineProviders('rule-providers', rulesProviderDirectoryName);
  injectUnconfinedProviders('proxy-providers', data.injectedProxyProviders);
  injectUnconfinedProviders('rule-providers', data.injectedRuleProviders);
  rawConfig['profile']['store-selected'] = false;
  rawConfig['geox-url'] = realPatchConfig.geoXUrl.raw;
  rawConfig['global-ua'] = realPatchConfig.globalUa ?? defaultUA;
  if (rawConfig['hosts'] == null) {
    rawConfig['hosts'] = {};
  }
  for (final host in realPatchConfig.hosts.entries) {
    rawConfig['hosts'][host.key] = host.value.splitByMultipleSeparators;
  }
  var rawDns = rawConfig['dns'] is Map
      ? Map<String, dynamic>.from(rawConfig['dns'] as Map)
      : <String, dynamic>{};
  final isEnableDns = rawDns['enable'] == true;
  const systemDns = 'system://';
  if (!isEnableDns) {
    rawDns = mergeDnsOverride(
      rawDns,
      defaultDns.overrideJson(baselineDnsOverrideKeys),
    );
  }
  if (overrideDns || !isEnableDns) {
    rawDns = mergeDnsOverride(
      rawDns,
      realPatchConfig.dns.overrideJson(realPatchConfig.dnsOverrideKeys),
    );
  }
  rawConfig['dns'] = rawDns;
  if (overrideNtp) {
    final rawNtp = rawConfig['ntp'] is Map
        ? Map<String, dynamic>.from(rawConfig['ntp'] as Map)
        : <String, dynamic>{};
    rawConfig['ntp'] = {
      ...rawNtp,
      ...realPatchConfig.ntp.overrideJson(realPatchConfig.ntpOverrideKeys),
    };
  }
  if (appendSystemDns) {
    final List<String> nameserver = List<String>.from(
      rawConfig['dns']['nameserver'] ?? [],
    );
    if (!nameserver.contains(systemDns)) {
      rawConfig['dns']['nameserver'] = [...nameserver, systemDns];
    }
  }
  if (data.safeMode) {
    rawConfig['dns']['listen'] = '';
    rawConfig['external-controller-tls'] = '';
    rawConfig['external-controller-unix'] = '';
    rawConfig['external-controller-pipe'] = '';
    final rawNtp = rawConfig['ntp'];
    if (rawNtp is Map) {
      rawConfig['ntp'] = {
        ...Map<String, dynamic>.from(rawNtp),
        NtpOverrideKey.writeToSystem.path: false,
      };
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
      String? replacementTarget = data.matchTarget?.trim();
      if (replacementTarget?.isEmpty == true) {
        replacementTarget = null;
      }

      if (hasMatchPlaceholder && replacementTarget == null) {
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
  if (data.proxies.isNotEmpty) {
    rawConfig['proxies'] = data.proxies.map((item) => item.definition).toList();
  }
  if (data.proxyGroups.isNotEmpty) {
    rawConfig['proxy-groups'] = data.proxyGroups
        .map((item) => item.definition)
        .toList();
  }
  rawConfig['rules'] = rules;
  final yaml = await _encodeYaml(Map<String, dynamic>.from(rawConfig));
  return (yaml: yaml, md5: yaml.toMd5());
}

typedef ShakingStoreArgs = ({
  Iterable<int> profileIds,
  Iterable<int> scriptIds,
  Iterable<String> providerFileNames,
});

Future<List<String>> shakingProfileTask(ShakingStoreArgs data) async {
  return compute<
    ({ShakingStoreArgs args, RootIsolateToken token}),
    List<String>
  >(_shakingProfileTask, (args: data, token: RootIsolateToken.instance!));
}

Future<List<String>> _shakingProfileTask(
  ({ShakingStoreArgs args, RootIsolateToken token}) data,
) async {
  BackgroundIsolateBinaryMessenger.ensureInitialized(data.token);
  return shakeOrphanFiles(
    profileIds: data.args.profileIds,
    scriptIds: data.args.scriptIds,
    providerFileNames: data.args.providerFileNames,
    profilesDirPath: await appPath.profilesPath,
    providersDirPath: await appPath.getProvidersRootPath(),
    providerCacheDirPath: await appPath.providerCacheRootPath,
    scriptsDirPath: await appPath.scriptsDirPath,
  );
}

@visibleForTesting
List<String> shakeOrphanFiles({
  required Iterable<int> profileIds,
  required Iterable<int> scriptIds,
  required Iterable<String> providerFileNames,
  required String profilesDirPath,
  required String providersDirPath,
  required String providerCacheDirPath,
  required String scriptsDirPath,
}) {
  final List<String> targets = [];
  void scanDirectory(
    Directory dir,
    bool Function(String baseName) isLive, {
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
      if (!isLive(basenameWithoutExtension(entity.path))) {
        targets.add(entity.path);
      }
    }
  }

  bool Function(String) isLiveId(Iterable<int> ids) =>
      (baseName) => ids.contains(int.tryParse(baseName));

  scanDirectory(Directory(profilesDirPath), isLiveId(profileIds));
  scanDirectory(
    Directory(providersDirPath),
    isLiveId(profileIds),
    includeDirectories: true,
  );
  final cacheNames = providerFileNames.toSet();
  for (final kind in ProviderKind.values) {
    scanDirectory(
      Directory(join(providerCacheDirPath, providerCacheDirectoryName(kind))),
      cacheNames.contains,
    );
  }
  scanDirectory(Directory(scriptsDirPath), isLiveId(scriptIds));
  return targets;
}

// Best-effort: a legacy url shared by two providers, or any rename failure,
// just leaves the file to be re-downloaded under the new path.
void _migrateLegacyProviderFile({
  required String legacyPath,
  required String newPath,
}) {
  if (legacyPath == newPath || File(newPath).existsSync()) {
    return;
  }
  try {
    final legacyFile = File(legacyPath);
    if (legacyFile.existsSync()) {
      Directory(dirname(newPath)).createSync(recursive: true);
      legacyFile.renameSync(newPath);
    }
  } catch (_) {}
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
    final path = BackupEntries.resolve(targetPath, BackupEntries.script(newId));
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

    final sourceFile = File(
      BackupEntries.resolve(sourcePath, BackupEntries.profile(rawId)),
    );
    final targetFilePath = BackupEntries.resolve(
      targetPath,
      BackupEntries.profile(profileId),
    );
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
