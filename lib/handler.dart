import 'dart:convert';
import 'dart:ffi' as ffi;

import 'package:fl_clash/enum/enum.dart';
import 'package:flutter_js/flutter_js.dart';

import 'common/path.dart';
import 'common/task.dart';
import 'core/controller.dart';
import 'models/models.dart';

class AppHandler {
  static AppHandler? _instance;

  AppHandler._internal();

  factory AppHandler() {
    _instance ??= AppHandler._internal();
    return _instance!;
  }

  SharedState getSharedState({
    required String currentProfileName,
    required bool onlyStatisticsProxy,
    required String stopText,
    required bool crashlytics,
    required String startTip,
    required String stopTip,
    required SetupParams setupParams,
    required VpnOptions vpnOptions,
  }) {
    return SharedState(
      currentProfileName: currentProfileName,
      onlyStatisticsProxy: onlyStatisticsProxy,
      stopText: stopText,
      crashlytics: crashlytics,
      stopTip: stopTip,
      startTip: startTip,
      setupParams: setupParams,
      vpnOptions: vpnOptions,
    );
  }

  SetupParams getSetupParams({
    required Map<String, String> selectedMap,
    required String testUrl,
  }) {
    return SetupParams(selectedMap: selectedMap, testUrl: testUrl);
  }

  VpnOptions getVpnOptions({
    required bool enable,
    required String stack,
    required bool systemProxy,
    required int port,
    required bool ipv6,
    required bool dnsHijacking,
    required AccessControlProps accessControlProps,
    required bool allowBypass,
    required List<String> bypassDomain,
  }) {
    return VpnOptions(
      stack: stack,
      enable: enable,
      systemProxy: systemProxy,
      port: port,
      ipv6: ipv6,
      dnsHijacking: dnsHijacking,
      accessControlProps: accessControlProps,
      allowBypass: allowBypass,
      bypassDomain: bypassDomain,
    );
  }

  SetupState getSetupState({
    required int? profileId,
    required DateTime? profileLastUpdateDate,
    required Overwrite? overwrite,
    required List<Rule> rules,
    required List<Script> scripts,
    required bool overrideDns,
    required Dns dns,
  }) {
    final scriptId = overwrite?.scriptOverwrite.scriptId;
    final scriptLastUpdateTime = scripts.get(scriptId)?.lastUpdateTime;
    final overwriteType = overwrite?.type ?? OverwriteType.standard;
    final standardOverwrite =
        overwrite?.standardOverwrite ?? StandardOverwrite();
    final globalAddedRules = rules.where(
      (item) => !standardOverwrite.disabledRuleIds.contains(item.id),
    );
    final addedRules = [...standardOverwrite.addedRules, ...globalAddedRules];
    return SetupState(
      profileId: profileId,
      profileLastUpdateDate: profileLastUpdateDate?.millisecondsSinceEpoch,
      overwriteType: overwriteType,
      addedRules: addedRules,
      scriptId: scriptId,
      scriptLastUpdateTime: scriptLastUpdateTime,
      overrideDns: overrideDns,
      dns: dns,
    );
  }

  Future<Map<String, dynamic>> getProfileConfig(int profileId) async {
    final configMap = await coreController.getConfig(profileId);
    configMap['rules'] = configMap['rule'];
    configMap.remove('rule');
    return configMap;
  }

  Future<Map<String, dynamic>> makeRealProfile({
    required List<Script> scripts,
    required SetupState setupState,
    required ClashConfig patchConfig,
    required String defaultUA,
    required bool appendSystemDns,
    required RouteMode routeMode,
    required bool overrideDns,
  }) async {
    final profileId = setupState.profileId;
    if (profileId == null) {
      return {};
    }
    final configMap = await getProfileConfig(profileId);
    String? scriptContent;
    final List<Rule> addedRules = [];
    if (setupState.overwriteType == OverwriteType.script) {
      final scriptId = setupState.scriptId;
      scriptContent = await scripts.get(scriptId)?.content;
    } else {
      addedRules.addAll(setupState.addedRules);
    }
    final realPatchConfig = patchConfig.copyWith(
      tun: patchConfig.tun.getRealTun(routeMode),
    );
    Map<String, dynamic> rawConfig = configMap;
    if (scriptContent?.isNotEmpty == true) {
      rawConfig = await handleEvaluate(scriptContent!, rawConfig);
    }
    final directory = await appPath.profilesPath;
    final res = makeRealProfileTask(
      MakeRealProfileState(
        profilesPath: directory,
        profileId: profileId,
        rawConfig: rawConfig,
        realPatchConfig: realPatchConfig,
        overrideDns: overrideDns,
        appendSystemDns: appendSystemDns,
        addedRules: addedRules,
        defaultUA: defaultUA,
      ),
    );
    return res;
  }

  Future<Map<String, dynamic>> handleEvaluate(
    String scriptContent,
    Map<String, dynamic> config,
  ) async {
    if (config['proxy-providers'] == null) {
      config['proxy-providers'] = {};
    }
    final configJs = json.encode(config);
    final runtime = getJavascriptRuntime();
    final res = await runtime.evaluateAsync('''
      $scriptContent
      main($configJs)
    ''');
    if (res.isError) {
      throw res.stringResult;
    }
    final value = switch (res.rawResult is ffi.Pointer) {
      true => runtime.convertValue<Map<String, dynamic>>(res),
      false => Map<String, dynamic>.from(res.rawResult),
    };
    return value ?? config;
  }
}

final appHandler = AppHandler();
