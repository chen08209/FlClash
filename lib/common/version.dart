import 'dart:io';
import 'dart:isolate';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/clash_config.dart';
import 'package:fl_clash/models/common.dart';
import 'package:fl_clash/models/config.dart';
import 'package:fl_clash/models/isar.dart';
import 'package:fl_clash/models/profile.dart';
import 'package:isar_community/isar.dart';

class Version {
  static Version? _instance;

  Version._internal();

  factory Version() {
    _instance ??= Version._internal();
    return _instance!;
  }

  Future<void> migration(Config config) async {
    final version = await preferences.getVersion();
    if (version == 0) {
      await _oldToV1(config);
      return;
    }
  }

  Future<void> _oldToV1(Config config) async {
    final configMap = await preferences.getConfigMap();
    if (configMap == null) {
      return;
    }
    Map<String, Object?> nextConfigMap = {};
    try {
      nextConfigMap = await Isolate.run(() async {
        final isar = Isar.getInstance()!;
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
          final scriptPropsJson =
              configMap['scriptProps'] as Map<String, Object?>?;
          if (scriptPropsJson != null) {
            rawScripts =
                scriptPropsJson['scripts'] as List<Map<String, Object?>>? ?? [];
          }
        }
        List<Map<String, Object?>> rawProfiles =
            configMap['profiles'] as List<Map<String, Object?>>? ?? [];
        final profileCollections = rawProfiles
            .map(
              (item) => ProfileCollection.fromProfile(Profile.fromJson(item)),
            )
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
          ruleCollections.add(
            RuleCollection.formRule(Rule(id: id, value: value)),
          );
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
              Script(
                id: id,
                label: label ?? id,
                lastUpdateTime: DateTime.now(),
              ),
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
      });
    } catch (_) {}
    config = Config.fromJson(nextConfigMap);
    await preferences.setVersion(1);
  }
}

final version = Version();
