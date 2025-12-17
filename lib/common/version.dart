import 'dart:io';
import 'dart:isolate';

import 'package:fl_clash/common/common.dart';
import 'package:fl_clash/models/config.dart';

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
        final accessControlMap = configMap['accessControl'];
        final isAccessControl = configMap['isAccessControl'];
        if (accessControlMap != null) {
          (accessControlMap as Map)['enable'] = isAccessControl;
          if (configMap['vpnProps'] != null) {
            (configMap['vpnProps'] as Map)['accessControl'] = accessControlMap;
          }
        }
        final scriptPropsJson =
            configMap['scriptProps'] as Map<String, Object?>?;
        List<Map<String, Object?>> rawScripts = [];
        if (scriptPropsJson != null) {
          rawScripts =
              scriptPropsJson['scripts'] as List<Map<String, Object?>>? ?? [];
        }
        for (final script in rawScripts) {
          final scriptId = script['id'] as String?;
          final content = script['content'] as String?;
          if (scriptId == null || content == null) {
            continue;
          }
          final path = await appPath.getScriptPath(scriptId);
          final file = await File(path).create(recursive: true);
          await file.writeAsString(content);
        }
        return configMap;
      });
    } catch (_) {}
    config = Config.fromJson(nextConfigMap);
    await preferences.setVersion(1);
  }
}

final version = Version();
